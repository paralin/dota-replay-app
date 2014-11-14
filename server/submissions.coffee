Meteor.startup ->
  Submissions.allow
    insert: (userId, submission)->
      show = Shows.findOne(_id: submission.show)
      submission.episode = show.episode if show?
      submission.status is 0 and submission.uid is userId and show? and show.submissionsOpen
    update: (userId, submission)->
      false
    remove: (userId, submission)->
      s = submission.status
      submission.uid is userId and !(s is 1 or (s > 2 and s isnt 5))
