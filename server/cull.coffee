Array::chunk = (chunkSize) ->
  array = this
  [].concat.apply [], array.map((elem, i) ->
    if i % chunkSize then [] else [ array.slice(i, i + chunkSize) ]
  )

Meteor.startup ->
  cullOld = ->
    console.log "checking replay files to cull..."
    since = new Date()
    since.setMinutes since.getMinutes()-43829
    sinceLong = new Date()
    sinceLong.setHours since.getHours()-1095
    toCull = Submissions.find({status: 4, $or: [{rating: {$lte: 5}, createdAt: {$lt: since}}, {createdAt: {$lt: sinceLong}, rating: {$lt: 8}}]}).fetch()
    toCullIds = []
    filesToDelete = []
    for cull in toCull
      toCullIds.push cull._id
      filesToDelete.push bucket.file("#{cull.matchid}.dem.bz2")
    if process.env.ENABLE_CULL_OLD? and filesToDelete.length > 0
      console.log "culling #{filesToDelete.length} files"
      Submissions.update {_id: {$in: toCullIds}}, {$set: {status: 6}}, {multi: true}
      deleteQueue.push filesToDelete
    else
      console.log "not actually culling #{filesToDelete.length} since ENABLE_CULL_OLD is not enabled"
  Meteor.setInterval ->
    cullOld()
  , 3600000
  cullOld()
