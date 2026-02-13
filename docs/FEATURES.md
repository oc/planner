# ProductPlanner Features

This document describes all implemented features with their business value, acceptance criteria, and technical implementation details.

---

## Feature Index

| Feature | OKR | GitHub Issue | Cucumber Feature |
|---------|-----|--------------|------------------|
| [Kanban Board](#kanban-board) | Ship MVP | [#5](https://github.com/oc/planner/issues/5) | `kanban_board.feature` |
| [Card Drag-Drop](#card-drag-drop) | Ship MVP | [#6](https://github.com/oc/planner/issues/6) | `card_drag_drop.feature` |
| [Gate Checklist](#gate-checklist) | Ship MVP | [#7](https://github.com/oc/planner/issues/7) | `gate_checklist.feature` |
| [Scenarios](#scenarios) | Ship MVP | [#8](https://github.com/oc/planner/issues/8) | `scenarios.feature` |
| [OKR Integration](#okr-integration) | Ship MVP | [#9](https://github.com/oc/planner/issues/9) | `okr_integration.feature` |
| [Activity Tracking](#activity-tracking) | Ship MVP | [#10](https://github.com/oc/planner/issues/10) | `activity_tracking.feature` |
| [Cards CRUD](#cards-crud) | Ship MVP | [#11](https://github.com/oc/planner/issues/11) | `cards.feature` |

---

## Kanban Board

### Business Value
Visualize the entire product pipeline to identify bottlenecks and track progress through the 8-stage product process.

### Key Result
- Functional Kanban board with 8-stage workflow (100%)

### Acceptance Scenarios
1. **View cards by stage** - Cards appear in their respective stage columns
2. **Card type styling** - Each card type has distinct color indicator
3. **Gate progress** - Cards show completion status (e.g., "2/4")
4. **Navigate to detail** - Click card to open slide-over

### Technical Implementation
```
Controller: ProductsController#show
View: app/views/products/show.html.erb
Stimulus: app/javascript/controllers/kanban_controller.js
Partial: app/views/cards/_card.html.erb
```

### Stage Columns
```
Opportunity → Discovery → Definition → Feasibility →
Commitment → Build → Validate → Operate → Done
```

---

## Card Drag-Drop

### Business Value
Allow intuitive progress tracking by moving cards through the workflow with gate enforcement.

### Key Results
- Functional Kanban board with 8-stage workflow
- Gate enforcement at each stage transition

### Acceptance Scenarios
1. **Move with complete gates** - Card moves without warning
2. **Warning on incomplete gates** - Confirmation dialog with incomplete gates listed
3. **Confirm despite warning** - Move proceeds after acknowledgment
4. **Cancel on warning** - Card stays in original position
5. **Move backward** - Always succeeds (no gate check)
6. **Reorder within stage** - Position updates via drag

### Technical Implementation
```
Stimulus: app/javascript/controllers/kanban_controller.js
API: PATCH /products/:slug/cards/:id/move
Controller: CardsController#move
Gate Check: Card#can_advance?
```

### API Parameters
```json
{
  "stage": "discovery",
  "position": 1,
  "force": true  // Skip gate warning
}
```

---

## Gate Checklist

### Business Value
Ensure cards meet quality criteria before advancing through the process.

### Key Result
- Gate enforcement at each stage transition (100%)

### Gate Requirements by Stage
```ruby
opportunity: [named_customer, stated_problem, quantified_value, okr_linked]
discovery:   [problem_statement, success_criteria, user_segments]
definition:  [scenarios_exist, acceptance_criteria, ui_direction]
feasibility: [feasibility_assessment, effort_estimate, risks_identified]
commitment:  [scope_locked, release_criteria, support_plan]
build:       [implementation_complete, criteria_verified, docs_updated]
validate:    [customer_feedback, success_measured, okr_impact_measured]
operate:     [monitoring_active, runbooks_created, deprecation_criteria]
```

### Auto-Gates
These gates are automatically verified from data:
- `okr_linked` - True when card has linked key results
- `scenarios_exist` - True when card has at least one scenario
- `okr_impact_measured` - True when all linked KRs have actual impact recorded

### Acceptance Scenarios
1. **View stage gates** - Display requirements for current stage
2. **Toggle gate** - Check/uncheck updates immediately (AJAX)
3. **Progress indicator** - Shows "X/Y" completion
4. **Ready to advance** - Message when all gates complete

### Technical Implementation
```
Model: Card#gate_checklist (JSONB)
Methods: Card#gate_complete?, Card#can_advance?, Card#gate_completion_count
Stimulus: app/javascript/controllers/gate_checklist_controller.js
API: PATCH /products/:slug/cards/:id/toggle_gate
Partial: app/views/cards/_gate_progress.html.erb
```

---

## Scenarios

### Business Value
Define clear, testable acceptance criteria for when features are complete.

### Key Result
- Scenario-based acceptance criteria (Given/When/Then) (100%)

### Acceptance Scenarios
1. **Add scenario** - Create with Given/When/Then fields
2. **View scenarios** - List on card detail
3. **Edit scenario** - Modify any field
4. **Delete scenario** - Remove from card
5. **Status workflow** - draft → approved → verified/failed
6. **Auto-gate** - Adding scenario completes `scenarios_exist` gate

### Technical Implementation
```
Model: Scenario (belongs_to :card)
Controller: ScenariosController
Views: app/views/scenarios/
Routes: /products/:slug/cards/:id/scenarios
```

### Data Model
```ruby
Scenario
├── card_id: references
├── title: string
├── given: text
├── when_clause: text
├── then_clause: text
├── status: enum (draft, approved, verified, failed)
└── position: integer
```

---

## OKR Integration

### Business Value
Connect work to measurable business outcomes, track impact through the process.

### Key Result
- OKR tracking integrated with product process (100%)

### Acceptance Scenarios
1. **Create company OKR** - At /objectives with period
2. **Create product OKR** - At /products/:slug/objectives
3. **Add key result** - Measurable target with unit
4. **Update progress** - Increment/decrement current value
5. **Link card to KR** - With expected impact
6. **Record actual impact** - In Validate stage
7. **Auto-gates** - `okr_linked` and `okr_impact_measured`

### Stage Integration
- **Stage 0 (Opportunity):** `okr_linked` gate auto-checks
- **Stage 6 (Validate):** `okr_impact_measured` gate auto-checks

### Technical Implementation
```
Models: Objective, KeyResult, CardKeyResult
Controllers: ObjectivesController, KeyResultsController, CardKeyResultsController
Views: app/views/objectives/, app/views/key_results/
Routes: /objectives (company), /products/:slug/objectives (product)
```

### Data Models
```ruby
Objective
├── product_id: references (nullable for company-level)
├── title: string
├── description: text
├── period: string (e.g., "2026-Q1")
└── status: enum (active, achieved, missed, abandoned)

KeyResult
├── objective_id: references
├── title: string
├── target_value: decimal
├── current_value: decimal
├── unit: string
└── status: enum (on_track, at_risk, behind, achieved)

CardKeyResult
├── card_id: references
├── key_result_id: references
├── expected_impact: text
└── actual_impact: text
```

---

## Activity Tracking

### Business Value
Understand history of decisions and changes for accountability.

### Key Result
- Activity audit trail for all changes (100%)

### Acceptance Scenarios
1. **Track creation** - Activity recorded on card create
2. **Track updates** - Activity recorded on card update
3. **Track moves** - Activity shows from/to stages
4. **Ordered by recency** - Most recent first
5. **Limited display** - Show last 15 in card detail

### Technical Implementation
```
Model: Activity (polymorphic trackable)
Concern: app/models/concerns/trackable.rb
Partial: app/views/activities/_activity.html.erb
```

### Data Model
```ruby
Activity
├── trackable: polymorphic (Card, etc.)
├── user_id: references
├── action: string (created, updated, moved)
├── change_data: jsonb
└── created_at: datetime
```

---

## Cards CRUD

### Business Value
Track work items through the product process with type-specific fields.

### Card Types and Metadata

| Type | Color | Metadata Fields |
|------|-------|-----------------|
| opportunity | Blue | customer_name, stated_problem, quantified_value, commitment_level |
| feature | Green | effort_estimate, feasibility, scope_in, scope_out |
| task | Yellow | due_date, external_ref |
| issue | Red | severity, reported_by, reproduction_steps |
| jtbd | Purple | job_statement, context |

### Acceptance Scenarios
1. **Create card** - With type and metadata
2. **Type selector** - Shows/hides appropriate fields
3. **View detail** - All information in slide-over
4. **Edit card** - Modify any field
5. **Delete card** - Remove from board

### Technical Implementation
```
Model: Card (with metadata JSONB)
Controller: CardsController
Stimulus: app/javascript/controllers/card_type_controller.js
Partials: _metadata_fields.html.erb, _metadata_display.html.erb
```

### Card Data Model
```ruby
Card
├── product_id: references
├── owner_id: references User
├── card_type: enum (opportunity, feature, task, issue, jtbd)
├── title: string
├── description: text
├── stage: enum (9 stages)
├── priority: enum (critical, high, medium, low)
├── position: integer
├── metadata: jsonb (type-specific)
└── gate_checklist: jsonb
```

---

## Reproducing Features

To reproduce any feature (e.g., for AI agents like Beads):

1. **Find the GitHub Issue** - Contains business value, acceptance criteria, technical details
2. **Read the Cucumber Feature File** - Contains Gherkin scenarios
3. **Check the Seed Data** - Card description has implementation references
4. **Follow the Technical Implementation** - Models, controllers, views listed

Example for Gate Checklist:
- GitHub Issue: https://github.com/oc/planner/issues/7
- Feature File: `features/gate_checklist.feature`
- Model: `app/models/card.rb` (GATE_REQUIREMENTS, AUTO_GATES)
- Controller: `app/controllers/cards_controller.rb#toggle_gate`
- Stimulus: `app/javascript/controllers/gate_checklist_controller.js`
