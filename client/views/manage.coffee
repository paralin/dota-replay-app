Template.Manage.events
  "click .viewSteam": (e)->
    e.stopImmediatePropagation()
    url = "http://steamcommunity.com/profiles/#{@services.steam.id}"
    window.open(url,'_blank')
Template.userRow.helpers
  "rowClass": ->
    bc = "userRow"
    if @canReview
      bc += " success"
    bc
