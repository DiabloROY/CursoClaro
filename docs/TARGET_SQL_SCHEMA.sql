-- CursoClaro Target SQL Schema (revised)
-- PostgreSQL-oriented draft schema
-- Revised identity model:
-- users + people + scoped memberships + scoped roles

begin;

create extension if not exists pgcrypto;

-- =========================================================
-- Identity
-- =========================================================

create table if not exists users (
    id uuid primary key default gen_random_uuid(),
    email varchar(320),
    phone varchar(40),
    password_hash text,
    status varchar(30) not null default 'active',
    last_login_at timestamptz,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    deleted_at timestamptz
);

create unique index if not exists users_email_unique_idx
    on users (lower(email))
    where email is not null and deleted_at is null;

create unique index if not exists users_phone_unique_idx
    on users (phone)
    where phone is not null and deleted_at is null;

create table if not exists people (
    id uuid primary key default gen_random_uuid(),
    user_id uuid references users(id),
    first_name varchar(120) not null,
    last_name varchar(120) not null,
    dni varchar(20),
    dni_normalized varchar(20),
    cuil varchar(20),
    cuil_normalized varchar(20),
    birth_date date,
    email varchar(320),
    phone varchar(40),
    status varchar(30) not null default 'active',
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    deleted_at timestamptz
);

create unique index if not exists people_dni_unique_idx
    on people (dni_normalized)
    where dni_normalized is not null and deleted_at is null;

create unique index if not exists people_cuil_unique_idx
    on people (cuil_normalized)
    where cuil_normalized is not null and deleted_at is null;

-- =========================================================
-- Students
-- =========================================================

create table if not exists students (
    id uuid primary key default gen_random_uuid(),
    first_name varchar(120) not null,
    last_name varchar(120) not null,
    dni varchar(20),
    dni_normalized varchar(20),
    cuil varchar(20),
    cuil_normalized varchar(20),
    birth_date date,
    status varchar(30) not null default 'active',
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    deleted_at timestamptz
);

create unique index if not exists students_dni_unique_idx
    on students (dni_normalized)
    where dni_normalized is not null and deleted_at is null;

create unique index if not exists students_cuil_unique_idx
    on students (cuil_normalized)
    where cuil_normalized is not null and deleted_at is null;

-- =========================================================
-- Family
-- =========================================================

create table if not exists family_groups (
    id uuid primary key default gen_random_uuid(),
    display_name varchar(160),
    status varchar(30) not null default 'active',
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    deleted_at timestamptz
);

create table if not exists family_group_people (
    id uuid primary key default gen_random_uuid(),
    family_group_id uuid not null references family_groups(id),
    person_id uuid not null references people(id),
    membership_role varchar(40) not null default 'member',
    status varchar(30) not null default 'active',
    joined_at timestamptz not null default now(),
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    deleted_at timestamptz
);

create unique index if not exists family_group_people_unique_idx
    on family_group_people (family_group_id, person_id)
    where deleted_at is null;

create table if not exists family_group_students (
    id uuid primary key default gen_random_uuid(),
    family_group_id uuid not null references family_groups(id),
    student_id uuid not null references students(id),
    status varchar(30) not null default 'active',
    joined_at timestamptz not null default now(),
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    deleted_at timestamptz
);

create unique index if not exists family_group_students_unique_idx
    on family_group_students (family_group_id, student_id)
    where deleted_at is null;

create table if not exists adult_student_relationships (
    id uuid primary key default gen_random_uuid(),
    person_id uuid not null references people(id),
    student_id uuid not null references students(id),
    relationship_type varchar(40) not null,
    is_legal_guardian boolean not null default false,
    receives_notifications boolean not null default true,
    can_pick_up boolean not null default false,
    can_authorize boolean not null default false,
    is_primary_contact boolean not null default false,
    verification_status varchar(30) not null default 'pending',
    source varchar(40) not null default 'system',
    notes text,
    status varchar(30) not null default 'active',
    verified_at timestamptz,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    deleted_at timestamptz
);

