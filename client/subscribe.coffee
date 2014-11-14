Meteor.startup ->
  Tracker.autorun ->
    if Meteor.userId()?
      Meteor.subscribe "clientdata"
