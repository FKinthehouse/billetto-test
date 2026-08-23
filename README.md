# Billetto Rails Test

A Ruby on Rails application that fetches and displays events from the [Billetto API](https://api.billetto.com/reference/list-public-events), with event-driven voting powered by [Rails Event Store](https://railseventstore.org/).

## Tech Stack

- **Ruby** 3.3.0
- **Rails** 7.2.3
- **PostgreSQL** 14
- **Rails Event Store** 3.0.0 — event-driven architecture for voting
- **RSpec** — testing framework
- **Clerk.com** — user authentication (planned)

## Architecture

This project follows Billetto's domain-driven design patterns:

```
app/
├── controllers/          # Thin controllers — parse params, delegate to services
│   └── events_controller.rb
├── domain/               # Business logic lives here
│   ├── billetto/         # 3rd party integration (ACL module)
│   │   ├── api.rb        # HTTP client for Billetto API
│   │   └── event_ingestor.rb  # Data ingestion service
│   └── events/           # Domain events for Rails Event Store
│       ├── event_upvoted.rb
│       └── event_downvoted.rb
├── models/
│   └── event.rb          # Event model with validations
└── views/
    └── events/           # Event listing and detail views
```

### Key Design Decisions

- **Service objects over fat controllers** — API integration and data ingestion are handled by `Billetto::Api` and `Billetto::EventIngestor`, keeping controllers thin
- **Rails Event Store for event-driven voting** — votes are recorded as domain events (`EventUpvoted`, `EventDownvoted`) rather than rows in a votes table, enabling audit trails and event replay
- **`app/domain/` for business logic** — separated from Rails conventions (controllers/models) following Billetto's module structure
- **Read models for vote counts** — async event handlers that pre-compute vote totals for fast reads

## Setup

### Prerequisites

- Ruby 3.3.0 (managed via rbenv)
- PostgreSQL 14+
- Billetto API credentials ([sign up here](https://api.billetto.com/reference/list-public-events))

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

Set your Billetto API credentials:

```bash
export BILLETTO_API_ID="your_api_id"
export BILLETTO_API_KEY="your_api_key"
```

Or add them to `config/credentials.yml.enc`:

```bash
EDITOR="code --wait" rails credentials:edit
```

```yaml
billetto:
  api_id: your_api_id
  api_key: your_api_key
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

## What's Implemented

- [x] Billetto API integration with error handling
- [x] Event data ingestion with deduplication
- [x] Events listing page (title, date, image, description)
- [x] Rails Event Store setup with domain events
- [ ] Voting feature (EventUpvoted / EventDownvoted)
- [ ] Vote count display
- [ ] Clerk.com authentication
- [ ] RSpec test suite

## Notes

- SSL verification is disabled for local development due to expired system certificates on macOS. In production, SSL verification should always be enabled.
- The Billetto API uses `Api-Keypair` header format: `api_id:api_secret`
- API documentation: https://api.billetto.com/reference/list-public-events
