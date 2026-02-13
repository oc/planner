# ProductPlanner Seed Data
# This seed data demonstrates dogfooding - using ProductPlanner to track its own development
# Each feature links to: OKR (business value), GitHub Issue (technical task), Cucumber Feature (acceptance criteria)

puts "=== Creating seed data ==="

# Create default user
user = User.find_or_create_by!(email: "admin@example.com") do |u|
  u.name = "Admin User"
  u.password = "password123456"
  u.verified = true
  u.role = :product_owner
end
puts "Created user: #{user.email}"

# Create ProductPlanner product (dogfooding)
product = Product.find_or_create_by!(slug: "product-planner") do |p|
  p.name = "ProductPlanner"
  p.description = "The product planning tool itself - tracking its own development with proper OKR integration"
end

# Add user as owner
Membership.find_or_create_by!(user: user, product: product) do |m|
  m.role = :owner
end
puts "Created product: #{product.name}"

# ============================================================================
# OBJECTIVES AND KEY RESULTS
# Business value that features must contribute to
# ============================================================================

puts "\n=== Creating OKRs ==="

# Product-level Objective: Ship MVP
mvp_objective = Objective.find_or_create_by!(product: product, title: "Ship ProductPlanner MVP") do |o|
  o.description = "Deliver a working product planning tool that can track its own development"
  o.period = "2026-Q1"
  o.status = :active
end

# Key Results for MVP Objective
kr_kanban = KeyResult.find_or_create_by!(objective: mvp_objective, title: "Functional Kanban board with 8-stage workflow") do |kr|
  kr.target_value = 100
  kr.current_value = 100
  kr.unit = "%"
  kr.status = :achieved
end

kr_gates = KeyResult.find_or_create_by!(objective: mvp_objective, title: "Gate enforcement at each stage transition") do |kr|
  kr.target_value = 100
  kr.current_value = 100
  kr.unit = "%"
  kr.status = :achieved
end

kr_scenarios = KeyResult.find_or_create_by!(objective: mvp_objective, title: "Scenario-based acceptance criteria (Given/When/Then)") do |kr|
  kr.target_value = 100
  kr.current_value = 100
  kr.unit = "%"
  kr.status = :achieved
end

kr_okr = KeyResult.find_or_create_by!(objective: mvp_objective, title: "OKR tracking integrated with product process") do |kr|
  kr.target_value = 100
  kr.current_value = 100
  kr.unit = "%"
  kr.status = :achieved
end

kr_activity = KeyResult.find_or_create_by!(objective: mvp_objective, title: "Activity audit trail for all changes") do |kr|
  kr.target_value = 100
  kr.current_value = 100
  kr.unit = "%"
  kr.status = :achieved
end

# Product-level Objective: Quality & Traceability
quality_objective = Objective.find_or_create_by!(product: product, title: "Maintain Quality Through Traceability") do |o|
  o.description = "Every feature must have clear business value, acceptance criteria, and technical tasks"
  o.period = "2026-Q1"
  o.status = :active
end

kr_cucumber = KeyResult.find_or_create_by!(objective: quality_objective, title: "BDD scenarios cover all features") do |kr|
  kr.target_value = 6
  kr.current_value = 6
  kr.unit = "feature files"
  kr.status = :achieved
end

kr_issues = KeyResult.find_or_create_by!(objective: quality_objective, title: "GitHub issues linked to all features") do |kr|
  kr.target_value = 7
  kr.current_value = 7
  kr.unit = "features"
  kr.status = :achieved
end

puts "Created #{Objective.count} objectives and #{KeyResult.count} key results"

# ============================================================================
# CARDS (FEATURES)
# Each card links to: Key Results (value), GitHub Issue (task), Feature File (criteria)
# ============================================================================

puts "\n=== Creating cards with full traceability ==="

