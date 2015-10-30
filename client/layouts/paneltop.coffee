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

Template.PanelTopNav.rendered = ->
  client = new ZeroClipboard($(".showTokenButton")[0])
  client.on 'ready', (readyEvent) ->
    client.on 'copy', (event)->
       clipboard = event.clipboardData
       clipboard.setData( "text/plain", Session.get("desktopToken") )
    client.on 'aftercopy', (event) ->
      swal
        title: "Token Copied"
        text: "Paste the copied token into the desktop client to log in."
        type: "success"
