# CursoClaro Product Functional Rules

## Purpose

This document consolidates the current functional product rules, UX principles, actor model, and phased scope decisions for CursoClaro.

It is intended to guide product decisions, architecture, data model design, frontend flows, and future implementation work.

## Product Positioning

CursoClaro is not intended to replace WhatsApp.

CursoClaro is intended to organize the important content that is currently mixed inside school and course WhatsApp groups.

Core positioning:

- `WhatsApp para avisar. CursoClaro para ordenar.`
- `Tu curso, más claro.`

Supporting promise:

- CursoClaro should help families find, understand, and act on important course and school information without digging through noisy chats, emails, or copied messages.

## Core Product Principle

The product must optimize for:

- clarity
- speed of understanding
- visual simplicity
- low-friction family use
- structured information instead of noisy chat behavior

The system must always privilege `clear structure` over `free-form messaging`.

## Primary Users and Actors

### Adults / Families

Primary end users.

They need to:

- see relevant information by child
- confirm attendance
- respond to invitations
- participate in community actions
- view official school communications
- view service-related information
- manage linked children and family context

### Schools / Staff

Institutional actors.

They need to:

- publish official communications
- send reminders
- share meeting notices
- request confirmations or authorizations
- communicate school-relevant information in an auditable way

### Course Community / Administrators

Community actors.

They need to:

- create birthdays
- create invitations
- coordinate gift collections
- organize community purchases
- publish lost and found items
- coordinate lightweight course logistics

### Service Providers

External institutional actors associated with a child or family.

Examples:

- catering / comedor
- transportation
- extracurricular providers
- other school-adjacent service providers

They need to:

- publish operational notices
- share invoices
- share schedules or menus
- surface relevant information tied to a child

### Student

The student is the contextual center of many product flows.

Most product modules should be filterable or understandable in relation to a specific student.

## Unique Identification Rules

CursoClaro must support a unique real-world identifier strategy for all major actor entities in order to minimize duplication and preserve cross-module consistency.

### Adult Identification Rule

Adults should support national identification fields appropriate to Argentina.

Preferred identifiers:

- `DNI`
- `CUIL`

Functional rule:

- at least one valid unique adult identifier should be supported
- when both exist, both may be stored
- duplicate adults should be prevented using normalized identifier rules

### Student Identification Rule

Students should support:

- `DNI`
- `CUIL` optionally when available

Functional rule:

- `DNI` should be the primary unique identifier for most children in MVP and near-term phases
- the system must not assume all children have active/usable `CUIL`
- future support for `CUIL` may exist without making it mandatory

### School Identification Rule

Schools/institutions should support unique tax or legal identifiers where applicable.

Preferred identifier:

- `CUIT`

Functional rule:

- each school should support a unique institutional identifier
- duplicate school creation should be prevented by normalized legal identifier rules where the identifier is known

### Service Provider Identification Rule

Service providers should support unique legal identifiers where applicable.

Preferred identifiers:

- `CUIT`
- `CUIL` where legally appropriate for the provider type

Functional rule:

- each service provider should support a unique legal identifier
- duplicate provider creation should be prevented by normalized identifier rules where the identifier is known

### Identifier Normalization Rule

All supported identifiers must be normalized before duplicate checks and validation.

Minimum normalization:

- strip spaces
- strip dashes
- store canonical numeric representation
- optionally preserve formatted display value separately

### Duplicate Prevention Rule

CursoClaro must not rely only on names to avoid duplication.

The system should use legal/national identifiers as primary anti-duplication signals when present.

This rule is critical for:

- adults
- students
- schools
- service providers

### CUIT / CUIL Validation Rule

The product must support validation for Argentinian `CUIT` / `CUIL` style identifiers.

Functional requirement:

- the system must validate structure before accepting or matching the identifier
- validation must include check-digit verification
- validation alone does not prove institutional or legal existence; it only proves structural correctness

Implementation note:

- the commonly used validation approach is the Modulo 11 weighted check-digit method applied to the first 10 digits
- the standard weights used in common implementations are: `5,4,3,2,7,6,5,4,3,2`
- the verifier is derived from the weighted sum and final modulo logic

This validation rule should be implemented as a reusable domain utility and applied wherever `CUIT` or `CUIL` data is captured.

