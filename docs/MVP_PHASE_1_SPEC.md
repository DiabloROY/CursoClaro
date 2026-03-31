# CursoClaro MVP Phase 1 Specification

## Purpose

This document defines the exact scope of `MVP Phase 1` for CursoClaro.

Its goal is to turn the product vision into a buildable, intentionally narrow, and internally consistent first execution scope.

This MVP is designed to validate the product's central value proposition:

- CursoClaro should organize what today gets mixed in school and course WhatsApp groups.

## MVP Phase 1 Goal

Families should be able to:

- understand what is important for each child
- clearly distinguish official school information from community activity
- interact with birthdays and invitations more cleanly than through WhatsApp alone
- respond to attendance and gift participation from a structured interface

## MVP Phase 1 Product Promise

CursoClaro will not try to replace WhatsApp in Phase 1.

Instead:

- WhatsApp may continue to act as a notice/distribution layer
- CursoClaro becomes the structured place where important course content is read and acted on

## In-Scope Modules

### 1. Family

Included in phase 1:

- family-first home context
- linked children display
- family person-child relationship support
- add/link child flow

### 2. School

Included in phase 1:

- basic institutional inbox
- official notices
- reminders
- meetings / important announcements

### 3. Community

Included in phase 1:

- birthdays
- invitations
- gift collection linked to invitations
- basic community item presentation

### 4. WhatsApp Notice Layer

Included in phase 1:

- WhatsApp-compatible outbound notice concept for published invitations or key community items

This should be treated as an alert/distribution behavior, not the main action surface.

### 5. Services Foundation

Included as foundation only in phase 1:

- service-provider domain kept in the data model and architecture
- no complete family-facing services module in phase 1 UX
- no public delivery of invoices, menus, or service dashboards in phase 1

## Out of Scope for Phase 1

The following should not be treated as phase 1 deliverables:

- full service-provider module exposed to families
- catering/comedor operations in family UX
- invoices and menus in family UX
- documentation / health module
- vaccine schedule logic
- full financial processing
- advanced moderation
- advanced workflow engines
- advanced school-side admin console
- production-grade external integrations with Classroom or email ingestion
- full mobile native app
- AI image generation as a hard requirement

AI-assisted design support for invitations may remain a future-ready concept, not a blocking MVP dependency.

## Primary Actors in Phase 1

### Family Adult

Primary actor for phase 1.

Canonical role:

- `family_adult`

Can:

- access Family Home
- see linked children
- read school notices
- read community items
- open invitations
- respond to attendance
- respond to gift participation

### Community Publisher

For MVP purposes, this can be a family/community organizer role or a controlled internal role.

Can:

- create birthday invitation
- configure gift collection details
- publish invitation

### School Publisher

For MVP purposes, this can be a school/admin/staff role or internal support role.

Can:

- create school notice
- publish official communication

## Phase 1 Navigation

The family-facing MVP should expose:

- `Inicio`
- `Colegio`
- `Comunidad`
- `Mi familia`

`Servicios` may exist as a placeholder or not be visible in phase 1 depending on implementation strategy, but full service functionality is not part of phase 1 delivery.

The `Services` domain is part of the overall product model and may exist as hidden foundation in phase 1, but it is not a complete phase 1 family-facing module.

## Required MVP Screens

### 1. Public Landing

Purpose:

- explain the value proposition
- support pilot onboarding

Required content:

- hero positioning
- product explanation
- visual preview
- pilot CTA
- footer with official brand treatment

### 2. Access / Entry Flow

Purpose:

- allow a family person with the `family_adult` role to enter the platform

### 3. Family Home

Purpose:

- summarize the family context
- show linked child or children
- highlight pending items
- separate official and community signals

Required elements:

- current child context
- pending summary
- upcoming birthday or relevant community item
- official notices summary
- navigation to child context and invitation flows

### 4. Student Context

Purpose:

- show a selected child's current context

Required elements:

- child identity
- current school/course
- relevant summary items

### 5. School Inbox

Purpose:

- display official communications only

Required elements:

- list of official items
- type distinction
- detail view
- read state or basic seen state if available

### 6. Community Home

Purpose:

- display structured community content

Initial item types:

- birthdays
- invitations
- gift-related items when tied to invitations

### 7. Create Invitation

Purpose:

- structured invitation creation

Required fields:

- child selector with autocomplete
- date
- start time
- end time
- place
- address
- message
- design theme
- gift collection optional setup

Rules:

