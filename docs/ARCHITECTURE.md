# ProductPlanner Architecture

## System Overview

ProductPlanner is a Rails 8 application implementing an 8-stage product development process with Kanban visualization, OKR tracking, and gate enforcement.

```
┌─────────────────────────────────────────────────────────────────┐
│                         Browser                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ Turbo Drive (page navigation) + Turbo Frames (partials) │   │
│  │ Stimulus Controllers (interactivity)                    │   │
│  └─────────────────────────────────────────────────────────┘   │
└───────────────────────────┬─────────────────────────────────────┘
                            │ HTTP/WebSocket
┌───────────────────────────▼─────────────────────────────────────┐
│                      Rails 8 Application                         │
│  ┌──────────────────┐  ┌──────────────────┐  ┌───────────────┐ │
│  │   Controllers    │  │     Models       │  │    Views      │ │
│  │  (REST + Turbo)  │  │  (ActiveRecord)  │  │ (ERB + Turbo) │ │
│  └────────┬─────────┘  └────────┬─────────┘  └───────────────┘ │
│           │                     │                               │
│  ┌────────▼─────────────────────▼───────────────────────────┐  │
│  │                    PostgreSQL                             │  │
│  │  Cards, Objectives, KeyResults, Activities, etc.          │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Domain Model

### Core Entities Diagram

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│    User     │────<│  Membership │>────│   Product   │
└─────────────┘     └─────────────┘     └──────┬──────┘
      │                                        │
      │ owns                                   │ has_many
      ▼                                        ▼
┌─────────────┐                         ┌─────────────┐
│    Card     │<────────────────────────│  Objective  │
└──────┬──────┘                         └──────┬──────┘
       │                                       │
       │ has_many                              │ has_many
       ▼                                       ▼
┌─────────────┐  ┌─────────────┐       ┌─────────────┐
│  Scenario   │  │   Comment   │       │  KeyResult  │
└─────────────┘  └─────────────┘       └──────┬──────┘
       │                                       │
       │                          ┌────────────┘
       │                          │
       ▼                          ▼
┌─────────────┐            ┌──────────────┐
│  Activity   │            │CardKeyResult │
└─────────────┘            └──────────────┘
```

### Key Relationships

- **Product** has many Cards, Objectives, Memberships
- **Card** belongs to Product, Owner (User), has many Scenarios, Comments, Activities
- **Card** has many KeyResults through CardKeyResult (OKR linkage)
- **Objective** can be company-level (product_id: null) or product-level
- **Activity** is polymorphic (trackable: Card, etc.)

---

## Data Flow

### Card Stage Transition

```
User drags card
       │
       ▼
┌──────────────────┐
│ kanban_controller│  (Stimulus)
│    .js drag()    │
└────────┬─────────┘
         │ PATCH /products/:slug/cards/:id/move
         ▼
┌──────────────────┐
│ CardsController  │
│    #move         │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐    ┌──────────────────┐
│ Card#can_advance?│───>│ Return warning   │ (if gates incomplete)
└────────┬─────────┘    │ with force option│
         │ (gates ok)   └──────────────────┘
         ▼
┌──────────────────┐
│ Card.update!     │
│ Activity.create! │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ Turbo Stream     │
│ response         │
└────────┬─────────┘
         │
         ▼
Browser updates card position
```

### Gate Toggle

```
User clicks checkbox
       │
       ▼
┌────────────────────────┐
│ gate_checklist_controller│ (Stimulus)
│         .js toggle()     │
└────────────┬─────────────┘
             │ PATCH /products/:slug/cards/:id/toggle_gate
             ▼
┌──────────────────┐
│ CardsController  │
│  #toggle_gate    │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ Card.gate_checklist │
│ [stage][gate] = val │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ Turbo Stream     │
│ replace progress │
└──────────────────┘
```

---

## File Organization

