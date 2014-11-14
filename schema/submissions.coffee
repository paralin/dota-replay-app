@Submissions = new Mongo.Collection "submissions"

SubmissionSchema = new SimpleSchema
    name:
        type: String
        label: "Name of the submission"
        min: 5
        max: 30
    description:
        type: String
        label: "Description of the submission"
        min: 5
        max: 130
    matchid:
        type: Number
        label: "Match ID of the submission"
        min: 1000000000
        max: 9999999999
        denyUpdate: true
    show:
        type: String
        label: "Show ID"
        index: true
    episode:
        type: Number
        label: "Optional episode # it was used in"
    #
    # 0: Submitted to replay server
    # 1: Being fetched by replay server
    # 2: Replay fetched, awaiting moderation
    # 3: Replay declined
    # 4: Replay accepted
    # 5: Replay invalid
    # 6: Match ID already used
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
Submissions.attachSchema SubmissionSchema
