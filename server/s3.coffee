AWS = Meteor.npmRequire "aws-sdk"

s3config = {}

if process.env.AWS_ACCESS_KEY?
  console.log "Using environment variables for s3 access..."
  AWS.config.update
    accessKeyId:     process.env.AWS_ACCESS_KEY
    secretAccessKey: process.env.AWS_ACCESS_SECRET
    region:          process.env.AWS_REGION || "us-east-1"
else
  console.log "No env variables for S3 access, using private dir..."
  config = JSON.parse Assets.getText "config.json"
  AWS.config.update config
  s3config = JSON.parse Assets.getText "s3config.json"

s3 = new AWS.S3 {params: s3config}

@GetSignedURL = (key,expires)->
  expires = expires || 60
  s3.getSignedUrl "getObject", {Key: key, Expires: 60}
