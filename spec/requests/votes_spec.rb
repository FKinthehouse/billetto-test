# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Votes", type: :request do
  let(:event) { create(:event) }

  describe "POST /events/:event_id/votes" do
    context "when user is not signed in" do
      it "redirects to Clerk sign-in" do
        post event_votes_path(event, vote_type: "up")
        expect(response).to have_http_status(:redirect)
        expect(response.location).to include("accounts.dev/sign-in")
      end

      it "does not create a vote event" do
        expect {
          post event_votes_path(event, vote_type: "up")
        }.not_to change { EVENT_STORE.read.count }
      end
    end

    context "when user is signed in" do
      before do
        # Stub Clerk session for authenticated requests
        allow_any_instance_of(ApplicationController).to receive(:signed_in?).and_return(true)
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(
          OpenStruct.new(id: "user_test123", first_name: "Test")
        )
      end

      it "creates an EventUpvoted event when vote_type is up" do
        expect {
          post event_votes_path(event, vote_type: "up")
        }.to change { EVENT_STORE.read.count }.by(1)

        expect(response).to redirect_to(events_path)
      end

      it "creates an EventDownvoted event when vote_type is down" do
        expect {
          post event_votes_path(event, vote_type: "down")
        }.to change { EVENT_STORE.read.count }.by(1)
      end

      it "prevents duplicate votes from the same user" do
        # First vote succeeds
        post event_votes_path(event, vote_type: "up")

        # Second vote is rejected
        expect {
          post event_votes_path(event, vote_type: "up")
        }.not_to change { EVENT_STORE.read.count }

        expect(response).to redirect_to(events_path)
      end

      it "rejects invalid vote types" do
        post event_votes_path(event, vote_type: "invalid")
        expect(response).to redirect_to(events_path)
      end
    end
  end
end
