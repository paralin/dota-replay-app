@Submissions = new Mongo.Collection "submissions"

SubmissionSchema = new SimpleSchema
  legacyUsed:
    type: Boolean
    label: "Exported to a table before UI was created"
    optional: true
  rating:
    type: Number
    label: "Rating, 1-10"
    min: 0
    max: 10
    optional: true
  reviewer:
    type: String
    optional: true
  reviewerUntil:
    type: Date
    optional: true
  reviewed:
    type: Boolean
    optional: false
    autoValue: ->
      if @isInsert
        false
  reviewerDescription:
    type: String
    optional: true
    min: 0
    max: 500
  description:
    type: String
    label: "Description of the submission"
    min: 0
    max: 400
  matchid:
    type: Number
    label: "Match ID of the submission"
    min: 1000000000
    max: 9999999999
    denyUpdate: true
    unique: true
  matchtime:
    type: Number
    label: "Time of the event"
    min: 0
    max: 100000
  show:
    type: String
    label: "Show ID"
    index: true
#
  # 0: Submitted to replay server
  # 1: Being fetched by replay server
  # 2: Replay fetched, awaiting moderation
  # 3: Replay being reviewed
  # 4: Replay reviewed
  # 5: Replay invalid
  # 6: Reviewed already, replay file deleted
  status:
    type: Number
    label: "The status number of the submission"
    min: 0
    max: 6
    autoValue: ->
      if @isInsert
        0
  uid:
    type: String
    label: "The user ID of the submitter"
    index: true
    denyUpdate: true
    optional: true
  uname:
    type: String
    label: "The profile name of the submitter"
    denyUpdate: true
    optional: true
  createdAt:
    type: Date
    denyUpdate: true
    autoValue: ->
      if @isInsert
        new Date
      else if @isUpsert
        $setOnInsert: new Date
      else
        @unset()
        return
  hero_to_watch:
    type: String
    min: 3
    max: 20
    optional: true
  fetch_error:
    type: Number
    optional: true
  fetch_error_replay_state:
    type: String
    optional: true
  ingame_time:
    type: String
    optional: true

Submissions.attachSchema SubmissionSchema
