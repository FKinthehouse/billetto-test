class Event < ApplicationRecord
  validates :title, presence: true
  validates :date, presence: true
  validates :billetto_id, uniqueness: true, presence: true
end
