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
    toCull = Submissions.find({status: 4, $or: [{rating: {$lte: 5}, createdAt: {$lt: since}}, {createdAt: {$lt: sinceLong}}]}).fetch()
    toCullIds = []
    filesToDelete = []
    for cull in toCull
      toCullIds.push cull._id
      filesToDelete.push "#{cull.matchid}.dem.bz2"
    if process.env.ENABLE_CULL_OLD? and filesToDelete.length > 0
      console.log "about to cull #{filesToDelete.length} files"
      Submissions.update {_id: {$in: toCullIds}}, {$set: {status: 6}}, {multi: true}
      for files in filesToDelete.chunk(100)
        knoxClient.deleteMultiple files, (err, res)->
          if err?
            console.log "cannot delete culled submission files, #{err}"
          else
            console.log "=== PURGED #{files.length} FILES FROM AWS ==="
    else
      console.log "not actually culling since ENABLE_CULL_OLD is not enabled"
  Meteor.setInterval ->
    cullOld()
  , 3600000
  cullOld()
