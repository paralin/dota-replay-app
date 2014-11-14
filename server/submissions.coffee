Meteor.startup ->
  Submissions.allow
    insert: (userId, submission)->
      submission.status is 0 and submission.uid is userId and Shows.findOne(_id: submission.show)?
    update: (userId, submission)->
      false
    remove: (userId, submission)->
      submission.uid is userId and submission.status < 3
