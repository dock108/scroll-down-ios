# Documentation

Technical documentation for the Scroll Down iOS app.

## Overview

This app provides a native iOS experience for catching up on sports games at your own pace. It's built with SwiftUI and follows MVVM architecture.

## Guides

| Document | Description |
|----------|-------------|
| [Architecture](architecture.md) | MVVM structure, data flow, and design principles |
| [Development](development.md) | Mock mode, testing, debugging, QA checklist |
| [Changelog](CHANGELOG.md) | Feature history and version updates |
| [Agent Notes](../AGENTS.md) | Context for AI coding assistants |

## Beta Phases

| Phase | Status | Description |
|-------|--------|-------------|
| [Phase A](PHASE_A.md) | ✅ Complete | Routing and trust fixes |
| [Phase B](PHASE_B.md) | ✅ Complete | Real backend feeds |
| [Phase C](PHASE_C.md) | ✅ Complete | Timeline usability improvements |
| [Phase D](PHASE_D.md) | ✅ Complete | Recaps and reveal control |
| [Phase E](PHASE_E.md) | ✅ Complete | Social blending (optional, reveal-aware) |

## Quick Reference

- **Environment toggle:** `AppConfig.shared.environment`
- **Run tests:** `xcodebuild test -scheme ScrollDown -destination 'platform=iOS Simulator,name=iPhone 16'`
- **Key screens:** HomeView → GameDetailView → CompactTimelineView
