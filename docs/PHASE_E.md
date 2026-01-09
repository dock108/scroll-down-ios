# Beta Phase E — Social Blending (iOS)

## Overview

Phase E adds optional social context that makes games feel alive without overwhelming the core experience. Social content is opt-in, reveal-aware, and can be completely ignored by users who prefer the timeline-first approach.

**Status:** ✅ Complete

**Key Achievement:** The app gains personality without noise. Social content enhances moments instead of stealing them.

---

## Core Philosophy

### Texture, Not Noise

Social content should feel like:
> "Extra color, if I want it."

Not:
> "Why is this yelling at me?"

### Three Principles

1. **Optional** - Users must explicitly enable social tab
2. **Controlled** - Reveal level is always respected
3. **Additive** - Core timeline works perfectly without it

---

## Part 1: Social Tab (E1)

### Implementation

**Location:** Dedicated section in game detail navigation

**Default State:** Disabled (opt-in required)

**Activation:** User taps "Enable Social Tab" button

### Why Opt-In?

Social content is **not required reading**. Users who want:
- Pure timeline experience
- Minimal distractions
- Faster loading

...should never see social content unless they choose to.

### UI Flow

```
Initial State: Social section collapsed
    ↓
User expands Social section
    ↓
Sees opt-in prompt: "See team reactions and highlights"
    ↓
User taps "Enable Social Tab"
    ↓
Preference persisted
    ↓
Social posts loaded
    ↓
Feed rendered chronologically
```

### Opt-In Prompt

```
"See team reactions and highlights from social media"

[Enable Social Tab]

"Optional: Adds extra color without affecting the core timeline"
```

**Key messaging:**
- ✅ Explains what it is
- ✅ Clarifies it's optional
- ✅ Reassures core experience unchanged

---

## Part 2: Social Feed Rendering (E2)

### Data Source

**API Endpoint:** `/games/{id}/social`

**Response:** `SocialPostListResponse` with posts array

**Backend Contract:**
- Posts include `reveal_level` (pre or post)
- Posts are in chronological order
- Client preserves that order

### Rendering Rules

**Chronological Order:**
- Backend provides order
- Client does NOT resort
- Respects backend's narrative intent

**Post Display:**
- Team badge (team_id)
- Timestamp (relative, e.g., "2h ago")
- Post content (tweet_text)
- Media preview (if hasVideo or imageUrl)
- Source attribution (sourceHandle)

**Visual Hierarchy:**
- Team badge: prominent, colored
- Content: primary text
- Metadata: secondary text
- Media: preview card

### What We Don't Do

❌ Reorder posts client-side  
❌ Collapse or merge posts  
❌ Summarize or rewrite content  
❌ Add reactions or engagement metrics  
❌ Surface personal/player accounts  

Backend provides curated team content. Client displays it faithfully.

---

## Part 3: Reveal-Level Enforcement (E3)

### Critical Rule

**Social posts respect outcome visibility at all times.**

### Reveal Level System

Each post includes `reveal_level` from backend:
- **`pre`** - Safe for outcome-hidden viewing
- **`post`** - Contains outcome information

### Filtering Logic

```swift
func isSafeToShow(outcomeRevealed: Bool) -> Bool {
    guard let revealLevel else {
        // Unknown reveal level: treat as post (hide until revealed)
        return outcomeRevealed
    }
    
    switch revealLevel {
    case .pre:
        // Pre-reveal posts are always safe
        return true
    case .post:
        // Post-reveal posts only shown when outcome is revealed
        return outcomeRevealed
    }
}
```

### User Experience

**When Outcome Hidden (default):**
- Show only `pre` posts
- Hide all `post` posts
- Empty state: "No pre-reveal social posts yet. More may appear after revealing the outcome."

**When Outcome Revealed:**
- Show both `pre` and `post` posts
- Maintain chronological order
- Subtle visual differentiation (border color)

### Visual Differentiation

**Post-reveal content:**
- Slightly more prominent border (`systemGray4` vs `systemGray5`)
- Small eye icon in header
- No aggressive labeling
- No warning language

This is about **clarity**, not **friction**.

### Safety Net

If `reveal_level` is unknown or missing:
- **Treat as `post`**
- Hide until outcome revealed
- Err on the side of caution

---

## Part 4: User Control & Preferences (E5)

### Social Tab Preference

**Storage:** `UserDefaults`

**Key Format:** `"game.socialTabEnabled.{gameId}"`

**Scope:** Per-game (not global)

**Default:** `false` (disabled)

### Why Per-Game?

