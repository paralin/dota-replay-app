Router.onBeforeAction ->
  # all properties available in the route function
  # are also available here such as this.params
  unless Meteor.userId()
    # if the user is not logged in, render the Login template
    @render "LoginSplash"
  else
    # otherwise don't hold up the rest of hooks or our route/action function
    # from running
    @next()
  return

Router.route "/", ->
    @layout "PanelLayout"
    @render "Submissions"
    return

Router.route "/shows/:_id", ->
    id = @params._id
    @layout "PanelLayout"
    @render "ShowDetail",
        data: ->
            Shows.findOne
                _id: id
    return

Router.route "/shows", ->
    @layout "PanelLayout"
    @render "ShowList"
