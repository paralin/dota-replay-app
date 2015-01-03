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
  "click .sendRating": (e)->
     e.preventDefault()
     id = @_id
     rating = parseInt $(".ratingIn").val()
     descrip = $(".reviewDes").val()
     Meteor.call "reviewSubmission", id, rating, descrip, (err, res)->
       if err?
         swal({title: "Can't Submit", text: err.reason, type: "error"})
  "click .reqPlayLink": (e)->
     e.preventDefault()
     window.open "dota2://matchid=#{@matchid}"+(if @matchtime? && @matchtime != 0 then "&matchtime="+@matchtime else ""), "_blank"
     window.focus()
