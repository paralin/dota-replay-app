Router.route "/", ->
    @render "Home"
    return
Router.route "/submissions", ->
    @render "Submissions"
    return
Router.route "/submissions/new", ->
    @render "NewSubmission"
    return
