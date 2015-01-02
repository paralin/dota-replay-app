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

Meteor.publish "admin", ->
  return [] if !@userId? || !OrbitPermissions.userCan("delegate-and-revoke", "permissions", @userId)
  Meteor.users.find {},
    fields:
      profile: 1
      orbit_roles: 1
      services: 1
Meteor.publish "review", ->
  return [] if !@userId? || !OrbitPermissions.userCan("review-submissions", "dr", @userId)
  Submissions.find {reviewed: false, reviewer: @userId}
