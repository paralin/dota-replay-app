@Bots = new Mongo.Collection "bots"

BotSchema = new SimpleSchema
  Username:
    type: String
  Password:
    type: String
  PersonaName:
    type: String
    optional: true
  FetchTimes:
    type: [Date]
  DisableUntil:
    type: Date
  Invalid:
    type: Boolean
    optional: true
  InvalidReason:
    type: String
    optional: true
