# Feature: OKR Integration
# GitHub Issue: To be linked after creation
#
# OKRs (Objectives and Key Results) can be defined at company or product level.
# Cards link to key results via CardKeyResult join table.
# - Stage 0 (Opportunity): Must link to OKR (okr_linked gate)
# - Stage 6 (Validate): Must record actual impact (okr_impact_measured gate)
#
# Technical Implementation:
# - Models: Objective, KeyResult, CardKeyResult
# - Controllers: ObjectivesController, KeyResultsController, CardKeyResultsController
# - Views: app/views/objectives/, app/views/key_results/, app/views/card_key_results/
# - Routes: /objectives (company), /products/:slug/objectives (product-level)

@okr
Feature: OKR Integration
  As a product owner
  I want to link cards to OKRs
  So that I can track how work contributes to business objectives

  Background:
    Given I am logged in as a product owner
    And a product "ProductPlanner" exists
    And I am a member of "ProductPlanner"

  # Company-level OKRs
  @smoke
  Scenario: Create a company-level objective
    When I visit the company OKRs page
    And I click "+ New Objective"
    And I fill in:
      | title       | Increase customer retention           |
      | description | Focus on keeping existing customers   |
      | period      | 2026-Q1                               |
    And I submit the objective
    Then I should see "Increase customer retention" in the objectives list
    And the objective should show "active" status
    And the objective should show "0%" progress

  Scenario: Add key result to objective
    Given a company objective "Increase retention" exists
    When I add a key result:
      | title        | Reduce churn rate        |
      | target_value | 5                        |
      | unit         | %                        |
    Then I should see "Reduce churn rate" under "Increase retention"
    And the key result should show "0/5 %"

  @javascript
  Scenario: Update key result progress
    Given a company objective "Increase retention" exists
    And a key result "Reduce churn to 5%" with target 5 and current 0
    When I increment the key result progress
    Then the key result should show "1/5 %"
    And the key result should show "20%" progress bar

  # Product-level OKRs
  Scenario: Create a product-level objective
    When I visit the product OKRs page for "ProductPlanner"
    And I click "+ New Objective"
    And I fill in:
      | title  | Ship MVP by Q1           |
      | period | 2026-Q1                  |
    And I submit the objective
    Then I should see "Ship MVP by Q1" in the product objectives list

  # Card-OKR Linking
  Scenario: Link card to key result
    Given a company objective "Increase retention" exists
    And a key result "Reduce churn to 5%" exists
    And a card "Improve onboarding" exists in "Opportunity" stage
    When I view the card detail for "Improve onboarding"
    And I click "+ Link to Key Result"
    And I select "Increase retention → Reduce churn to 5%"
    And I fill in expected impact "Should reduce churn by 2%"
    And I submit the link
    Then I should see "Reduce churn to 5%" in the OKR linkage section
    And I should see expected impact "Should reduce churn by 2%"

  Scenario: Unlink card from key result
    Given a card "Improve onboarding" linked to "Reduce churn to 5%"
    When I view the card detail for "Improve onboarding"
    And I unlink from "Reduce churn to 5%"
    Then I should not see "Reduce churn to 5%" in the OKR linkage section

  # Stage Integration (Gates)
  Scenario: OKR linked gate auto-completes when card is linked
    Given a card "New feature" exists in "Opportunity" stage
    And the gate "okr_linked" is not completed
    And a key result "Ship 3 features" exists
    When I link "New feature" to "Ship 3 features"
    Then the gate "okr_linked" should be automatically completed
    And I should see "okr_linked" checked in the gate checklist

  # Validate stage - Record actual impact
  Scenario: Record actual impact in Validate stage
    Given a card "Improve onboarding" exists in "Validate" stage
    And "Improve onboarding" is linked to "Reduce churn to 5%"
    When I view the card detail for "Improve onboarding"
    Then I should see "Record Impact" button on the key result
    When I click "Record Impact"
    And I fill in actual impact "Reduced churn by 1.5%"
    And I save the impact
    Then I should see actual impact "Reduced churn by 1.5%"

  Scenario: OKR impact measured gate auto-completes when all impacts recorded
    Given a card "Improve onboarding" exists in "Validate" stage
    And "Improve onboarding" is linked to 2 key results
    And 1 actual impact is recorded
    Then the gate "okr_impact_measured" should not be completed
    When I record actual impact for the remaining key result
    Then the gate "okr_impact_measured" should be automatically completed

  # OKR Progress aggregation
  Scenario: Objective progress calculated from key results
    Given an objective "Ship MVP" with:
      | key_result  | target | current |
      | Feature A   | 100    | 50      |
      | Feature B   | 100    | 100     |
    When I view the company OKRs page
    Then "Ship MVP" should show "75%" overall progress

  # Period filtering
  Scenario: Filter OKRs by period
    Given the following objectives exist:
      | title      | period   |
      | Q1 Goals   | 2026-Q1  |
      | Q2 Goals   | 2026-Q2  |
    When I visit the company OKRs page
    Then I should see period tabs for "2026-Q1" and "2026-Q2"
    When I click on "2026-Q2" tab
    Then I should only see "Q2 Goals"
