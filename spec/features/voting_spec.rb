# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Voting on events", type: :feature do
  let!(:event) { create(:event, title: "Test Concert") }

  before do
    # Stub Clerk session for feature tests
    allow_any_instance_of(ApplicationController).to receive(:signed_in?).and_return(true)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(
      OpenStruct.new(id: "user_feature_test", first_name: "Test", email_address: "test@example.com")
    )
  end

  describe "viewing events" do
    it "displays events on the listing page" do
      visit root_path

      expect(page).to have_content("Test Concert")
      expect(page).to have_content("Upvote")
      expect(page).to have_content("Downvote")
    end

    it "shows vote counts starting at zero" do
      visit root_path

      expect(page).to have_content("Upvotes: 0")
      expect(page).to have_content("Downvotes: 0")
    end
  end

  describe "voting" do
    it "allows a user to upvote an event" do
      visit root_path

      click_button "Upvote"

      expect(page).to have_content("Vote recorded!")
      expect(page).to have_content("Upvotes: 1")
    end

    it "allows a user to downvote an event" do
      visit root_path

      click_button "Downvote"

      expect(page).to have_content("Vote recorded!")
      expect(page).to have_content("Downvotes: 1")
    end

    it "prevents duplicate votes" do
      visit root_path

      # First vote
      click_button "Upvote"
      expect(page).to have_content("Vote recorded!")

      # Second vote should be rejected
      click_button "Upvote"
      expect(page).to have_content("You have already voted on this event")
    end
  end
end
