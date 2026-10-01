# ADR-0002: get_it for Dependency Injection

## Status
Accepted (documents current implementation)

## Date
2026-09-28 (documentation baseline)

## Context
Features need shared repositories, use cases, network services, and scoped BLoCs. Registrations are centralized in `core/di/injection_container.dart`.

## Decision
Use `get_it` as the service locator and register dependencies centrally, choosing lazy singleton or factory lifetime according to sharing and state lifecycle.

## Consequences
- Registration order and lifetimes are explicit in one file.
- Global mutable state should be limited; stateful BLoCs should be factories unless cross-screen sharing is intentional.

