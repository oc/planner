# Feature: AI Product Assistant

## Overview

An AI-powered assistant that helps users navigate the product process, providing contextual guidance, suggestions, and insights tailored to their role.

## Core Capabilities

### 1. Process Guidance
- Explain what's needed at each stage
- Suggest next steps based on current card state
- Identify missing gate requirements
- Recommend actions to unblock progress

### 2. Role-Tailored Responses
Different personas based on user role:

| Role | Assistant Focus |
|------|----------------|
| **Sales** | Customer value articulation, opportunity qualification, value quantification |
| **Product Owner** | Problem validation, scenario writing, success criteria, OKR alignment |
| **Tech Lead** | Feasibility assessment, effort estimation, risk identification |
| **Engineer** | Acceptance criteria clarification, scope boundaries |
| **Project Manager** | Progress tracking, blocker identification, stakeholder communication |

### 3. Actionable Suggestions
- "This opportunity is missing quantified value. Based on similar cards, consider: revenue impact, time saved, or customer retention."
- "This feature has 0 scenarios defined. Would you like me to draft some based on the problem statement?"
- "Gate 3 (Feasibility) requires Tech Lead sign-off. Tag @techleads or schedule a review."

### 4. Insights & Analytics
- "Cards from Sales typically spend 5 days in Discovery. This one has been here 12 days."
- "Features linked to KR3 have 80% completion rate. This card isn't linked to any OKR."
- "Similar features took average L-size effort. Current estimate is S."

## Implementation Approach

### Phase 1: Rule-Based Assistant
- Predefined prompts for common situations
- Gate checklist analysis
- Time-in-stage alerts
- Missing field warnings

### Phase 2: LLM-Enhanced
- OpenAI/Claude API integration
- Context-aware responses using card data
- Scenario generation assistance
- Problem statement refinement

### Phase 3: Learning
- Learn from completed cards
- Pattern recognition across products
- Predictive suggestions

## Agent Modes

### 1. Process Coach (Default)
- Guides users through the process
- Explains requirements
- Suggests next actions

### 2. Writing Assistant
- Helps draft problem statements
- Generates scenario templates
- Refines acceptance criteria

### 3. Analyst
- Provides metrics and insights
- Identifies bottlenecks
- Tracks OKR progress

## UI Integration

### Chat Interface
Slide-out panel on the right side:
```
┌─────────────────────────────┐
│ 🤖 Product Assistant        │
│ ─────────────────────────── │
│                             │
│ [User]: What's missing for  │
│ this card to move forward?  │
│                             │
│ [Assistant]: This card is   │
│ in Discovery (Stage 1).     │
│ Missing:                    │
│ - [ ] Problem statement     │
│ - [ ] Success criteria      │
│                             │
│ Would you like help         │
│ drafting a problem          │
│ statement?                  │
│                             │
│ [Yes] [No, show examples]   │
│                             │
│ ─────────────────────────── │
│ [Type your question...]     │
└─────────────────────────────┘
```

### Inline Suggestions
Contextual tips on card forms:
```
┌─────────────────────────────┐
│ Problem Statement           │
│ ┌─────────────────────────┐ │
│ │                         │ │
│ └─────────────────────────┘ │
│ 💡 Tip: A good problem      │
│ statement is one paragraph, │
│ uses no solution language,  │
│ and names the affected      │
│ user segment.               │
│                             │
│ [Generate draft]            │
└─────────────────────────────┘
```

## Technical Notes

### Models
```ruby
Conversation
├── user_id: references
├── card_id: references (nullable, for card-specific chats)
├── product_id: references (nullable, for product-wide context)
└── has_many: messages

Message
├── conversation_id: references
├── role: enum (user, assistant, system)
├── content: text
├── metadata: jsonb (model used, tokens, etc.)
└── created_at: datetime
```

### API Integration
- Use OpenAI/Anthropic API with system prompts defining role
- Include card/product context in messages
- Cache common responses
- Rate limit per user

### Privacy
- No card data sent to external APIs without user consent
- Option for self-hosted LLM (Ollama, llama.cpp)
- Audit log of AI interactions

## Out of Scope (v1)
- Voice interface
- Autonomous actions (AI makes changes)
- Cross-product learning
- Custom model fine-tuning