create unique index if not exists adult_student_relationships_unique_idx
    on adult_student_relationships (person_id, student_id)
    where deleted_at is null;

-- =========================================================
-- Institutions and academics
-- =========================================================

create table if not exists schools (
    id uuid primary key default gen_random_uuid(),
    name varchar(200) not null,
    display_name varchar(200),
    short_name varchar(120),
    cuit varchar(20),
    cuit_normalized varchar(20),
    logo_url text,
    brand_color varchar(20),
    contact_email varchar(320),
    contact_phone varchar(40),
    address text,
    website text,
    status varchar(30) not null default 'active',
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    deleted_at timestamptz
);

create unique index if not exists schools_name_unique_idx
    on schools (lower(name))
    where deleted_at is null;

create unique index if not exists schools_cuit_unique_idx
    on schools (cuit_normalized)
    where cuit_normalized is not null and deleted_at is null;

create table if not exists school_years (
    id uuid primary key default gen_random_uuid(),
    school_id uuid not null references schools(id),
    name varchar(80) not null,
    start_date date not null,
    end_date date not null,
    status varchar(30) not null default 'active',
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    deleted_at timestamptz
);

create unique index if not exists school_years_unique_idx
    on school_years (school_id, lower(name))
    where deleted_at is null;

create table if not exists courses (
    id uuid primary key default gen_random_uuid(),
    school_id uuid not null references schools(id),
    school_year_id uuid not null references school_years(id),
    name varchar(120) not null,
    grade_level varchar(60),
    section varchar(30),
    shift varchar(30),
    status varchar(30) not null default 'active',
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    deleted_at timestamptz
);

create unique index if not exists courses_unique_idx
    on courses (school_id, school_year_id, lower(name))
    where deleted_at is null;

create table if not exists school_staff_memberships (
    id uuid primary key default gen_random_uuid(),
    school_id uuid not null references schools(id),
    person_id uuid not null references people(id),
    status varchar(30) not null default 'active',
    joined_at timestamptz not null default now(),
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    deleted_at timestamptz
);

create unique index if not exists school_staff_memberships_unique_idx
    on school_staff_memberships (school_id, person_id)
    where deleted_at is null;

create table if not exists student_enrollments (
    id uuid primary key default gen_random_uuid(),
    student_id uuid not null references students(id),
    school_id uuid not null references schools(id),
    school_year_id uuid not null references school_years(id),
    course_id uuid not null references courses(id),
    enrollment_status varchar(30) not null default 'active',
    start_date date,
    end_date date,
    is_current boolean not null default true,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    deleted_at timestamptz,
    constraint student_enrollments_status_check check (
        enrollment_status in ('pending', 'active', 'completed', 'withdrawn', 'transferred_out', 'transferred_in')
    )
);

create unique index if not exists student_enrollments_one_current_per_year_idx
    on student_enrollments (student_id, school_year_id)
    where is_current = true and deleted_at is null;

-- =========================================================
-- Authorization / security
-- =========================================================

