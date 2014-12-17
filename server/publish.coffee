Meteor.publish null, ->
  Meteor.users.find
    _id: @userId
  ,
    limit: 1
    fields:
      "services.steam.avatar": 1
      "reviewShows": 1

Meteor.publish null, ->
  Meteor.users.find { "status.online": true },
    fields:
      profile: 1
      "services.steam.avatar": 1

Meteor.publish "reviewData", ->
  return [] if !@userId?
  user = Meteor.users.findOne {_id: @userId}
  return if !user? || !user.reviewShows?
  Shows.find {_id: {$in: user.reviewShows}}

Meteor.publish "submissions", (showid)->
  return [] if !@userId?
  user = Meteor.users.findOne {_id: @userId}
  return [] if !user? || !user.reviewShows? || !_.contains(user.reviewShows, showid)
  show = Shows.find {_id: showid}
  return [] if !show?
  Submissions.find {show: showid}
