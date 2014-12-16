Tracker.autorun ->
  user = Meteor.user()
  if user?
    Meteor.subscribe "reviewData"
