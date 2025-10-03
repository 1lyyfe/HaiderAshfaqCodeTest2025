###  What I shipped (within ~4 hours)
- **Headlines page** (swipe horizontally between full-page articles)
- **Article detail page** (title, date, image header, body)
- **Favouriting** (toggle on page; sticky bottom bar with ★ and “Favourites”)
- **Favourites modal list** (search, newest-first, tap to jump back to article)
- **Error/empty states + pull-to-refresh**
- **Offline fallback**: caches last successful fetch to disk and shows a small auto-hiding banner when using it
- **Accessibility**: labels/values/hints, Dynamic Type support, Reduce Motion respected, larger hit targets
- **Tests**: JSON decoding, service (mocked URLSession), ArticleViewModel (success/offline/failure), FavouritesViewModel (filter/sort). One tiny smoke test for the store.
**Light/Dark Mode Support**: The app is useable fully across colour schemes.
- **Launch Screen + App Icons** I feel like this is super important as we are treating this project to be shipped, without these (what seems minor) the app is not shippable.

---

### Priorities & why

- **Shippability first**: correct data, resilient states (loading / offline / error), and favouriting that feels reliable.
- **Accessibility & UX basics over flashy animation**: clear labels, contrast, Dynamic Type, predictable gestures.
- **Simple + testable**: injectable URLSession for the service and a cache adapter for the VM to make robust tests fast.
- **Stay close to the spec** but make pragmatic calls for readability and contrast (documented below).
- **My approach was refactor “as you go”** and consider accessibility + end user experience always to make this project shippable.
---

### Approximately How Long I Spent
~3 hours end-to-end (coding, tests, polish), plus a 30 minutes to write this document as required by the spec.

---

### Architecture (overview)

Simple, clean and light weight MVVM

- **Views**: ArticlesPagerView → ArticlePageView, FavouritesListView, BottomFavouritesBar
- **State**: ArticleViewModel (loading, selection, offline banner), FavouritesStore (persistence), FavouritesViewModel (read-only snapshot + filtering)
- **Networking**: ArticleService (injectable URLSession)
- **Cache**: ArticlesCache (last-good payload in Caches directory)
- **Models**: ArticlesResponse, Article, FavouriteArticle
- **Utilities**: string HTML strip + URL detection, tiny debug fetch printer

**Rationale**: SwiftUI end-to-end let me move quickly, leverage a11y defaults, and keep code compact. The favourites modal receives a snapshot of items (read-only) to keep coupling low; the ★ toggle lives on the article page.

---

### Accessibility
- Full Voiceover support
- Texts scale with Dynamic Type.
- Layout metrics (headerHeight, paddings) use @ScaledMetric to breathe at large sizes.
- High contrast: I moved the title above the image on a white panel for guaranteed contrast.
(I originally overlaid text on the photo with a gradient, but some images were still borderline.)

I trialed a VoiceOver announcement helper:
```
// Optional fast-follow
func announce(_ message: String) {
    guard UIAccessibility.isVoiceOverRunning else { return }
    UIAccessibility.post(notification: .announcement, argument: message)
}
```
This requires VoiceOver running on device/simulator (macOS Accessibility Inspector doesn’t speak .announcement). The baseline label/value/hint remains in place.

---
### Visual decisions (and small deviations)
- Title above image: deviates from the PNG (which overlays text) to guarantee contrast and readability across arbitrary photos and text sizes.

- Never truncate the headline: I use a small length-based step-down (largeTitle/title/title2) so long Guardian titles stay readable. If needed, I’d replace this with measurement-based fitting (e.g. TextLayout) to target ≤3 lines.

- Discoverability: full-width pages can hide pagination; I added a subtle “Swipe →” chip on the image and show page dots only until the user swipes once.

- Sticky bottom bar: matches spec intent, bigger hit targets, consistent yellow accent.


---
## If I had another two days

- Custom pager: replicate the PNG’s stacked/tilt effect with a peeking next card, Reduce Motion fallback, and Voiceover focus management.
- Cool Animation polish across the app.
- Snapshot tests: light/dark, multiple devices and Dynamic Type using SnapshotTesting; add smoke snapshots for the favourites list.
- Pagination & search: proper pagination params,
- In-page search.
- Home screen with article categories
---

