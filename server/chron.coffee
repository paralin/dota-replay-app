SyncedCron.options =
  log: false
  collectionName: "cronHistory"
  utc: true
  collectionTTL: 172800
SyncedCron.add
  name: "Expire old review delegations."
  schedule: (parser) ->
    parser.text "every 10 seconds"
  job: ->
    Submissions.update {status: 3, reviewed: false, reviewer: {$exists: true}, reviewerUntil: {$lte: new Date()}}, {$unset: {reviewer: "", reviewerUntil: ""}, $set: {reviewed: false, status: 2}}

checkEdge = ->
  Submissions.update {reviewer: {$exists: false}, status: 3}, {$set: {status: 2}}
SyncedCron.add
  name: "Check for edge cases."
  schedule: (parser)->
    parser.text "every 2 minutes"
  job: ->
    checkEdge()
checkEdge()

Meteor.startup ->
  SyncedCron.start()
