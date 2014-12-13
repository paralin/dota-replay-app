Token
=====

Every request has a `token` field that is `sha256(data + secret)`.

Submissions
==========

### POST -> `/api/submissions/create`

To make a submission submit the following data (shown here in JSON). Please note that the contents of these fields are simply the value, not the min/max values. These are just there to show you the properties used to store the data in the database.

```json
    {
       "name":{
          "label":"Name of the submission",
          "min":5,
          "max":30
       },
       "description":{
          "label":"Description of the submission",
          "min":5,
          "max":130
       },
       "matchid":{
          "label":"Match ID of the submission",
          "min":1000000000,
          "max":9999999999,
          "unique":true
       },
       "show":{
          "label":"Show ID",
          "index":true
       },
       "uid":{
          "label":"The user ID of the submitter",
          "index":true,
          "denyUpdate":true
       }
    }
```

Token is required. All but matchid are strings.

### POST -> `/api/submissions/list`

Lists all submissions in the system. Token is required.

### GET -> `/api/submissions/id/:id`

Token is required. Returns information about a specific submission.

### GET -> `/api/submissions/user/:id`

Token is required. Returns information about all submissions from a user.

### GET -> `/api/submissions/matchid/:id`

Token is required. Returns information about a submission from a match ID.


### Dealing with Errors

The return object will always look like this:

```json
    {"error": "This is the error reason.", "status": 404, "data": {}}
```

The `error` field will have the error text. This could be null.

The `status` field will be the HTTP status.

The data will be an array, object, or null, depending on the API method.
