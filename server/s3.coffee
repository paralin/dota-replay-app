AWS = Meteor.npmRequire "aws-sdk"
config = JSON.parse Assets.getText "config.json"
AWS.config.update config
s3config = JSON.parse Assets.getText "s3config.json"
s3 = new AWS.S3 {params: s3config}
@GetSignedURL = (key,expires)->
  expires = expires || 60
  s3.getSignedUrl "getObject", {Key: key, Expires: 60}
