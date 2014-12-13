ServiceConfiguration.configurations.remove service: "steam"
ServiceConfiguration.configurations.insert
    service: "steam"
    apiKey: process.env.STEAM_API_KEY
@api_secret = process.env.API_SECRET