### Identifier Enrichment Rule

The product should be designed to support future identifier-based enrichment for institutions and service providers.

Examples of enrichable fields:

- legal name
- address
- city
- postal code

Rules:

- identifier enrichment is a future-capability, not a hard MVP dependency
- enrichment should be treated as assisted prefill, not unquestioned truth
- users should be able to confirm or edit enriched values before saving
- structural identifier validation should exist independently from enrichment

This rule is especially relevant for:

- `school`
- `service_provider`

### DNI Validation Rule

The system should validate `DNI` structure at least syntactically.

Minimum validation:

- numeric-only after normalization
- expected length rules according to business decision
- duplicate checks against existing records where appropriate

## Role Model Rules

CursoClaro should support a minimum platform role model from the beginning, even if some roles are introduced later in UI.

Canonical role names must be kept in English in backend, DB, and authorization logic.

Frontend labels can remain in Spanish.

### Minimum roles

- `platform_admin`
- `school_admin`
- `service_provider_admin`
- `course_representative`

### `platform_admin`

Purpose:

- full control over the platform

Capabilities:

- unrestricted administration
- access to setup and oversight tools
- operational control over institutions, providers, and moderation/admin tasks

### `school_admin`

Purpose:

- institution-scoped administration

Capabilities:

- manage only its own school context
- publish school communications
- manage school-relevant records within its scope

Restriction:

- must not access data from other institutions unless explicitly granted at a higher platform level

### `service_provider_admin`

Purpose:

- service-provider-scoped administration

Capabilities:

- manage only its own provider context
- publish provider/service information
- operate only over services, students, and records legitimately linked to that provider scope

Restriction:

- must not access unrelated school/community data

### `course_representative`

Purpose:

- limited community operator, often a parent or guardian

Capabilities:

- create or share only approved community items
- operate only within enabled course/community flows

Restriction:

- must not gain institutional admin rights
- must not access unrelated sensitive data

### Role Display Rule

Roles must remain canonical in English in data and code.

Example display mappings:

- `platform_admin` → `Admin`
- `school_admin` → `Institución`
- `service_provider_admin` → `Prestador de servicios`
- `course_representative` → `Referente de curso`

## Main Product Modules

CursoClaro should be functionally organized into these modules:

### 1. Family

Contains:

- linked children
- linked adults
- family relationships
- child context
- key pending items by child

Purpose:

- establish who the family is
- which children are linked
- what belongs to each child

### 2. School

Contains:

- official notices
- reminders
- meetings
- institutional messages
- school-authorized communications

Purpose:

- separate official communication from community noise

### 3. Community

Contains:

- birthdays
- invitations
- gift collections
- community purchases
- end-of-year events
- lost and found
- course logistics

Purpose:

- structure course social/community activity without becoming a generic chat

### 4. Services

Contains:

- comedor / catering
- invoices
- menus
- transportation
- extracurricular service updates
- service-related notices

Purpose:

- centralize operational child-related services that today arrive via email or scattered channels

### 5. Documentation / Health

Future-oriented module.

Contains:

- physical fitness certificates
- vaccine records
- expiration reminders
- student certificates
- required family or child documents

Purpose:

- centralize non-chat school-family documentation that should not be lost

## Cross-Module Rule

Every important item in CursoClaro should make these three things obvious:

- who sent it
- which child it affects
- whether it requires action

## UX Principles

CursoClaro must feel:

- visually friendly
- parent-facing
- extremely intuitive
- light and clean
- mobile-first

The interface should avoid:

- dense configuration-first experiences
- complex menus
- generic “feed” behavior
- visually undifferentiated content

The product should strongly separate:

- official / school content
- community content
- service-related content
- sensitive documentation content

## Communication Model Rules

### School Communications

School communication should ideally be authored directly inside CursoClaro.

That is the target model.

Email, Classroom, or copied WhatsApp messages may exist as transitional operational sources, but they should not be the long-term source of truth.

Rules:

- school messages should be structured
- school messages should be auditable
- school messages should be visually differentiated
- school messages should support future read / recipient tracking

### Community Communications

Community communication should not behave like free chat by default.

Community items should be typed and structured.

Examples:

