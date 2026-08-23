# Billetto Rails Test

A Ruby on Rails application that fetches and displays events from the [Billetto API](https://api.billetto.com/reference/list-public-events), with event-driven voting powered by [Rails Event Store](https://railseventstore.org/) and user authentication via [Clerk.com](https://clerk.com/).

## Tech Stack

- **Ruby** 3.3.0
- **Rails** 7.2.3
- **PostgreSQL** 14
- **Rails Event Store** 3.0.0 — event-driven architecture for voting
- **Clerk.com** — user authentication
- **RSpec** + **Capybara** — testing framework
- **FactoryBot** — test factories

## Architecture

This project follows Billetto's domain-driven design patterns:

```
app/
├── controllers/                    # Thin controllers — parse params, delegate to services
│   ├── application_controller.rb   # Clerk auth helpers, session management
│   ├── events_controller.rb        # Public events listing
│   ├── sessions_controller.rb      # Sign-out handler
│   └── votes_controller.rb         # Auth-protected voting
├── domain/                         # Business logic (separated from Rails conventions)
│   ├── billetto/                   # 3rd party integration (ACL module)
│   │   ├── api.rb                  # HTTP client for Billetto API
│   │   └── event_ingestor.rb       # Data ingestion service
│   ├── event_upvoted.rb            # Domain event for upvotes
│   ├── event_downvoted.rb          # Domain event for downvotes
│   └── voting/
│       └── vote_count_handler.rb   # Read model — updates vote counts async
├── models/
│   ├── event.rb                    # Event model with validations
│   └── vote_count.rb              # Cached vote totals (read model table)
└── views/
    └── events/                     # Event listing with vote buttons
```

### Key Design Decisions

- **Service objects over fat controllers** — API integration (`Billetto::Api`) and data ingestion (`Billetto::EventIngestor`) are isolated in `app/domain/`, keeping controllers thin
- **Rails Event Store for event-driven voting** — votes are recorded as domain events (`EventUpvoted`, `EventDownvoted`) rather than rows in a votes table, enabling audit trails and event replay
- **`app/domain/` for business logic** — separated from Rails conventions following Billetto's module structure
- **Read models for vote counts** — `VoteCountHandler` subscribes to vote events and pre-computes totals in a `vote_counts` table for fast reads
- **Duplicate vote prevention** — application-level check reads the stream before publishing to prevent same-user double-votes
- **Clerk.com for authentication** — hosted sign-in/sign-up pages, Rack middleware for session verification, votes restricted to authenticated users

## Setup

### Prerequisites

- Ruby 3.3.0 (managed via rbenv)
- PostgreSQL 14+
- Billetto API credentials ([sign up here](https://api.billetto.com/reference/list-public-events))
- Clerk.com account ([sign up here](https://clerk.com))

### Installation

```bash
# Clone the repository
git clone <your-repo-url>
cd billetto_test

# Install dependencies
bundle install

# Set up database
rails db:create
rails db:migrate

# Generate Rails Event Store tables
bin/rails generate ruby_event_store:active_record:migration
rails db:migrate
```

### Environment Variables

Set your API credentials:

```bash
# Billetto API
export BILLETTO_API_ID="your_api_id"
export BILLETTO_API_KEY="your_api_key"

# Clerk Authentication
export CLERK_SECRET_KEY="sk_test_..."
export CLERK_PUBLISHABLE_KEY="pk_test_..."
export CLERK_SIGN_IN_URL="https://your-app.clerk.accounts.dev/sign-in"
export CLERK_SIGN_UP_URL="https://your-app.clerk.accounts.dev/sign_up"
export CLERK_SIGN_OUT_URL="https://your-app.clerk.accounts.dev/sign-out"
```

### Ingesting Events

Open the Rails console and run:

```ruby
bin/rails console
Billetto::EventIngestor.new(limit: 20).call
```

### Running the App

```bash
bin/rails server
```

Visit [http://localhost:3000](http://localhost:3000) to see the events listing.

## Testing

```bash
bundle exec rspec
```

### Test Coverage

| Category | File | Tests | What it covers |
|----------|------|-------|----------------|
| Model | `spec/models/event_spec.rb` | 7 | Title/date/billetto_id validations, associations |
| Model | `spec/models/vote_count_spec.rb` | 2 | Event association, default values |
| Request | `spec/requests/votes_spec.rb` | 6 | Auth redirect, vote creation, duplicate prevention |
| Event Store | `spec/domain/voting/vote_count_handler_spec.rb` | 6 | Handler creates/increments upvotes and downvotes |
| Feature | `spec/features/voting_spec.rb` | 5 | Browse events, upvote, downvote, duplicate rejection |

## What's Implemented

- [x] Billetto API integration with error handling
- [x] Event data ingestion with deduplication
- [x] Events listing page (title, date, image, description)
- [x] Rails Event Store setup with domain events (EventUpvoted, EventDownvoted)
- [x] Voting feature with stream-based event storage
- [x] Vote count display via read model (VoteCountHandler)
- [x] Clerk.com authentication (sign-in, sign-out, session management)
- [x] Voting restricted to authenticated users
- [x] Duplicate vote prevention per user per event
- [x] RSpec test suite (24 examples, 0 failures)

## Design Choices & Assumptions

1. **Events are publicly viewable** — only voting requires authentication, as the assignment focuses on restricting voting functionality
2. **One vote per user per event** — enforced at the application level by reading the stream before publishing
3. **Read model for performance** — vote counts are pre-computed in a `vote_counts` table rather than counting events on every page load
4. **SSL verification disabled locally** — due to macOS LibreSSL certificate issues; should be enabled in production
5. **Clerk hosted pages** — used for sign-in/sign-up UI rather than embedded components, keeping frontend simple per assignment guidelines

## Notes

- The Billetto API uses `Api-Keypair` header format: `api_id:api_secret`
- API documentation: https://api.billetto.com/reference/list-public-events
- Rails Event Store documentation: https://railseventstore.org/
- Clerk Ruby SDK documentation: https://clerk.com/docs/reference/ruby/rails
