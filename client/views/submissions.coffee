Template.Submissions.events
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
  "click .submitMatch": (e)->
    e.preventDefault()
    Router.go "/submit/#{@_id}"

Template.Submissions.helpers
  "isFull": ->
    @_id is "all"
  "submissions": ->
    failed = Session.get "showFailed"
    if failed
      filter = {show: @_id}
      delete filter["show"] if @_id is "all"
      return Submissions.find(filter).fetch()
    else
      filter = {show: @_id, status: {$lt: 5}}
      delete filter["show"] if @_id is "all"
      return Submissions.find(filter).fetch()
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
