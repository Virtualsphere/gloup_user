# ADR-0007: Firebase Cloud Messaging for Push

## Status
Accepted (documents current implementation)

## Date
2026-09-28 (documentation baseline)

## Context
The app needs remote appointment and promotional notifications across supported mobile platforms.

## Decision
Use Firebase Messaging for delivery and `flutter_local_notifications` to present foreground/data-only notifications and handle tap payloads.

## Consequences
- Native Firebase configuration and permission behavior are required.
- Payload keys and type aliases form a client/backend contract and must be tested together.

