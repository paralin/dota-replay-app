Workers = []
workerCount = process.env.WORKER_COUNT || 4
util =  Meteor.npmRequire "util"
fs =    Meteor.npmRequire "fs"
async = Meteor.npmRequire "async"
http =  Meteor.npmRequire "http"

fetchingIds = []

cleanupBotCooldowns = (bot)->
  res = _.clone(bot.FetchTimes || [])
  now = new Date().getTime()
  for cd in bot.FetchTimes
    if !cd.time? || cd.time.getTime() <= now
      res = _.without res, cd
  bot.FetchTimes = res

assignBotToWorker = (worker)->
  return if worker.bot?
  bots = Bots.find({$or: [{Invalid: false}, {Invalid: {$exists: false}}]}).fetch()

  minCount = 9999
  nbot = null
  for bot in bots
    continue if bot.DisableUntil? and bot.DisableUntil.getTime() > (new Date()).getTime()
    bot.FetchTimes = [] if !bot.FetchTimes?
    cleanupBotCooldowns bot
    continue if _.some Workers, (work)->
      work.bot? and work.bot._id? and work.bot._id is bot._id
    if bot.FetchTimes.length < 90 && bot.FetchTimes.length < minCount
      nbot = bot
      minCount = bot.FetchTimes.length
  if nbot?
    console.log "assigning bot #{nbot.Username}, fetch count #{bot.FetchTimes.length} to worker #{worker._id}"
    worker.bot = nbot
  else
    console.log "can't find a bot for #{worker._id}"

assignAndLaunch = (work)->
  if !work.bot?
    assignBotToWorker work
  launchBot work

downloadQueue = async.queue(Meteor.bindEnvironment((match, done)->
  url = util.format("http://replay%s.valve.net/570/%s_%s.dem.bz2", match.cluster, match._id, match.replaySalt)
  console.log "[#{match._id}] streaming replay from #{url} to aws"
  http.get(url, Meteor.bindEnvironment (res)->
    headers =
      'Content-Length': res.headers['content-length']
      'Content-Type': res.headers['content-type']
    filename = "#{match._id}.dem.bz2"
    knoxClient.putStream res, filename, headers, Meteor.bindEnvironment (err, ures)->
      if err?
        console.log "[#{match._id}] error uploading, #{err}"
      else
        console.log "[#{match._id}] upload complete, #{filename}"
        Submissions.update {matchid: parseInt(match._id)}, {$set: {status: 2}}
      done()
  ).on 'error', (err)->
    console.log "[#{match._id}] error downloading replay, #{err.message}"
    done()
), 4)

launchBot = (work)->
  return if !work.bot?
  bot = work.client = new Bot({accountName: work.bot.Username, password: work.bot.Password}, {nick: work.bot.PersonaName})
  bot.on "dotaHelloTimeout", Meteor.bindEnvironment ->
    bot.log "dota ClientHello timeout, disabling this bot for 24 hours"
    bot.stop()
    work.bot = null
    assignAndLaunch work
  bot.on "error", Meteor.bindEnvironment (err)->
    # TODO: handle log on errors
    if err.cause is "logonFail"
      bot.log "login failure, marking this bot as invalid"
      Bots.update {_id: work.bot._id}, {$set: {Invalid: true, InvalidReason: "Login failure, #{err.eresult}"}}
    else
      bot.log "unknown steam error, restarting bot"
    bot.stop()
    work.bot = null
    assignAndLaunch work
  bot.on "steamReady", Meteor.bindEnvironment ->
    bot.dota.launch()
  bot.on "dotaReady", Meteor.bindEnvironment ->
    fetchNext = ->
      if work.bot.FetchTimes.length >= 91
        bot.log "[#{sub.matchid}] this bot has fetched #{work.bot.FetchTimes.length} matches, rotating it out"
        bot.stop()
        work.bot = null
        assignAndLaunch work
        return
      if downloadQueue.length() >= 30
        console.log "more than 30 downloads waiting, postponing dota requests"
        bot.setSessionTimeout ->
          fetchNext()
        , 30000
        return
      sub = Submissions.findOne {matchid: {$nin: fetchingIds}, $or: [{legacyUsed: false}, {legacyUsed: {$exists: false}}], status: 0}, {sort: {createdAt: -1}}
      if !sub?
        #bot.log "no submissions available, will re-check in 30 seconds"
        bot.setSessionTimeout ->
          fetchNext()
        , 30000
      else
        fetchingIds.push sub.matchid
        sub.status = 1
        Submissions.update {_id: sub._id}, {$set: {status: 1}}
        bot.log "[#{sub.matchid}] requesting match data from DOTA"
        work.bot.FetchTimes = [] if !work.bot.FetchTimes?
        work.bot.FetchTimes.push (new Date()).getTime()
        Bots.update {_id: work.bot._id}, {$set: {FetchTimes: work.bot.FetchTimes}}
        eres = Results.findOne {_id: "#{sub.matchid}"}
        if eres?
          bot.log "[#{sub.matchid}] already fetched, grabbing it again"
        hasTimedOut = false
        timeout = Meteor.setTimeout ->
          hasTimedOut = true
          bot.log "[#{sub.matchid}] request timed out, disabling bot"
          nxt = new Date()
          nxt.setMinutes nxt.getMinutes()+1440
          Bots.update {_id: work.bot._id}, {$set: {DisableUntil: nxt}}
          bot.stop()
          work.bot = null
          assignAndLaunch work
        , 15000
        bot.dota.matchDetailsRequest sub.matchid, Meteor.bindEnvironment (err, resp)->
          return if hasTimedOut
          Meteor.clearTimeout timeout
          if err? || !resp?
            bot.log "error fetching #{sub.matchid}, #{JSON.stringify err}" if err?
            bot.log "no response for #{sub.matchid}!" if !resp?
            err = err || 0
            Submissions.update {_id: sub._id}, {$set: {status: 5, fetch_error: parseInt(err)}}
          else
            resp = resp.match
            resp._id = "#{sub.matchid}"
            Results.upsert {_id: resp._id}, resp
            bot.log "[#{sub.matchid}] received match data"
            if resp.replayState isnt "REPLAY_AVAILABLE"
              bot.log "[#{sub.matchid}] replay not available, #{resp.replayState}"
              Submissions.update {_id: sub._id}, {$set: {status: 5, fetch_error: -1, fetch_error_replay_state: resp.replayState}}
            else
              downloadQueue.push resp
          bot.setSessionTimeout ->
            fetchNext()
          , 3000
    fetchNext()

  bot.start()

Meteor.startup ->
  Submissions.update {status: 1}, {$set: {status: 0}}, {multi: true}
  console.log "starting #{workerCount} bot workers"

  i = workerCount
  x = 1
  while i > 0
    work = {_id: "bot#{x}"}
    assignBotToWorker work
    Workers.push work
    if work.bot?
      launchBot work
    i--
    x++

