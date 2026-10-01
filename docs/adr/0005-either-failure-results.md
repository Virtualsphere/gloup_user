# ADR-0005: Either Failure Results

## Status
Accepted (documents current implementation)

## Date
2026-09-28 (documentation baseline)

## Context
UI workflows need explicit recoverable error states without coupling domain code to transport exceptions.

## Decision
Use `dartz` `Either<Failure, T>` at repository/use-case boundaries where currently adopted; map Dio exceptions to domain failures in data implementations.

## Consequences
- Callers handle success and failure explicitly.
- Preserve consistent semantics and avoid swallowing failures into empty success values.

