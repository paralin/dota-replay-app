Meteor.publish null, ->
  Meteor.roles.find {}

Meteor.publish null, ->
  Meteor.users.find
    _id: @userId
  ,
    limit: 1
    fields:
      "services.steam.avatar": 1

Meteor.publish null, ->
  Meteor.users.find { "status.online": true },
    fields:
      profile: 1
      "services.steam.avatar": 1
