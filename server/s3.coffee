AWS = Meteor.npmRequire "aws-sdk"
knox = Meteor.npmRequire "knox"

s3config = {}
config = {}

if process.env.AWS_ACCESS_KEY?
  console.log "Using environment variables for s3 access..."
  config =
    accessKeyId:     process.env.AWS_ACCESS_KEY
    secretAccessKey: process.env.AWS_ACCESS_SECRET
    region:          process.env.AWS_REGION || "us-east-1"
  AWS.config.update config
else
  console.log "No env variables for S3 access, using private dir..."
  config = JSON.parse Assets.getText "config.json"
  AWS.config.update config
  s3config = JSON.parse Assets.getText "s3config.json"

s3config.Bucket = process.env.S3_BUCKET || "dotareplay"
console.log "Using S3 bucket: #{s3config.Bucket}"

@knoxClient = knox.createClient
  key: config.accessKeyId
  secret: config.secretAccessKey
  bucket: s3config.Bucket

s3 = new AWS.S3 {params: s3config}

@GetSignedURL = (key,expires)->
  expires = expires || 600
  s3.getSignedUrl "getObject", {Key: key, Expires: expires}

Meteor.startup ->
  console.log "checking entire s3 bucket..."
  allKeys = []

  listAllKeys = (marker, cb) ->
    s3.listObjects {
      Bucket: s3config.Bucket
      Marker: marker
    }, (err, data) ->
      for item in data.Contents
        allKeys.push item.Key unless item.Key in allKeys
      if data.IsTruncated
        listAllKeys data.Contents.slice(-1)[0].Key, cb
      else
        cb()
      return
    return

  if process.env.ENABLE_CULL_UNKNOWN?
    listAllKeys "", Meteor.bindEnvironment ->
      console.log "#{allKeys.length} files in amazon s3"
      matchIds = allKeys.map (key)->
        parseInt(key.replace(".dem.bz2", ""))

      # Find submissions that are marked as downloaded but aren't in the array
      msubs = Submissions.update {status: {$in: [2, 3]}, matchid: {$nin: matchIds}}, {$set: {status: 0, reviewed: false}, $unset: {reviewer: "", reviewerUntil: ""}}, {multi: true}, (err, aff)->
        console.log "reset #{aff} downloaded submissions that don't exist in s3"

      subs = Submissions.find({matchid: {$in: matchIds}, status: {$lte: 4}}).fetch()
      for sub in subs
        matchIds = _.without matchIds, sub.matchid
      toRemove = matchIds.map (id)->
        "/#{id}.dem.bz2"
      console.log "removing #{JSON.stringify toRemove} as they don't match any submissions in the system"
      for files in toRemove.chunk(100)
        knoxClient.deleteMultiple files, (err, res)->
          if err?
            console.log "unable to remove #{err}"
          else
            console.log "removed #{files}"
