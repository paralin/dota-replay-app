throwErr = (resp, code, descrip)->
  resp.writeHead code, {}
  resp.end JSON.stringify
    code: code
    err: descrip

Router.route("/api/shows/:show/submit", ->
  #Verify the token
  shown = @params.show
  throwErr @response, 404, "No show ID given." if !shown?

  show = Shows.findOne _id: shown
  throwErr @response, 404, "Can't find that show." if !show?

  @response.end JSON.stringify show
, {where: "server"})
