WebSocket = Meteor.npmRequire("ws").Server
jwt = Meteor.npmRequire("jsonwebtoken")

secret = "TDQFAL7KEDCTo0"

ws = new WebSocket({port: 10304})

clii = 0
clients = {}

@generateToken = (uid)->
  return jwt.sign({user: uid, time: new Date().getTime()}, secret, {issuer: "dotareplay", audience: "user", subject: "desktop client", expiresInMinutes: 10080})

class Client
  constructor: (@ws, @ix)->
    console.log "new client connected"
    @state = 0
    @setupBinds()
  setupBinds: ->
    @ws.on "message", (msg)=>
      @processMessage msg
  sendMsg: (m)->
    console.log "sending #{JSON.stringify m}"
    @ws.send JSON.stringify m
  getUser: ->
    Meteor.users.findOne {_id: @uid}
  processMessage: (msg)->
    console.log "Received message: "+msg
    jmsg = JSON.parse msg
    console.log jmsg.m
    return if !jmsg.m?
    if jmsg.m is 0
      return if !jmsg.token?
      console.log "Checking handshake..."
      tokend = null
      try
        tokend = jwt.verify jmsg.token, secret
      catch
        console.log "Token is invalid"
        @sendMsg {m:0,success:false}
        return
      # tokend should have a valid user id
      console.log "Token is valid for user ID #{tokend.user} with timestamp #{tokend.time}"
      @uid = tokend.user
      user = @getUser @uid
      if !user?
        console.log "User does not exist!"
        @send {m: 0, success: false}
        return
      @state = 1
      console.log "Authenticated #{user.profile.name} succesfully."
    else if @state is 0
      return
    else
      #Parse some other message

ws.on 'connection', (ws)->
  clii++
  tclii = clii
  clients[clii] = new Client(ws, tclii)
  ws.on "close", ->
    delete clients[tclii]
