Router.route "/", ->
    @render "Home"
    return
Router.route "/submissions", ->
    @layout "PanelLayout"
    @render "Submissions"
    return
Router.route "/submissions/new", ->
    @render "NewSubmission"
    return
