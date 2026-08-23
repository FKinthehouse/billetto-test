# frozen_string_literal: true

class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  include Clerk::Authenticatable

  helper_method :current_user, :signed_in?

  private

  def current_user
    clerk.user if clerk.session
  end

  def signed_in?
    !!clerk.session
  end

  def require_clerk_session!
    unless signed_in?
      redirect_to clerk.sign_in_url, allow_other_host: true, alert: "You must be signed in to access this page."
    end
  end
end
