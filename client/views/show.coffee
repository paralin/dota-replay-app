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

Template.ShowDetail.helpers
   "submissions": ->
      Submissions.find({show: @_id}).fetch()
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
