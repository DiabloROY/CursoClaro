# CursoClaro Security and Privacy Baseline

## Purpose

This document defines the baseline security, privacy, and compliance posture for CursoClaro.

It is intended to guide:

- product decisions
- architecture choices
- data modeling
- secure development practices
- operational controls
- future certification and assurance work

This document is not legal advice.

Where laws or regulated school contexts apply, legal review is required.

## Security and Compliance Philosophy

CursoClaro should be built as if it will eventually handle:

- student-related personal data
- family relationship data
- school records
- service-provider operational data
- financial artifacts such as invoices
- sensitive child health or documentation data

Therefore:

- security must be designed in from the beginning
- privacy must be treated as a product concern, not only an infrastructure concern
- compliance readiness should be planned from the beginning, even if formal certification comes later

## Reference Frameworks and Standards

CursoClaro should align to the following external references.

### 1. NIST Cybersecurity Framework 2.0

Primary use:

- enterprise security governance
- risk management structure
- security program maturity

Role in CursoClaro:

- organizing cybersecurity governance
- identifying, protecting, detecting, responding, and recovering
- defining internal security roadmap and priorities

Target usage:

- use as top-level security management framework

### 2. NIST Secure Software Development Framework (SSDF)

Primary use:

- secure software development lifecycle practices

Role in CursoClaro:

- secure requirements definition
- code security practices
- testing and release security
- vulnerability prevention and remediation

Target usage:

- use as development lifecycle baseline

### 3. OWASP ASVS

Primary use:

- application security verification requirements

Role in CursoClaro:

- secure authentication
- session handling
- access control
- input validation
- data protection
- logging
- API and application control design

Target usage:

- use OWASP ASVS as the application-level control checklist
- target at least an `L2-style` rigor for the core product
- consider stricter controls for sensitive modules

### 4. OWASP Top 10

Primary use:

- awareness of the most critical web application security risks

Role in CursoClaro:

- secure developer education
- threat awareness
- guardrails against common failure modes

Target usage:

- treat as minimum awareness baseline, not as sufficient control set by itself

### 5. OWASP MASVS

Primary use:

- mobile application security

Role in CursoClaro:

- if CursoClaro is delivered as mobile app or hybrid app, MASVS should guide:
  - mobile storage decisions
  - local secrets handling
  - transport protections
  - device-level data exposure protections

Target usage:

- apply when mobile-specific implementation exists

### 6. ISO/IEC 27001

Primary use:

- information security management system

Role in CursoClaro:

- long-term operational and governance target
- risk management and control discipline

Target usage:

- medium-term target for organizational security maturity

### 7. ISO/IEC 27701

Primary use:

- privacy information management system

Role in CursoClaro:

- privacy governance around personally identifiable information
- accountability for PII handling

Target usage:

- medium-term target for privacy maturity, especially if handling broader child/family data at scale

### 8. SOC 2

Primary use:

- external assurance for service organizations

Role in CursoClaro:

- future trust and procurement readiness for institutional customers
- demonstrates controls around security, availability, confidentiality, processing integrity, and privacy

Target usage:

- medium-term or commercialization-stage target, especially if selling into schools and service organizations that require vendor assurance

### 9. FERPA

Primary use:

- U.S. student education record privacy context

Role in CursoClaro:

- relevant if serving U.S. schools or handling records that fall within FERPA scope
- especially relevant for student records, institutional disclosures, and school-official / vendor roles

Target usage:

- evaluate applicability per market and deployment context

### 10. COPPA

Primary use:

- children’s online privacy protections in the U.S.

Role in CursoClaro:

- relevant if the service is directed to children under 13 or has actual knowledge of collecting personal information from children under 13 in applicable contexts

Target usage:

- evaluate applicability carefully before child-directed or child-operated experiences are introduced

### 11. NIST Digital Identity Guidelines

Primary use:

- identity proofing, authentication, and federation guidance

Role in CursoClaro:

- useful for stronger identity, enrollment, credential, and access assurance decisions

Target usage:

- apply selectively to auth, account recovery, and elevated-access workflows

## Practical Baseline for CursoClaro

### Security by Design

All features must be designed under these assumptions:

- family data is private
- student data is highly sensitive
- some documents may become regulated or institutionally sensitive
- service providers must not gain broader access than required
- school and community content must not leak across authorization boundaries

### Privacy by Design

Every feature must answer:

