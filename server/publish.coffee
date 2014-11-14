Meteor.publish null, ->
  Meteor.roles.find {}

Meteor.publishComposite "clientdata", ->
  find: ->
    Shows.find()
  children: [
    {
      find: (show)->
        Submissions.find
          show: show._id
          uid: @userId
    }
  ]