# Helper to create card with full metadata
def create_traced_card(product:, user:, attrs:, key_results: [], scenarios: [])
  card = Card.find_or_create_by!(product: product, title: attrs[:title]) do |c|
    c.owner = user
    c.card_type = attrs[:card_type]
    c.stage = attrs[:stage]
    c.priority = attrs[:priority]
    c.description = attrs[:description]
    c.metadata = attrs[:metadata] || {}
    c.initialize_gate_checklist!
  end

  # Complete relevant gates based on stage
  if attrs[:completed_gates]
    attrs[:completed_gates].each do |gate|
      card.gate_checklist[card.stage] ||= {}
      card.gate_checklist[card.stage][gate.to_s] = true
    end
    card.save!
  end

  # Link to key results
  key_results.each do |kr|
    CardKeyResult.find_or_create_by!(card: card, key_result: kr) do |ckr|
      ckr.expected_impact = attrs[:expected_impact]
      ckr.actual_impact = attrs[:actual_impact] if attrs[:stage].to_s.in?(%w[validate operate done])
    end
  end

  # Create scenarios
  scenarios.each_with_index do |scenario_attrs, i|
    Scenario.find_or_create_by!(card: card, title: scenario_attrs[:title]) do |s|
      s.given = scenario_attrs[:given]
      s.when_clause = scenario_attrs[:when_clause]
      s.then_clause = scenario_attrs[:then_clause]
      s.status = scenario_attrs[:status] || :draft
      s.position = i + 1
    end
  end

  puts "  - #{card.title} (#{card.stage}) -> #{key_results.map(&:title).join(', ')}"
  card
end

# Card 1: Kanban Board
kanban_card = create_traced_card(
  product: product,
  user: user,
  attrs: {
    title: "Kanban Board with 8-Stage Workflow",
    card_type: :feature,
    stage: :done,
    priority: :high,
    description: <<~DESC,
      Implement a Kanban board view showing all cards organized by the 8 stages of the product process.

      ## Business Value
      Visualize the entire product pipeline to identify bottlenecks and track progress.

      ## Technical References
      - Feature File: features/kanban_board.feature
      - GitHub Issue: https://github.com/oc/planner/issues/5

      ## Implementation
      - Controller: ProductsController#show
      - View: app/views/products/show.html.erb
      - Stimulus: app/javascript/controllers/kanban_controller.js
    DESC
    metadata: {
      "effort_estimate" => "M",
      "feasibility" => "yes",
      "scope_in" => "8-stage columns, card rendering, column counts",
      "scope_out" => "Advanced filtering, search, bulk operations"
    },
    completed_gates: %w[named_customer stated_problem quantified_value okr_linked problem_statement success_criteria user_segments scenarios_exist acceptance_criteria ui_direction feasibility_assessment effort_estimate risks_identified scope_locked release_criteria support_plan implementation_complete criteria_verified docs_updated customer_feedback success_measured],
    expected_impact: "Core visualization for product process",
    actual_impact: "Fully functional board with all 9 columns (including Done)"
  },
  key_results: [kr_kanban],
  scenarios: [
    { title: "View cards by stage", given: "cards exist in multiple stages", when_clause: "I visit the product page", then_clause: "I see cards organized in their respective columns", status: :verified },
    { title: "Card shows type styling", given: "cards of different types exist", when_clause: "I view the board", then_clause: "each card shows its type-specific color indicator", status: :verified }
  ]
)

