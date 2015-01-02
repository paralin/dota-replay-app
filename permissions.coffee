@Permissions = new OrbitPermissions.Registrar "dr"
# Permissions
Permissions
  .definePermission "view-shows",
    en:
      summary: "View show list."
      name: "View Shows"
  .definePermission "set-show",
    en:
      summary: "Set the show for a submission."
      name: "Set Show"
  .definePermission "delete-submission", 
    en:
      summary: "Delete a submission."
      name: "Delete Submission"
  .definePermission "create-submission",
    en:
      summary: "Create a submission."
      name: "Create Submission"
  .definePermission "retry-submission",
    en:
      summary: "Retry a failed submission."
      name: "Retry Submission"
  .definePermission "set-submissions-enabled",
    en:
      summary: "Set submissions for a show enabled."
      name: "Set Submissions Enabled"
  .definePermission "download-replay",
    en:
      summary: "Download an expired replay from the server."
      name: "Download Replay"
  .definePermission "view-submissions",
    en:
      summary: "View submission list."
      name: "View Submissions"
  .definePermission "review-submissions",
    en:
      summary: "Review submissions."
      name: "Review Submissions"
  .defineRole "producer", [ #All but delete-submission
    "view-shows"
    "view-submissions"
    "download-replay"
    "set-submissions-enabled"
    "retry-submission"
    "create-submission"
    "set-show"
    "review-submissions"
  ]
  .defineRole "review", [
    "review-submissions"
    "view-shows"
    "download-replay"
  ]
