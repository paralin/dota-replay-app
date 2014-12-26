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
