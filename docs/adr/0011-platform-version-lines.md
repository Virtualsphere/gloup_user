# ADR-0011: Platform Version Metadata

## Status
Proposed for clarification (current declarations are ambiguous)

## Date
2026-09-28 (documentation baseline)

## Context
`pubspec.yaml` has an active version `2.8.14+73` and a commented iOS example `2.9.11+72`. Platform store build numbers must be tracked correctly.

## Decision
The repository records a separate iOS version line only as a comment; this is not a reliable release source of truth. Release owners should define the intended versioning policy and automate validation.

## Consequences
- Current iOS version must be confirmed from release configuration/store metadata.
- A follow-up decision is needed before treating platform version lines as intentional policy.

