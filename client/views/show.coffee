Template.ShowDetail.helpers
    "submissions": ->
        Submissions.find({uid: Meteor.userId(), show: @_id}).fetch()
    "stringify": (obj)->
        JSON.stringify obj
