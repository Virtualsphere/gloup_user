# ADR-0012: Service Price and Strike-Through Display

## Status
Accepted (documents current implementation)

## Date
2026-09-28 (documentation baseline)

## Context
Backend payloads and navigation extras may represent prices as numbers or strings and may use alternate field names. Users need a consistent payable/list price display.

## Decision
Normalize the payable amount from supported price aliases and show original/list price only when it exceeds the payable amount. `BookingPriceCalculator` centralizes booking-screen normalization and totals.

## Consequences
- Malformed values are handled defensively, but backend schemas should be stabilized.
- The server remains authoritative for payable totals; keep display logic aligned with API contracts.

