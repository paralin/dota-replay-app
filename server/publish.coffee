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

Meteor.publishComposite "reviewData",
  find: ->
    return [] if !@userId?
    user = Meteor.users.findOne {_id: @userId}
    return if !user? || !user.reviewShows?
    Shows.find {_id: {$in: user.reviewShows}}
  children: [
    {
      find: (show)->
        Submissions.find {show: show._id}
    }
  ]
