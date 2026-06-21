# ADR-0001: Enforce inward Clean Architecture dependencies

- Status: Accepted
- Date: 2026-06-21

## Context

Presentation state previously coordinated authentication, customer-environment configuration, profile loading, HR rules, persistence, and Flutter notifications. Domain models also parsed transport envelopes and threw network exceptions. This made infrastructure changes visible across the application.

## Decision

Dependencies point inward:

```text
presentation -> application -> domain
data ------------------------> domain
infrastructure -> application/domain
main composes every adapter
```

- Domain contains entities and repository contracts with no Flutter, storage, or network imports.
- Application contains session and HR workflow modules and depends only on domain contracts.
- Data contains repository adapters, transport mappers, persistence mapping, and seed data.
- Infrastructure contains HTTP, platform, and storage adapters.
- Presentation state invokes application modules and publishes notification state only.
- Automated dependency tests reject inward-module imports of outer modules.

## Consequences

- Transport mapping and errors remain local to data adapters.
- Business workflows can be tested without Flutter or HTTP.
- Adding a repository requires a domain contract only when multiple adapters or tests use the seam.
- Composition remains explicit in `main.dart`.
