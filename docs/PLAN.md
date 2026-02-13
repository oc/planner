# ProductPlanner: Implementation Plan

A Rails 8 application for managing the product development process from opportunity to operation.

## Overview

**Goal:** Build a product planning tool that implements the 8-stage product process, with Kanban visualization, OKR tracking, and bi-directional sync with external tools.

**First customer:** Self (dogfooding). Track ProductPlanner's own development using ProductPlanner.

**Approach:** Start simple, single-tenant. Use Hotwire/Turbo for reactive UI. Single Card model with JSONB for flexibility.

---

## Implementation Status

### Phase 1: Foundation (MVP) ✅ COMPLETE

| Feature | Status | GitHub Issue | Feature File |
|---------|--------|--------------|--------------|
| Rails 8 setup | ✅ Done | - | - |
| Authentication | ✅ Done | - | - |
| Core models | ✅ Done | - | - |
| Kanban board | ✅ Done | [#5](https://github.com/oc/planner/issues/5) | `features/kanban_board.feature` |
| Card drag-drop | ✅ Done | [#6](https://github.com/oc/planner/issues/6) | `features/card_drag_drop.feature` |
| Card detail slide-over | ✅ Done | [#11](https://github.com/oc/planner/issues/11) | `features/cards.feature` |
| Comments | ✅ Done | - | - |

### Phase 2: Process Enforcement ✅ COMPLETE

| Feature | Status | GitHub Issue | Feature File |
|---------|--------|--------------|--------------|
| Gate checklist | ✅ Done | [#7](https://github.com/oc/planner/issues/7) | `features/gate_checklist.feature` |
| Gate warnings on move | ✅ Done | [#6](https://github.com/oc/planner/issues/6) | `features/card_drag_drop.feature` |
| Scenarios (Given/When/Then) | ✅ Done | [#8](https://github.com/oc/planner/issues/8) | `features/scenarios.feature` |
| Type-specific metadata | ✅ Done | [#11](https://github.com/oc/planner/issues/11) | `features/cards.feature` |
| Activity tracking | ✅ Done | [#10](https://github.com/oc/planner/issues/10) | `features/activity_tracking.feature` |

### Phase 3: OKR Integration ✅ COMPLETE

| Feature | Status | GitHub Issue | Feature File |
|---------|--------|--------------|--------------|
| OKR models | ✅ Done | [#9](https://github.com/oc/planner/issues/9) | `features/okr_integration.feature` |
| Company/product OKRs | ✅ Done | [#9](https://github.com/oc/planner/issues/9) | `features/okr_integration.feature` |
| Card-OKR linking | ✅ Done | [#9](https://github.com/oc/planner/issues/9) | `features/okr_integration.feature` |
| Stage 0 & 6 integration | ✅ Done | [#9](https://github.com/oc/planner/issues/9) | `features/okr_integration.feature` |
| Auto-gates (okr_linked, etc) | ✅ Done | [#7](https://github.com/oc/planner/issues/7) | `features/gate_checklist.feature` |

### Phase 4: External Integrations 🔲 PENDING

| Feature | Status | GitHub Issue | Feature File |
|---------|--------|--------------|--------------|
| GitHub OAuth | 🔲 Pending | - | - |
| GitHub issue linking | 🔲 Pending | - | - |
| Shortcut integration | 🔲 Pending | - | - |
| Bi-directional sync | 🔲 Pending | - | - |

### Phase 5: Polish & Views 🔲 PENDING

| Feature | Status | GitHub Issue | Feature File |
|---------|--------|--------------|--------------|
| View modes (Pre-Build, etc) | 🔲 Pending | - | - |
| Advanced filtering | 🔲 Pending | - | - |
| Dashboard | 🔲 Pending | - | - |
| Keyboard shortcuts | 🔲 Pending | - | - |

---

## Traceability Chain

Every feature follows this chain for full audit trail:

```
Business Value (OKR)
    ↓
Feature Card (ProductPlanner)
    ↓
Acceptance Criteria (Scenarios in Card)
    ↓
Executable Spec (Cucumber Feature File)
    ↓
Technical Task (GitHub Issue)
    ↓
Implementation (Code + Commits)
```

### Current OKRs (2026-Q1)

**Objective: Ship ProductPlanner MVP**
- KR: Functional Kanban board (100%) ✅
- KR: Gate enforcement (100%) ✅
- KR: Scenario-based acceptance criteria (100%) ✅
- KR: OKR tracking (100%) ✅
- KR: Activity audit trail (100%) ✅

**Objective: Maintain Quality Through Traceability**
- KR: BDD scenarios cover all features (6/6 feature files) ✅
- KR: GitHub issues linked to all features (7/7) ✅

---

## Technical Stack

- **Framework:** Rails 8.0.4
- **Database:** PostgreSQL
- **Frontend:** Hotwire (Turbo + Stimulus), Tailwind CSS
- **Auth:** authentication-zero
- **Testing:** Cucumber (BDD), Capybara, Selenium

---

## Key Files

### Models
- `app/models/card.rb` - Work items with stages, gates, metadata
- `app/models/scenario.rb` - Given/When/Then acceptance criteria
- `app/models/objective.rb` - OKRs (company or product level)
- `app/models/key_result.rb` - Measurable targets
- `app/models/activity.rb` - Audit trail

### Controllers
- `app/controllers/cards_controller.rb` - CRUD + move + toggle_gate
- `app/controllers/objectives_controller.rb` - Company OKRs
- `app/controllers/product_objectives_controller.rb` - Product OKRs
- `app/controllers/scenarios_controller.rb` - Nested under cards

### Stimulus Controllers
- `app/javascript/controllers/kanban_controller.js` - Drag-drop
- `app/javascript/controllers/gate_checklist_controller.js` - Toggle gates
- `app/javascript/controllers/card_type_controller.js` - Metadata fields
- `app/javascript/controllers/key_result_controller.js` - Progress updates

### Feature Files (Cucumber)
- `features/kanban_board.feature`
- `features/card_drag_drop.feature`
- `features/gate_checklist.feature`
- `features/scenarios.feature`
- `features/okr_integration.feature`
- `features/activity_tracking.feature`
- `features/cards.feature`

---

## Running the Application

```bash
# Setup
bin/rails db:setup

# Development server
bin/dev

# Login
# Email: admin@example.com
# Password: password123456

# Run Cucumber tests (when step definitions are implemented)
bin/cucumber
```

---

## Next Steps

1. **Phase 4: GitHub Integration**
   - OAuth flow for GitHub
   - Create/link issues from cards
   - Sync status updates via webhooks

2. **Phase 5: Polish**
   - Dashboard with OKR progress
   - View modes for different roles
   - Advanced filtering and search
