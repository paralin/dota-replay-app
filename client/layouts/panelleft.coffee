Template.PanelLeftSidebar.helpers
  "shows": ->
    Shows.find()
  "isActiveShowDetail": ->
    if Router.current().url is "/submissions/"+@_id
      "active"
    else
      ""
  "isActiveShowList": ->
    if Router.current().url is "/submissions"
      "active"
    else
      ""
  "canViewSubmissions": ->
    user = Meteor.user()
    Shows.find().count() > 0 # XXX check role
