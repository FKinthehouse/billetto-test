# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Event, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      event = build(:event)
      expect(event).to be_valid
    end

    it 'requires a title' do
      event = build(:event, title: nil)
      expect(event).not_to be_valid
      expect(event.errors[:title]).to include("can't be blank")
    end

    it 'requires a date' do
      event = build(:event, date: nil)
      expect(event).not_to be_valid
      expect(event.errors[:date]).to include("can't be blank")
    end

    it 'requires a billetto_id' do
      event = build(:event, billetto_id: nil)
      expect(event).not_to be_valid
      expect(event.errors[:billetto_id]).to include("can't be blank")
    end

    it 'requires unique billetto_id' do
      create(:event, billetto_id: 123)
      duplicate = build(:event, billetto_id: 123)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:billetto_id]).to include("has already been taken")
    end
  end

  describe 'vote_count association' do
    it 'can have a vote_count' do
      event = create(:event)
      vote_count = create(:vote_count, event: event, upvotes: 3, downvotes: 1)
      expect(event.reload.vote_count).to eq(vote_count)
    end

    it 'returns nil when no vote_count exists' do
      event = create(:event)
      expect(event.vote_count).to be_nil
    end
  end
end
