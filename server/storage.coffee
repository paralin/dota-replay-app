gcloudconfig =
  projectId: process.env.GCE_PROJECT_ID || 'paralin-2'
  keyFilename: process.env.GCE_KEY_PATH || process.cwd()+'/assets/google-key.json'
config =
  bucket: process.env.GCE_BUCKET || "dota-replay"

if process.env.GCE_PROJECT_ID? or process.env.GCE_KEY_PATH?
  console.log "Using environment variables for gce access..."
else
  if process.env.NODE_ENV is "production"
    console.log "No env variables for gce access in production, exiting!"
    process.exit 1

  console.log "No env variables for gcloud access, assuming development..."

gcloud = Meteor.npmRequire "gcloud"
async = Meteor.npmRequire "async"
storage = gcloud.storage gcloudconfig

@deleteQueue = async.queue((task, cb)->
  task.delete (err) ->
    if err?
      console.log "Failed to delete #{task.name}, #{err}"
    cb()
, 10)

console.log "Using GCE bucket: #{config.bucket}"
@bucket = storage.bucket config.bucket

@GetSignedURL = (key,expires)->
  expires = expires || 600
  expiretime = new Date().getTime()
  expiretime = expiretime + (expires*60000)
  return Async.runSync((done) ->
    bucket.file(key).getSignedUrl {action: 'read', expires: expiretime}, (err, resp)->
      done(err, resp)
  ).result

#Meteor.startup ->
#  return unless process.env.ENABLE_CULL_UNKNOWN?
#
  ### todo: update this code for GCE
  console.log "checking entire s3 bucket..."
  allKeys = Async.runSync((done) ->
    bucket.getFiles (err, files) ->
      done err, files
  ).result
  console.log "#{allKeys.length} files in amazon s3"

  matchIdToFile = {}
  matchIds = []
  allKeys.forEach (key) ->
    id = parseInt(key.name.replace(".dem.bz2", ""))
    matchIds.push id
    matchIdToFile[id] = key

  # Find submissions that are marked as downloaded but aren't in the array
  msubs = Submissions.update {status: {$in: [2, 3]}, matchid: {$nin: matchIds}}, {$set: {status: 0, reviewed: false}, $unset: {reviewer: "", reviewerUntil: ""}}, {multi: true}, (err, aff)->
    console.log "reset #{aff} downloaded submissions that don't exist in s3"

  subs = Submissions.find({matchid: {$in: matchIds}, status: {$lte: 4}}).fetch()
  for sub in subs
    matchIds = _.without matchIds, sub.matchid

  toRemove = []
  matchIds.forEach (id)->
    file = matchIdToFile[id]
    return unless file?
    toRemove.push file

  totalRem = toRemove.length
  deleteQueue.push toRemove
  ###
