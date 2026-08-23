# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Voting::VoteCountHandler do
  let(:handler) { described_class.new }

  describe '#call' do
    context 'with EventUpvoted' do
      it 'creates a VoteCount record when none exists' do
        event = create(:event)
        vote_event = EventUpvoted.new(data: { "event_id" => event.billetto_id, "user_id" => "user_1" })

        expect {
          handler.call(vote_event)
        }.to change { VoteCount.count }.by(1)

        vote_count = VoteCount.find_by(event_id: event.billetto_id)
        expect(vote_count.upvotes).to eq(1)
        expect(vote_count.downvotes).to eq(0)
      end

      it 'increments upvotes on existing VoteCount' do
        event = create(:event)
        create(:vote_count, event: event, upvotes: 2, downvotes: 0)

        vote_event = EventUpvoted.new(data: { "event_id" => event.billetto_id, "user_id" => "user_1" })
        handler.call(vote_event)

        expect(event.reload.vote_count.upvotes).to eq(3)
      end
    end

    context 'with EventDownvoted' do
      it 'creates a VoteCount record when none exists' do
        event = create(:event)
        vote_event = EventDownvoted.new(data: { "event_id" => event.billetto_id, "user_id" => "user_1" })

        expect {
          handler.call(vote_event)
        }.to change { VoteCount.count }.by(1)

        vote_count = VoteCount.find_by(event_id: event.billetto_id)
        expect(vote_count.downvotes).to eq(1)
        expect(vote_count.upvotes).to eq(0)
      end

      it 'increments downvotes on existing VoteCount' do
        event = create(:event)
        create(:vote_count, event: event, upvotes: 0, downvotes: 3)

        vote_event = EventDownvoted.new(data: { "event_id" => event.billetto_id, "user_id" => "user_1" })
        handler.call(vote_event)

        expect(event.reload.vote_count.downvotes).to eq(4)
      end
    end
  end
end