create table if not exists roles (
    id uuid primary key default gen_random_uuid(),
    role_key varchar(60) not null unique,
    display_name varchar(120) not null,
    description text,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

insert into roles (role_key, display_name, description)
values
    ('platform_admin', 'Platform Admin', 'Full platform administration'),
    ('family_adult', 'Family Adult', 'Family-facing adult role'),
    ('school_admin', 'School Admin', 'Institution administrator'),
    ('school_teacher', 'School Teacher', 'Course or classroom teacher'),
    ('school_admin_staff', 'School Administrative Staff', 'Operational school staff'),
    ('school_communications_manager', 'School Communications Manager', 'School-wide communications role'),
    ('service_provider_admin', 'Service Provider Admin', 'Service provider administrator'),
    ('service_provider_operator', 'Service Provider Operator', 'General service operator'),
    ('service_provider_billing_staff', 'Service Provider Billing Staff', 'Billing and finance role for service providers'),
    ('service_provider_content_staff', 'Service Provider Content Staff', 'Content, menu, or notice publishing role for providers'),
    ('course_representative', 'Course Representative', 'Community organizer role for a course')
on conflict (role_key) do update
set
    display_name = excluded.display_name,
    description = excluded.description,
    updated_at = now();

create table if not exists sessions (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references users(id),
    session_token_hash text not null,
    user_agent text,
    ip_address inet,
    expires_at timestamptz not null,
    revoked_at timestamptz,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table if not exists invites (
    id uuid primary key default gen_random_uuid(),
    family_group_id uuid references family_groups(id),
    person_id uuid references people(id),
    email varchar(320),
    phone varchar(40),
    invite_type varchar(40) not null,
    token_hash text not null,
    expires_at timestamptz not null,
    accepted_at timestamptz,
    status varchar(30) not null default 'pending',
    created_by_user_id uuid references users(id),
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table if not exists audit_logs (
    id uuid primary key default gen_random_uuid(),
    actor_user_id uuid references users(id),
    entity_type varchar(60) not null,
    entity_id uuid,
    action varchar(60) not null,
    before_json jsonb,
    after_json jsonb,
    created_at timestamptz not null default now()
);

-- =========================================================
-- Communications
-- =========================================================

create table if not exists communications (
    id uuid primary key default gen_random_uuid(),
    school_id uuid references schools(id),
    course_id uuid references courses(id),
    family_group_id uuid references family_groups(id),
    student_id uuid references students(id),
    communication_domain varchar(30) not null,
    communication_kind varchar(40) not null,
    title varchar(250) not null,
    body text not null,
    status varchar(30) not null default 'draft',
    published_at timestamptz,
    created_by_user_id uuid references users(id),
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    deleted_at timestamptz,
    constraint communications_domain_check check (
        communication_domain in ('institutional', 'community', 'service')
    ),
    constraint communications_status_check check (
        status in ('draft', 'published', 'archived')
    )
);

create table if not exists communication_recipients (
    id uuid primary key default gen_random_uuid(),
    communication_id uuid not null references communications(id),
    person_id uuid references people(id),
    student_id uuid references students(id),
    recipient_type varchar(40) not null,
    delivery_status varchar(30) not null default 'pending',
    read_at timestamptz,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

-- =========================================================
-- Community
-- =========================================================

create table if not exists community_posts (
    id uuid primary key default gen_random_uuid(),
    family_group_id uuid references family_groups(id),
    course_id uuid references courses(id),
    post_type varchar(40) not null,
    title varchar(250) not null,
    body text,
    status varchar(30) not null default 'draft',
    published_at timestamptz,
    created_by_user_id uuid references users(id),
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    deleted_at timestamptz,
    constraint community_posts_status_check check (
        status in ('draft', 'published', 'archived')
    )
);

create table if not exists invitations (
    id uuid primary key default gen_random_uuid(),
    student_id uuid not null references students(id),
    course_id uuid references courses(id),
    invitation_type varchar(40) not null default 'birthday',
    theme_category varchar(40),
    title varchar(250) not null,
    message text,
    age_turning integer,
    location_name varchar(200),
    location_address text,
    maps_url text,
    starts_at timestamptz not null,
    ends_at timestamptz not null,
    include_gift_collection boolean not null default false,
    status varchar(30) not null default 'draft',
    published_at timestamptz,
    created_by_user_id uuid references users(id),
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    deleted_at timestamptz,
    constraint invitations_status_check check (
        status in ('draft', 'published', 'archived', 'cancelled')
    ),
    constraint invitations_time_range_check check (ends_at > starts_at)
);

create table if not exists invitation_responses (
    id uuid primary key default gen_random_uuid(),
    invitation_id uuid not null references invitations(id),
    person_id uuid not null references people(id),
    student_id uuid references students(id),
    attendance_status varchar(30) not null default 'pending',
    gift_participation_status varchar(30) not null default 'unknown',
    responded_at timestamptz,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    constraint invitation_attendance_check check (
        attendance_status in ('pending', 'attending', 'not_attending')
    ),
    constraint invitation_gift_check check (
        gift_participation_status in ('unknown', 'participating', 'not_participating')
    )
);

create unique index if not exists invitation_responses_unique_idx
    on invitation_responses (invitation_id, person_id);

create table if not exists gift_collections (
    id uuid primary key default gen_random_uuid(),
    invitation_id uuid not null references invitations(id),
    title varchar(250) not null,
    payment_alias varchar(200),
    suggested_amount numeric(12, 2),
    deadline_at timestamptz,
    status varchar(30) not null default 'active',
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    deleted_at timestamptz
);

create table if not exists gift_participants (
    id uuid primary key default gen_random_uuid(),
    gift_collection_id uuid not null references gift_collections(id),
    person_id uuid not null references people(id),
    participation_status varchar(30) not null default 'pending',
    payment_status varchar(30) not null default 'unknown',
    amount_reported numeric(12, 2),
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create unique index if not exists gift_participants_unique_idx
    on gift_participants (gift_collection_id, person_id);

-- =========================================================
-- Services
-- =========================================================

create table if not exists service_providers (
    id uuid primary key default gen_random_uuid(),
    name varchar(200) not null,
    display_name varchar(200),
    cuit varchar(20),
    cuit_normalized varchar(20),
    cuil varchar(20),
    cuil_normalized varchar(20),
    logo_url text,
    brand_color varchar(20),
    description text,
    contact_email varchar(320),
    contact_phone varchar(40),
    website text,
    status varchar(30) not null default 'active',
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    deleted_at timestamptz
);

create unique index if not exists service_providers_name_unique_idx
    on service_providers (lower(name))
    where deleted_at is null;

create unique index if not exists service_providers_cuit_unique_idx
    on service_providers (cuit_normalized)
    where cuit_normalized is not null and deleted_at is null;

create unique index if not exists service_providers_cuil_unique_idx
    on service_providers (cuil_normalized)
    where cuil_normalized is not null and deleted_at is null;

create table if not exists service_provider_staff_memberships (
    id uuid primary key default gen_random_uuid(),
    service_provider_id uuid not null references service_providers(id),
    person_id uuid not null references people(id),
    status varchar(30) not null default 'active',
    joined_at timestamptz not null default now(),
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    deleted_at timestamptz
);

create unique index if not exists service_provider_staff_memberships_unique_idx
    on service_provider_staff_memberships (service_provider_id, person_id)
    where deleted_at is null;

create table if not exists school_service_providers (
    id uuid primary key default gen_random_uuid(),
    school_id uuid not null references schools(id),
    service_provider_id uuid not null references service_providers(id),
    status varchar(30) not null default 'active',
    starts_at timestamptz,
    ends_at timestamptz,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    deleted_at timestamptz
);

create unique index if not exists school_service_providers_unique_idx
    on school_service_providers (school_id, service_provider_id)
    where deleted_at is null;

create table if not exists services (
    id uuid primary key default gen_random_uuid(),
    service_provider_id uuid not null references service_providers(id),
    service_type varchar(40) not null,
    name varchar(200) not null,
    description text,
    status varchar(30) not null default 'active',
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    deleted_at timestamptz
);

create table if not exists school_service_offerings (
    id uuid primary key default gen_random_uuid(),
    school_service_provider_id uuid not null references school_service_providers(id),
    service_id uuid not null references services(id),
    school_year_id uuid not null references school_years(id),
    course_id uuid references courses(id),
    status varchar(30) not null default 'active',
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    deleted_at timestamptz
);

create table if not exists service_enrollment_requests (
    id uuid primary key default gen_random_uuid(),
    school_service_offering_id uuid not null references school_service_offerings(id),
    student_id uuid not null references students(id),
    family_group_id uuid references family_groups(id),
    requested_by_person_id uuid references people(id),
    status varchar(30) not null default 'pending',
    notes text,
    submitted_at timestamptz not null default now(),
    resolved_at timestamptz,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    deleted_at timestamptz,
    constraint service_enrollment_requests_status_check check (
        status in ('pending', 'approved', 'rejected', 'cancelled')
    )
);

create unique index if not exists service_enrollment_requests_open_unique_idx
    on service_enrollment_requests (school_service_offering_id, student_id)
    where status = 'pending' and deleted_at is null;

create table if not exists student_service_enrollments (
    id uuid primary key default gen_random_uuid(),
    school_service_offering_id uuid not null references school_service_offerings(id),
    student_id uuid not null references students(id),
    family_group_id uuid references family_groups(id),
    service_status varchar(30) not null default 'active',
    starts_at timestamptz,
    ends_at timestamptz,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    deleted_at timestamptz,
    constraint student_service_enrollments_status_check check (
        service_status in ('pending', 'active', 'inactive', 'rejected', 'cancelled')
    )
);

create unique index if not exists student_service_enrollments_unique_idx
    on student_service_enrollments (school_service_offering_id, student_id)
    where deleted_at is null;

create table if not exists student_service_profiles (
    id uuid primary key default gen_random_uuid(),
    student_service_enrollment_id uuid not null references student_service_enrollments(id),
    profile_type varchar(40) not null,
    data_json jsonb not null default '{}'::jsonb,
    status varchar(30) not null default 'active',
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table if not exists service_messages (
    id uuid primary key default gen_random_uuid(),
    school_service_offering_id uuid not null references school_service_offerings(id),
    student_id uuid references students(id),
    message_type varchar(40) not null,
    title varchar(250) not null,
    body text,
    published_at timestamptz,
    created_by_user_id uuid references users(id),
    status varchar(30) not null default 'draft',
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    deleted_at timestamptz
);

create table if not exists service_invoices (
    id uuid primary key default gen_random_uuid(),
    student_service_enrollment_id uuid not null references student_service_enrollments(id),
    invoice_number varchar(120) not null,
    amount numeric(12, 2) not null,
    currency varchar(10) not null default 'ARS',
    due_date date not null,
    status varchar(30) not null default 'issued',
    file_url text,
    issued_at timestamptz,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    deleted_at timestamptz,
    constraint service_invoices_status_check check (
        status in ('issued', 'paid', 'overdue', 'cancelled')
    )
);

create unique index if not exists service_invoices_unique_idx
    on service_invoices (student_service_enrollment_id, invoice_number)
    where deleted_at is null;

create table if not exists access_scopes (
    id uuid primary key default gen_random_uuid(),
    scope_type varchar(40) not null,
    family_group_id uuid references family_groups(id),
    school_id uuid references schools(id),
    course_id uuid references courses(id),
    service_provider_id uuid references service_providers(id),
    service_id uuid references services(id),
    school_service_offering_id uuid references school_service_offerings(id),
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    deleted_at timestamptz,
    constraint access_scopes_scope_type_check check (
        scope_type in (
            'platform',
            'family_group',
            'school',
            'course',
            'service_provider',
            'service',
            'school_service_offering'
        )
    ),
    constraint access_scopes_target_match_check check (
        (
            scope_type = 'platform'
            and family_group_id is null
            and school_id is null
            and course_id is null
            and service_provider_id is null
            and service_id is null
            and school_service_offering_id is null
        )
        or (
            scope_type = 'family_group'
            and family_group_id is not null
            and school_id is null
            and course_id is null
            and service_provider_id is null
            and service_id is null
            and school_service_offering_id is null
        )
        or (
            scope_type = 'school'
            and family_group_id is null
            and school_id is not null
            and course_id is null
            and service_provider_id is null
            and service_id is null
            and school_service_offering_id is null
        )
        or (
            scope_type = 'course'
            and family_group_id is null
            and school_id is null
            and course_id is not null
            and service_provider_id is null
            and service_id is null
            and school_service_offering_id is null
        )
        or (
            scope_type = 'service_provider'
            and family_group_id is null
            and school_id is null
            and course_id is null
            and service_provider_id is not null
            and service_id is null
            and school_service_offering_id is null
        )
        or (
            scope_type = 'service'
            and family_group_id is null
            and school_id is null
            and course_id is null
            and service_provider_id is null
            and service_id is not null
            and school_service_offering_id is null
        )
        or (
            scope_type = 'school_service_offering'
            and family_group_id is null
            and school_id is null
            and course_id is null
            and service_provider_id is null
            and service_id is null
            and school_service_offering_id is not null
        )
    )
);

create unique index if not exists access_scopes_platform_unique_idx
    on access_scopes (scope_type)
    where scope_type = 'platform' and deleted_at is null;

create unique index if not exists access_scopes_family_group_unique_idx
    on access_scopes (family_group_id)
    where scope_type = 'family_group' and deleted_at is null;

create unique index if not exists access_scopes_school_unique_idx
    on access_scopes (school_id)
    where scope_type = 'school' and deleted_at is null;

create unique index if not exists access_scopes_course_unique_idx
    on access_scopes (course_id)
    where scope_type = 'course' and deleted_at is null;

create unique index if not exists access_scopes_service_provider_unique_idx
    on access_scopes (service_provider_id)
    where scope_type = 'service_provider' and deleted_at is null;

create unique index if not exists access_scopes_service_unique_idx
    on access_scopes (service_id)
    where scope_type = 'service' and deleted_at is null;

create unique index if not exists access_scopes_school_service_offering_unique_idx
    on access_scopes (school_service_offering_id)
    where scope_type = 'school_service_offering' and deleted_at is null;

create table if not exists role_assignments (
    id uuid primary key default gen_random_uuid(),
    person_id uuid not null references people(id),
    role_id uuid not null references roles(id),
    access_scope_id uuid not null references access_scopes(id),
    status varchar(30) not null default 'active',
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    deleted_at timestamptz
);

create unique index if not exists role_assignments_unique_idx
    on role_assignments (person_id, role_id, access_scope_id)
    where deleted_at is null;

create index if not exists role_assignments_person_idx
    on role_assignments (person_id, role_id)
    where deleted_at is null;

-- =========================================================
-- Documentation / health (future)
-- =========================================================

create table if not exists student_documents (
    id uuid primary key default gen_random_uuid(),
    student_id uuid not null references students(id),
    document_type varchar(40) not null,
    title varchar(250) not null,
    file_url text,
    issued_at date,
    expires_at date,
    status varchar(30) not null default 'active',
    created_by_user_id uuid references users(id),
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    deleted_at timestamptz
);

create table if not exists student_health_profiles (
    id uuid primary key default gen_random_uuid(),
    student_id uuid not null references students(id),
    profile_type varchar(40) not null,
    data_json jsonb not null default '{}'::jsonb,
    status varchar(30) not null default 'active',
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table if not exists certificate_records (
    id uuid primary key default gen_random_uuid(),
    student_id uuid not null references students(id),
    certificate_type varchar(40) not null,
    title varchar(250) not null,
    file_url text,
    issued_at date,
    expires_at date,
    status varchar(30) not null default 'active',
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    deleted_at timestamptz
);

create table if not exists vaccination_records (
    id uuid primary key default gen_random_uuid(),
    student_id uuid not null references students(id),
    vaccine_name varchar(160) not null,
    applied_at date,
    next_due_at date,
    status varchar(30) not null default 'recorded',
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    deleted_at timestamptz
);

commit;
