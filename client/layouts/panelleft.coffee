Template.PanelLeftSidebar.helpers
  "shows": ->
    Shows.find()
  "isActiveShowDetail": ->
    if Router.current().url is "/shows/"+@_id
      "active"
    else
      ""
  "isActiveShowList": ->
    if Router.current().url is "/shows"
      "active"
    else
      ""
  "isActiveShowSubmit": ->
    if Router.current().url is "/submit/"+@_id
      "active"
    else
      ""
  "hasShows": ->
    Shows.find().count() > 0
