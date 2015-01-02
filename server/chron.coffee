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
    Submissions.update {reviewed: false, reviewer: {$exists: true}, reviewerUntil: {$lte: new Date()}}, {$unset: {reviewer: "", reviewerUntil: ""}, $set: {reviewed: false}}

Meteor.startup ->
  SyncedCron.start()
