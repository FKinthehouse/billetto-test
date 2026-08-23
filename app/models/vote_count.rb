class VoteCount < ApplicationRecord
  belongs_to :event, foreign_key: "event_id", primary_key: "billetto_id", optional: true
end
