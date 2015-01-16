Meteor.publish null, ->
  Meteor.users.find { "status.online": true },
    fields:
      profile: 1
      "services.steam.avatar": 1

Meteor.publish "shows", ->
  Shows.find()

Meteor.publish "submissions", (showid)->
  check showid, String
  return [] if !@userId? || !OrbitPermissions.userCan("view-submissions", "dr", @userId)
  Submissions.find {show: showid},
    fields:
      uid: 0
      description: 0
      reviewerDescription: 0
      reviewerUntil: 0
      hero_to_watch: 0
      matchtime: 0
      rating: 0

Meteor.publish "allsubmissions", ->
  return [] if !@userId? || !OrbitPermissions.userCan("view-submissions", "dr", @userId)
  Submissions.find {},
    fields:
      uid: 0
      description: 0
      reviewerDescription: 0
      reviewerUntil: 0
      hero_to_watch: 0
      matchtime: 0
      rating: 0

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
