# ADR-0004: Dio with Interceptors for API Access

## Status
Accepted (documents current implementation)

## Date
2026-09-28 (documentation baseline)

## Context
Feature data sources need one HTTP client configuration with authentication and diagnostics.

## Decision
Use Dio through `DioClient`, configured with JSON, timeouts, an auth interceptor, and a logging interceptor. Resolve the API base URL through `API_BASE_URL` with a production default.

## Consequences
- Headers, timeouts, and exception mapping are consistent.
- Endpoint auth policy must remain explicit and logging must not expose sensitive values.

