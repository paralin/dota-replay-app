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
        throwErr @response, 403, "You are missing #{k} on your submission."
        return
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
        throwErr @response, 403, err.sanitizedError.reason
        return
      else
        @response.writeHead 200
        @response.end JSON.stringify
          status: 200
          data: null
          error: null

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
