# frozen_string_literal: true

module Billetto
  class EventIngestor
    def initialize(api: default_api, limit: 10)
      @api = api
      @limit = limit
    end

    def call
      raw_events = @api.fetch_events(limit: @limit)
      raw_events&.dig("data").each { |raw_event| process_event(raw_event) }
    end

    private

    def process_event(raw_event)
      return unless raw_event

      Event.find_or_create_by(billetto_id: raw_event["id"]) do |event|
        event.title = raw_event["title"]
        event.date = raw_event["startdate"]
        event.description = raw_event["description"]
        event.image_link = raw_event["image_link"]
      end
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error("Failed to process event with Billetto ID #{raw_event['id']}: #{e.message}")
    end

    def default_api
      @default_api ||= Billetto::Api.new
    end
  end
end
