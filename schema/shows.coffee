@Shows = new Mongo.Collection "shows"

ShowSchema = new SimpleSchema
    name:
        type: String
        label: "Name"
        max: 200
    thumbnail:
        type: String
        label: "Thumbnail of show"
    description:
        type: String
        label: "Description"
        min: 10
    requirements:
        type: [String]
        label: "Requirements for submissions"
    submissionsOpen:
        type: Boolean
        label: "Are submissions allowed for the current episode?"
    episode:
        type: Number
        label: "The current episode for submissions"
    maxSubmissions:
      type: Number
      label: "Maximum number of allowed open submissions"
    createdAt:
      type: Date
      autoValue: ->
        if @isInsert
          new Date
        else if @isUpsert
          $setOnInsert: new Date
        else
          @unset()
        return

Shows.attachSchema ShowSchema
