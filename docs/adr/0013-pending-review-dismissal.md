# ADR-0013: Dismiss Pending Review Prompt per Appointment

## Status
Accepted (documents current implementation)

## Date
2026-09-28 (documentation baseline)

## Context
The home screen can prompt a customer to review an appointment. Dismissing one prompt should not suppress unrelated appointments.

## Decision
Persist dismissed appointment IDs in SharedPreferences and filter prompts against that set.

## Consequences
- Dismissal survives app restarts on the device.
- The state is local to the installation and is cleared by `clearAll()`; this behavior should remain intentional.

