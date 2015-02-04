Template.PanelTopNav.events
    "click .logoutButton": ->
      Meteor.logout()
    "click .showTokenButton": ->
Template.PanelTopNav.rendered = ->
  Meteor.call "getDesktopToken", (err, res)->
    if err?
      console.log err
    else
      client = new ZeroClipboard($(".showTokenButton")[0])
      client.on 'ready', (readyEvent) ->
        client.on 'copy', (event)->
           clipboard = event.clipboardData
           clipboard.setData( "text/plain", res )
        client.on 'aftercopy', (event) ->
          swal
            title: "Token Copied"
            text: "Paste the copied token into the desktop client to log in."
            type: "success"
