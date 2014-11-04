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

Shows.attachSchema ShowSchema
