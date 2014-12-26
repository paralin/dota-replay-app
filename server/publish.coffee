Meteor.publish null, ->
  Meteor.users.find { "status.online": true },
    fields:
      profile: 1
      "services.steam.avatar": 1

Meteor.publish "shows", ->
  Shows.find()

Meteor.publish "submissions", (showid)->
  return [] if !@userId? || !OrbitPermissions.userCan("view-submissions", "dr", @userId)
  Submissions.find {show: showid}

Meteor.publish "allsubmissions", ->
  return [] if !@userId? || !OrbitPermissions.userCan("view-submissions", "dr", @userId)
  Submissions.find {}
