Meteor.methods
  "setSubmissionsEnabled": (showid, enable)->
    check showid, String
    check enable, Boolean
    if !@userId?
      throw new Meteor.Error "login", "You are not signed in."
    show = Shows.findOne {_id: showid}
    if !show?
      throw new Meteor.Error 404, "Can't find that show."
    OrbitPermissions.throwIfUserCant "set-submissions-enabled", "dr", @userId
    Shows.update {_id: showid}, {$set: {submissionsOpen: enable}}
    enable
  "retrySubmission": (id)->
    check id, String
    sub = Submissions.findOne {_id: id}
    if !sub?
      throw new Meteor.Error 404, "Can't find submission."
    if !@userId?
      throw new Meteor.Error "login", "You are not signed in."
    show = Shows.findOne {_id: sub.show}
    if !show?
      throw new Meteor.Error 404, "Can't find that show."
    OrbitPermissions.throwIfUserCant "retry-submission", "dr", @userId
    if sub.status is 4
      Submissions.update {_id: id}, {$set: {status: 2, reviewed: false}, $unset: {reviewer: "", reviewerDescription: ""}}
      return
    if sub.status < 5
      throw new Meteor.Error 403, "That submission hasn't failed (yet)."
    Submissions.update {_id: id}, {$set: {status: 0}}
    return
  "setShow": (id, show)->
    check id, String
    check show, String
    console.log show
    sub = Submissions.findOne {_id: id}
    if !sub?
      throw new Meteor.Error 404, "Can't find submission."
    if !@userId?
      throw new Meteor.Error "login", "You are not signed in."
    show = Shows.findOne {_id: show}
    if !show?
      throw new Meteor.Error 404, "Can't find that show."
    OrbitPermissions.throwIfUserCant "set-show", "dr", @userId
    Submissions.update {_id: id}, {$set: {show: show._id}}
