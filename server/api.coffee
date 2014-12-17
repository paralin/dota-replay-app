throwErr = (resp, code, descrip)->
  resp.writeHead code, {}
  resp.end JSON.stringify
    code: code
    err: descrip

#Todo: implement new API
