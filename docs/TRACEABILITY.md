# ProductPlanner Traceability

This document explains the full traceability chain from business value to code implementation.

## The Traceability Chain

```
┌─────────────────────────────────────────────────────────────────┐
│                      BUSINESS VALUE                              │
│  Objective: Ship ProductPlanner MVP                              │
│  Key Result: Gate enforcement at each stage transition (100%)    │
└───────────────────────────┬─────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                      PRODUCT FEATURE                             │
│  Card: "Gate Checklist Enforcement"                              │
│  Stage: Done | Priority: High | Type: Feature                    │
│  Linked to KR: Gate enforcement at each stage transition         │
└───────────────────────────┬─────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                   ACCEPTANCE CRITERIA                            │
│  Scenarios (in Card):                                            │
│  - Given: a card in Definition stage                             │
│    When: I view card detail                                      │
│    Then: I see scenarios_exist, acceptance_criteria gates        │
│  - Given: an unchecked gate                                      │
│    When: I check the checkbox                                    │
│    Then: the gate is marked complete, progress updates           │
└───────────────────────────┬─────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                   EXECUTABLE SPECIFICATION                       │
│  Cucumber: features/gate_checklist.feature                       │
│  Contains Gherkin scenarios that can be automated                │
│  Reference: # GitHub Issue: https://github.com/oc/planner/issues/7│
└───────────────────────────┬─────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                      TECHNICAL TASK                              │
│  GitHub Issue: #7 - Gate Checklist Enforcement                   │
│  Contains: Business value, acceptance criteria, implementation   │
│  Status: Closed (completed)                                      │
└───────────────────────────┬─────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                      IMPLEMENTATION                              │
│  Model: app/models/card.rb (GATE_REQUIREMENTS, AUTO_GATES)       │
│  Controller: app/controllers/cards_controller.rb#toggle_gate     │
│  Stimulus: app/javascript/controllers/gate_checklist_controller.js│
│  View: app/views/cards/_gate_progress.html.erb                   │
│  Commits: Referenced in GitHub issue                             │
└─────────────────────────────────────────────────────────────────┘
```

---

## Traceability Matrix

