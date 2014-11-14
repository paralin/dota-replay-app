Template.ShowSubmit.helpers
    "disabled": ->
      disabled = false
      subCount = Submissions.find {show: @_id, status: {$lt: 3}}
      count = subCount.count()
      not @submissionsOpen or count >= @maxSubmissions
Template.ShowSubmit.rendered = ->
    $(".form-horizontal")
        .bootstrapValidator
            message: "This value is not valid"
            feedbackIcons:
                valid: "fa fa-ok"
                invalid: "fa fa-ban"
                validating: "fa fa-refresh fa-spin"
            fields:
                name:
                    message: "This clip name is not valid."
                    validators:
                        notEmpty:
                            message: "Name is mandatory."
                        stringLength:
                            message: "Name must be between 5 and 30 characters."
                            max: 30
                            min: 5
                        regexp:
                            message: "Alphanumeric characters only please."
                            regexp: "^[a-zA-Z0-9_ ]*$"
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
                    Router.go "/shows/#{showId}"
                    swal
                        title: "Submission Complete"
                        text: "Your clip has been submitted. You can monitor its status."
                        type: "success"
            console.log data
            return
