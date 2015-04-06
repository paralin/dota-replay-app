AWS = Meteor.npmRequire "aws-sdk"
knox = Meteor.npmRequire "knox"

@s3config = {}
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
  expires = expires || 60
  s3.getSignedUrl "getObject", {Key: key, Expires: 60}
