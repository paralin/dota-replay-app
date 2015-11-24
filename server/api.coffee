json2csv = Meteor.npmRequire "json2csv"

throwErr = (resp, code, descrip)->
  console.log "=== API ERROR ==="
  resp.writeHead code
  err = JSON.stringify
    error: descrip
    status: code
    data: null
  console.log err
  console.log "================="
  resp.end err

verifyToken = (request)->
  #todo: Actually verify
  true

submission =
  description: ""
  matchid: 0
  show: ""
  uid: ""
  uname: ""
  matchtime: 0
  hero_to_watch: ""
  ingame_time: "optional"

Router.route('/api/shows/:id', { where: 'server' })
  .get ->
    id = @params.id
    show = Shows.findOne {_id: id}
    if !show?
      throwErr @response, 404, "The show \"#{id}\" does not exist."
      return
    @response.writeHead 200
    @response.end JSON.stringify
      status: 200
      data: show
      error: null

Router.route('/api/submissions/create', { where: 'server' })
  .post ->
    return unless verifyToken @request
    sub = _.pick @request.body, _.keys submission
    for k, v of submission
      if !sub[k]?
        if submission[k] isnt "optional"
          throwErr @response, 403, "You are missing #{k} on your submission."
          return
        continue
      typ = typeof v
      if typeof(sub[k]) isnt typ
        throwErr @response, 403, "The submission property #{k} should be a #{typ}."
        return
    show = Shows.findOne {_id: sub.show}
    if !show?
      throwErr @response, 403, "The show #{sub.show} does not exist."
      return
    if !show.submissionsOpen
      throwErr @response, 403, "The show \"#{show.name}\" is not open for submissions."
      return
    Submissions.insert sub, (err)=>
      if err?
        throwErr @response, 403, err.reason
        return
      else
        @response.writeHead 200
        @response.end JSON.stringify
          status: 200
          data: null
          error: null

Router.route('/api/submissions/byuid/:uid', { where: 'server' })
  .get ->
    return unless verifyToken @request
    @response.writeHead 200
    @response.end JSON.stringify
      status: 200
      data: Submissions.find({uid: @params.uid}).fetch()

Router.route('/api/submissions/bymatchid/:mid', { where: 'server' })
  .get ->
    return unless verifyToken @request

    match = Submissions.findOne {matchid: parseInt(@params.mid)}

    status = if match? then 200 else 404
    @response.writeHead status
    @response.end JSON.stringify
      status: status
      data: match
      error: if match? then null else "Not found."

roleSet =
  secret: ""
  steamid: ""
  roles: [""]

Router.route('/api/users/roles', { where: 'server' })
  .post ->
    req = _.pick @request.body, _.keys roleSet
    for k, v of roleSet
      if !req[k]?
        throwErr @response, 403, "You are missing #{k} on your submission."
        return
      typ = typeof v
      if typeof(req[k]) isnt typ
        throwErr @response, 403, "The request property #{k} should be a #{typ}."
        return
    if req.secret isnt "LOm6HcsSTHZU5g"
      throwErr @response, 403, "The secret is wrong."
      return
    user = Meteor.users.findOne({"services.steam.id": req.steamid})
    if !user?
      throwErr @response, 403, "Can't find user with that steam ID."
      return
    if OrbitPermissions.isAdmin user._id
      throwErr @response, 403, "Can't change roles of an admin."
      return
    Meteor.users.update {_id: user._id}, {$set: {orbit_roles: req.roles}}
    @response.writeHead 200
    @response.end JSON.stringify
      status: 200
      data: null
      error: null

Router.route('/download_match/:matchid', { where: 'server' })
  .get ->
    id = @params.matchid
    iid = parseInt id
    if !id? || iid isnt iid
      return throwErr @response, 403, "Please specify a match id."
    sub = Submissions.findOne {matchid: iid, status: 4}
    if !sub?
      return throwErr @response, 404, "That submission couldn't be found or hasn't been downloaded yet."
    url = GetSignedURL "#{sub.matchid}.dem.bz2"
    @response.writeHead 302,
      "Location": url
    @response.end JSON.stringify
      status: 200
      data: url
      error: null

Router.route('/api/submissions/dumpcsv', { where: 'server' })
  .get ->
    usernameCache = {}
    subs = Submissions.find({reviewed: true, legacyUsed: null}, {sort: {rating: -1}}).fetch()

    @response.writeHead 200,
      "Content-Disposition": "attachment;filename=submissions.csv"

    for sub in subs
      name = usernameCache[sub.reviewer]
      if !name?
        user = Meteor.users.findOne {_id: sub.reviewer}
        if user?
          sub.reviewerName = user.profile.name
        else
          sub.reviewerName = "Unknown"
        usernameCache[sub.reviewer] = sub.reviewerName

    res = json2csv {data: subs, fields: ["rating", "show", "matchid", "hero_to_watch", "uname", "reviewerDescription", "description", "reviewerName", "matchtime"]}, (err, csv)=>
      if err?
        console.log "Error generating sheet #{err}"
      else
        console.log "Generated sheet, length #{csv.length}"
      @response.end csv

Router.route('/api/submissions/markold', { where: 'server' })
  .get ->
    subs = Submissions.update({status: 4}, {$set: {legacyUsed: true}}, {multi: true})

    @response.writeHead 200
    @response.end "Done"
