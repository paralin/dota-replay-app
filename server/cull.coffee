Meteor.startup ->
  cullOld = ->
    console.log "checking replay files to cull..."
    since = new Date()
    since.setMinutes since.getMinutes()-20160
    toCull = Submissions.find({status: 3, rating: {$lte: 5}, createdAt: {$lt: since}}).fetch()
    toCullIds = []
    filesToDelete = []
    console.log "deleting #{toCull.length} submissions"
    for cull in toCull
      toCullIds.push cull._id
      filesToDelete.push "#{cull.matchid}.dem.bz2"
    Submissions.update {_id: {$in: toCullIds}}, {$set: {status: 6}}, {multi: true}
    knoxClient.deleteMultiple filesToDelete, (err, res)->
      if err?
        console.log "cannot delete culled submission files, #{err}"
      else
        console.log "=== PURGED #{filesToDelete.length} FILES FROM AWS ==="
  Meteor.setInterval ->
    cullOld()
  , 600000