# Card 2: Card Drag-Drop
dragdrop_card = create_traced_card(
  product: product,
  user: user,
  attrs: {
    title: "Card Drag-Drop Between Stages",
    card_type: :feature,
    stage: :done,
    priority: :high,
    description: <<~DESC,
      Enable dragging cards between stages on the Kanban board, with gate enforcement checks.

      ## Business Value
      Allow intuitive progress tracking by moving cards through the workflow.

      ## Technical References
      - Feature File: features/card_drag_drop.feature
      - GitHub Issue: https://github.com/oc/planner/issues/6

      ## Implementation
      - Stimulus: app/javascript/controllers/kanban_controller.js
      - API: PATCH /products/:slug/cards/:id/move
      - Controller: CardsController#move
    DESC
    metadata: {
      "effort_estimate" => "M",
      "feasibility" => "yes",
      "scope_in" => "Drag between stages, reorder within stage, gate warnings",
      "scope_out" => "Multi-select, keyboard shortcuts"
    },
    completed_gates: %w[named_customer stated_problem quantified_value okr_linked problem_statement success_criteria user_segments scenarios_exist acceptance_criteria ui_direction feasibility_assessment effort_estimate risks_identified scope_locked release_criteria support_plan implementation_complete criteria_verified docs_updated customer_feedback success_measured],
    expected_impact: "Enable visual workflow management",
    actual_impact: "Working drag-drop with confirmation dialog for incomplete gates"
  },
  key_results: [kr_kanban, kr_gates],
  scenarios: [
    { title: "Move card with complete gates", given: "all gates are complete", when_clause: "I drag card to next stage", then_clause: "card moves without warning", status: :verified },
    { title: "Warning on incomplete gates", given: "gates are incomplete", when_clause: "I drag card forward", then_clause: "I see confirmation dialog listing incomplete gates", status: :verified }
  ]
)

# Card 3: Gate Checklist
gates_card = create_traced_card(
  product: product,
  user: user,
  attrs: {
    title: "Gate Checklist Enforcement",
    card_type: :feature,
    stage: :done,
    priority: :high,
    description: <<~DESC,
      Display and enforce stage-specific gate requirements with interactive checkboxes.

      ## Business Value
      Ensure cards meet quality criteria before advancing through the process.

      ## Technical References
      - Feature File: features/gate_checklist.feature
      - GitHub Issue: https://github.com/oc/planner/issues/7

      ## Implementation
      - Model: Card#gate_checklist (JSONB), Card#gate_complete?, Card#can_advance?
      - Stimulus: app/javascript/controllers/gate_checklist_controller.js
      - API: PATCH /products/:slug/cards/:id/toggle_gate
    DESC
    metadata: {
      "effort_estimate" => "M",
      "feasibility" => "yes",
      "scope_in" => "Per-stage requirements, toggle via checkbox, progress indicator, auto-gates",
      "scope_out" => "Custom gate definitions, approval workflows"
    },
    completed_gates: %w[named_customer stated_problem quantified_value okr_linked problem_statement success_criteria user_segments scenarios_exist acceptance_criteria ui_direction feasibility_assessment effort_estimate risks_identified scope_locked release_criteria support_plan implementation_complete criteria_verified docs_updated customer_feedback success_measured],
    expected_impact: "Enforce process quality at each stage",
    actual_impact: "Gates work with manual toggles and auto-verification for data-driven gates"
  },
  key_results: [kr_gates],
  scenarios: [
    { title: "View stage gates", given: "a card in Definition stage", when_clause: "I view card detail", then_clause: "I see scenarios_exist, acceptance_criteria, ui_direction gates", status: :verified },
    { title: "Toggle gate completion", given: "an unchecked gate", when_clause: "I check the checkbox", then_clause: "the gate is marked complete and progress updates", status: :verified }
  ]
)