## What I’d change structurally (future refactor)
- Repository (high-level plan for Day-2)
    - Introduce a tiny Repository layer so view models talk to clean interfaces rather than directly to URLSession, UserDefaults, or files.
- Introduce a small Design System (spacing, colors, typography) if the app grows.
- Consider SwiftData for favourites if the scope expands beyond a list.
---
### Notes from the first 20 minutes (SwiftUI Commitment + Modelling JSON)
- Why SwiftUI (vs. UIKit + hosting)
   -  Faster to implement the spec in 4h, excellent a11y defaults, easy Dynamic Type, and concise state handling.
   -  If a UIKit base was required, I’d use a hosting controller for the article page and favourites list to keep velocity without sacrificing native structure.
   
-  Modelling JSON:
    - I always start by hitting the API and printing the raw JSON to confirm shape & fields (see GuardianDebug.printResponse).
    - Final models: ArticlesResponse → ArticlesMeta → [Article] matching webPublicationDate, fields.headline/thumbnail/body.

---
### Trade-offs & Rationale
**SwiftUI end-to-end (vs UIKit + hosting)**
    - Chosen: SwiftUI for all screens.
    - Why: Fastest path to “shippable in 4h”, great a11y defaults, less boilerplate.
    - Risk: Some reviewers may expect UIKit.
    - Mitigation/Alt: Could wrap screens in UIHostingController inside a UIKit shell if needed.

**System pager (TabView(.page)) (vs custom stacked/tilt pager)**

   - Chosen: Standard page control with a subtle “Swipe →” hint.
    - Why: Accessibility, reliability, and time—custom gestures/layout are risky in 4h.
    - Risk: Doesn’t exactly match fancy peek/tilt in the PNG.
    - Mitigation/Alt: Documented as “day-2” item; keep dots visible until first swipe for discoverability.


**Title above image (vs overlay with gradient)**
- Chosen: Title on a white panel.
- Why: Guaranteed contrast across arbitrary photos & Dynamic Type sizes.
- Risk: Deviates from the spec.
- Mitigation/Alt: Could restore overlay with dynamic scrim strength based on image luminance.

**Never truncate headline + simple length-based sizing**
- Chosen: Step down (largeTitle/title/title2) by character count.
- Why: Ensures meaning isn’t lost; minimal code.
- Risk: Heuristic, not perfect.
- Mitigation/Alt: Measurement-based fit with TextLayout (target ≤3 lines).

**Offline cache = last-good payload**
- Chosen: Save/load a single snapshot in Caches; auto-hide banner on use.
- Why: Reliability when offline with tiny cost.
- Risk: Could show stale content if network is down for long.
- Mitigation/Alt: Add “stale by X minutes” messaging; per-query caches.

**Favourites modal uses read-only snapshot (vs shared live store)**
- Chosen: Pass a value snapshot into FavouritesViewModel.
- Why: Low coupling; predictable flow in 4h.
- Risk: Edits from the modal wouldn’t propagate (not needed for this task for stretch goal).
- Mitigation/Alt: Inject the store or a repository for bi-directional updates.

**UserDefaults for favourites (vs SwiftData/CoreData)**
- Chosen: Simple JSON blob in UserDefaults.
- Why: Meets requirements quickly.
- Risk: No queries/relationships, limited scalability.
- Mitigation/Alt: Swap to SwiftData with the same FavouriteArticle model.

**Plain-text body (vs rich HTML rendering)**
- Chosen: Strip tags and render text.
- Why: Faster, predictable typography.
- Risk: Loses inline links/formatting.
- Mitigation/Alt: Use AttributedString(html:) or a WebView for full fidelity.

**Minimal tests where they mean the most**
- Chosen: Decoding, service (mocked), view-models; one smoke for store.
- Why: Covers correctness paths cheaply.
- Risk: No UI snapshots; fewer regressions caught on layout.
- Mitigation/Alt: Add SnapshotTesting for key screens (light/dark, Dynamic Type).

**Accessibility announcements optional**
- Chosen: Labels/values/hints + Reduce Motion; announcement helper not enforced.
- Why: Voiceover `.announcement` requires Voiceiver to be running;
- Risk: Less auditory feedback on toggle.
- Mitigation/Alt: Gate announcements behind UIAccessibility.isVoiceOverRunning and add a small haptic.



