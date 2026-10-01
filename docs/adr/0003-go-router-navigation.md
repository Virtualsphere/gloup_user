# ADR-0003: go_router for Navigation

## Status
Accepted (documents current implementation)

## Date
2026-09-28 (documentation baseline)

## Context
The app has nested booking screens, shell navigation, redirects, and notification-driven destinations.

## Decision
Use `go_router` with centralized route paths in `RouteNames` and route construction in `AppRouter`.

## Consequences
- Route paths and `extra` payload shapes need coordinated updates.
- Push payload routing is centralized, while App Links currently only log inbound URIs.

