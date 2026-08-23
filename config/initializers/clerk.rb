# frozen_string_literal: true

Clerk.configure do |config|
  config.secret_key = ENV.fetch("CLERK_SECRET_KEY", "")
  config.publishable_key = ENV.fetch("CLERK_PUBLISHABLE_KEY", "")
end
