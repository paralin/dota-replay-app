#Set default admins
Meteor.startup ->
  ids = ["76561198029304414"]
  for id in ids
    user = Meteor.users.findOne {"services.steam.id": id}
    continue if !user?
    OrbitPermissions.addAdmins user
