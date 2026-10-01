# ADR-0009: Shorebird for Dart Code Updates

## Status
Accepted (documents current configuration)

## Date
2026-09-28 (documentation baseline)

## Context
The repository contains Shorebird project configuration and scripts for patch workflows.

## Decision
Use Shorebird patches for eligible Dart-only updates associated with a released native binary. Ship native or plugin changes through a new store build.

## Consequences
- Patch and store release versions must remain traceable.
- Shorebird does not replace store review or native SDK deployment.

