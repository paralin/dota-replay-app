ServiceConfiguration.configurations.remove service: "steam"
ServiceConfiguration.configurations.insert
    service: "steam"
    apiKey: process.env.STEAM_API_KEY
@api_secret = process.env.API_SECRET

@Config =
  maxConcurrentReview: process.env.DR_CONCURRENT_REVIEW || 5
  timeToReview: process.env.DR_REVIEW_TIME_MINS || 30
