Router.onBeforeAction ->
  # all properties available in the route function
  # are also available here such as this.params
  if Meteor.isClient and !Meteor.userId()?
    # if the user is not logged in, render the Login template
    @render "Login"
  else
    # otherwise don't hold up the rest of hooks or our route/action function
    # from running
    @next()
  return

Router.route "/", ->
  @layout "PanelLayout"
  @render "Submissions"
  return

Router.route "/submit/:_id", ->
  id = @params._id
  @layout "PanelLayout"
  @render "ShowSubmit",
    data: ->
      Shows.findOne
        _id: id
  return

Router.route "/shows/:_id", ->
  id = @params._id
  @layout "PanelLayout"
  Meteor.subscribe "submissions", id
  @render "ShowDetail",
    data: ->
      Shows.findOne
        _id: id
  return

Router.route "/shows", ->
  @layout "PanelLayout"
  @render "ShowList"
