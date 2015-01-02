Meteor.methods
  "downloadReplay": (id)->
    check id, String
    sub = Submissions.findOne {_id: id}
    if !sub?
      throw new Meteor.Error 404, "Can't find submission."
    if !@userId?
      throw new Meteor.Error "login", "You are not signed in."
    show = Shows.findOne {_id: sub.show}
    if !show?
      throw new Meteor.Error 404, "Can't find that show."
    OrbitPermissions.throwIfUserCant "download-replay", "dr", @userId
    if sub.status < 2 || sub.status > 4
      throw new Meteor.Error 403, "That submission replay isn't available (yet?)."
    GetSignedURL sub.matchid+".dem.bz2"
  "requestSubmission": ->
    if !@userId?
      throw new Meteor.Error "login", "You are not signed in."
    OrbitPermissions.throwIfUserCant "review-submissions", "dr", @userId
    esub = Submissions.find {reviewed: false, reviewer: @userId}
    if esub.count() >= Config.maxConcurrentReview
      throw new Meteor.Error "max", "You already have #{Config.maxConcurrentReview} submissions to review."
    tsub = Submissions.find {reviewed: false, reviewer: {$exists: false}}, {limit: Config.maxConcurrentReview-esub.count(), fields: {_id: 1}}
    if tsub.count() == 0
      throw new Meteor.Error 404, "There are no more available submissions to review."
    ids = []
    for su in tsub.fetch()
      ids.push su._id
    till = new Date(new Date().getTime()+Config.timeToReview*60000)
    Submissions.update {_id: {$in: ids}}, {$set: {reviewer: @userId, reviewed: false, reviewerUntil: till}}
