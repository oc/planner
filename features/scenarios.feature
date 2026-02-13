# Feature: Scenarios (Given/When/Then)
# GitHub Issue: https://github.com/oc/planner/issues/8
# ProductPlanner Card: "Scenarios (Given/When/Then)"
#
# Scenarios are acceptance criteria written in Given/When/Then format.
# They are associated with cards and help define when a feature is complete.
# Scenarios have a status workflow: draft -> approved -> verified -> failed
#
# Technical Implementation:
# - Model: Scenario (belongs_to :card)
# - Controller: ScenariosController (nested under cards)
# - Views: app/views/scenarios/
# - Routes: /products/:slug/cards/:id/scenarios

@scenarios
Feature: Scenarios (Given/When/Then)
  As a product owner
  I want to define acceptance scenarios for cards
  So that I have clear criteria for when work is complete

  Background:
    Given I am logged in as a product owner
    And a product "ProductPlanner" exists
    And I am a member of "ProductPlanner"
    And a card "User Login" exists in "Definition" stage

  Scenario: View empty scenarios list
    When I view the card detail for "User Login"
    Then I should see "Scenarios (0)"
    And I should see "No scenarios defined yet"

  @javascript
  Scenario: Add a new scenario
    When I view the card detail for "User Login"
    And I click "+ Add scenario"
    Then I should see the new scenario modal
    When I fill in the scenario:
      | title       | Successful login                           |
      | given       | a registered user with valid credentials   |
      | when_clause | they enter their email and password        |
      | then_clause | they are redirected to the dashboard       |
    And I submit the scenario
    Then I should see "Successful login" in the scenarios list
    And the scenario should show status "draft"
    And the scenarios count should be "1"

  Scenario: View scenario details
    Given a scenario "Successful login" exists for "User Login":
      | given       | a registered user with valid credentials   |
      | when_clause | they enter their email and password        |
      | then_clause | they are redirected to the dashboard       |
    When I view the card detail for "User Login"
    Then I should see the scenario:
      | Given | a registered user with valid credentials   |
      | When  | they enter their email and password        |
      | Then  | they are redirected to the dashboard       |

  @javascript
  Scenario: Edit an existing scenario
    Given a scenario "Successful login" exists for "User Login"
    When I view the card detail for "User Login"
    And I click edit on scenario "Successful login"
    And I change the then clause to "they see a welcome message"
    And I save the scenario
    Then the scenario should show "they see a welcome message"

  @javascript
  Scenario: Delete a scenario
    Given a scenario "Successful login" exists for "User Login"
    When I view the card detail for "User Login"
    And I delete scenario "Successful login"
    Then I should not see "Successful login" in the scenarios list
    And the scenarios count should be "0"

  Scenario: Multiple scenarios per card
    Given the following scenarios exist for "User Login":
      | title               | status   |
      | Successful login    | approved |
      | Invalid password    | draft    |
      | Account locked      | draft    |
    When I view the card detail for "User Login"
    Then I should see "Scenarios (3)"
    And I should see all scenario titles

  Scenario Outline: Scenario status workflow
    Given a scenario "Login flow" exists for "User Login" with status "<initial_status>"
    When I change the scenario status to "<new_status>"
    Then the scenario should show status "<new_status>"

    Examples:
      | initial_status | new_status |
      | draft          | approved   |
      | approved       | verified   |
      | approved       | failed     |
      | failed         | draft      |

  # Integration with Gate Checklist
  Scenario: Adding scenario auto-completes scenarios_exist gate
    Given the card "User Login" has no scenarios
    And the gate "scenarios_exist" is not completed
    When I add a scenario "Basic login" to "User Login"
    Then the gate "scenarios_exist" should be automatically completed