- birthday
- invitation
- gift collection
- community purchase
- lost and found

Rules:

- each type should have its own UI structure
- actions should be simple and obvious
- content should remain easy to scan

### Service Communications

Service communications must belong to a third actor category, separate from school and community.

Rules:

- service provider identity must be explicit
- service content must be associated to a child when relevant
- service items must not be mixed visually with informal community content

## WhatsApp Role

WhatsApp should be treated as a notification and circulation layer, not the system of record.

Rules:

- WhatsApp may notify that new content exists
- WhatsApp may contain share links into CursoClaro
- the actual action should happen in CursoClaro

Examples:

- invitation published in CursoClaro also sends a WhatsApp notice
- the parent taps the link and responds inside CursoClaro

## Family and Student Rules

### Adult Identity

An adult must exist only once in the system.

An adult must not be duplicated by school, course, or year.

### Student Identity

A student must exist only once in the system.

A student must not be duplicated by year, course, or school movement.

### Student Context

A student must be independent from academic enrollment history.

Academic context should be represented separately from student identity.

### Family Context

Family context is the primary user-facing experience layer.

But family grouping must not replace permission logic or academic logic.

## Invitation and Birthday Rules

### Invitation Creation

The invitation creation flow must be simple, visually guided, and structured.

It should support:

- selecting the child
- defining event details
- generating the invitation design
- configuring attendance response
- optionally configuring a gift collection

### Child Selector

When creating a birthday or child-specific invitation, the user should select the child from the database.

Rules:

- the selector should support autocomplete while typing
- the system should suggest child matches to accelerate selection
- the flow should not require browsing a large flat list when the child can be found by name

### Birthday Age Rule

The system should support `birth_date` as a child profile field.

Functional rule:

- if `birth_date` exists, the system may calculate the age the child is turning
- if `birth_date` does not exist, invitation flows must allow the creator to manually specify `age turning`
- absence of `birth_date` must not block birthday invitation creation in the MVP

This rule should remain valid even if the full `birth_date` becomes more useful in future modules.

### Event Time Rule

Invitations must support:

- `start time`
- `end time`

Invitations should not be modeled as single-point time only when event duration matters.

Example:

- `18:00 to 20:30`

### Location Rule

Invitations with an address should include route/navigation support by default.

Rules:

- if a valid address is provided, the invitation should expose `Cómo llegar`
- this should generate a Google Maps-compatible link
- this should not be treated as optional in the default invitation experience

### Calendar Rule

Adding to calendar is a receiver-facing action, not a creator-facing setup choice.

Rules:

- invitation recipients should be able to add the event to their calendar
- the invitation should support Google Calendar and Outlook-compatible behavior
- an `.ics` fallback should be considered in implementation
- the creator should not need to configure this manually in standard flows

### Design Generation Rule

Design assistance may use AI-backed generation, but the product should present it as a simple design automation feature, not a technical AI workflow.

Rules:

- users choose a visual theme
- the system offers ready-to-use variants
- the system should not force prompt-writing
- layout and readability should remain controlled by CursoClaro

Suggested invitation design categories:

- superheroes
- videogames
- animals
- minimal
- colorful

The `videogames` category should be broad enough to cover common child-relevant aesthetics such as Roblox, Brawl Stars, Astrobot, and similar references.

### Attendance Response Rule

Invitations should support explicit attendance response.

Recipients should be able to indicate:

- yes, attending
- not attending

Attendance response must be stored independently from gift participation.

### Gift Participation Rule

Gift participation must be modeled as separate from event attendance.

Because these are different decisions.

A recipient may:

- attend and participate
- attend and not participate
- not attend and still participate

Rules:

- invitations may optionally enable gift participation
- gift participation should expose alias / payment destination when configured
- gift participation should support basic status tracking

### Gift Tracking Rule

Gift collection tracking should be structured, not buried inside invitation free text.

At minimum, the system should support:

- gift enabled / disabled
- alias or payment destination
- optional suggested amount
- participant count
- optional paid/not-paid tracking later

## Publication Rule

When a community invitation is published, it should:

- appear inside relevant family dashboards in CursoClaro
- optionally trigger a WhatsApp notice to recipients or course group contexts

The dashboard is the structured system of record.

