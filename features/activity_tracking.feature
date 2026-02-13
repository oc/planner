# Feature: Activity Tracking
# GitHub Issue: https://github.com/oc/planner/issues/10
# ProductPlanner Card: "Activity Tracking"
#
# All changes to cards are automatically tracked via the Trackable concern.
# Activity records capture user, action, and change data.
#
# Technical Implementation:
# - Model: Activity (polymorphic trackable)
# - Concern: app/models/concerns/trackable.rb
# - Partial: app/views/activities/_activity.html.erb
# - Automatic tracking via after_create/after_update callbacks

@activity
Feature: Activity Tracking
  As a product owner
  I want to see a history of changes to cards
  So that I can understand how work has progressed

  Background:
    Given I am logged in as a product owner
    And a product "ProductPlanner" exists
    And I am a member of "ProductPlanner"

  Scenario: Track card creation
    When I create a new card "Feature X" with type "feature"
    And I view the card detail for "Feature X"
    Then I should see activity "created Feature X"
    And the activity should show the current user
    And the activity should show "a few seconds ago"

  Scenario: Track card stage movement
    Given a card "Feature X" exists in "Opportunity" stage
    When I move "Feature X" to "Discovery" stage
    And I view the card detail for "Feature X"
    Then I should see activity "moved"
    And the activity should show "from: Opportunity, to: Discovery"

  Scenario: Track card updates
    Given a card "Feature X" exists in "Discovery" stage
    When I update the card title to "Feature X Renamed"
    And I view the card detail for "Feature X Renamed"
    Then I should see activity "updated"
    And the activity should show the title change

  Scenario: Activity list is ordered by recency
    Given a card "Feature X" exists
    And the following activities occurred:
      | action  | time          |
      | created | 3 hours ago   |
      | updated | 2 hours ago   |
      | moved   | 1 hour ago    |
    When I view the card detail for "Feature X"
    Then the activities should be ordered most recent first:
      | moved   |
      | updated |
      | created |

  Scenario: Activity list limited to recent entries
    Given a card "Feature X" exists
    And "Feature X" has 20 activity records
    When I view the card detail for "Feature X"
    Then I should see at most 15 activities
