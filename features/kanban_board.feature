# Feature: Kanban Board
# GitHub Issue: https://github.com/oc/planner/issues/5
# ProductPlanner Card: "Kanban Board with 8-Stage Workflow"
#
# The Kanban board is the primary view for visualizing cards moving through
# the 8-stage product process defined in PRODUCT_PROCESS.md:
# Opportunity -> Discovery -> Definition -> Feasibility -> Commitment -> Build -> Validate -> Operate -> Done
#
# Technical Implementation:
# - Rails controller: ProductsController#show
# - View: app/views/products/show.html.erb
# - Stimulus controller: app/javascript/controllers/kanban_controller.js
# - Card partial: app/views/cards/_card.html.erb

@kanban
Feature: Kanban Board
  As a product owner
  I want to see all cards organized by stage on a Kanban board
  So that I can visualize the product pipeline and track progress

  Background:
    Given I am logged in as a product owner
    And a product "ProductPlanner" exists
    And I am a member of "ProductPlanner"

  @smoke
  Scenario: View empty Kanban board
    When I visit the product "ProductPlanner" page
    Then I should see 9 stage columns
    And the columns should be named:
      | Opportunity |
      | Discovery   |
      | Definition  |
      | Feasibility |
      | Commitment  |
      | Build       |
      | Validate    |
      | Operate     |
      | Done        |
    And each column should show "0" card count

  @smoke
  Scenario: View cards on Kanban board
    Given the following cards exist for "ProductPlanner":
      | title           | card_type | stage       | priority |
      | Customer need   | opportunity | opportunity | high     |
      | New feature     | feature   | definition  | medium   |
      | Bug fix         | issue     | build       | critical |
    When I visit the product "ProductPlanner" page
    Then I should see "Customer need" in the "Opportunity" column
    And I should see "New feature" in the "Definition" column
    And I should see "Bug fix" in the "Build" column
    And the "Opportunity" column should show "1" card count
    And the "Definition" column should show "1" card count
    And the "Build" column should show "1" card count

  Scenario: Cards display type-specific styling
    Given the following cards exist for "ProductPlanner":
      | title        | card_type   | stage       |
      | Opportunity  | opportunity | opportunity |
      | Feature      | feature     | discovery   |
      | Task         | task        | definition  |
      | Issue        | issue       | build       |
      | JTBD         | jtbd        | opportunity |
    When I visit the product "ProductPlanner" page
    Then I should see "Opportunity" card with blue type indicator
    And I should see "Feature" card with green type indicator
    And I should see "Task" card with yellow type indicator
    And I should see "Issue" card with red type indicator
    And I should see "JTBD" card with purple type indicator

  Scenario: Card shows gate completion progress
    Given a card "Feature X" exists in "Definition" stage
    And the card has 2 of 3 gates completed
    When I visit the product "ProductPlanner" page
    Then I should see "Feature X" card with gate progress "2/3"

  @javascript
  Scenario: Navigate to card detail via click
    Given a card "Feature X" exists in "Definition" stage
    When I visit the product "ProductPlanner" page
    And I click on card "Feature X"
    Then I should see the card detail slide-over
    And I should see "Feature X" as the card title

  @javascript
  Scenario: Add new card from column
    When I visit the product "ProductPlanner" page
    And I click "+ Add card" in the "Discovery" column
    Then I should see the new card modal
    And the stage should be pre-selected as "Discovery"
