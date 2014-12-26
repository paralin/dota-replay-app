Meteor.startup ->
  Tracker.autorun ->
    user = Meteor.user()
    if user?
      Meteor.subscribe "shows"
