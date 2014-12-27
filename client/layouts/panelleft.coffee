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
    Shows.find().count() > 0 && OrbitPermissions.userCan "view-submissions", "dr"
  "canReview": ->
    Shows.find().count() > 0 && OrbitPermissions.userCan "review-submissions", "dr"
  "canManage": ->
    OrbitPermissions.userCan "delegate-and-revoke", "permissions"
