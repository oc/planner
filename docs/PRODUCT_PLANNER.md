# ProductPlanner: Rails Application Plan

A Rails 8 application for managing the product development process from opportunity to operation.

## Overview

**Goal:** Build a product planning tool that implements the 8-stage product process, with Kanban visualization, OKR tracking, and bi-directional sync with external tools (Shortcut/Linear, GitHub/GitLab).

**First customer:** Self (dogfooding). Track ProductPlanner's own development using ProductPlanner.

**Approach:** Start simple, single-tenant. Use Hotwire/Turbo for reactive UI. Single Card model with JSONB for flexibility.

---

## Domain Model

### Core Entities

```
User
├── name: string
├── email: string (unique)
├── github_username: string (nullable)
├── phone: string (nullable)
├── avatar_url: string (nullable, fallback to Gravatar)
├── role: enum (sales, product_owner, project_manager, tech_lead, engineer, design)
└── has_many: memberships, cards (as owner), comments, activities

Product
├── name: string
├── slug: string (unique, URL-friendly)
├── description: text
├── status: enum (active, archived)
├── has_many: memberships, cards, objectives
└── settings: jsonb (stage configuration, integrations)

Membership (join: User <-> Product)
├── user_id, product_id
├── role: enum (owner, member, viewer)
└── notifications: boolean

Card (the work item moving through stages)
├── product_id: references
├── owner_id: references User
├── card_type: enum (opportunity, feature, task, issue, jtbd)
├── title: string
├── description: text (rich text / markdown)
├── stage: enum (opportunity, discovery, definition, feasibility, commitment, build, validate, operate, done)
├── priority: enum (critical, high, medium, low)
├── position: integer (ordering within stage)
├── metadata: jsonb (type-specific fields)
├── gate_checklist: jsonb (stage gate requirements)
├── has_many: scenarios, comments, activities, external_links
├── belongs_to: parent_card (optional, for hierarchy)
└── has_many: child_cards

Scenario (Given/When/Then acceptance criteria)
├── card_id: references
├── title: string
├── given: text
├── when_clause: text
├── then_clause: text
├── status: enum (draft, approved, verified, failed)
└── position: integer

Objective (OKR - can be company-level or product-level)
├── product_id: references (nullable for company-level)
├── title: string
├── description: text
├── period: string (e.g., "2026-Q1")
├── status: enum (active, achieved, missed, abandoned)
└── has_many: key_results

KeyResult
├── objective_id: references
├── title: string
├── target_value: decimal
├── current_value: decimal
├── unit: string (e.g., "customers", "hours", "%")
├── has_many: card_key_results
└── status: enum (on_track, at_risk, behind, achieved)

CardKeyResult (join: Card <-> KeyResult)
├── card_id, key_result_id
├── expected_impact: text
└── actual_impact: text (filled in Stage 6)

ExternalLink (integrations)
├── card_id: references
├── provider: enum (github, gitlab, shortcut, linear)
├── external_id: string
├── external_url: string
├── sync_status: enum (synced, pending, error)
├── last_synced_at: datetime
└── metadata: jsonb

Comment
├── card_id: references
├── user_id: references
├── body: text
└── created_at: datetime

Activity (audit log)
├── trackable: polymorphic
├── user_id: references
├── action: string
├── changes: jsonb
└── created_at: datetime
```

---

## Implementation Phases

### Phase 1: Foundation (MVP) ✅ COMPLETE
- Rails 8 setup with PostgreSQL, Tailwind, Hotwire
- Authentication with authentication-zero
- Core models: User (with roles), Product, Membership, Card, Comment, Scenario, Activity, ExternalLink
- Kanban board with drag-drop (Stimulus controller)
- Card detail slide-over panel
- Comments with Turbo Stream updates
- Seed data with ProductPlanner product (dogfooding)

### Phase 2: Process Enforcement
- Gate validation and enforcement
- Scenarios (Given/When/Then)
- Card types with type-specific fields
- Activity log

### Phase 3: OKR Integration
- Objectives and Key Results
- Card-OKR linking
- Progress visualization

### Phase 4: External Integrations
- GitHub sync
- Shortcut sync
- Webhook handlers

### Phase 5: Polish
- Role-based views
- Advanced filtering
- Dashboard
- Keyboard shortcuts

---

## Tech Stack

- Rails 8.0
- PostgreSQL
- Hotwire (Turbo + Stimulus)
- Tailwind CSS
- Sidekiq (background jobs)

See `docs/features/` for detailed feature specs.
