# frozen_string_literal: true

# Create a single EventStore client for the entire application
EVENT_STORE = RailsEventStore::Client.new

Rails.application.config.after_initialize do
  # Subscribe the VoteCountHandler to vote events
  EVENT_STORE.subscribe(
    Voting::VoteCountHandler.new,
    to: ["EventUpvoted", "EventDownvoted"]
  )
end
