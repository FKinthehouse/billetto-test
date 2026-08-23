# frozen_string_literal: true

class VotesController < ApplicationController
  before_action :require_clerk_session!

  def create
    event = Event.find(params[:event_id])
    vote_type = params[:vote_type]

    unless %w[up down].include?(vote_type)
      redirect_to events_path, alert: "Invalid vote type"
      return
    end

    # Check if user already voted on this event
    existing_votes = EVENT_STORE.read
      .stream("EventVote$#{event.billetto_id}")
      .to_a
      .select { |e| e.data["user_id"] == current_user.id }

    if existing_votes.any?
      redirect_to events_path, alert: "You have already voted on this event"
      return
    end

    event_class = vote_type == "up" ? EventUpvoted : EventDownvoted

    EVENT_STORE.publish(
      event_class.new(data: {
        "event_id" => event.billetto_id,
        "user_id" => current_user.id
      }),
      stream_name: "EventVote$#{event.billetto_id}"
    )

    redirect_to events_path, notice: "Vote recorded!"
  end
end