# Card 4: Scenarios (Given/When/Then)
scenarios_card = create_traced_card(
  product: product,
  user: user,
  attrs: {
    title: "Scenarios (Given/When/Then)",
    card_type: :feature,
    stage: :done,
    priority: :medium,
    description: <<~DESC,
      Add acceptance criteria as scenarios with Given/When/Then structure.

      ## Business Value
      Define clear, testable criteria for when features are complete.

      ## Technical References
      - Feature File: features/scenarios.feature
      - GitHub Issue: https://github.com/oc/planner/issues/8

      ## Implementation
      - Model: Scenario (belongs_to :card)
      - Controller: ScenariosController
      - Views: app/views/scenarios/
    DESC
    metadata: {
      "effort_estimate" => "S",
      "feasibility" => "yes",
      "scope_in" => "CRUD for scenarios, status workflow",
      "scope_out" => "Export to Gherkin files, test runner integration"
    },
    completed_gates: %w[named_customer stated_problem quantified_value okr_linked problem_statement success_criteria user_segments scenarios_exist acceptance_criteria ui_direction feasibility_assessment effort_estimate risks_identified scope_locked release_criteria support_plan implementation_complete criteria_verified docs_updated customer_feedback success_measured],
    expected_impact: "Enable BDD-style acceptance criteria",
    actual_impact: "Full CRUD for scenarios with auto-gate integration"
  },
  key_results: [kr_scenarios],
  scenarios: [
    { title: "Add scenario to card", given: "viewing a card", when_clause: "I add a scenario with Given/When/Then", then_clause: "the scenario appears in the list", status: :verified },
    { title: "Auto-complete scenarios_exist gate", given: "no scenarios exist", when_clause: "I add first scenario", then_clause: "scenarios_exist gate auto-completes", status: :verified }
  ]
)

# Card 5: OKR Integration
okr_card = create_traced_card(
  product: product,
  user: user,
  attrs: {
    title: "OKR Integration",
    card_type: :feature,
    stage: :done,
    priority: :high,
    description: <<~DESC,
      Track Objectives and Key Results at company and product level, link cards to OKRs.

      ## Business Value
      Connect work to measurable business outcomes, track impact through the process.

      ## Technical References
      - Feature File: features/okr_integration.feature
      - GitHub Issue: https://github.com/oc/planner/issues/9

      ## Implementation
      - Models: Objective, KeyResult, CardKeyResult
      - Controllers: ObjectivesController, KeyResultsController, CardKeyResultsController
      - Stage 0: okr_linked gate auto-checks
      - Stage 6: okr_impact_measured gate auto-checks
    DESC
    metadata: {
      "effort_estimate" => "L",
      "feasibility" => "yes",
      "scope_in" => "Company/product OKRs, card linking, expected/actual impact, auto-gates",
      "scope_out" => "OKR inheritance, scoring algorithms"
    },
    completed_gates: %w[named_customer stated_problem quantified_value okr_linked problem_statement success_criteria user_segments scenarios_exist acceptance_criteria ui_direction feasibility_assessment effort_estimate risks_identified scope_locked release_criteria support_plan implementation_complete criteria_verified docs_updated customer_feedback success_measured],
    expected_impact: "Full traceability from work to business outcomes",
    actual_impact: "OKRs at company/product level with bi-directional card linking and impact tracking"
  },
  key_results: [kr_okr],
  scenarios: [
    { title: "Link card to key result", given: "a card and key result exist", when_clause: "I link the card to the key result", then_clause: "the linkage shows in card detail and okr_linked gate completes", status: :verified },
    { title: "Record actual impact", given: "a card in Validate stage linked to KR", when_clause: "I record actual impact", then_clause: "the impact shows and okr_impact_measured gate completes", status: :verified }
  ]
)

# Card 6: Activity Tracking
activity_card = create_traced_card(
  product: product,
  user: user,
  attrs: {
    title: "Activity Tracking",
    card_type: :feature,
    stage: :done,
    priority: :low,
    description: <<~DESC,
      Automatically track all changes to cards for audit trail.

      ## Business Value
      Understand history of decisions and changes for accountability.

      ## Technical References
      - Feature File: features/activity_tracking.feature
      - GitHub Issue: https://github.com/oc/planner/issues/10

      ## Implementation
      - Model: Activity (polymorphic trackable)
      - Concern: app/models/concerns/trackable.rb
      - Auto-tracking via after_create/after_update callbacks
    DESC
    metadata: {
      "effort_estimate" => "S",
      "feasibility" => "yes",
      "scope_in" => "Track creates, updates, moves; show in card detail",
      "scope_out" => "Notifications, RSS feeds, detailed diff view"
    },
    completed_gates: %w[named_customer stated_problem quantified_value okr_linked problem_statement success_criteria user_segments scenarios_exist acceptance_criteria ui_direction feasibility_assessment effort_estimate risks_identified scope_locked release_criteria support_plan implementation_complete criteria_verified docs_updated customer_feedback success_measured],
    expected_impact: "Complete audit trail for all card changes",
    actual_impact: "Activity log shows creates, updates, and stage moves"
  },
  key_results: [kr_activity],
  scenarios: [
    { title: "Track card creation", given: "I create a card", when_clause: "I view card detail", then_clause: "I see 'created' activity", status: :verified },
    { title: "Track stage movement", given: "I move a card", when_clause: "I view card detail", then_clause: "I see 'moved' activity with from/to stages", status: :verified }
  ]
)