```
app/
├── controllers/
│   ├── application_controller.rb
│   ├── cards_controller.rb          # CRUD + move + toggle_gate
│   ├── card_key_results_controller.rb
│   ├── comments_controller.rb
│   ├── home_controller.rb
│   ├── key_results_controller.rb
│   ├── objectives_controller.rb     # Company OKRs
│   ├── product_objectives_controller.rb
│   ├── products_controller.rb
│   └── scenarios_controller.rb
│
├── models/
│   ├── activity.rb
│   ├── card.rb                      # Core: stages, gates, types
│   ├── card_key_result.rb
│   ├── comment.rb
│   ├── key_result.rb
│   ├── membership.rb
│   ├── objective.rb
│   ├── product.rb
│   ├── scenario.rb
│   ├── user.rb
│   └── concerns/
│       └── trackable.rb             # Auto activity logging
│
├── views/
│   ├── activities/
│   │   └── _activity.html.erb
│   ├── cards/
│   │   ├── _card.html.erb           # Kanban card
│   │   ├── _form.html.erb
│   │   ├── _gate_progress.html.erb
│   │   ├── _metadata_display.html.erb
│   │   ├── _metadata_fields.html.erb
│   │   ├── edit.html.erb
│   │   ├── new.html.erb
│   │   └── show.html.erb            # Card detail slide-over
│   ├── card_key_results/
│   ├── comments/
│   ├── key_results/
│   ├── objectives/
│   ├── products/
│   │   ├── index.html.erb
│   │   └── show.html.erb            # Kanban board
│   └── scenarios/
│
├── javascript/
│   └── controllers/
│       ├── application.js
│       ├── card_type_controller.js   # Show/hide metadata fields
│       ├── gate_checklist_controller.js
│       ├── kanban_controller.js      # Drag-drop
│       └── key_result_controller.js  # Progress increment
│
features/                             # Cucumber BDD
├── activity_tracking.feature
├── card_drag_drop.feature
├── cards.feature
├── gate_checklist.feature
├── kanban_board.feature
├── okr_integration.feature
├── scenarios.feature
├── step_definitions/
└── support/
    └── env.rb
```

---

## Key Design Decisions

### 1. Single Card Model with JSONB

Instead of separate models for each card type (Opportunity, Feature, Task, Issue, JTBD), we use a single Card model with:
- `card_type` enum for type classification
- `metadata` JSONB for type-specific fields

**Rationale:** Simpler schema, easier to add new types, all cards share the stage workflow.

### 2. Gate Checklist in JSONB

Gates are stored as `gate_checklist: { stage: { gate: boolean } }` rather than a separate GateCompletion model.

**Rationale:** Atomic updates, no N+1 queries, all gate state in one column.

### 3. Auto-Gates

Some gates verify themselves from data:
```ruby
AUTO_GATES = {
  okr_linked: ->(card) { card.card_key_results.any? },
  scenarios_exist: ->(card) { card.scenarios.any? },
  okr_impact_measured: ->(card) { card.all_impacts_recorded? }
}
```

**Rationale:** Reduces manual checkbox clicking, ensures data integrity.

### 4. Hotwire for Reactivity

Using Turbo Streams and Stimulus instead of a JavaScript framework:
- Turbo Drive: SPA-like navigation
- Turbo Frames: Partial page updates (modals, slide-overs)
- Turbo Streams: Real-time updates (gate progress, activities)
- Stimulus: Progressive enhancement (drag-drop, toggles)

**Rationale:** Rails-native, less JavaScript, server-rendered HTML.

### 5. Activity Tracking via Concern

The `Trackable` concern automatically creates Activity records:
```ruby
module Trackable
  included do
    has_many :activities, as: :trackable
    after_create :track_creation
    after_update :track_changes
  end
end
```

**Rationale:** DRY, consistent audit trail, no forgetting to log.

---

## Database Schema

### Key Tables

