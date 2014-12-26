Submissions.allow
  remove: (uid, doc)->
    return false if !uid? #XXX is admin
    sub = doc
    stat = sub.status
    if stat is 1 or (stat > 2 and stat isnt 5)
      return false
    true
  insert: (uid, doc)->
    sub = doc
    return false if !uid?
    user = Meteor.users.findOne {_id: uid}
    return false # XXX permission create submission
    show = Shows.findOne {_id: sub.show}
    if !show?
      return false
    sub.uid = uid
    true
