Session.set "1min", new Date().getTime()
Meteor.setInterval ->
  Session.set "1min", new Date().getTime()
, 60000