- `Cómo llegar` is included by default when address exists
- calendar support is receiver-facing, not creator-facing
- age can be calculated from `birth_date` if available
- if `birth_date` is unavailable, the flow must allow manual `age turning`

### 8. Invitation Preview

Purpose:

- review invitation before publication

### 9. Invitation Detail

Purpose:

- allow recipients to consume and act on the invitation

Required actions:

- confirm attendance
- indicate non-attendance
- open Maps link
- add event to calendar
- indicate gift participation
- see alias and gift info if gift is enabled

### 10. Add / Link Child

Purpose:

- let a family person link another child without recreating the person record

Required rule:

- the person record must not be duplicated

### 11. My Family

Purpose:

- show linked children and basic family context

## Functional Requirements

## Family Home Requirements

### FH-1

The authenticated family person must be able to access a family-first home view.

### FH-2

The home must display linked child context.

### FH-3

The home must visually separate:

- school information
- community information

### FH-4

The home must highlight pending or relevant items.

## School Communication Requirements

### SC-1

Official communication must be visually distinct from community items.

### SC-2

Official communication must be structured and queryable.

### SC-3

The family must be able to open a detail screen for an official notice.

## Community Invitation Requirements

### CI-1

The system must allow creation of a birthday/community invitation.

### CI-2

The invitation must allow child selection from the database via typed search/autocomplete.

### CI-3

The invitation must support `start time` and `end time`.

### CI-4

The invitation must support `location name` and `address`.

### CI-5

When an address exists, the invitation must expose a default `Cómo llegar` behavior.

### CI-6

Recipients must be able to add the event to their own calendar.

### CI-7

The creator must be able to choose a visual theme.

Phase 1 theme categories:

- superheroes
- videogames
- animals
- minimal
- colorful

### CI-8

Recipients must be able to respond to attendance.

### CI-9

Gift participation must be separate from attendance response.

### CI-10

If gift collection is enabled, the invitation must show alias and optional suggested amount.

### CI-11

Publishing an invitation must make it visible in CursoClaro and trigger a WhatsApp notice pathway.

## Data Rules for Phase 1

### DR-1

People acting as parents, mothers, fathers, or tutors must not be duplicated by school, course, or child.

### DR-2

Students must not be duplicated by year or course.

### DR-3

Student identity must remain separate from academic enrollment.

### DR-4

If `student.birth_date` exists, birthday age can be calculated from it.

### DR-5

If `student.birth_date` does not exist, age-turning input must be allowed for the invitation flow.

### DR-6

Gift participation and attendance must be persisted independently.

## WhatsApp Notice Requirements

### WA-1

WhatsApp is a notice/distribution layer, not the primary action interface.

### WA-2

A published invitation should be representable as a WhatsApp notice with a link back to CursoClaro.

### WA-3

The link target should direct the recipient into the structured invitation detail experience.

## Security and Privacy Requirements for Phase 1

### SP-1

All access control must be enforced server-side.

### SP-2

Only linked family users may access child-specific invitation and family content.

### SP-3

No secrets may be hardcoded in code or frontend bundles.

### SP-4

Sensitive files are out of phase 1 scope, but all private data flows must still respect the baseline security model.

### SP-5

The architecture must remain compatible with MFA and stronger privileged-role security, even if not required for all family users in phase 1.

## Phase 1 Visual Requirements

The MVP must preserve the CursoClaro visual direction:

- use official `logo.png`
- use official compact icon where needed
- white or very light header
- soft blue contextual strip where appropriate
- light background
- rounded white cards
- orange/coral primary CTA
- semantically meaningful status colors

Footer baseline:

- `© CursoClaro · Simplificando la organización del curso`

## Acceptance Criteria for Phase 1

Phase 1 is considered complete only if:

1. A family adult can enter the app and see a family-first home.
2. Official communication is visibly separate from community content.
3. A child can be selected and contextualized correctly.
4. An invitation can be created with structured fields.
5. An invitation can be published.
6. The published invitation can be opened and responded to.
7. Attendance and gift participation are tracked separately.
8. Maps and calendar receiver actions are available in the invitation detail experience.
9. WhatsApp notice flow is conceptually or functionally supported as an outbound alert layer.
10. People and students are not duplicated as a workaround.
11. Security baseline expectations are respected.

## Recommended Build Order

1. data model and SQL
2. auth and permissions
3. family domain
4. school communication module
5. invitation domain
6. family-facing app shell
7. invitation create/publish/respond flow
8. WhatsApp notice support
9. hardening and validation
