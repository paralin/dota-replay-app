WebSocket = Meteor.npmRequire("ws").Server
jwt = Meteor.npmRequire("jsonwebtoken")

secret = "TDQFAL7KEDCTo0"

ws = new WebSocket({port: 10304})

clii = 0
clients = {}

@generateToken = (uid)->
  return jwt.sign({user: uid}, secret, {expiresInMinutes: 10080})

Meteor.methods
  "getDesktopToken": ->
    if !@userId?
      throw new Meteor.Error "notloggedin", "You must be signed in."
    return generateToken(@userId)

class Client
  constructor: (@ws, @ix)->
    console.log "new client connected"
    @state = 0
    @setupBinds()
  setupBinds: ->
    @ws.on "message", Meteor.bindEnvironment (msg)=>
      @processMessage msg
  sendMsg: (m)->
    console.log "sending #{JSON.stringify m}"
    @ws.send JSON.stringify m
  getUser: ->
    Meteor.users.findOne {_id: @uid}
  setupObserve: ->
    return false if !OrbitPermissions.userCan("review-submissions", "dr", @uid)
    @watchhand = Submissions.find({reviewed: false, reviewer: @uid}).observe
      added: (doc)=>
        @sendMsg
          m: 2
          replay: doc
      changed: (doc)=>
        @sendMsg
          m: 2
          replay: doc
      removed: (doc)=>
        @sendMsg
          m: 3
          id: doc._id
    return true
  processMessage: (msg)->
    console.log "Received message: "+msg
    jmsg = JSON.parse msg
    console.log jmsg.m
    return if !jmsg.m?
    if jmsg.m is 0
      return if !jmsg.token?
      console.log "Checking handshake..."
      tokend = null
      try
        tokend = jwt.verify jmsg.token, secret
      catch
        console.log "Token is invalid"
        @sendMsg {m:0,success:false}
        return
      # tokend should have a valid user id
      console.log "Token is valid for user ID #{tokend.user}"
      @uid = tokend.user
      user = @getUser @uid
      if !user?
        console.log "User does not exist!"
        @sendMsg {m: 0, success: false}
        return
      @state = 1
      console.log "Authenticated #{user.profile.name} (#{@uid}) succesfully."
      @sendMsg {m: 0, success: true}
      @sendMsg {m: 4, user: {name: user.profile.name, roles: user.orbit_roles, steam: user.services.steam}}
      allSubs = Submissions.find()
      @sendMsg {m: 5, submissions: allSubs.count(), yoursubmissions: Submissions.find({reviewer: user._id}).count()}
      if !@setupObserve()
        @sendMsg {m: 1}
    else if @state is 0
      return
    else
      #Parse some other message

ws.on 'connection', Meteor.bindEnvironment (ws)->
  clii++
  tclii = clii
  clients[clii] = new Client(ws, tclii)
  ws.on "close", Meteor.bindEnvironment ->
    client = clients[tclii]
    if client.uid?
      console.log "User #{client.uid} disconnected."
    if client.watchhand
      client.watchhand.stop()
    delete clients[tclii]
