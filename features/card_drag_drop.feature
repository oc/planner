# Feature: Card Drag-Drop
# GitHub Issue: To be linked after creation
#
# Cards can be dragged between stages on the Kanban board. Moving forward
# through stages triggers gate requirement checks. Moving backward is always
# allowed (for corrections).
#
# Technical Implementation:
# - Stimulus controller: app/javascript/controllers/kanban_controller.js
# - API endpoint: PATCH /products/:slug/cards/:id/move
# - Controller action: CardsController#move
# - Gate enforcement: Card#can_advance? method

@drag_drop @javascript
Feature: Card Drag-Drop Between Stages
  As a product owner
  I want to drag cards between stages
  So that I can update their progress through the product process

  Background:
    Given I am logged in as a product owner
    And a product "ProductPlanner" exists
    And I am a member of "ProductPlanner"

  Scenario: Move card forward with all gates complete
    Given a card "Feature X" exists in "Opportunity" stage
    And all gate requirements are completed for "Feature X"
    When I visit the product "ProductPlanner" page
    And I drag "Feature X" from "Opportunity" to "Discovery"
    Then "Feature X" should appear in the "Discovery" column
    And an activity "moved" should be recorded for "Feature X"
    And the activity should show "from: Opportunity, to: Discovery"

  Scenario: Move card forward with incomplete gates shows warning
    Given a card "Feature X" exists in "Opportunity" stage
    And the gate "named_customer" is incomplete for "Feature X"
    When I visit the product "ProductPlanner" page
    And I drag "Feature X" from "Opportunity" to "Discovery"
    Then I should see a confirmation dialog
    And the dialog should warn about incomplete gates
    And the dialog should list "named_customer" as incomplete

  Scenario: Confirm move despite incomplete gates
    Given a card "Feature X" exists in "Opportunity" stage
    And the gate "named_customer" is incomplete for "Feature X"
    When I visit the product "ProductPlanner" page
    And I drag "Feature X" from "Opportunity" to "Discovery"
    And I confirm the move in the dialog
    Then "Feature X" should appear in the "Discovery" column
    And an activity "moved" should be recorded for "Feature X"

  Scenario: Cancel move when warned about incomplete gates
    Given a card "Feature X" exists in "Opportunity" stage
    And the gate "named_customer" is incomplete for "Feature X"
    When I visit the product "ProductPlanner" page
    And I drag "Feature X" from "Opportunity" to "Discovery"
    And I cancel the move in the dialog
    Then "Feature X" should remain in the "Opportunity" column

  Scenario: Move card backward always succeeds
    Given a card "Feature X" exists in "Discovery" stage
    And the gate "problem_statement" is incomplete for "Feature X"
    When I visit the product "ProductPlanner" page
    And I drag "Feature X" from "Discovery" to "Opportunity"
    Then "Feature X" should appear in the "Opportunity" column
    And I should not see a confirmation dialog

  Scenario: Reorder cards within the same stage
    Given the following cards exist for "ProductPlanner":
      | title     | stage     | position |
      | Card A    | discovery | 1        |
      | Card B    | discovery | 2        |
      | Card C    | discovery | 3        |
    When I visit the product "ProductPlanner" page
    And I drag "Card C" to position 1 in "Discovery"
    Then the cards in "Discovery" should be ordered:
      | Card C |
      | Card A |
      | Card B |
