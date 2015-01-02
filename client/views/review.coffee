Template.Review.helpers
  "submissions": ->
    Submissions.find()
  "maxSubs": ->
    Submissions.find().count() >= 2
Template.Review.events
  "click .reqSub": ->
    Meteor.call "requestSubmission", (err, res)->
      if err?
        swal
          title: "Can't Add Submissions"
          text: err.reason
          type: "error"
