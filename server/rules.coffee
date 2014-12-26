Submissions.allow
  remove: (uid, doc)->
    return false if !uid? || !OrbitPermissions.userCan("delete-submission", "dr", uid)
    sub = doc
    stat = sub.status
    if stat is 1 or (stat > 2 and stat isnt 5)
      return false
    true
  insert: (uid, doc)->
    sub = doc
    return false if !uid? || !OrbitPermissions.userCan("create-submission", "dr", uid)
    show = Shows.findOne {_id: sub.show}
    return false if !show?
    sub.uid = uid
    true
