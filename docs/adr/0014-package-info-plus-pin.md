# ADR-0014: Pin package_info_plus to 10.1.0

## Status
Accepted (documents current dependency override)

## Date
2026-09-28 (documentation baseline)

## Context
`pubspec.yaml` records a compatibility issue with 10.2.x during Android release/Shorebird builds, including a missing `PackageInfoPlugin` compile symbol.

## Decision
Pin `package_info_plus` to exactly `10.1.0` through a dependency override until the affected build combination is verified fixed.

## Consequences
- Android release/patch builds avoid the reported breakage.
- Revisit the pin with a clean release build before removing or updating it.