- what personal data is collected?
- why is it necessary?
- who can access it?
- how long is it retained?
- how is it protected?
- how is it deleted, archived, or restricted later?

### Least Privilege

Every actor should only have the minimum access needed.

This applies to:

- parents / guardians
- school staff
- course administrators
- service providers
- platform administrators

## Data Classification Baseline

CursoClaro should classify data into tiers.

### Tier 1: contextual operational data

Examples:

- course name
- event title
- school display name
- generic menu entry

Controls:

- normal access control
- no field-level encryption by default

### Tier 2: private operational data

Examples:

- adult names
- email
- phone
- family relationships
- invitation responses
- invoices
- service enrollment data

Controls:

- strict authorization
- protected transport
- protected storage
- logging where relevant

### Tier 3: sensitive or high-risk data

Examples:

- health information
- allergies
- certificates
- personal documents
- physical fitness records
- vaccination records

Controls:

- tighter authorization
- auditability
- controlled storage
- stronger encryption strategy where appropriate
- exposure minimization

## Authentication and Identity Baseline

CursoClaro should adopt the following baseline:

- strong password policy or trusted external identity provider
- secure password hashing using current best-practice password hashing methods
- MFA support for administrative and privileged roles
- strong session management
- secure account recovery
- no plaintext credentials ever stored

Identity and enrollment decisions should become stricter for privileged roles than for ordinary family-facing roles.

## Authorization Baseline

Authorization must be enforced server-side.

Never rely only on frontend logic.

Authorization should be checked across:

- actor type
- linked child context
- school relationship
- service relationship
- module scope

Examples:

- a parent may access only linked child information
- a service provider may access only the service-related scope it is authorized for
- a course community actor must not gain access to sensitive school or documentation records

## Secrets Management Baseline

Secrets must never be hardcoded in source code, frontend bundles, or client-visible configuration.

Required baseline:

- use environment-based secret management
- restrict production secret access
- rotate secrets when needed
- separate secrets by environment

Examples of secrets:

- database credentials
- API keys
- signing secrets
- storage credentials
- webhook verification secrets

## Encryption Baseline

### In Transit

All traffic must use strong transport encryption.

Baseline:

- HTTPS everywhere
- modern TLS configuration
- no insecure downgrade behavior

### At Rest

Production data storage must be protected at rest.

Baseline:

- encrypted infrastructure storage
- encrypted backups
- protected document/object storage

### Application / Field Level

Field-level or application-level encryption should be considered for Tier 3 data and selected Tier 2 high-risk fields.

Examples:

- medical notes
- health restrictions
- sensitive document metadata
- especially sensitive identifiers if required by law or institutional contracts

Field-level encryption should be applied selectively and intentionally, not blindly to every field.

## File and Document Security Baseline

Sensitive files must not be publicly exposed.

Required baseline:

- private storage by default
- controlled download URLs
- role-based access checks before file delivery
- logging for sensitive document access where appropriate

Examples:

- apto físico
- certificates
- invoices
- service documents

## Logging and Audit Baseline

CursoClaro should distinguish:

- operational logs
- security logs
- audit logs

At minimum, audit logging should exist for:

- permission changes
- family relationship changes
- creation or editing of sensitive records
- service enrollment changes
- admin setup changes
- school or provider identity changes
- publication of important institutional communications

Sensitive personal data should not be overexposed in logs.

## Secure Development Lifecycle Baseline

The development process should align with NIST SSDF and OWASP practices.

Minimum expectations:

- secure requirements review
- code review with security checkpoints
- dependency tracking
- vulnerability remediation process
- security testing for critical flows
- release discipline

Recommended implementation practices:

- SAST in CI where feasible
- dependency scanning
- secret scanning
- environment separation
- secure defaults in configuration

## API and Backend Security Baseline

All APIs must follow:

- server-side authorization
- strict input validation
- output minimization
- rate limiting where appropriate
- anti-enumeration protections for sensitive endpoints
- safe error handling without data leakage

Particular care is needed for:

- family lookup
- invitation links
- student documents
- service-provider APIs
- admin operations

## Mobile and Client Baseline

If mobile or hybrid apps are introduced:

- avoid storing sensitive data unnecessarily on device
- use secure local storage for tokens if needed
- avoid exposing secrets in client code
- ensure logout and session invalidation work properly
- minimize offline exposure of sensitive records

OWASP MASVS should guide this layer.