WhatsApp is the alert/distribution surface.

## Service Module Rules

### General Service Rule

Services should be modeled as associated to the student or family, not as generic community content.

### Service Provider Identity Rule

The system must support visible identity data for each `service_provider`.

At minimum, a service provider should support:

- `name`
- `display_name`
- `logo`
- `status`

Optional but recommended future-support fields:

- `brand_color`
- `description`
- `contact_email`
- `contact_phone`
- `website`

Functional expectations:

- the provider identity should be visible in service cards, notices, invoices, menus, and service detail views
- provider identity should be modeled explicitly in the entity-relationship design
- provider identity should be capturable and editable through admin or management screens

### Service Provider School Association Rule

The product must support a `service_provider` being associated with multiple `schools`.

The product must also support a `school` being associated with multiple `service_providers`.

Therefore:

- the relationship between `service_provider` and `school` must be modeled explicitly
- the operational relationship between `service_provider` and `student` / `family` must be modeled separately
- school reference must not be treated only as an attribute inside a client relationship row

This rule must be considered in:

- the entity-relationship model
- service provider management screens
- school-service assignment flows

### Catering / Comedor

The first service use case with strong product value is the comedor / catering service.

It may include:

- menu
- weekly menu
- notices
- invoices
- due dates
- student restrictions or allergies

### Service Information Types

Service modules may eventually support:

- operational notices
- service-specific schedules
- invoices / billing artifacts
- child-level service profile data

### Child Food Restriction Rule

For comedor-related services, the system should eventually support child-level food notes such as:

- allergies
- restrictions
- relevant meal observations

These should be treated as controlled service profile data, not informal message content.

## Documentation / Health Rules

This module is not required for phase 1, but should be contemplated in the long-term product model.

Possible contents:

- physical fitness certificate
- vaccine records
- expiration dates
- uploaded certificates
- reminders

Rules:

- this is sensitive data
- it must remain clearly separated from community content
- it should not be treated as casual social information

### Vaccination Calendar Rule

The system may eventually surface vaccination-related records and reminders.

But official vaccination schedule automation should only be implemented if maintained carefully and responsibly.

Until then, the safer path is:

- record keeping
- expiration reminders
- uploaded documentation

## Institutional Identity Rules

### School Identity Rule

The system must support visible institutional identity data for each `school`.

At minimum, a school should support:

- `name`
- `display_name`
- `logo`
- `status`

Optional but recommended future-support fields:

- `short_name`
- `brand_color`
- `contact_email`
- `contact_phone`
- `address`
- `website`

Functional expectations:

- school identity should be shown consistently in official communications, child context views, headers, and navigation context
- school identity should be modeled explicitly in the entity-relationship design
- school identity should be capturable and editable through institutional setup or admin screens

### Institutional Identity Capture Rule

Both `school` and `service_provider` identity data must be considered first-class setup information, not secondary presentation-only metadata.

This means the product should eventually provide dedicated screens or forms to:

- create the institution/provider
- upload or assign logo
- define visible name
- define operational status
- maintain identity information over time

These screens do not need to be part of phase 1 family-facing MVP, but the data model and management flows must be planned from the start.

## MVP Scope Rules

### Phase 1: Core MVP

Must prioritize:

- Family / child context
- School communications
- Community content
- invitation flows
- birthdays
- gift collections
- pending items

Main validation question:

- does CursoClaro organize the chaos of WhatsApp better than current fragmented workflows?

### Phase 2: Operational Extension

Should consider:

- service provider modules
- comedor
- invoices
- menus
- more family management

### Phase 3: Extended Family-School Hub

May include:

- documentation / health
- broader service provider ecosystem
- deeper automation
- more advanced integrations

## Delivery Rule for Development

Whenever a new feature is designed or implemented, development should verify:

1. Is the actor explicit?
2. Is the child context explicit?
3. Is the action or non-action state explicit?
4. Is the module boundary clear?
5. Is the flow simpler than the current WhatsApp/email/Classroom behavior?

If the answer to these is not clearly yes, the feature should be reconsidered before implementation.

## Competitive Risks and Product Lessons

The following lessons should be considered based on recurring complaints and friction patterns seen in adjacent or competing tools such as school communication apps, parent portals, Google Classroom-like flows, and school-family messaging products.

