Steam = Meteor.npmRequire "steam"
dota2 = Meteor.npmRequire "dota2"

class Bot
  constructor: (@loginInfo, @otherInfo)->
    @bot = new (Steam.SteamClient)
    @dota = new dota2.Dota2Client(@bot, true)
    #@csgo = new csgor.CSGOClient(@bot, true)
    @bindCallbacks()
    @callbacks = {}
    @csgoProfileCallbacks = {}
    @friendDataCallbacks = {}
    @mentionedBlocks = []
    @intervals = []
    @timeouts = []
    @dotaRunning = false
    @startedWithSocket = false
  start: ->
    @startedWithSocket = false
    @bot.logOn @loginInfo
  startWithSocket: (socket)->
    @startedWithSocket = true
    @bot.logOn @loginInfo,
      customSocket: socket
      socketConnected: true
  setSessionTimeout: (fcn, int)->
    id = Meteor.setTimeout =>
      @timeouts = _.without @timeouts, id
      fcn()
    , int
    @timeouts.push id
  clearSessionTimeouts: ->
    for timeout in @timeouts
      Meteor.clearTimeout timeout
    @timeouts.length = 0
  setSessionInterval: (fcn, int)->
    id = Meteor.setInterval =>
      @intervals = _.without @intervals, id
      fcn()
    , int
    @intervals.push id
  clearSessionIntervals: ->
    for interval in @intervals
      Meteor.clearInterval interval
    @intervals.length = 0
  stop: ->
    @clearSessionTimeouts()
    @clearSessionIntervals()
    @dota.exit()
    @bot.logOff()
  log: (msg)->
    console.log "[#{@loginInfo.accountName}] #{msg}"
  on: (name, cb)->
    if !@callbacks[name]?
      @callbacks[name] = [cb]
    else
      @callbacks[name].push cb
  fire: (name)->
    cbs = @callbacks[name]
    if !cbs?
      #@log "warn: callback #{name} not handled"
    else
      args = [].slice.call(arguments)
      args.shift()
      for cb in cbs
        cb.apply @, args
  processRelationship: (sid, status)->
    rel = Steam.EFriendRelationship
    switch status
      when rel.None
        @log "player #{sid} removed the bot"
        @fire "friendRemoved", sid
      when rel.RequestRecipient
        @log "incoming friend request from #{sid}"
        @fire "friendRequest", sid
      when rel.Friend
        #@log "currently we are a friend with #{sid}"
        @fire "friend", sid
      #when rel.RequestInitiator
        #@log "still waiting for a friend response from #{sid}"
      when rel.Blocked
        if sid not in @mentionedBlocks
          @log "we blocked / are blocked by #{sid}"
          @mentionedBlocks.push sid
  processRelationships: ->
    bot = @bot
    for sid, status of bot.friends
      @processRelationship sid, status
    @fire "initRelationships", bot.friends
  fetchSteamProfile: (sid, cb)->
    @friendDataCallbacks[sid] = cb
    @bot.requestFriendData [sid]
  fetchDotaProfile: (sid, cb)->
    accid = @dota.ToAccountID sid
    @dota.profileRequest accid, true, (err, resp)=>
      args = []
      if err?
        args.push err
      else
        args.push null
      if resp?
        args.push resp
      else
        args.push null
      cb.apply @, args
  fetchCsgoProfile: (sid, cb)->
    accid = @csgo.ToAccountID sid
    @csgoProfileCallbacks[accid] = cb
    @csgo.playerProfileRequest accid
  sendMessage: (sid, msg)->
    return @log("dropping message to #{sid} because not logged on") if !@bot.loggedOn
    @bot.sendMessage sid, msg
    @fire "messageSent", sid, msg
  bindCallbacks: ->
    bot = @bot
    dota = @dota
    bot.on 'debug', (msg)=>
      @log msg
    bot.on 'loggedOn', =>
      @log 'Logged in!'
      bot.setPersonaState Steam.EPersonaState.Online
      bot.setPersonaName  @otherInfo.nick
      @fire "steamReady"
      return
    bot.on 'loggedOff', =>
      @log "Logged off!"
      @fire "steamUnready"
      if @startedWithSocket
        @stop()
      else
        @clearSessionTimeouts()
        @clearSessionIntervals()
      return
    bot.on 'chatInvite', (chatRoomID, chatRoomName, patronID) =>
      @log 'Got an invite to ' + chatRoomName + ' from ' + bot.users[patronID].playerName
      bot.joinChat chatRoomID
      return
    sentInfoMsg = []
    bot.on 'message', (source, message, type, chatter) =>
      @fire "messageReceived", source, message, type, chatter
    bot.on 'chatStateChange', (stateChange, chatterActedOn, steamIdChat, chatterActedBy) =>
      if stateChange == Steam.EChatMemberStateChange.Kicked and chatterActedOn == bot.steamID
        bot.joinChat steamIdChat
      return
    bot.on 'user', (data)=>
      wids = _.keys @friendDataCallbacks
      if data.friendid in wids
        @friendDataCallbacks[data.friendid](data)
        delete @friendDataCallbacks[data.friendid]
      @fire "user", data
    bot.on 'announcement', (group, headline) =>
      @log 'Group with SteamID ' + group + ' has posted ' + headline
      return
    bot.on 'relationships', =>
      @log "Received relationships list."
      @processRelationships()
    bot.on 'friend', (sid, status)=>
      @processRelationship sid, status
    dota.on 'ready', =>
      @log 'Connected to DOTA 2.'
      @dotaRunning = true
      @fire "dotaReady"
    dota.on 'unready', =>
      @dotaRunning = false
      @log "Disconnected from DOTA"
      @fire "dotaUnready"
    dota.on 'hellotimeout', =>
      @dotaRunning = false
      @dota.exit()
      @fire "dotaHelloTimeout"
    dota.on 'servers', (servers)->
      @fire "servers", servers
    bot.on 'error', (err)=>
      @log "!! steam error: #{JSON.stringify err}"
      @fire "error", err
@Bot = Bot
