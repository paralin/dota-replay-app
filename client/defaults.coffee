Meteor.startup ->
  show = Session.get "showFailed"
  show = show || true
  Session.set "showFailed", show
