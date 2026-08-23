# frozen_string_literal: true

class SessionsController < ApplicationController
  #I am using sessions controller to handle the sign out process. I am deleting the cookies and resetting the session to ensure that the user is signed out properly.
  def destroy
    cookies.delete("__session", domain: :all)
    cookies.delete("__client_uat", domain: :all)
    reset_session
    redirect_to root_path, notice: "Signed out successfully"
  end
end