## Privacy and Legal Readiness Baseline

CursoClaro should plan for privacy compliance as a product capability.

Recommended baseline:

- privacy notice and data handling documentation
- clear data ownership model
- retention policy by data category
- deletion / deactivation policy
- role and disclosure controls

Where relevant market or customer context requires it, assess:

- FERPA applicability
- COPPA applicability
- local privacy law applicability
- contractual school-vendor obligations

## Third-Party and Vendor Risk Baseline

If CursoClaro processes data on behalf of schools or handles service provider integrations, it should treat third-party risk seriously.

Baseline:

- vet hosted services and subprocessors
- minimize third-party access to student/family data
- document critical vendors
- assess storage, email, auth, analytics, and messaging providers

## Product-Specific Baseline Rules

### Family and Student Data

- no cross-family data leakage
- child context must be explicit in authorization decisions
- adults must not gain access to a child merely by being in the same broad organizational context

### School Communications

- official school content should be clearly marked
- future read-state and delivery-state support should be planned

### Community Features

- community content must remain isolated from sensitive student or service data
- invitation links must not leak broader data than needed

### Services

- service providers must only see what is necessary to operate their service
- provider-school relationships and provider-student relationships must remain distinct in the authorization model

### Documentation / Health

- treat as restricted domain from day one of design
- use stronger access rules and audit support
- do not expose through informal or community pathways

## Compliance Strategy by Phase

### Phase 1: Security-Ready MVP

Required:

- secure auth baseline
- secure secrets handling
- HTTPS
- server-side authorization
- protected storage
- private file handling
- audit for sensitive changes
- data classification in design

Not required yet:

- formal certification
- full ISMS
- full PIMS

### Phase 2: Operational Hardening

Recommended:

- more formal security logging
- stronger admin and provider role controls
- structured vendor inventory
- deeper testing and security automation

### Phase 3: Assurance and Certification Readiness

Potential targets:

- ISO 27001
- ISO 27701
- SOC 2

This phase should also include:

- formal policies
- evidence gathering
- control ownership
- internal audits and remediation loops

## Non-Negotiable Rules

1. No secrets hardcoded in code or frontend.
2. No sensitive files publicly exposed by default.
3. No trust in frontend-only authorization.
4. No sensitive feature without data-classification review.
5. No new module without explicit actor, access, and retention thinking.

## Recommended Implementation Targets

For CursoClaro specifically, I recommend:

- NIST CSF 2.0 as the overall security governance model
- NIST SSDF as the secure development process baseline
- OWASP ASVS as the application control baseline
- OWASP MASVS if/when a real mobile app exists
- ISO 27001 and ISO 27701 as medium-term organizational maturity targets
- SOC 2 as a medium-term trust/commercial assurance target
- FERPA/COPPA review where U.S. educational or child-directed applicability is in scope

## Sources

- NIST Secure Software Development Framework (SSDF) Version 1.1: https://www.nist.gov/publications/secure-software-development-framework-ssdf-version-11-recommendations-mitigating-risk
- NIST Cybersecurity Framework (CSF) 2.0: https://www.nist.gov/publications/nist-cybersecurity-framework-csf-20
- NIST Privacy Framework: https://www.nist.gov/privacy-framework
- NIST Digital Identity Guidelines: https://www.nist.gov/publications/nist-sp-800-63-4-digital-identity-guidelines
- OWASP ASVS: https://owasp.org/www-project-application-security-verification-standard/
- OWASP Top Ten: https://owasp.org/www-project-top-ten/
- OWASP MASVS: https://mas.owasp.org/MASVS/
- ISO/IEC 27001:2022 overview: https://www.iso.org/standard/27001
- ISO/IEC 27701:2025 overview: https://www.iso.org/standard/27701
- AICPA SOC suite overview: https://www.aicpa-cima.com/soc
- AICPA SOC 2 overview: https://www.aicpa-cima.com/topic/audit-assurance/audit-and-assurance-greater-than-soc-2
- FERPA overview: https://studentprivacy.ed.gov/faq/what-ferpa
- FERPA school official guidance: https://studentprivacy.ed.gov/faq/who-school-official-under-ferpa
- COPPA business guidance: https://www.ftc.gov/business-guidance/privacy-security/childrens-privacy
- COPPA rule summary: https://www.ftc.gov/legal-library/browse/rules/childrens-online-privacy-protection-rule-coppa
