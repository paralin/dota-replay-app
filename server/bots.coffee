util =  Meteor.npmRequire "util"
fs =    Meteor.npmRequire "fs"
http =  Meteor.npmRequire "http"

API_URL = process.env.API_URL
unless API_URL?
  console.log "API_URL must be set in environment for replay fetching"
  return

getExpiredTime = ->
  # This is when reborn actually was enabled
  #rebornEnabled = new Date("2015-09-09T19:00:00-05:00")
  # This is after the "new bot system" was done
  rebornEnabled = new Date("2015-10-08T00:00:00+00:00")
  lastAcceptable = new Date()
  lastAcceptable.setMinutes lastAcceptable.getMinutes()-20160
  if lastAcceptable.getTime() < rebornEnabled.getTime()
    return rebornEnabled
  lastAcceptable

jobQueue = JobCollection("downloadJobQueue")
jobQueue.processJobs "downloadReplay", {concurrency: 5, payload: 1, prefetch: 1, workTimeout: 30000}, (job, cb)->
  data = Results.findOne {_id: "#{job.data.matchid}"}
  log = (msg)->
    console.log "[#{data._id}] #{msg}"
    job.log msg

  unless data?
    msg = "unable to find result for match id #{job.data.matchid}!"
    console.log msg
    Submissions.update {_id: job.data._id}, {$set: {status: 5}}
    job.fail msg, {fatal: true}
    return cb()

  match = data
  url = util.format("http://replay%s.valve.net/570/%s_%s.dem.bz2", match.cluster, match.match_id, match.replay_salt)
  log "streaming replay from #{url} to aws"
  http.get(url, Meteor.bindEnvironment (res)->
    headers =
      'Content-Length': res.headers['content-length']
      'Content-Type': res.headers['content-type']
    filename = "#{match.match_id}.dem.bz2"
    knoxClient.putStream res, filename, headers, Meteor.bindEnvironment (err, ures)->
      if err?
        log "[#{match.match_id}] error uploading, #{err}"
        Submissions.update {_id: job.data._id}, {$set: {status: 5}}
        job.fail "error uploading, #{err}"
      else
        log "[#{match.match_id}] upload complete, #{filename}"
        mid = parseInt(match.match_id)
        Submissions.update {_id: job.data._id}, {$set: {status: 2}}
        job.done mid
      cb()
  ).on 'error', Meteor.bindEnvironment (err)->
    msg = "[#{match.match_id}] error downloading replay, #{err.message}"
    console.log msg
    job.fail msg
    Submissions.update {_id: job.data._id}, {$set: {status: 5}}
    cb()

jobQueue.processJobs "getMatchDetails", {concurrency: 2, payload: 1, prefetch: 2, workTimeout: 30000}, (job, cb)->
  data = sub = job.data
  log = (msg)->
    console.log "[#{sub.matchid}] #{msg}"
    job.log msg

  Submissions.update {_id: sub._id}, {$set: {status: 1}}
  sapikey = process.env.STEAM_API_KEY

  resp = Results.findOne {_id: "#{sub.matchid}"}
  if resp?
    log "result object already fetched!"
    job.done()
    return cb()

  if sapikey?
    log "[#{sub.matchid}] checking replay web API to see if this replay can be skipped"
    aresp = {}
    try
      aresp = HTTP.call "GET", "https://api.steampowered.com/IDOTA2Match_570/GetMatchDetails/V001/?key=#{sapikey}&match_id=#{sub.matchid}"
      if aresp.statusCode is 200 and aresp.data? and aresp.data.result? and aresp.data.result.start_time?
        matchDate = new Date(aresp.data.result.start_time*1000)
        lastAcceptable = getExpiredTime()
        if matchDate.getTime() < lastAcceptable.getTime()
          msg = "#{matchDate} is older than 2 weeks or pre-reborn, skipping replay"
          log msg
          Submissions.update {_id: sub._id}, {$set: {status: 5, fetch_error: -5}}
          job.fail msg, {fatal: true}
          return cb()
        else
          log "is not more than 1.5 weeks old, continuing"
      else
        log "response from web api #{aresp.statusCode}, continuing with checks..."
    catch herr
      aresp = herr.response
      log "Unable to check DOTA 2 api, #{herr}"

  # put http calls here
  # set match.match_id to the match id
  try
    resp = HTTP.call "GET", API_URL, {params: {match_id: sub.matchid}}
    data = resp.data
    if data.result is 1 and data.match?
      match = data.match
      match.match_id = sub.matchid
      match._id = "#{match.match_id}"
      Results.remove {_id: match._id}
      Results.insert match
      log "finished fetching match details"
      job.done()
    else if data.match? and data.vote?
      msg = "result was #{data.result}, failing this replay"
      Submissions.update {_id: sub._id}, {$set: {status: 5, fetch_error: data.result}}
      log msg
      job.fail JSON.stringify(data), {fatal: true}
    else
      msg = "result was #{JSON.stringify data}, failing non-fatally"
      log msg
      job.fail msg
  catch e
    msg = "Unable to query the API for match details, #{e}"
    log msg
    job.fail msg

  return cb()

Meteor.startup ->
  lastAcceptable = getExpiredTime()
  Submissions.find({$or: [{legacyUsed: false}, {legacyUsed: {$exists: false}}], status: 0}, {sort: {createdAt: -1}}).observe
    added: (doc)->
      return if jobQueue.findOne({"data._id": doc._id})?
      job = new Job(jobQueue, "getMatchDetails", doc)
      job.priority('normal')
        .retry
          retries: 3
          wait: 5*60*1000
        .save()

      down = new Job(jobQueue, "downloadReplay", doc)
      down.priority("normal")
        .retry
          retries: 3
          wait: 5*60*1000
        .depends [job]
        .save()

  Submissions.update {status: 0, createdAt: {$lt: lastAcceptable}}, {$set: {status: 5, fetch_error: -5}}, {multi: true}, (err, aff)->
    console.log "cleared #{aff} known expired replays"
  jobQueue.startJobServer()
