Meteor.startup ->
  cullOld = ->
    console.log "checking replay files to cull..."
    since = new Date()
    since.setMinutes since.getMinutes()-43829
    sinceLong = new Date()
    sinceLong.setHours since.getHours()-1095
    toCull = Submissions.find({status: 3, $or: [{rating: {$lte: 5}, createdAt: {$lt: since}}, {createdAt: {$lt: sinceLong}}]}).fetch()
    toCullIds = []
    filesToDelete = []
    for cull in toCull
      toCullIds.push cull._id
      filesToDelete.push "#{cull.matchid}.dem.bz2"
    console.log "about to cull: #{JSON.stringify filesToDelete}"
    if process.env.ENABLE_CULL_OLD?
      Submissions.update {_id: {$in: toCullIds}}, {$set: {status: 6}}, {multi: true}
      knoxClient.deleteMultiple filesToDelete, (err, res)->
        if err?
          console.log "cannot delete culled submission files, #{err}"
        else
          console.log "=== PURGED #{filesToDelete.length} FILES FROM AWS ==="
     else
       console.log "not actually culling since ENABLE_CULL_OLD is not enabled"
  Meteor.setInterval ->
    cullOld()
  , 3600000
  cullOld()
