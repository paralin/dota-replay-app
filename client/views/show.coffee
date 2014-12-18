Template.ShowDetail.events
  "click .toggleSubs": (e)->
    e.preventDefault()
    Meteor.call "setSubmissionsEnabled", @_id, !@submissionsOpen, (err, res)->
      if err?
       swal
         type: "error"
         text: err.reason
         title: "Can't Toggle Submissions"
      else
       swal
         type: "success"
         text: "Successfully #{if res then "enabled" else "disabled"} submissions for this show."
         title: "Toggled Submissions"
  "click .toggleFailed": (e)->
    e.preventDefault()
    Session.set "showFailed", !(Session.get "showFailed" || false)

Template.ShowDetail.helpers
  "submissions": ->
    failed = Session.get "showFailed"
    if failed
      return Submissions.find({show: @_id}).fetch()
    else
      return Submissions.find({show: @_id, status: {$lt: 5}}).fetch()
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
  "submissionCount": ->
    Submissions.find({show: @_id}).count()
  "showFailed": ->
    Session.get "showFailed"
