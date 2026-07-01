<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:02569B,100:6DB33F&height=180&section=header&text=Pawffy&fontSize=60&fontColor=ffffff&animation=fadeIn&fontAlignY=38&desc=Pet%20care,%20on%20demand.&descAlignY=58&descSize=20" width="100%"/>

<a href="https://git.io/typing-svg">
  <img src="https://readme-typing-svg.demolab.com?font=Fira+Code&weight=500&size=20&pause=1000&color=02569B&center=true&vCenter=true&width=650&lines=Connecting+pet+owners+with+trusted+vets+%F0%9F%90%BE;Real-time+booking+for+dog+walkers+%26+groomers;Built+solo%2C+end+to+end%2C+in+Flutter+%2B+Riverpod;Pixel-perfect+fidelity+to+the+original+Figma+design" alt="Typing SVG" />
</a>

A production-ready Flutter application connecting pet owners with trusted vets, dog walkers, and groomers — built solo, end to end, with pixel-perfect fidelity to the original design.

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Riverpod](https://img.shields.io/badge/Riverpod-00BCD4?style=for-the-badge&logo=dart&logoColor=white)](https://riverpod.dev)
[![Stripe](https://img.shields.io/badge/Stripe-635BFF?style=for-the-badge&logo=stripe&logoColor=white)](https://stripe.com)
[![Spring Boot](https://img.shields.io/badge/Backend-Spring_Boot-6DB33F?style=for-the-badge&logo=springboot&logoColor=white)](https://spring.io/projects/spring-boot)

![Status](https://img.shields.io/badge/status-production--ready-brightgreen?style=flat-square)
![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20Android%20%7C%20macOS%20%7C%20Linux-lightgrey?style=flat-square)
![Built by](https://img.shields.io/badge/built%20by-Mohammad%20Zaidi-blueviolet?style=flat-square)

</div>

---

## Overview

**Pawffy** is a full-featured pet services mobile app built for a US-based freelance client. It connects pet owners with vets, dog walkers, and groomers — handling everything from discovery and booking to in-app messaging and payments.

The entire app — architecture, state management, UI, and API integration — was designed and built solo, from Figma handoff to a shipped, production-ready product.

> **Design approach:** Figma exports are used as precisely-overlaid background layers inside Flutter `Stack` widgets, giving the app 1:1 pixel fidelity to the original design files.

---

## Features

| Discovery | Booking | Payments | Communication |
|---|---|---|---|
| Home feed with categories | Vet appointments | Stripe checkout | Real-time chat |
| Search & filters | Dog walking sessions | Payment history | Conversation threads |
| GPS-based nearby listings | `bookingType`-driven flows | Refund handling | Provider messaging |
| Service detail pages | Booking history | Secure card storage | — |

**Also included:** onboarding & OTP-verified auth, pet profile management, multi-address support, and a full settings/notifications section.

<details>
<summary><strong>Full feature breakdown</strong></summary>

**Onboarding & Authentication**
- Splash and multi-step onboarding flow
- Email sign up / sign in with validation
- Forgot password and OTP verification
- JWT-based session handling

**Home & Discovery**
- Dynamic home feed with service categories
- Search with location, rating, and service-type filters
- Real-time GPS for nearby vets and walkers
- Service and provider detail pages

**Booking**
- Single booking screen with `bookingType`-driven logic for vet vs. dog-walking flows
- Pet selection per booking
- Date and time scheduling
- Stripe-powered checkout and booking confirmation

**Messaging**
- Conversation list and real-time chat with providers

**Profile & Pet Management**
- Editable user profile
- Add/edit/delete pet profiles
- Multiple saved addresses

**Settings**
- Notification preferences, account, and privacy controls

</details>

---

## Tech Stack

| Layer | Choice |
|---|---|
| Framework | Flutter (Dart) |
| State Management | Riverpod (`NotifierProvider` pattern) |
| Typography | Google Fonts — Barlow |
| Location | `geolocator` + `geocoding`, shared GPS provider |
| Payments | Stripe SDK |
| Backend | REST API (Spring Boot) |
| Performance | `RepaintBoundary` on high-resolution assets |

---

## Architecture

```
lib/
├── main.dart
├── core/
│   ├── config/         # App-wide configuration & environment values
│   ├── networks/       # API service layer & network clients
│   ├── storage/        # Local storage (secure storage, caching)
│   └── utils/          # Shared helpers & extensions
└── features/
    ├── auth/           # Onboarding, login, register, OTP
    ├── booking/        # Vet & dog-walking booking flow
    ├── home/           # Home feed
    ├── message/        # Chat
    ├── notification/   # Notification handling & preferences
    ├── pets/           # Pet profile management
    ├── profile/        # User profile & addresses
    ├── search/         # Search & filters
    └── vets/           # Vet discovery & detail pages
```

The project also ships with platform folders for **iOS**, **macOS**, and **Linux**, alongside a dedicated `test/` directory.

**Notable engineering decisions:**
- A single shared GPS stream provider is consumed across every feature that needs location, avoiding redundant permission prompts and duplicate location listeners.
- `RepaintBoundary` wraps high-res Figma-exported PNGs to keep scroll and animation performance smooth.
- Booking logic branches on a single `bookingType` field rather than duplicating screens, keeping the vet and dog-walking flows in one maintainable path.
- Keyboard-aware layouts prevent content jumping when form fields gain focus.
- Dark-theme styling is explicitly isolated on dropdowns so system dark mode can't bleed into the UI unexpectedly.

---

## Getting Started

### Prerequisites
- Flutter SDK `>=3.x`
- Dart `>=3.x`
- Android Studio or VS Code with the Flutter extension
- The Pawffy backend (Spring Boot) running locally or deployed

### Installation

```bash
# Clone the repository
git clone https://github.com/mzaidiii/Pawffy_User.git
cd Pawffy_User

# Install dependencies
flutter pub get

# Run on a connected device or emulator
flutter run
```

### Configuration

Set your environment values in `lib/core/config.dart`:

```dart
const String baseUrl   = 'YOUR_BACKEND_BASE_URL';
const String stripeKey = 'YOUR_STRIPE_PUBLISHABLE_KEY';
```

---

## Project Status

All core modules are implemented, tested, and ready for production deployment.

| Module | Status |
|---|---|
| Onboarding & Splash | ✅ Complete |
| Authentication (Sign Up / Sign In / OTP) | ✅ Complete |
| Home Feed & Service Discovery | ✅ Complete |
| Search & Filters | ✅ Complete |
| Booking Flow (Vet + Dog Walking) | ✅ Complete |
| Stripe Payment Integration | ✅ Complete |
| Messaging / Chat | ✅ Complete |
| User Profile & Pet Management | ✅ Complete |
| Address Management | ✅ Complete |
| Settings | ✅ Complete |

---

## About the Developer

**Mohammad Zaidi**
Flutter & Spring Boot Developer

- 🏆 SIH 2025 National Finalist — *SymbioMed*, validated by the Ministry of AYUSH
- 🐾 Solo-built Pawffy end to end for a US-based freelance client
- 📱 Delivers production Flutter apps and has run Flutter workshops
- 💡 Stack: Flutter · Dart · Spring Boot · Java · Firebase · MySQL · Docker · JWT

[GitHub](https://github.com/mzaidiii) · [LinkedIn](https://linkedin.com/in/mzaidiii) · [LeetCode](https://leetcode.com/mzaidiii)

---

<div align="center">

**Designed, architected, and built solo — every screen, every provider, every pixel.**

⭐ If this project is useful to you, consider starring the repo.

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:6DB33F,100:02569B&height=100&section=footer" width="100%"/>

</div>