# CursoClaro Access Control Matrix

## Purpose

This document defines the initial access-control model for CursoClaro.

It should be read together with:

- `PRODUCT_FUNCTIONAL_RULES.md`
- `SECURITY_AND_PRIVACY_BASELINE.md`
- `TARGET_ARCHITECTURE_AND_ERD.md`
- `TARGET_SQL_SCHEMA.sql`

The model is based on:

- canonical roles in English
- scoped access
- entity memberships
- relationship-aware authorization

## Core Access Principle

Access in CursoClaro should never be decided by role alone.

All authorization decisions should evaluate:

- `role`
- relevant `access_scope`
- relevant relationship to `student`, `family_group`, `school`, `course`, or `service_provider`

## Canonical Roles

Initial canonical roles:

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

## Role Matrix

| Canonical role | Actor category | Typical real-world user | Scope type | Core allowed actions | Main restrictions |
|---|---|---|---|---|---|
| `platform_admin` | Platform | Superadmin | `platform` | Full administration, manage schools, manage providers, manage users, assign roles, audit, intervene anywhere | Should use strongest security controls; no ordinary business scope limits |
| `family_adult` | Family | Mother, father, guardian, tutor | `family_group`, relationship to `student` | View linked children, view Family Home, read official notices, read community items, respond to invitations, participate in gifts, manage family context within allowed scope. May later consume approved service features for linked students once Services is exposed in UX beyond Phase 1. | Cannot access unrelated families, institutions, or providers; cannot publish official school communications |
| `school_admin` | Institution | Principal, institutional admin | `school` | Manage school profile, assign school roles, manage courses and school context, publish institutional notices, oversee institution-scoped operations | Cannot operate other schools unless additionally authorized |
| `school_teacher` | Institution | Teacher | `course`, optionally `school` | Publish course-scoped notices, communicate with linked families in approved school flows, access class-relevant information in scope | Cannot manage school-wide configuration, cannot access unrelated courses or administrative data by default |
| `school_admin_staff` | Institution | Administrative staff | `school` | Publish administrative notices, operate school-side administrative workflows, manage operational family-facing information within school scope | Cannot assume pedagogical or teacher authority by default; cannot manage institution-wide settings unless granted |
| `school_communications_manager` | Institution | School communications role | `school` | Publish school-wide notices, closures, meetings, events, general institutional communication | Cannot manage all school settings unless separately granted |
| `service_provider_admin` | Service provider | Provider owner/admin | `service_provider` | Manage provider profile, assign provider roles, manage services, oversee invoices, notices, menus, provider operations | Cannot access unrelated providers, unrelated schools, or family/community data outside service scope |
| `service_provider_operator` | Service provider | General service operator | `service`, `service_provider`, `school_service_offering` | Operate service workflows, publish service notices, manage approved service-level data | Cannot manage provider-wide settings by default |
| `service_provider_billing_staff` | Service provider | Billing/finance staff | `service_provider`, `service`, `school_service_offering` | Create invoices, update due dates, send payment reminders, view billing-relevant enrollment scope | Cannot publish unrelated content by default; cannot manage provider settings unless granted |
| `service_provider_content_staff` | Service provider | Menu/content/notices staff | `service`, `service_provider`, `school_service_offering` | Publish menus, service notices, operational updates | Cannot manage billing by default; cannot manage provider settings unless granted |
| `course_representative` | Community | Parent/tutor acting as course organizer | `course` | Create allowed community items, create invitations, create approved gift collections, share community content enabled by policy | Cannot act as school; cannot access institutional admin data; cannot access sensitive student/family data outside permitted community use |

## Permission Model

Roles should be complemented by explicit permissions.

Recommended initial permission keys:

| Permission key | Description | Typical roles |
|---|---|---|
| `manage_platform` | Full platform administration | `platform_admin` |
| `manage_school_settings` | Manage school configuration and identity | `school_admin` |
| `manage_school_roles` | Assign and manage school roles | `school_admin` |
| `publish_school_wide_notice` | Publish school-wide official communications | `school_admin`, `school_communications_manager` |
| `publish_course_notice` | Publish class/course-level notices | `school_admin`, `school_teacher` |
| `message_linked_families` | Contact linked families in approved teacher/school flows | `school_teacher` |
| `publish_administrative_notice` | Publish administrative school notices | `school_admin`, `school_admin_staff` |
| `manage_provider_settings` | Manage provider identity and configuration | `service_provider_admin` |
| `manage_provider_roles` | Assign and manage provider roles | `service_provider_admin` |
| `publish_service_notice` | Publish service notices and operational messages | `service_provider_admin`, `service_provider_operator`, `service_provider_content_staff` |
| `publish_service_menu` | Publish service menus | `service_provider_operator`, `service_provider_content_staff` |
| `publish_service_invoice` | Create and publish invoices/reminders | `service_provider_admin`, `service_provider_billing_staff` |
| `review_service_request` | Approve/reject service enrollment requests | `service_provider_admin`, `service_provider_operator` |
| `create_community_invitation` | Create invitation in community scope | `course_representative` |
| `create_gift_collection` | Create gift collection linked to community flows | `course_representative` |
| `respond_invitation` | Respond to invitation attendance | `family_adult` |
| `participate_gift_collection` | Participate in gift collection | `family_adult` |
| `request_service_enrollment` | Request service enrollment for linked student once service flows are exposed beyond the hidden foundation of Phase 1 | `family_adult` |
| `export_scoped_data` | Export authorized data under scope | explicit by role and use case only |

## Scope Model

Recommended scope types:

- `platform`
- `family_group`
- `school`
- `course`
- `service_provider`
- `service`
- `school_service_offering`

The same role name may appear multiple times for different scope records.

Example:

- person A can be `school_teacher` in course X
- person B can be `school_teacher` in course Y

## Membership and Role Relationship

Roles should typically be attached only when the person has a valid membership in the scoped entity.

Examples:

- `school_teacher` should correspond to a valid `school_staff_membership`
- `service_provider_operator` should correspond to a valid `service_provider_staff_membership`
- `family_adult` should correspond to a valid `family_group_people` record and/or adult-student relationship

## Additional Family Access Rule

Even if a person has `family_adult`, access to child-specific data must still respect the adult-student relationship.

This means:

- family role alone is not enough
- linked relationship to the student matters

## Export Controls

Exports must never be assumed from read permissions alone.

Examples:

- a teacher may read course data but not export it unless explicitly allowed
- a provider operator may view service enrollments but not export them without `export_scoped_data`

All exports should be auditable.

## Sensitive Domain Restrictions

Restricted domains such as documentation and health should require stronger checks than ordinary community content.

Recommended rule:

- no community-scoped role should gain access to documentation/health by default
- service-provider roles should only access health/service profile data if explicitly needed and permitted

## Recommended Default Mapping for Frontend Labels

| Canonical role | Spanish display label |
|---|---|
| `platform_admin` | `Admin` |
| `family_adult` | `Familia` |
| `school_admin` | `Institución` |
| `school_teacher` | `Docente` |
| `school_admin_staff` | `Administración` |
| `school_communications_manager` | `Comunicaciones` |
| `service_provider_admin` | `Prestador de servicios` |
| `service_provider_operator` | `Operador de servicio` |
| `service_provider_billing_staff` | `Facturación del servicio` |
| `service_provider_content_staff` | `Contenido del servicio` |
| `course_representative` | `Referente de curso` |

## Authorization Implementation Notes

Recommended backend decision model:

1. identify authenticated user
2. resolve `person`
3. resolve memberships
4. resolve role assignments in relevant access scope
5. validate child/family relationship if needed
6. validate permission
7. allow or deny

This flow should be enforced server-side.
