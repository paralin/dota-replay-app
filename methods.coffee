Meteor.methods
  "setSubmissionsEnabled": (showid, enable)->
    check showid, String
    check enable, Boolean
    if !@userId?
      throw new Meteor.Error "login", "You are not signed in."
    show = Shows.findOne {_id: showid}
    if !show?
      throw new Meteor.Error 404, "Can't find that show."
    user = Meteor.users.findOne {_id: @userId}
    if !user? # XXX roles
      throw new Meteor.Error 403, "Not authorized to change show submission status."
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
    user = Meteor.users.findOne {_id: @userId}
    if !user? || !hasAnyRole(user, ["admin", "produce"])
      throw new Meteor.Error 403, "Not authorized to retry failed submissions."
    if sub.status < 5
      throw new Meteor.Error 403, "That submission hasn't failed (yet)."
    Submissions.update {_id: id}, {$set: {status: 0}}
  "setShow": (id, show)->
    check id, String
    check show, String
    sub = Submissions.findOne {_id: id}
    if !sub?
      throw new Meteor.Error 404, "Can't find submission."
    if !@userId?
      throw new Meteor.Error "login", "You are not signed in."
    show = Shows.findOne {_id: show}
    if !show?
      throw new Meteor.Error 404, "Can't find that show."
    user = Meteor.users.findOne {_id: @userId}
    if !user? || !hasAnyRole(user, ["admin", "produce"])
      throw new Meteor.Error 403, "Not authorized to change show for submissions."
    Submissions.update {_id: id}, {$set: {show: show}}