| OKR | Card | GitHub Issue | Feature File | Key Implementation |
|-----|------|--------------|--------------|-------------------|
| Ship MVP / Kanban board | Kanban Board with 8-Stage Workflow | [#5](https://github.com/oc/planner/issues/5) | `kanban_board.feature` | `products/show.html.erb`, `kanban_controller.js` |
| Ship MVP / Kanban board + Gates | Card Drag-Drop Between Stages | [#6](https://github.com/oc/planner/issues/6) | `card_drag_drop.feature` | `kanban_controller.js`, `cards_controller.rb#move` |
| Ship MVP / Gate enforcement | Gate Checklist Enforcement | [#7](https://github.com/oc/planner/issues/7) | `gate_checklist.feature` | `card.rb`, `gate_checklist_controller.js` |
| Ship MVP / Scenarios | Scenarios (Given/When/Then) | [#8](https://github.com/oc/planner/issues/8) | `scenarios.feature` | `scenario.rb`, `scenarios_controller.rb` |
| Ship MVP / OKR tracking | OKR Integration | [#9](https://github.com/oc/planner/issues/9) | `okr_integration.feature` | `objective.rb`, `key_result.rb`, `card_key_result.rb` |
| Ship MVP / Activity trail | Activity Tracking | [#10](https://github.com/oc/planner/issues/10) | `activity_tracking.feature` | `activity.rb`, `trackable.rb` concern |
| Quality / BDD coverage | BDD with Cucumber Feature Files | - | All 6 features | `features/*.feature` |
| Quality / GitHub issues | GitHub Issue Traceability | - | - | This documentation |

---

## How to Trace a Feature

### Forward (Business → Code)

1. **Start with OKR** - What business value are we delivering?
   - Example: "Ship MVP" → "Gate enforcement at each stage transition"

2. **Find the Card** - What feature implements this KR?
   - View product board or seed data
   - Example: "Gate Checklist Enforcement" card

3. **Read Scenarios** - What are the acceptance criteria?
   - In card detail, view Scenarios section
   - Example: "Toggle gate via checkbox", "Auto-gate for scenarios_exist"

4. **Check Feature File** - What's the executable spec?
   - Reference in card description
   - Example: `features/gate_checklist.feature`

5. **Find GitHub Issue** - What's the technical task?
   - Reference in card description
   - Example: https://github.com/oc/planner/issues/7

6. **Locate Implementation** - What code implements this?
   - Listed in GitHub issue body
   - Example: `card.rb`, `gate_checklist_controller.js`

### Backward (Code → Business)

1. **Start with Code** - What file are you looking at?
   - Example: `app/models/card.rb`

2. **Find Feature File** - Which feature uses this?
   - Grep for class/method name in features/
   - Example: `gate_checklist.feature` mentions gates

3. **Find GitHub Issue** - What issue documents this?
   - Search issues for feature name
   - Example: Issue #7 "Gate Checklist Enforcement"

4. **Find Card** - What ProductPlanner card is this?
   - Issue references card title
   - Example: "Gate Checklist Enforcement" card

5. **Find OKR** - What business value does this deliver?
   - View card's linked Key Results
   - Example: "Gate enforcement at each stage transition"

---

## For AI Agents (Beads, etc.)

When reproducing a feature, follow this process:

### 1. Read the GitHub Issue
```bash
gh issue view 7 --repo oc/planner
```
Contains:
- Business value (which OKR)
- Acceptance criteria (key scenarios)
- Scope (in/out)
- Technical implementation (files to create/modify)

### 2. Read the Feature File
```bash
cat features/gate_checklist.feature
```
Contains:
- Gherkin scenarios as precise specifications
- Background setup requirements
- Edge cases and variations

### 3. Check Existing Implementation
The issue body lists implementation files. Read them to understand:
- Data model structure
- API endpoints and parameters
- UI components and interactions

### 4. Reproduce by Following Scenarios
Each Gherkin scenario is a test case:
```gherkin
Scenario: Toggle gate requirement via checkbox
  Given a card "Feature X" exists in "Opportunity" stage
  And the gate "named_customer" is not completed
  When I view the card detail for "Feature X"
  And I check the gate "named_customer"
  Then the gate "named_customer" should be marked as complete
```

Implement to satisfy each Given/When/Then.

---

## Maintaining Traceability

### When Adding a Feature

1. **Create OKR** (if new business value)
   - Add Objective and/or Key Result
   - Define measurable target

2. **Create Card** in ProductPlanner
   - Link to Key Result(s)
   - Add description with Technical References section

3. **Add Scenarios** to Card
   - Given/When/Then format
   - Cover happy path and edge cases

4. **Create Cucumber Feature File**
   - Header references GitHub Issue and Card
   - Scenarios match those in Card

5. **Create GitHub Issue**
   - Title matches Card title
   - Body includes: Business Value, Acceptance Criteria, Technical Implementation, Scope

6. **Implement and Commit**
   - Reference issue number in commits
   - Close issue when complete

### When Modifying a Feature

1. **Update Card** description if behavior changes
2. **Update Scenarios** in Card if acceptance criteria change
3. **Update Feature File** to match
4. **Add comment to GitHub Issue** explaining changes
5. **Commit with issue reference**

---

## Seed Data Structure

The seed data (`db/seeds.rb`) demonstrates the full traceability:

```ruby
create_traced_card(
  product: product,
  user: user,
  attrs: {
    title: "Gate Checklist Enforcement",
    card_type: :feature,
    stage: :done,
    description: <<~DESC,
      Display and enforce stage-specific gate requirements...

      ## Business Value
      Ensure cards meet quality criteria before advancing.

      ## Technical References
      - Feature File: features/gate_checklist.feature
      - GitHub Issue: https://github.com/oc/planner/issues/7

      ## Implementation
      - Model: Card#gate_checklist (JSONB)
      - Stimulus: gate_checklist_controller.js
    DESC
    # ... metadata, completed gates, expected/actual impact
  },
  key_results: [kr_gates],  # Links to "Gate enforcement" KR
  scenarios: [
    { title: "View stage gates", given: "...", when_clause: "...", then_clause: "..." },
    { title: "Toggle gate completion", ... }
  ]
)
```

Run `bin/rails db:seed` to populate this structure.
