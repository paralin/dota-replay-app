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
  @render "Home"
  return

Router.route "/submit/:_id", ->
  id = @params._id
  @layout "PanelLayout"
  @render "ShowSubmit",
    data: ->
      Shows.findOne
        _id: id
  return

Router.route "/submissions", 
  subscriptions: ->
    [Meteor.subscribe("allsubmissions"), Meteor.subscribe("shows")]
  action: ->
    @layout "PanelLayout"
    if @ready()
      @render "Submissions",
        data: ->
          _id: "all"
          name: "All Submissions"
    else
      @render "Loading"

Router.route "/submissions/:_id",
  subscriptions: ->
    id = @params._id
    [Meteor.subscribe("submissions", id), Meteor.subscribe("shows")]
  action: ->
    id = @params._id
    @layout "PanelLayout"
    if @ready()
      @render "Submissions",
        data: ->
          Shows.findOne
            _id: id
    else
      @render "Loading"
