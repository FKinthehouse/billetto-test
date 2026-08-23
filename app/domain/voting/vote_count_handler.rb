# frozen_string_literal: true

module Voting
  class VoteCountHandler
    def call(event)
      event_id = event.data.fetch("event_id")
      vote_count = VoteCount.find_or_create_by!(event_id: event_id)

      case event
      when EventUpvoted
        vote_count.increment!(:upvotes)
      when EventDownvoted
        vote_count.increment!(:downvotes)
      end
    end
  end
end