```sql
-- Cards with stages and gates
CREATE TABLE cards (
  id SERIAL PRIMARY KEY,
  product_id INTEGER REFERENCES products,
  owner_id INTEGER REFERENCES users,
  card_type INTEGER,           -- enum
  title VARCHAR NOT NULL,
  description TEXT,
  stage INTEGER,               -- enum (0-8)
  priority INTEGER,            -- enum
  position INTEGER,            -- acts_as_list
  metadata JSONB DEFAULT '{}', -- type-specific
  gate_checklist JSONB,        -- stage -> gate -> bool
  parent_id INTEGER REFERENCES cards
);

-- OKRs with company/product scope
CREATE TABLE objectives (
  id SERIAL PRIMARY KEY,
  product_id INTEGER REFERENCES products, -- NULL = company-level
  title VARCHAR NOT NULL,
  description TEXT,
  period VARCHAR NOT NULL,     -- "2026-Q1"
  status INTEGER DEFAULT 0     -- enum
);

-- Key Results with progress tracking
CREATE TABLE key_results (
  id SERIAL PRIMARY KEY,
  objective_id INTEGER REFERENCES objectives,
  title VARCHAR NOT NULL,
  target_value DECIMAL(10,2),
  current_value DECIMAL(10,2),
  unit VARCHAR,
  status INTEGER DEFAULT 0
);

-- Card-to-KeyResult linkage with impact
CREATE TABLE card_key_results (
  id SERIAL PRIMARY KEY,
  card_id INTEGER REFERENCES cards,
  key_result_id INTEGER REFERENCES key_results,
  expected_impact TEXT,
  actual_impact TEXT,
  UNIQUE(card_id, key_result_id)
);

-- Polymorphic activity log
CREATE TABLE activities (
  id SERIAL PRIMARY KEY,
  trackable_type VARCHAR,
  trackable_id INTEGER,
  user_id INTEGER REFERENCES users,
  action VARCHAR,
  change_data JSONB,
  created_at TIMESTAMP
);
```

### Key Indexes

```sql
CREATE INDEX idx_cards_product_stage ON cards(product_id, stage, position);
CREATE INDEX idx_activities_trackable ON activities(trackable_type, trackable_id);
CREATE INDEX idx_objectives_period ON objectives(period);
```

---

## API Endpoints

### Cards
```
GET    /products/:slug/cards/:id          # Show
POST   /products/:slug/cards              # Create
PATCH  /products/:slug/cards/:id          # Update
DELETE /products/:slug/cards/:id          # Destroy
PATCH  /products/:slug/cards/:id/move     # Stage transition
PATCH  /products/:slug/cards/:id/toggle_gate
```

### OKRs
```
GET    /objectives                        # Company OKRs
POST   /objectives                        # Create company
PATCH  /objectives/:id                    # Update
DELETE /objectives/:id                    # Destroy
GET    /products/:slug/objectives         # Product OKRs
POST   /products/:slug/objectives         # Create product

POST   /objectives/:id/key_results        # Add KR
PATCH  /objectives/:id/key_results/:id/update_progress
```

### Card-KR Linking
```
POST   /products/:slug/cards/:id/key_results     # Link
PATCH  /products/:slug/cards/:id/key_results/:id # Update impact
DELETE /products/:slug/cards/:id/key_results/:id # Unlink
```

---

## Testing Strategy

### Cucumber (BDD)
Feature files define acceptance criteria in Gherkin:
```gherkin
Scenario: Move card with incomplete gates shows warning
  Given a card "Feature X" exists in "Opportunity" stage
  And the gate "named_customer" is incomplete
  When I drag "Feature X" to "Discovery"
  Then I should see a confirmation dialog
```

### Unit Tests (future)
- Model validations and methods
- Gate completion logic
- OKR progress calculations

### Integration Tests (future)
- Controller actions
- Turbo Stream responses
- Full user flows

---

## Future Considerations

### Scaling
- Card table partitioning by product
- Activity archival to cold storage
- Redis caching for Kanban board

### Multi-tenancy
- Add Organization model
- Scope all queries with `acts_as_tenant`
- Subdomain routing

### External Integrations
- GitHub: OAuth + webhook + API
- Shortcut/Linear: Similar pattern
- Bi-directional sync with conflict resolution
