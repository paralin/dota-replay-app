Template.registerHelper "replayStatus", ->
  0: "In download queue..."
  1: "Replay downloading..."
  2: "Waiting for review..."
  3: "Accepted for next show."
  4: "Declined for next show."
  5: "Replay isn't available."
  6: "Invalid match."
