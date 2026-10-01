# ADR-0001: Feature-Oriented Clean Architecture with BLoC

## Status
Accepted (documents current implementation)

## Date
2026-09-28 (documentation baseline)

## Context
The app contains multiple customer workflows with UI, business rules, and remote data access. Feature folders separate these capabilities, and several use presentation/domain/data layers. BLoC is the primary workflow state mechanism.

## Decision
Organize feature code by capability and use presentation, domain, and data boundaries where the workflow warrants them. Use BLoC/Cubit for feature state.

## Consequences
- Business rules and API details can change behind domain contracts.
- Some features are thinner and existing Provider use remains for global theme/location state.
- Avoid adding layers that only forward calls without clarifying ownership.

