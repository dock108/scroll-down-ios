# Changelog

## [Unreleased]

### Added
- Spoiler-safe game list with progressive disclosure and status context
- Home feed with Earlier/Today/Upcoming sections and scroll-to-today behavior
- Game detail view with collapsible sections (Overview, Timeline, Stats, etc.)
- Dev-mode clock for consistent mock data generation (fixed to Nov 12, 2024)
- Reusable `CollapsibleCards` component extracted to Components/

### Changed
- README streamlined for clarity and quick start
- GameDetailView refactored from 578 → 450 LOC
- Empty directories removed (Components now populated, Assets removed)

### Fixed
- Navigation tap reliability improved (List → ScrollView+LazyVStack)
- Mock service now generates unique game detail for each game ID
