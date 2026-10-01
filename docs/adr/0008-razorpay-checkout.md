# ADR-0008: Razorpay for Payment Checkout

## Status
Accepted (documents current implementation)

## Date
2026-09-28 (documentation baseline)

## Context
Customers need an in-app payment experience for booking orders.

## Decision
Use the Razorpay Flutter SDK for checkout after the backend creates an order, then call the backend payment verification endpoint before presenting the booking as confirmed.

## Consequences
- Native SDK configuration and platform testing are required.
- Gateway callbacks alone are not authoritative; server verification and duplicate-submit behavior must be respected.

