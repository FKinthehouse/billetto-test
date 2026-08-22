class EventDownvoted < RailsEventStore::Event
  SCHEMA = {
    type: "object",
    properties: {
      event_id: { type: "string" },
      user_id: { type: "string" },
      downvotes_count: { type: "integer" }
    },
    required: %w[event_id user_id downvotes_count]
  }.freeze
end
