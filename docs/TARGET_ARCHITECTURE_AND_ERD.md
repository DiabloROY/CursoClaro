# CursoClaro Target Architecture and ERD Foundation

## Purpose

This document defines the revised target architecture and entity-relationship foundation for CursoClaro after consolidating:

- family-first UX
- institutional communication
- community coordination
- service-provider support
- unique legal/national identifiers
- scoped roles and memberships

The main design correction in this version is:

- people are modeled as a single identity concept
- roles belong to people within an entity scope
- students remain distinct from people
- academic history remains separate from student identity
- services are offered through school/provider relationships and consumed through requests/enrollments

## Architecture Recommendation

### Style

CursoClaro should start as a `modular monolith`.

### Recommended stack

- `Next.js App Router`
- `TypeScript`
- `React`
- `NestJS`
- `Fastify`
- `PostgreSQL`
- `Drizzle ORM`
- private object storage
- background job/queue support

### Why

- fast execution
- clean domain boundaries
- strong consistency
- easier authorization and audit
- simpler operations

## Core Architecture Principles

1. Family is the primary user-facing context.
2. A person should exist only once in the platform.
3. A student should exist only once in the platform.
4. Student academic history must live in enrollments, not in the student row.
5. Roles must be scoped to entities, not treated as identity.
6. School, community, services, and documentation must remain separate modules.
7. Sensitive information must be access-controlled and auditable.

## Main Domain Modules

### 1. Identity

Owns:

- users
- people
- sessions

### 2. Family

Owns:

- family_groups
- family memberships
- adult-student relationships

### 3. Academics

Owns:

- schools
- school years
- courses
- student enrollments
- school staff memberships

### 4. School Communications

Owns:

- official communications
- recipients
- delivery/read states

### 5. Community

Owns:

- birthdays
- invitations
- gift collections
- invitation responses
- community posts

### 6. Services

Owns:

- service providers
- provider staff memberships
- school/provider associations
- service offerings
- service enrollment requests
- student service enrollments
- service messages
- service invoices

### 7. Documentation / Health

Future-oriented restricted domain.

### 8. Security / Authorization

Owns:

- role assignments
- access grants
- audit logs

## Navigation Model

Family-facing navigation:

- `Inicio`
- `Colegio`
- `Comunidad`
- `Servicios`
- `Mi familia`

## Identity Model

## `users`

Authentication account.

## `people`

Canonical human identity for:

- parents
- mothers
- fathers
- tutors
- teachers
- school staff
- provider staff
- administrators

This avoids duplicating the same real-world person across modules.

## `students`

Students remain separate from `people`.

Reason:

- they are the central child entity in the domain
- family and school logic revolve around them
- many product flows are child-centric rather than actor-centric

## Organizational Membership Model

Instead of making roles the primary identity, the model should use:

- `person`
- `entity`
- `membership`
- `role assignment`

Examples:

- a teacher is a `person`
- the school is the entity
- the school staff membership links the teacher to the school
- the assigned role defines whether that person is a teacher, admin staff, communications manager, etc.

## Institutional Model

## `schools`

Master institution record with:

- unique legal identifier (`CUIT`)
- visible identity (name, logo, etc.)

## `school_years`

Academic cycle per school.

## `courses`

Course per school and school year.

## `school_staff_memberships`

Links people to schools.

Example people:

- principal
- teacher
- administrative staff
- communications manager

## `role_assignments`

Roles are assigned to memberships/scopes.

Canonical role names:

- `platform_admin`
- `family_adult`
- `school_admin`
- `school_teacher`
- `school_admin_staff`
- `school_communications_manager`
- `service_provider_admin`
- `service_provider_operator`
- `service_provider_billing_staff`
- `service_provider_content_staff`
- `course_representative`

## Family Model

## `family_groups`

Family operating context for UX.

## `family_group_people`

Links people to family groups.

## `adult_student_relationships`

Links adult people to students with relationship and permission semantics.

This is still necessary because:

- family membership alone should not imply all permissions
- relationship semantics matter

## Student Academic Model

## `student_enrollments`

The source of academic truth.

Fields should represent:

- school
- school year
- course
- status
- start/end dates
- current/not current

### Enrollment rule

For current business rules:

- one student should have only one active/current enrollment in the same school year

If a student changes schools during the year:

- the old enrollment is closed / transferred out
- the new enrollment becomes current

The student record itself remains the same.

## Services Model

## `service_providers`

Master record for providers.

Supports:

- name
- logo
- `CUIT` / `CUIL` where relevant
- contact data

## `service_provider_staff_memberships`

Links people to providers.

## `school_service_providers`

Many-to-many relationship between schools and providers.

This says:

- which providers are associated with which schools

## `services`

Global provider-defined service type or named service.

Examples:

- Comedor
- Transporte
- Taller de fútbol

## `school_service_offerings`

School-scoped offering of a service.

This says:

- this service is available in this school
- in this school year
- optionally for this course

This is the right place for “service availability”.

## `service_enrollment_requests`

Request made by a family for a student to join a service offering.

This supports the preferred UX:

1. school/provider makes service available
2. family sees it
3. family requests enrollment
4. provider/school approves or rejects

## `student_service_enrollments`

Final accepted student participation in the service.

## `student_service_profiles`

Child-specific service data.

Examples:

- food restrictions
- allergies
- service notes

## Communications Model

## Official communications

Should remain institutional.

## Community posts and invitations

Should remain separate from official communication.

## Service messages

Should remain separate from both official communication and community content.

## ERD Foundation: Revised Table List

### Identity

- `users`
- `people`
- `sessions`

### Family

- `family_groups`
- `family_group_people`
- `adult_student_relationships`

### Student

- `students`

### Academics

- `schools`
- `school_years`
- `courses`
- `student_enrollments`
- `school_staff_memberships`

### Authorization

- `role_assignments`
- `access_grants`

### Communications

- `communications`
- `communication_recipients`

### Community

- `community_posts`
- `invitations`
- `invitation_responses`
- `gift_collections`
- `gift_participants`

### Services

- `service_providers`
- `service_provider_staff_memberships`
- `school_service_providers`
- `services`
- `school_service_offerings`
- `service_enrollment_requests`
- `student_service_enrollments`
- `student_service_profiles`
- `service_messages`
- `service_invoices`

### Documentation / Health

- `student_documents`
- `student_health_profiles`
- `certificate_records`
- `vaccination_records`

### Audit / Security

- `invites`
- `audit_logs`

## Key Relationship Rules

1. `people` are unique across the platform.
2. `students` are unique across the platform.
3. `people` can belong to multiple entities through memberships.
4. `roles` are assigned in scope, not globally assumed.
5. `students` belong academically through enrollments, not direct mutable school/course fields.
6. `services` are offered through school/provider associations and offerings.
7. `families` request service enrollment; providers/schools can resolve it.

## Implementation Guidance

### Build order

1. identity + people
2. family
3. academics
4. auth + scoped roles
5. communications
6. community + invitations
7. services foundation

### Next technical deliverables

1. revise SQL schema to match this identity/membership model
2. define access-control matrix as scoped role model
3. derive APIs and read models from revised entities
