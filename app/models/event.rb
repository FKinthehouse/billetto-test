# frozen_string_literal: true

class Event < ApplicationRecord
  validates :title, presence: true
  validates :date, presence: true
  validates :billetto_id, uniqueness: true, presence: true

  has_one :vote_count, foreign_key: "event_id", primary_key: "billetto_id"
end
