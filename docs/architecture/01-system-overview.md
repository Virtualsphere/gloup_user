# 01. System Overview

> Owner: Mobile Engineering · Last reviewed: 2026-09-28 · Applies to version: Android `2.8.14+73`

## Purpose

GloUp User (Flutter package name `tressy`) is the customer-facing mobile app for discovering salons and services, viewing prices and availability, booking appointments, paying, and managing bookings and profile information. The primary supported release platforms are Android and iOS. Web and desktop scaffolding in the repository is not evidence of supported distribution.

## Context and scope

The app is one client in the GloUp platform. It depends on the GloUp user REST API for business data and transactions, Firebase Cloud Messaging for push delivery, Razorpay for checkout, and Google location services for place search and device location. Sign-in providers and platform stores support authentication, update checks, and distribution. Partner and administrative applications are outside this repository.

The app owns presentation, client-side validation and price display, local UX state, and orchestration of external SDKs. The backend remains authoritative for availability, order creation, payment verification, appointment status, and user data. The client-side booking calculator is a display calculation; confirm its rules with the server contract before changing amounts.

## Runtime and version

Flutter/Dart app organized by feature. `pubspec.yaml` currently declares Android version `2.8.14+73`; a separate iOS version is present only as a commented example (`2.9.11+72`), so release automation must explicitly confirm iOS build metadata. Android and iOS native projects are present. `API_BASE_URL` is a Dart define; absent an override, the app targets `https://api.v1.gloup.in`.

## Architecture links

See [context](02-c4-context.md), [containers](03-c4-containers.md), [app architecture](04-app-architecture.md), [feature catalog](05-feature-catalog.md), [navigation](06-navigation-and-deep-links.md), and [release process](13-build-release-deployment.md).