# Card 7: GitHub Issue Integration (current work)
github_card = create_traced_card(
  product: product,
  user: user,
  attrs: {
    title: "GitHub Issue Traceability",
    card_type: :feature,
    stage: :build,
    priority: :high,
    description: <<~DESC,
      Link cards to GitHub issues for technical task tracking and audit trail.

      ## Business Value
      Connect product requirements to technical implementation tasks for full traceability.

      ## Technical References
      - Feature File: features/github_integration.feature (to be created)
      - GitHub Issue: #7 (this card's issue)

      ## Implementation
      - Extend ExternalLink model for GitHub
      - Create issues via gh CLI
      - Reference feature files and cards in issue body
    DESC
    metadata: {
      "effort_estimate" => "M",
      "feasibility" => "yes",
      "scope_in" => "Create issues, link to cards, reference feature files",
      "scope_out" => "Bi-directional sync, webhook handling"
    },
    completed_gates: %w[named_customer stated_problem quantified_value problem_statement success_criteria user_segments scenarios_exist acceptance_criteria ui_direction feasibility_assessment effort_estimate risks_identified scope_locked release_criteria support_plan],
    expected_impact: "Full traceability from OKR -> Feature -> Task -> Code"
  },
  key_results: [kr_issues, kr_cucumber]
)

# Card 8: BDD/Cucumber Setup (current work)
cucumber_card = create_traced_card(
  product: product,
  user: user,
  attrs: {
    title: "BDD with Cucumber Feature Files",
    card_type: :feature,
    stage: :build,
    priority: :high,
    description: <<~DESC,
      Set up Cucumber for Gherkin-based acceptance testing that mirrors card scenarios.

      ## Business Value
      Executable specifications that serve as both documentation and tests.

      ## Technical References
      - All feature files in features/ directory
      - GitHub Issue: #8 (this card's issue)

      ## Implementation
      - Add cucumber-rails gem
      - Create feature files for each product feature
      - Link feature files to cards via description
    DESC
    metadata: {
      "effort_estimate" => "M",
      "feasibility" => "yes",
      "scope_in" => "Cucumber setup, feature files for core features",
      "scope_out" => "Step definitions, CI integration"
    },
    completed_gates: %w[named_customer stated_problem quantified_value problem_statement success_criteria user_segments scenarios_exist acceptance_criteria ui_direction feasibility_assessment effort_estimate risks_identified scope_locked release_criteria support_plan],
    expected_impact: "Executable documentation for all features"
  },
  key_results: [kr_cucumber]
)

puts "\n=== Summary ==="
puts "Products: #{Product.count}"
puts "Objectives: #{Objective.count}"
puts "Key Results: #{KeyResult.count}"
puts "Cards: #{Card.count}"
puts "Card-KR Links: #{CardKeyResult.count}"
puts "Scenarios: #{Scenario.count}"

puts "\n=== Traceability Chain ==="
puts "OKR -> Card -> Scenario -> Feature File -> GitHub Issue"
puts ""
product.cards.includes(:key_results, :scenarios).each do |card|
  puts "#{card.title} (#{card.stage})"
  puts "  OKRs: #{card.key_results.map(&:title).join(', ')}"
  puts "  Scenarios: #{card.scenarios.count}"
end

puts "\nSeed completed!"
puts "Login with: admin@example.com / password123456"
