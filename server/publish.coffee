Meteor.publish null, ->
  Meteor.users.find { "status.online": true },
    fields:
      profile: 1
      "services.steam.avatar": 1

Meteor.publish "shows", ->
  Shows.find()

Meteor.publish "submissions", (showid, skip, count)->
  check showid, String
  skip = skip || 0
  count = count || 50
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
    skip: skip
    limit: count
    sort:
      createdAt: -1

Meteor.publish "allsubmissions", (skip, count)->
  skip = skip || 0
  count = count || 50
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
    skip: skip
    limit: count
    sort:
      createdAt: -1

Meteor.publish "review", ->
  return [] if !@userId? || !OrbitPermissions.userCan("review-submissions", "dr", @userId)
  Submissions.find {reviewed: false, reviewer: @userId}
