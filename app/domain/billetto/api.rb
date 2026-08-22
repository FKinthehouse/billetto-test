#frozen_string_literal: true
require 'uri'
require 'net/http'

module Billetto
  class Api
    BASE_URL = "https://billetto.dk/api/v3".freeze
    def initialize
      @api_key = ENV.fetch("BILLETTO_API_KEY")
      @api_id = ENV.fetch("BILLETTO_API_ID")
    end

    def fetch_events(limit:10)
      url = URI(BASE_URL + "/public/events?limit=#{limit}")

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      # Disable SSL verification as my certs are expired so workaround it for now. In production, you should not disable SSL verification.
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Get.new(url)
      request["accept"] = 'application/json'
      request["Api-Keypair"] = "#{@api_id}:#{@api_key}"
      byebug
      response = http.request(request)
      handle_response(response)
    end

    private

    def handle_response(response)
      case response.code.to_i
      when 200..299
        JSON.parse(response.body.force_encoding("UTF-8"))
      when 401
        raise "Unauthorized: Invalid API credentials"
      when 429
        raise "Rate limit exceeded: Too many requests"
      else
        raise "Billetto API error: #{response.code}"
      end
    end
  end
end