These lessons are product-wide and should influence future design even when they are not part of phase 1.

### 1. Channel Fragmentation Risk

Families often receive relevant information across too many places:

- WhatsApp
- email
- LMS / classroom tools
- portals
- school apps
- copied or re-posted messages

Product lesson:

- each information type should have a clear source-of-truth policy
- CursoClaro should avoid becoming just one more parallel channel with duplicated content
- module boundaries must remain explicit

### 2. Notification Overload Risk

A recurring complaint in education and parent apps is excessive notification volume.

Product lesson:

- CursoClaro should prioritize signal over noise
- not every event should trigger a push-style interruption
- future notification design should support prioritization, summary logic, and pending-based relevance

### 3. Parent Anxiety / Over-Surveillance Risk

Some school apps create stress by over-reporting small events or over-monitoring student activity.

Product lesson:

- CursoClaro should avoid hyper-detailed or constant micro-updates by default
- the product should help families act on meaningful information, not create monitoring fatigue

### 4. Unclear Delivery / Receipt Risk

Families often do not know if a communication was actually received, delivered, or seen.

Product lesson:

- the model should support explicit communication state when relevant
- future institutional communication should support states such as `published`, `delivered`, `seen`, or equivalent

### 5. Formal vs Informal Boundary Risk

Many existing tools fail because they mix institutional communication and informal group dynamics.

Product lesson:

- CursoClaro must maintain strict separation between school, community, and services
- future flows must define what belongs in each module and what does not

### 6. Mobile Usability Risk

Poor school apps are often criticized for slow, confusing, or heavy mobile experiences.

Product lesson:

- CursoClaro must remain mobile-first
- key user actions should take very few taps
- interfaces should be scannable, touch-friendly, and visually obvious

### 7. Multi-Child / Multi-Family Complexity Risk

Many tools do not handle multiple children cleanly from the family point of view.

Product lesson:

- family-first UX remains a strategic advantage
- all future modules should preserve child context clarity without duplicating adults or students

### 8. Data Freshness Risk

School-family products degrade quickly when contact data, family links, or service relationships become outdated.

Product lesson:

- future flows should support maintenance of linked adults, children, and relationships
- service assignments and institutional identity should remain manageable over time

### 9. Privacy and Sensitive Data Risk

Documentation, health data, and child-related service information increase the sensitivity of the product.

Product lesson:

- CursoClaro should plan for more granular visibility and access rules over time
- sensitive modules must remain clearly separated from community/social modules

### 10. Setup Friction Risk

Many education apps lose trust early because setup, onboarding, and account linking are too complex.

Product lesson:

- high-friction data should not block light-value flows when avoidable
- the product should support progressive capture of richer data over time

### Product-Wide Guardrails Derived from Competitive Lessons

These guardrails should be considered across roadmap phases:

- define a clear source of truth for each communication type
- minimize unnecessary notifications
- avoid surveillance-style UX
- preserve family-first context
- keep module boundaries explicit
- plan delivery/read-state support where high-value
- design for mobile simplicity first
- separate sensitive data domains carefully
- support progressive data capture instead of overloading setup

## Export Capability Rules

CursoClaro should be designed to support controlled data exports for operational use cases.

This is not necessarily a phase 1 family-facing feature, but it should be contemplated from the beginning in data model and permission design.

### Export Use Cases

Examples:

- students enrolled by course
- students enrolled by service
- pending service enrollment requests
- invitation attendance lists
- gift participation lists
- operational school or provider reports

### Export Scope Rule

Exports must always be scope-bound.

Examples:

- a school can export only its own data
- a teacher may export only course-scoped data if explicitly allowed
- a service provider can export only provider/service-scoped data

### Export Permission Rule

The ability to export must be permission-based, not assumed from basic access.

This means:

- read access does not automatically imply export access
- export permissions should be granted explicitly where needed

### Export Audit Rule

All export actions should be auditable.

At minimum, the system should be able to record:

- who exported
- what was exported
- when it was exported
- under which scope it was exported

### Export Safety Rule

Sensitive data exports should be minimized and justified.

The product should avoid exposing more columns or records than necessary for the use case.
