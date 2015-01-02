@enums =
  replayStatus:
    0: "In download queue..."
    1: "Replay downloading..."
    2: "Waiting for review..."
    3: "Currently being reviewed..."
    4: "Review complete."
    5: "Replay isn't available."
    6: "Invalid matchid."
    7: "Access denied to replay."
Template.registerHelper "replayStatus", (status)->
  enums.replayStatus[status]
