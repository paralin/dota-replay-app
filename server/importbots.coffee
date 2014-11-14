Meteor.startup ->
  asset = Assets.getText 'bots'

  if asset?
    lines = asset.split '\n'
    i = -1
    user = ""
    pass = ""
    accounts = {}
    for line in lines
      if line is "x"
        i=0
      
      if i is 2
        user = line
      if i is 3
        pass = line
        i = -1
        accounts[user] = pass

      i++ if i isnt -1
    
    inserted = 0
    updated = 0
    for u, p of accounts
      existing = Bots.findOne Username: u
      if !existing?
        Bots.insert
          Username: u
          Password: p
          Invalid: false
        inserted+=1
      else
        if existing.Password isnt p
          Bots.update {_id: existing._id}, {$set: {Password: p, Invalid: false}}
    if inserted>0 or updated>0
      console.log "Loaded bot list, inserted #{inserted} and updated #{updated}"