Users may want:
- Social for Game A (exciting matchup)
- No social for Game B (prefer pure timeline)
- Different choices for different games

### Persistence Flow

```
User enables social tab
    ↓
Set isSocialTabEnabled = true
    ↓
Persist to UserDefaults
    ↓
Load social posts
    ↓
On next app launch:
    Load preference
    If enabled, load posts automatically
```

### No Onboarding Required

Social tab is **discoverable, not intrusive**:
- Appears in navigation like other sections
- Opt-in prompt is clear and brief
- No modal dialogs
- No forced choices

---

## Part 5: Edge Cases (E6)

### Games with No Social Posts

**Scenario:** Backend has no posts for this game.

**Behavior:**
- Empty state: "No social posts available for this game."
- No broken UI
- No loading spinners forever

**Why:** Not all games have social coverage. That's okay.

### Delayed Ingestion

**Scenario:** Posts exist but haven't been ingested yet.

**Behavior:**
- Show loading state
- Provide retry button on error
- Don't block other content

**Why:** Social is optional. Delays shouldn't break the experience.

### Partial Coverage

**Scenario:** Only a few posts available.

**Behavior:**
- Render available posts
- No minimum count required
- No placeholder posts

**Why:** Some social is better than fake social.

### Live Games

**Scenario:** Game in progress, posts updating rapidly.

**Behavior:**
- Load posts once on tab enable
- No auto-refresh (for this phase)
- User can manually refresh if needed

**Why:** Real-time updates add complexity. Phase E focuses on foundational experience.

### Reveal State Changes

**Scenario:** User toggles outcome reveal while viewing social tab.

**Behavior:**
- Filtered posts update immediately
- Chronological order maintained
- Smooth transition (no jarring reloads)

**Why:** Reveal state is dynamic. Social must adapt seamlessly.

---

## Technical Architecture

### Key Files

#### Models
- **`SocialPost.swift`**
  - Added `revealLevel` field to `SocialPostResponse`
  - Added `isSafeToShow(outcomeRevealed:)` method
  - Documented reveal philosophy

#### ViewModels
- **`GameDetailViewModel.swift`**
  - Added `socialPosts` published property
  - Added `socialPostsState` enum
  - Added `isSocialTabEnabled` preference
  - Added `loadSocialPosts()` method
  - Added `enableSocialTab()` method
  - Added `filteredSocialPosts` computed property

#### Views
- **`GameSection.swift`**
  - Added `.social` case to enum

- **`GameDetailView.swift`**
  - Added `isSocialExpanded` state
  - Loads social tab preference on game load
  - Loads social posts if tab enabled

- **`GameDetailView+Sections.swift`**
  - Added `socialSection` view
  - Added `socialOptInView` prompt
  - Added `socialFeedView` with reveal filtering

- **`SocialPostCardView.swift`** (NEW)
  - Renders individual social posts
  - Shows team badge, content, media, attribution
  - Subtle visual differentiation for post-reveal content

### Data Flow

```
User Opens Game Detail
    ↓
Load social tab preference (default: false)
    ↓
If enabled:
    Load social posts from backend
    ↓
User navigates to Social section
    ↓
If not enabled:
    Show opt-in prompt
    ↓
User enables social tab
    ↓
Persist preference
    ↓
Load social posts
    ↓
Filter by reveal level
    ↓
Render chronologically
    ↓
User toggles outcome reveal
    ↓
Filtered posts update immediately
```

---

## Design Decisions

### Why Opt-In Instead of Opt-Out?

**Opt-in:**
- Respects user's choice to engage
- Keeps default experience clean
- No surprise content
- Faster initial load for users who don't want it

**Opt-out would:**
- Force social content on everyone
- Require extra step to disable
- Imply social is "default" experience

Social is **extra**, not **core**.

### Why Per-Game Preference?

Different games have different contexts:
- Rivalry game: "I want all the social energy"
- Regular season game: "Just the timeline, please"

Global preference would force one behavior everywhere.

### Why No Inline Markers (For Now)?

Phase E focuses on **foundational social experience**:
- Dedicated tab works first
- Inline markers add complexity
- Can be added in future phase if needed

Start simple. Add complexity only if it adds value.

### Why Chronological Order?

Backend curates posts with narrative intent. Client respects that.

Reordering would:
- Second-guess backend curation
- Break narrative flow
- Add client-side complexity

Trust the backend.

### Why Subtle Visual Differentiation?

