Meteor.publish null, ->
  Meteor.users.find { "status.online": true },
    fields:
      profile: 1
      "services.steam.avatar": 1

Meteor.publish "shows", ->
  Shows.find()

Meteor.publish "submissions", (showid)->
  return [] if !@userId?
  user = Meteor.users.findOne {_id: @userId}
  return [] if !user?
  show = Shows.find {_id: showid}
  return [] if !show?
  Submissions.find {show: showid}

Meteor.publish "allsubmissions", ->
  return [] if !@userId?
  user = Meteor.users.findOne {_id: @userId}
  Submissions.find {}
