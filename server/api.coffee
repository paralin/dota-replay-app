throwErr = (resp, code, descrip)->
  resp.writeHead code
  resp.end JSON.stringify
    error: descrip
    status: code
    data: null

verifyToken = (request)->
  #todo: Actually verify
  true

submission = ["name", "description", "matchid", "show", "uid", "matchtime", "hero_to_watch", "country"]
submissiont = [typeof(""), typeof(""), typeof(0), typeof(""), typeof(""), typeof(3), typeof(""), typeof("")]

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
    sub = _.pick @request.body, submission
    for k in submission
      if !sub[k]?
        throwErr @response, 403, "You are missing #{k} on your submission."
        return
      typ = submissiont[submission.indexOf(k)]
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
