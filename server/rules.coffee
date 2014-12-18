Submissions.allow
  remove: (uid, doc)->
    sub = doc
    return false if !uid?
    show = Shows.findOne {_id: sub.show}
    if !show?
      return false
    user = Meteor.users.findOne {_id: uid}
    if !user? or !user.reviewShows? or !_.contains(user.reviewShows, show._id)
      return false
    stat = sub.status
    if stat is 1 or (stat > 2 and stat isnt 5)
      return false
    true
  insert: (uid, doc)->
    sub = doc
    return false if !uid?
    show = Shows.findOne {_id: sub.show}
    if !show?
      return false
    user = Meteor.users.findOne {_id: uid}
    if !user? or !user.reviewShows? or !_.contains(user.reviewShows, show._id)
      return false
    stat = sub.status
    if stat is 1 or (stat > 2 and stat isnt 5)
      return false
    true
