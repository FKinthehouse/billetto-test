# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VoteCount, type: :model do
  describe 'associations' do
    it 'belongs to an event' do
      event = create(:event)
      vote_count = create(:vote_count, event: event)
      expect(vote_count.event).to eq(event)
    end
  end

  describe 'defaults' do
    it 'defaults upvotes and downvotes to 0' do
      vote_count = create(:vote_count)
      expect(vote_count.upvotes).to eq(0)
      expect(vote_count.downvotes).to eq(0)
    end
  end
end
