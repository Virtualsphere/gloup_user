# ADR-0006: Secure Access Token Storage with Legacy Migration

## Status
Accepted (documents current implementation)

## Date
2026-09-28 (documentation baseline)

## Context
The app needs a synchronously readable token for request interception and previously stored tokens in preferences.

## Decision
Store the access token in `FlutterSecureStorage`, warm an in-memory cache at startup, and migrate/remove a legacy SharedPreferences token.

## Consequences
- Auth credentials use platform secure storage.
- Storage initialization must precede authenticated requests; migration behavior needs regression tests.

