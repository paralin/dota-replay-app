Meteor.methods
  "setSubmissionsEnabled": (showid, enable)->
    check showid, String
    check enable, Boolean
    if !@userId?
      throw new Meteor.Error "login", "You are not signed in."
    show = Shows.findOne {_id: showid}
    if !show?
      throw new Meteor.Error 404, "Can't find that show."
    user = Meteor.users.findOne {_id: @userId}
    if !user? or !user.reviewShows? or !_.contains(user.reviewShows, show._id)
      throw new Meteor.Error 403, "Not authorized to open/close shows to submissions."
    Shows.update {_id: showid}, {$set: {submissionsOpen: enable}}
    enable
