class EventUpvoted < RailsEventStore::Event
  SCHEMA = {
    type: "object",
    properties: {
      event_id: { type: "string" },
      user_id: { type: "string" },
      upvotes_count: { type: "integer" }
    },
    required: %w[event_id user_id upvotes_count]
  }.freeze
end
