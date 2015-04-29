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

Router.route "/review/",
  subscriptions: ->
    [Meteor.subscribe("review")]
  action: ->
    @layout "PanelLayout"
    @render "Review"
    return

@ManageDep = new Tracker.Dependency()

Router.route "/manage/",
  action: ->
    ManageDep.depend()
    Meteor.call "adminUsersList", (err, res)->
      if err?
        swal
          title: "Unable to Fetch Users"
          text: err.reason
          type: "error"
      else
        Session.set "adminUsers", res

    @layout "PanelLayout"
    @render "Manage",
      data: ->
        users: Session.get("adminUsers")

Router.route "/submit/:_id", ->
  id = @params._id
  @layout "PanelLayout"
  @render "ShowSubmit",
    data: ->
      Shows.findOne
        _id: id
  return

Router.route "/submissions/:_count?",
  subscriptions: ->
    [Meteor.subscribe("shows")]
  action: ->
    count = @params._count || 1
    count = 1 if count < 1
    count = count-1
    console.log count
    Session.set "submissionsSkip", (count*100)
    Meteor.subscribe("allsubmissions", Session.get("submissionsSkip"))
    @layout "PanelLayout"
    if @ready()
      @render "Submissions",
        data: ->
          _id: "all"
          name: "All"
    else
      @render "Loading"

Router.route "/submissions/:_id/:_count?",
  subscriptions: ->
    id = @params._id
    [Meteor.subscribe("shows")]
  action: ->
    count = @params._count || 1
    count = 1 if count < 1
    count = count-1
    console.log count
    Session.set "submissionsSkip", (count*100)
    Meteor.subscribe("submissions", id, Session.get("submissionsSkip"))
    id = @params._id
    @layout "PanelLayout"
    if @ready()
      @render "Submissions",
        data: ->
          Shows.findOne
            _id: id
    else
      @render "Loading"
