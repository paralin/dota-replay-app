WebSocket = Meteor.npmRequire("ws").Server
jwt = Meteor.npmRequire("jsonwebtoken")

secret = "TDQFAL7KEDCTo0"

ws = new WebSocket({port: 10304})

clii = 0
clients = {}

@generateToken = (uid)->
  return jwt.sign({user: uid}, secret, {expiresInMinutes: 10080})

Meteor.methods
  "getDesktopToken": ->
    if !@userId?
      throw new Meteor.Error "notloggedin", "You must be signed in."
    return generateToken(@userId)

class Client
  constructor: (@ws, @ix)->
    console.log "new client connected"
    @state = 0
    @setupBinds()
  setupBinds: ->
    @ws.on "message", Meteor.bindEnvironment (msg)=>
      @processMessage msg
  sendMsg: (m)->
    console.log "sending #{JSON.stringify m}"
    @ws.send JSON.stringify m
  getUser: ->
    Meteor.users.findOne {_id: @uid}
  setupObserve: ->
    return false if !OrbitPermissions.userCan("review-submissions", "dr", @uid)
    @watchhand = Submissions.find({reviewed: false, reviewer: @uid}).observe
      added: (doc)=>
        doc.showname = Shows.findOne({_id: doc.show}).name
        @sendMsg
          m: 2
          replay: doc
      changed: (doc)=>
        doc.showname = Shows.findOne({_id: doc.show}).name
        @sendMsg
          m: 2
          replay: doc
      removed: (doc)=>
        @sendMsg
          m: 3
          id: doc._id
    return true
  sendStats: ->
    allSubs = Submissions.find({}, {fields: {_id: 1}})
    needReview = Submissions.find({status: 2}, {fields: {_id: 1}})
    reviewed = Submissions.find({status: 4}, {fields: {_id: 1}})
    reviewedByYou = Submissions.find({status: 4, reviewer: @uid}, {fields: {_id: 1}})
    @sendMsg {m: 5, allSubmissions: allSubs.count(), needReview: needReview.count(), reviewed: reviewed.count(), reviewedByYou: reviewedByYou.count()}
  processMessage: (msg)->
    console.log "Received message: "+msg
    jmsg = JSON.parse msg
    console.log jmsg.m
    return if !jmsg.m?
    if jmsg.m is 0
      return if !jmsg.token?
      console.log "Checking handshake..."
      if jmsg.version isnt "1.6"
        console.log "Client is out of date #{jmsg.version}..."
        @sendMsg {m: 9999}
        return
      tokend = null
      try
        tokend = jwt.verify jmsg.token, secret
      catch
        console.log "Token is invalid"
        @sendMsg {m:0,success:false}
        return
      # tokend should have a valid user id
      console.log "Token is valid for user ID #{tokend.user}"
      @uid = tokend.user
      user = @getUser @uid
      if !user?
        console.log "User does not exist!"
        @sendMsg {m: 0, success: false}
        return
      @state = 1
      console.log "Authenticated #{user.profile.name} (#{@uid}) succesfully."
      @sendMsg {m: 0, success: true}
      @sendMsg {m: 4, user: {name: user.profile.name, roles: user.orbit_roles, steam: user.services.steam}}
      @sendStats()
      if !@setupObserve()
        @sendMsg {m: 1}
    else if @state is 0
      return
    else
      switch jmsg.m
        when 1
          sub = {}
          if !jmsg.matchid
            sub = Submissions.findOne {_id: jmsg.id, reviewer: @uid}
          else
            sub = Submissions.findOne {matchid: parseInt(jmsg.id)}
          if !sub?
            return @sendMsg {m: 6, id: jmsg.id, success: false, reason: "Can't find that submission. Try again."}
          url = GetSignedURL "#{sub.matchid}.dem.bz2"
          @sendMsg {m: 6, success: true, id: jmsg.id, url: url, matchid: sub.matchid, matchtime: sub.matchtime}
        when 2
          unless OrbitPermissions.userCan "review-submissions", "dr", @uid
            @sendMsg {m: 7, success: false, reason: "You are not allowed to review submissions."}
            return
          esub = Submissions.find {reviewed: false, reviewer: @uid}
          if esub.count() >= Config.maxConcurrentReview
            @sendMsg {m: 7, success: false, reason: "You already have #{Config.maxConcurrentReview} submissions to review."}
            return
          tsub = Submissions.find {reviewed: false, reviewer: null, status: 2}, {limit: Config.maxConcurrentReview-esub.count(), fields: {_id: 1}}
          if tsub.count() == 0
            @sendMsg {m: 7, success: false, reason: "There are no more available submissions to review."}
            return
          ids = []
          for su in tsub.fetch()
            ids.push su._id
          till = new Date(new Date().getTime()+Config.timeToReview*60000)
          Submissions.update {_id: {$in: ids}}, {$set: {reviewer: @uid, reviewed: false, reviewerUntil: till, status: 3}}, {multi: true}
          @sendMsg {m: 7, success: true}
        when 3
          unless OrbitPermissions.userCan "review-submissions", "dr", @uid
            return
          sub = Submissions.findOne {_id: jmsg.id, reviewer: @uid}
          return if !sub?
          Submissions.update {_id: jmsg.id}, {$set: {reviewed: true, rating: parseInt(""+jmsg.rating), reviewerDescription: jmsg.descrip, status: 4}, $unset: {reviewerUntil: ""}}
          @sendStats()

ws.on 'connection', Meteor.bindEnvironment (ws)->
  clii++
  tclii = clii
  clients[clii] = new Client(ws, tclii)
  ws.on "close", Meteor.bindEnvironment ->
    client = clients[tclii]
    if client.uid?
      console.log "User #{client.uid} disconnected."
    if client.watchhand
      client.watchhand.stop()
    delete clients[tclii]
