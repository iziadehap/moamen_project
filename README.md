# Jihagz — حجز
[![Flutter](https://img.shields.io/badge/Flutter-3.8+-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![GetX](https://img.shields.io/badge/State--Management-GetX-02569B?logo=flutter&logoColor=white)](https://pub.dev/packages/get)
[![Supabase](https://img.shields.io/badge/Backend-Supabase-3ECF8E?logo=supabase&logoColor=white)](https://supabase.com/)
[![Architecture](https://img.shields.io/badge/Architecture-Feature--First-orange)](#system-architecture)

**Jihagz** is a real-world sports logistics and booking platform built to centralize the exploration and reservation of sports fields. It digitizes the fragmented process of finding and booking sports venues (Football pitches, Padel courts, and Tennis courts) into a single, unified mobile interface.

The application replaces informal coordination methods (direct phone calls, scattered social media messages, and manual availability checks) with an automated, location-aware platform used by athletes and venue owners.

---
# Project Overview

This system is designed to streamline the athletic booking ecosystem by removing the friction of finding open field slots.  
The application manages the entire exploration and submission lifecycle:

1. Users discover nearby sports venues.
2. Real-time proximity calculations show the closest options.
3. Users can submit unlisted venues for admin approval.
4. Detailed venue information and reviews help users make informed decisions.

The platform focuses on **high operational visibility, crisp map-based delivery, and rapid booking alternatives**.

---
# Problem Statement

Many athletes and sports enthusiasts rely on informal, decentralized methods to book courts:
- Direct phone calls to venue handlers
- Disorganized WhatsApp coordination  
- Unpredictable manual scheduling checks

This leads to several common challenges:
- Lack of visibility into real-time slot availability
- High friction when a target field is fully booked
- Disorganized venue metadata (pricing, contact info, locations)
- Travel inefficiencies due to lack of distance calculations

**Jihagz** eliminates these bottlenecks by centralizing stadium discovery, proximity calculations, and venue tracking in one app.

---
# Key Features

### Sports Exploration Engine
- Categorized browsing (Football, Padel, Tennis, etc.)
- Advanced venue profiles with photo galleries and pricing

### Proximity & Mapping System
- Automatic GPS location detection
- Dynamic distance calculation showing top closest venues
- Visual map integration with precise coordinates

### User Lifecycle & Social Proof
- Secure SSO authentication
- User profiling and onboarding
- Crowdsourced ratings and reviews

### Decentralized Venue Ingestion
- Users can submit missing sports venues with photos and location markers

### Performance & Caching
- Local persistence caching for fast loading and offline support

---
# System Architecture

The project follows a **Feature-First Modular Architecture** designed to keep the codebase maintainable and scalable.

### Architecture Layers

**Presentation Layer**
- Flutter UI with Material 3
- GetX for state management and routing

**Domain Layer**
- Business models and core application logic

**Data Layer**
- Supabase PostgreSQL backend
- SharedPreferences for local caching

This separation allows the project to scale while keeping the code organized.

---
# Map & Location System

A central part of the application is the **proximity and mapping system**:
- Automatic client-side GPS detection
- Real-time distance calculations
- Top 3 closest venues recommendation
- Interactive map with venue pinpoints

---
# Engineering Highlights
- Clean feature-first architecture
- Reactive state management with GetX
- Secure Supabase backend integration
- Client-side geospatial calculations
- Modular and scalable codebase

---
# Tech Stack

### Mobile
Flutter (Material 3)

### State Management & Routing
GetX

### Backend
Supabase + PostgreSQL

### Geospatial & Mapping
- flutter_map
- location

### Storage
SharedPreferences

---
# Screenshots

| Authentication | Field Exploration | Stadium Details | Add Missing Place |
| ---------------- | ---------------- | ---------------- | ---------------- |
| ![](jihagz/screenshots/Screenshot_1784500552.png) | ![](jihagz/screenshots/Screenshot_1784500558.png) | ![](jihagz/screenshots/Screenshot_1784500563.png) | ![](jihagz/screenshots/Screenshot_1784500572.png) |

---
# Future Improvements

- Direct slot booking system
- Advanced search and filtering
- Interactive map filters
- Click-to-call and WhatsApp integration

---
# Author

**GitHub**  
[https://github.com/iziadehap](https://github.com/iziadehap)

**LinkedIn**  
[linkedin.com/in/iziadehap](https://linkedin.com/in/iziadehap)

---
# License
This project is shared for **portfolio and demonstration purposes**.
