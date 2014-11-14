@Bots = new Mongo.Collection "bots"

BotSchema = new SimpleSchema
  Username:
    type: String
  Password:
    type: String
  PersonaName:
    type: String
    optional: true
  Invalid:
    type: Boolean
