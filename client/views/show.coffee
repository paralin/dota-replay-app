Template.ShowDetail.events
  "click .submitBtn": (e)->
    subCount = Submissions.find {show: @_id, status: {$lt: 3}}
    count = subCount.count()
    if count >= @maxSubmissions
      e.preventDefault()
      swal
        type: "error"
        text: "You already have #{@maxSubmissions} active submissions, you can't submit any more for this episode."
        title: "Too Many Submissions"
Template.ShowDetail.helpers
    "submissions": ->
        Submissions.find({uid: Meteor.userId(), show: @_id}).fetch()
    "stringify": (obj)->
        JSON.stringify obj
    "submissionStatus": ->
        if @submissionsOpen
            "Open"
        else
            "Closed"
    "submissionLabel": ->
        if @submissionsOpen
            "label label-success"
        else
            "label label-danger"
    "submissionsClosed": ->
        not @submissionsOpen
