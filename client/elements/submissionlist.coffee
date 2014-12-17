Template.submissionList.events
  "click .subDel": ->
    return if @status is 1 or (@status > 2 and @status isnt 5)
    Submissions.remove {_id: @_id}, (err)->
      if err?
        swal({type: "error", title: "Can't Delete Submission", text: err.reason})
      else
        swal
          type: "success"
          title: "Submission Deleted"
          text: "The submission has been deleted."
Template.submissionList.helpers
  "hasSubmissions": ->
    @? && @.length > 0
  "submissionCount": ->
    @.length
  "acceptedCount": ->
    0
  "rowClass": ->
    if @status >= 4
      "danger"
    else if @status == 1
      "info"
    else if @status == 2
      "active"
    else if @status == 4
      "warning"
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
