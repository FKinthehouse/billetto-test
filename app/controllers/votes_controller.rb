# frozen_string_literal: true

class VotesController < ApplicationController
  def create
    event = Event.find(params[:event_id])
    vote_type = params[:vote_type]

    unless %w[up down].include?(vote_type)
      redirect_to events_path, alert: "Invalid vote type"
      return
    end

    event_class = vote_type == "up" ? EventUpvoted : EventDownvoted

    EVENT_STORE.publish(
      event_class.new(data: {
        "event_id" => event.billetto_id,
        "user_id" => 1 # TODO: Replace with Clerk auth user ID
      }),
      stream_name: "EventVote$#{event.billetto_id}"
    )

    redirect_to events_path, notice: "Vote recorded!"
  end
end
