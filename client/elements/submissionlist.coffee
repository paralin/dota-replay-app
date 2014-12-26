Template.submissionList.events
  "click .subDel": ->
    return if @status is 1 or (@status > 2 and @status isnt 5)
    swal
      title: "Are you sure?"
      text: "Are you sure you want to delete this submission?"
      type: "warning"
      showCancelButton: true
      confirmButtonColor: "#DD6B55"
      confirmButtonText: "Yes, delete it!"
      closeOnConfirm: false
    , =>
      Submissions.remove {_id: @_id}, (err)=>
        if err?
          swal({type: "error", title: "Can't Delete Submission", text: err.reason})
        else
          swal
            type: "success"
            title: "Submission Deleted"
            text: "The submission has been deleted."
  "click .retryReplay": ->
    return if @status < 5
    Meteor.call "retrySubmission", @_id, (err)->
      if err?
        swal({type: "error", title: "Can't Retry Submission", text: err.reason})
  "click .downloadReplay": (e)->
    e.preventDefault()
    $(e.currentTarget).attr("disabled", true)
    Meteor.call "downloadReplay", @_id, (err, res)->
      $(e.currentTarget).attr("disabled", false)
      if err?
        swal({type: "error", title: "Can't Download Replay", text: err.reason})
      else
        window.open res, "_blank"
        window.focus()
Template.submissionList.helpers
  "hasSubmissions": ->
    @? && @.length > 0
  "submissionCount": ->
    @.length
  "acceptedCount": ->
    0
  "iconClass": ->
    if @status is 0
      "fa fa-circle-o-notch fa-spin"
    else if @status is 1
      "fa fa-download"
    else if @status is 2
      "fa fa-send"
    else if @status is 3
      "fa fa-check"
    else if @status is 4
      "fa fa-trash"
    else
      "fa fa-exclamation-triangle"
  "cannotDelete": ->
    @status is 1 or (@status > 2 and @status isnt 5)
  "submissionCountR": ->
    (_.where @, {status: 2}).length
  "submissionCountP": ->
    match = _.filter @, (sub)->
      sub.status < 2
    console.log @
    console.log match
    match.length
  "ready": ->
    @status >= 2 && @status < 5
  "notready": ->
    not (@status >= 2 && @status < 5)
  "failed": ->
    @status >= 5
  "notfailed": ->
    @status < 5
Template.submissionRow.rendered = ->
  @$ "select"
    .select2({width: "resolve"})
    .on "change", (e)->
      id = $(e.currentTarget).find("option[value=\"#{e.val}\"]").attr("id")
      Meteor.call "setShow", id, e.val, (err, res)->
        if err?
          swal
            title: "Issue Changing Show"
            text: err.reason
            type: "error"

Template.submissionRow.helpers
  "shows": ->
    Shows.find()
  "isSelected": ->
    @_id is @show
  "rowClass": ->
    if @status >= 4
      "danger"
    else if @status == 1
      "info"
    else if @status == 2
      "active"
    else if @status == 4
      "warning"
