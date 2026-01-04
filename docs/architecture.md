# Architecture

## Directory Layout

```
ScrollDown/Sources/
├── Models/         # Codable data models (spec-aligned)
├── ViewModels/     # Business logic (MVVM)
├── Views/Screens/  # SwiftUI views
├── Components/     # Reusable UI components
├── Networking/     # GameService protocol + implementations
└── Mock/           # Mock data for development
```

## Data Flow

Views → ViewModels → `GameService` (mock or real)

## Core Principles

- Spoiler-safe by default
- Progressive disclosure before scores
- User control over reveals
