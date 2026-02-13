# Feature: Gate Checklist
# GitHub Issue: To be linked after creation
#
# Each stage in the product process has specific gate requirements that should
# be completed before advancing. Gates are stored in the card's gate_checklist
# JSONB column. Some gates are auto-verified from data (AUTO_GATES in Card model).
#
# Gate Requirements by Stage (from Card::GATE_REQUIREMENTS):
# - opportunity: named_customer, stated_problem, quantified_value, okr_linked
# - discovery: problem_statement, success_criteria, user_segments
# - definition: scenarios_exist, acceptance_criteria, ui_direction
# - feasibility: feasibility_assessment, effort_estimate, risks_identified
# - commitment: scope_locked, release_criteria, support_plan
# - build: implementation_complete, criteria_verified, docs_updated
# - validate: customer_feedback, success_measured, okr_impact_measured
# - operate: monitoring_active, runbooks_created, deprecation_criteria
#
# Technical Implementation:
# - Model: Card#gate_checklist (JSONB), Card#gate_complete?, Card#can_advance?
# - Stimulus controller: app/javascript/controllers/gate_checklist_controller.js
# - API endpoint: PATCH /products/:slug/cards/:id/toggle_gate
# - Partial: app/views/cards/_gate_progress.html.erb

@gates
Feature: Gate Checklist
  As a product owner
  I want to track gate requirements for each stage
  So that cards meet quality criteria before advancing

  Background:
    Given I am logged in as a product owner
    And a product "ProductPlanner" exists
    And I am a member of "ProductPlanner"

  Scenario Outline: View stage-specific gate requirements
    Given a card "Feature X" exists in "<stage>" stage
    When I view the card detail for "Feature X"
    Then I should see the following gate requirements:
      | <gate1> |
      | <gate2> |
      | <gate3> |

    Examples:
      | stage       | gate1               | gate2            | gate3            |
      | opportunity | named_customer      | stated_problem   | quantified_value |
      | discovery   | problem_statement   | success_criteria | user_segments    |
      | definition  | scenarios_exist     | acceptance_criteria | ui_direction  |
      | feasibility | feasibility_assessment | effort_estimate | risks_identified |
      | commitment  | scope_locked        | release_criteria | support_plan     |
      | build       | implementation_complete | criteria_verified | docs_updated |
      | validate    | customer_feedback   | success_measured | okr_impact_measured |
      | operate     | monitoring_active   | runbooks_created | deprecation_criteria |

  @javascript
  Scenario: Toggle gate requirement via checkbox
    Given a card "Feature X" exists in "Opportunity" stage
    And the gate "named_customer" is not completed
    When I view the card detail for "Feature X"
    And I check the gate "named_customer"
    Then the gate "named_customer" should be marked as complete
    And the gate progress should update to show the new count

  @javascript
  Scenario: Uncheck previously completed gate
    Given a card "Feature X" exists in "Opportunity" stage
    And the gate "named_customer" is completed
    When I view the card detail for "Feature X"
    And I uncheck the gate "named_customer"
    Then the gate "named_customer" should be marked as incomplete

  Scenario: Gate progress indicator on card
    Given a card "Feature X" exists in "Opportunity" stage
    And the following gates are completed for "Feature X":
      | named_customer   |
      | stated_problem   |
    And the following gates are incomplete for "Feature X":
      | quantified_value |
      | okr_linked       |
    When I view the card detail for "Feature X"
    Then I should see gate progress "2/4"

  Scenario: All gates complete shows ready to advance message
    Given a card "Feature X" exists in "Opportunity" stage
    And all gate requirements are completed for "Feature X"
    When I view the card detail for "Feature X"
    Then I should see "All gates complete - ready to advance"

  # Auto-gates: These gates are automatically verified from data
  Scenario: OKR linked gate auto-checks when key result is linked
    Given a card "Feature X" exists in "Opportunity" stage
    And an objective "Increase retention" exists with key result "Reduce churn to 5%"
    When I link "Feature X" to key result "Reduce churn to 5%"
    Then the gate "okr_linked" should be automatically completed

  Scenario: Scenarios exist gate auto-checks when scenario is added
    Given a card "Feature X" exists in "Definition" stage
    And "Feature X" has no scenarios
    And the gate "scenarios_exist" is not completed
    When I add a scenario to "Feature X"
    Then the gate "scenarios_exist" should be automatically completed

  Scenario: OKR impact measured gate auto-checks when all impacts recorded
    Given a card "Feature X" exists in "Validate" stage
    And "Feature X" is linked to key result "Reduce churn to 5%"
    And the actual impact is not recorded
    When I record actual impact "Reduced churn by 3%"
    Then the gate "okr_impact_measured" should be automatically completed
