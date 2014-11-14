Template.submissionList.helpers
    "hasSubmissions": ->
        @? && @.length > 0
    "submissionCount": ->
        @.length
    "acceptedCount": ->
        0
    "rowClass": ->
        if @status >= 4
            "danger"
        else if @status == 1
            "info"
        else if @status == 2
            "active"
        else if @status == 4
            "warning"
    "iconClass": ->
        if @status is 0
            "fa fa-circle-o-notch fa-spin"
        else if @status is 1
            "fa fa-download"
        else if @status is 2
            "fa fa-send"
        else if @status is 3
            "fa fa-check"
        else if @status is 4
            "fa fa-trash"
        else
            "fa fa-exclamation-triangle"
