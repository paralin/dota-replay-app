Template.Review.helpers
  "submissions": ->
    Submissions.find()
  "maxSubs": ->
    Submissions.find().count() >= 2
  "remainingTime": ->
    Session.get "1min"
    moment(@reviewerUntil).fromNow()
  "thisShow": ->
    Shows.findOne _id: @show
Template.Review.events
  "click .reqSub": ->
    Meteor.call "requestSubmission", (err, res)->
      if err?
        swal
          title: "Can't Add Submissions"
          text: err.reason
          type: "error"
  "click .reqDown": (e)->
    e.preventDefault()
    Meteor.call "downloadReplay", @_id, (err, res)->
      if err?
        swal({type: "error", title: "Can't Download Replay", text: err.reason})
      else
        window.open res, "_blank"
        window.focus()