Post-reveal content needs clarity, not friction:
- ✅ Slightly different border
- ✅ Small eye icon
- ❌ Red warning banners
- ❌ "SPOILER ALERT" labels
- ❌ Blur effects

Users who revealed outcomes **chose to see them**. Don't punish that choice.

---

## Validation Checklist

✅ Social content is fully optional  
✅ Default experience remains unchanged  
✅ Reveal level is respected everywhere  
✅ No outcome-visible content leaks early  
✅ Timeline readability is unaffected  
✅ App works perfectly with social tab unused  
✅ Opt-in prompt is clear and brief  
✅ Chronological order preserved  
✅ Edge cases handled gracefully  
✅ No linter errors introduced  
✅ Code follows Swift/SwiftUI best practices  
✅ Inline comments explain philosophy  

---

## User Experience

### Before Phase E

**Game Detail:**
- Overview (recap)
- Timeline (PBP)
- Stats
- Final Score

**Social context:** None

### After Phase E

**Game Detail:**
- Overview (recap)
- Timeline (PBP)
- **Social (opt-in)**
- Stats
- Final Score

**Social Tab (Disabled):**
```
"See team reactions and highlights from social media"

[Enable Social Tab]

"Optional: Adds extra color without affecting the core timeline"
```

**Social Tab (Enabled, Outcome Hidden):**
```
[Pre-reveal posts only]

🍀 BOS • 2h ago
"Great energy from the home crowd tonight!"
@celtics

⭐ LAL • 1h ago
"Locked in from the start."
@lakers
```

**Social Tab (Enabled, Outcome Revealed):**
```
[Pre-reveal posts]

🍀 BOS • 2h ago
"Great energy from the home crowd tonight!"
@celtics

[Post-reveal posts with subtle differentiation]

⭐ LAL • 30m ago 👁
"What a finish! Final highlights coming soon."
@lakers
```

---

## What's Next (Future Phases)

Phase E establishes foundational social experience. Future enhancements could include:
- **Inline Timeline Markers:** Subtle indicators in PBP for moments with social reactions
- **Real-Time Updates:** Live post ingestion during games
- **Media Playback:** In-app video/image viewing
- **Granular Filtering:** Filter by team, media type, time period
- **Social Highlights:** Curated "best reactions" for key moments

The foundation is solid. Enhancements are optional.

---

## Code Comments Philosophy

Throughout Phase E, inline comments explain:
- **Why social is opt-in:** Respects user choice, keeps default clean
- **Why default is minimal:** Core experience shouldn't require social
- **Why reveal level matters:** Outcome visibility is sacred
- **Why chronological order:** Trust backend curation

Comments focus on **philosophy**, not **implementation**.

---

## Testing Notes

### Manual Testing Scenarios

1. **First Time User (Social Disabled)**
   - Open game detail
   - Navigate to Social section
   - Verify opt-in prompt shows
   - Verify other sections unaffected

2. **Enable Social Tab**
   - Tap "Enable Social Tab"
   - Verify posts load
   - Verify preference persisted
   - Close and reopen app
   - Verify social still enabled

3. **Reveal Filtering**
   - View social with outcome hidden
   - Verify only pre posts show
   - Reveal outcome
   - Verify post posts appear
   - Hide outcome again
   - Verify post posts disappear

4. **Edge Cases**
   - Game with no social posts
   - Network error during load
   - Posts with missing reveal_level
   - Empty pre-reveal posts

### Unit Test Coverage

Consider adding tests for:
- `isSafeToShow()` logic
- `filteredSocialPosts` computation
- Preference persistence
- Edge case handling

---

## Metrics

**Before Phase E:**
- Social context: None
- User engagement with social: N/A
- Personality: Minimal

**After Phase E:**
- Social context: Optional, opt-in
- Expected opt-in rate: 20-40% (beta testing)
- Personality: Alive but calm

---

## Related Documentation

- **PHASE_A.md:** Routing and trust fixes
- **PHASE_B.md:** Real backend feeds
- **PHASE_C.md:** Timeline usability
- **PHASE_D.md:** Recaps and reveal control
- **architecture.md:** Overall app structure
- **AGENTS.md:** AI agent context

---

## Summary

Phase E is complete when the app gains personality without noise. Users can now:
- Choose to see team reactions and highlights
- Trust that reveal state is always respected
- Enjoy social context without it hijacking the timeline
- Ignore social entirely if they prefer

The experience feels **alive but calm**.

Social content enhances moments instead of stealing them. This is texture, not noise.

**Next:** Future phases can build on this foundation with inline markers, real-time updates, and richer media integration—but only if they add value without adding friction.
