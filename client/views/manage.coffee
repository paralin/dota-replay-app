Template.Manage.events
  "click .viewSteam": (e)->
    e.stopImmediatePropagation()
    url = "http://steamcommunity.com/profiles/#{@services.steam.id}"
    window.open(url,'_blank')
  "click .toggleAccess": (e)->
    e.stopImmediatePropagation()
    Meteor.call "toggleReview", @_id, (err)->
      ManageDep.changed()
Template.userRow.helpers
  "rowClass": ->
    bc = "userRow"
    if @canReview
      bc += " success"
    bc
