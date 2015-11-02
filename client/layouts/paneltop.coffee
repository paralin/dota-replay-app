Template.PanelTopNav.events
    "click .logoutButton": ->
      Meteor.logout()

hasGottenToken = false
Meteor.startup ->
  Tracker.autorun ->
    user = Meteor.user()
    if user? and !hasGottenToken
      hasGottenToken = true
      Meteor.call "getDesktopToken", (err, res)->
        if err?
          console.log err
          hasGottenToken = false
        else
          console.log "Desktop token: #{res}"
          Session.set "desktopToken", res
