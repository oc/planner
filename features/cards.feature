# Feature: Cards CRUD
# GitHub Issue: To be linked after creation
#
# Cards are the work items that move through the product process stages.
# Each card has a type (opportunity, feature, task, issue, jtbd) with
# type-specific metadata fields.
#
# Technical Implementation:
# - Model: Card (app/models/card.rb)
# - Controller: CardsController (app/controllers/cards_controller.rb)
# - Views: app/views/cards/
# - Type metadata stored in JSONB column

@cards
Feature: Cards CRUD
  As a product owner
  I want to create and manage cards
  So that I can track work through the product process

  Background:
    Given I am logged in as a product owner
    And a product "ProductPlanner" exists
    And I am a member of "ProductPlanner"

  @smoke
  Scenario: Create a new feature card
    When I visit the product "ProductPlanner" page
    And I click "+ New Card"
    And I fill in:
      | title       | User authentication         |
      | card_type   | feature                     |
      | priority    | high                        |
      | stage       | opportunity                 |
      | description | Allow users to sign in      |
    And I submit the card
    Then I should see "User authentication" in the "Opportunity" column
    And the card should show the green feature type indicator

  Scenario Outline: Create cards of different types
    When I create a card with type "<type>"
    Then the card should show the <color> type indicator

    Examples:
      | type        | color  |
      | opportunity | blue   |
      | feature     | green  |
      | task        | yellow |
      | issue       | red    |
      | jtbd        | purple |

  # Type-specific metadata fields
  Scenario: Opportunity card has customer fields
    When I create a new card with type "opportunity"
    Then I should see metadata fields:
      | Customer Name      |
      | Stated Problem     |
      | Quantified Value   |
      | Commitment Level   |

  Scenario: Feature card has scope fields
    When I create a new card with type "feature"
    Then I should see metadata fields:
      | Effort Estimate |
      | Feasibility     |
      | In Scope        |
      | Out of Scope    |

  Scenario: Task card has due date field
    When I create a new card with type "task"
    Then I should see metadata fields:
      | Due Date         |
      | External Reference |

  Scenario: Issue card has severity field
    When I create a new card with type "issue"
    Then I should see metadata fields:
      | Severity           |
      | Reported By        |
      | Reproduction Steps |

  Scenario: JTBD card has job statement field
    When I create a new card with type "jtbd"
    Then I should see metadata fields:
      | Job Statement |
      | Context       |

  @javascript
  Scenario: Type selector shows/hides appropriate metadata fields
    When I start creating a new card
    And I select card type "opportunity"
    Then I should see the opportunity metadata fields
    And I should not see the feature metadata fields
    When I change card type to "feature"
    Then I should see the feature metadata fields
    And I should not see the opportunity metadata fields

  Scenario: Fill in opportunity metadata
    When I create an opportunity card:
      | title             | Equinor media monitoring |
      | customer_name     | Equinor                  |
      | stated_problem    | Need faster alerts       |
      | quantified_value  | $50k ARR                 |
      | commitment_level  | piloting                 |
    And I view the card detail
    Then I should see:
      | Customer  | Equinor            |
      | Value     | $50k ARR           |
      | Commitment| piloting           |

  # Edit and Delete
  @javascript
  Scenario: Edit card details
    Given a card "Feature X" exists
    When I view the card detail for "Feature X"
    And I click "Edit"
    And I change the title to "Feature X Updated"
    And I save the card
    Then I should see "Feature X Updated"

  @javascript
  Scenario: Delete a card
    Given a card "Feature X" exists in "Discovery" stage
    When I view the card detail for "Feature X"
    And I click "Delete"
    And I confirm the deletion
    Then I should not see "Feature X" on the board

  # Card detail slide-over
  Scenario: View card detail shows all information
    Given a card "Feature X" exists with:
      | card_type   | feature              |
      | stage       | definition           |
      | priority    | high                 |
      | description | Implement user login |
    When I view the card detail for "Feature X"
    Then I should see:
      | Title       | Feature X            |
      | Type        | feature              |
      | Stage       | Definition           |
      | Priority    | high                 |
      | Description | Implement user login |
    And I should see the gate checklist
    And I should see the scenarios section
    And I should see the OKR linkage section
    And I should see the comments section
    And I should see the activity section
