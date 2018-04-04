Template.ShowSubmit.helpers
  "disabled": ->
    not @submissionsOpen
Template.ShowSubmit.rendered = ->
  $(".form-horizontal")
    .bootstrapValidator
      message: "This value is not valid"
      feedbackIcons:
        valid: "fab fa-ok"
        invalid: "fab fa-ban"
        validating: "fab fa-refresh fa-spin"
      fields:
        description:
          message: "This field is not valid."
          validators:
            notEmpty:
              message: "Description is mandatory."
            stringLength:
              message: "Description must be between 5 and 130 characters."
              max: 130
              min: 5
            regexp:
              message: "Alphanumeric characters only please."
              regexp: "^[a-zA-Z0-9_ ]*$"
        hero_to_watch:
          message: "This field is not valid."
          validators:
            stringLength:
              message: "Hero to watch must be between 0 and 20 characters."
              max: 20
              min: 0
            regexp:
              message: "Alphanumeric characters only please."
              regexp: "^[a-zA-Z ]*$"
        matchid:
          message: "This field is not valid."
          validators:
            notEmpty:
              message: "Match ID is mandatory."
            integer:
              message: "Match ID must be an integer."
            between:
              min: 1000000000
              max: 9999999999
              message: "Match ID is invalid."
    .on "success.form.bv", (e) ->
      # Prevent form submission
      e.preventDefault()
      # Get the form instance
      window.form = $form = $(e.target)
      # Get the BootstrapValidator instance
      bv = $form.data("bootstrapValidator")
      showId = Router.current().params._id
      console.log showId

      data =
        status: 0
        show: showId
        episode: 1
        uid: Meteor.userId()
        uname: Meteor.user().profile.name
        matchtime: 0

      dataa = $form.serializeArray()
      for da in dataa
        data[da.name] = da.value
      data.matchid = parseInt data.matchid
      Submissions.insert data, (err, res)->
        if err?
          console.log err
          swal
            title: "Problem Submitting"
            text: err.message
            type: "error"
        else
          Router.go "/submissions/#{showId}"
          swal
            title: "Submission Complete"
            text: "Your clip has been submitted. You can monitor its status."
            type: "success"
      console.log data
      return
