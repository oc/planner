# Feature: Kanban Board

## Overview

The Kanban board is the primary view for managing cards through the product development stages.

## Stages (Columns)

1. **Opportunity** (Stage 0) - Sales identifies customer need
2. **Discovery** (Stage 1) - PO validates problem, defines success criteria
3. **Definition** (Stage 2) - PO creates scenarios, acceptance criteria
4. **Feasibility** (Stage 3) - Tech Lead assesses approach and effort
5. **Commitment** (Stage 4) - PO + Tech lock scope
6. **Build** (Stage 5) - Engineering implements
7. **Validate** (Stage 6) - PO measures success
8. **Operate** (Stage 7) - Platform maintains
9. **Done** - Completed and validated

## Card Appearance

Cards display:
- Top border color by type (blue=opportunity, green=feature, yellow=task, red=issue, purple=jtbd)
- Type icon
- Title
- Owner avatar
- Gate completion indicator (e.g., "3/5")
- Priority badge (if critical or high)

## Interactions

### Drag and Drop
- Cards can be dragged between stages
- Position within stage is preserved
- Gate warnings shown when moving to next stage with incomplete gates

### View Modes
- **All Stages** - Full pipeline view
- **Pre-Build** - Stages 0-4 (for Sales/PO)
- **Build & Beyond** - Stages 5-7+ (for Engineering)
- **My Cards** - Filtered to current user

### Filters
- Card type
- Owner
- Priority
- OKR linkage

## Routes

- `GET /products/:slug` - Show board
- `PATCH /cards/:id/move` - Move card to new stage/position

## UI Components

### Board Container
```
┌────────────────────────────────────────────────────────────┐
│ [Product Name]              [+ New Card] [Filters] [View] │
├────────────────────────────────────────────────────────────┤
│ Stage columns with cards...                                │
└────────────────────────────────────────────────────────────┘
```

### Stage Column
```
┌─────────────┐
│ Stage Name  │
│ (count)     │
├─────────────┤
│ [Card]      │
│ [Card]      │
│ [Card]      │
│             │
│ [+ Add]     │
└─────────────┘
```

### Card Preview
```
┌─────────────────┐
│ 🎯 Title        │  <- type icon + title
│ @owner  3/5 ✓   │  <- avatar + gate progress
│ [HIGH]          │  <- priority badge (if applicable)
└─────────────────┘
```

## Stimulus Controllers

### `kanban_controller.js`
Handles:
- Drag start/end events
- Drop zone highlighting
- POST to server on drop
- Turbo Stream response handling

### `filter_controller.js`
Handles:
- Filter button toggles
- URL state management
- Turbo Frame reload with filters

## Technical Notes

- Uses Turbo Frames for card detail slide-over
- Uses Turbo Streams for real-time updates
- Cards ordered by `position` column (acts_as_list)
- Stages are enum, not database records (fixed process)
