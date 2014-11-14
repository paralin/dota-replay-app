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
