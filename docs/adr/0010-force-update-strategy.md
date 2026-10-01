# ADR-0010: Force Update Checks

## Status
Accepted (documents current implementation)

## Date
2026-09-28 (documentation baseline)

## Context
The app checks for updates at startup and on resume. Android supports an in-app update path, and `upgrader` provides a cross-platform alert path.

## Decision
Use `upgrader` and `in_app_update` through `ForceUpdateService` and the root upgrade alert to prompt users when an update is required/available.

## Consequences
- Store metadata, native support, and network availability affect the user experience.
- Test update behavior on supported platform versions and retain a Dart-level fallback for older builds.

