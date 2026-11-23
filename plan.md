# ui_plus (UI Plus) — Development Roadmap

> **Role:** Central development roadmap for `ui_plus`.  
> **Branding:** UI Plus — More power to your Flutter UI.  
> **Last verified against source:** 2026-11-23 (lib exports, tests, example, docs).  
> **Package version in `pubspec.yaml`:** `0.2.0`

Modular, architecture-agnostic Flutter UI toolkit for reusable components,
application states, connectivity presentation, and productivity utilities.
Core stays free of Bloc, Riverpod, Provider, GetX, Dio, and connectivity plugins.
Flagship widget remains `ScaffoldPlus`.

---

## Product principles (preserved)

1. Architecture agnostic — apps map their states at the UI boundary.
2. Composable — every public widget usable without adopting the whole package.
3. Flutter-native — prefer SDK APIs over wrappers that only rename.
4. Customizable — builders and overrides without parallel design systems by default.
5. Accessible — semantics, text scaling, reduced motion, theme brightness.
6. Testable — deterministic widgets; widget tests per public API.
7. Lightweight — no mandatory third-party runtime deps beyond Flutter SDK.
8. Stable APIs — small public surface; document breaking changes.

**Deferred by design:** project generation, DI, routing frameworks, networking clients, global app state, analytics, automatic connectivity monitoring plugins.

---

## Status legend

| Status | Meaning |
| --- | --- |
| **Completed** | Implemented, exported, tested, documented, demoed |
| **In Progress** | Actively being built or incomplete against DoD |
| **Planned** | Approved for a milestone; not started |
| **Future** | Candidate only; needs a clear value case before scheduling |

**Definition of done:** reviewed API, const where appropriate, constrained layouts, theming/a11y, widget tests, example demo, barrel export, README/docs, format/analyze/tests green.

---

## Snapshot

| Milestone | Theme | Implementation | Release |
| --- | --- | --- | --- |
| **v0.1.0** Core Foundation | Scaffold + async + state widgets | **Completed** (theme config still open) | `0.1.0` (changelog) |
| **v0.2.0** Connectivity | Plugin-free connectivity UI | **Completed** | `0.2.0+1` |
| **v0.3.0** Everyday Productivity | Snackbars, dialogs, sheets, search | **Planned** | — |
| **v0.4.0** Responsive UI & Utilities | Adaptive / responsive helpers | **Planned** | — |
| **v0.5.0** Advanced Application UI | Higher-value advanced helpers | **Planned / Future** | — |
| **v1.0.0** Stable Release | API freeze + pub.dev readiness | **Planned** | — |

**In Progress:** none.

---

# Completed

## v0.1.0 — Core Foundation

### ScaffoldPlus\<T\>

| Field | Detail |
| --- | --- |
| **Purpose** | Drop-in `Scaffold` replacement with optional async body + opt-in connectivity. |
| **Public API** | `ScaffoldPlus<T>` |
| **Main functionality** | Forwards Flutter `Scaffold` API; composes native `Scaffold` (`Scaffold.of` works). When `state != null`, async body wins and `body` is ignored. Shares internal `PlusAsyncBody` with `PlusAsyncView`. |
| **Dependencies** | Flutter SDK only |
| **Testing** | `test/src/scaffold/scaffold_plus_test.dart` (plain body, async branches, skeleton, connectivity overlay) |
| **Status** | **Completed** |

### PlusAsyncState / PlusAsyncView\<T\>

| Field | Detail |
| --- | --- |
| **Purpose** | Exhaustive async presentation without architecture lock-in. |
| **Public API** | `PlusAsyncState<T>`, `PlusLoading`, `PlusSuccess`, `PlusFailure`, `PlusAsyncView<T>`, typedefs in `plus_async_types.dart` |
| **Main functionality** | Precedence: loading → failure → success/`isEmpty` → success body. Defaults: `PlusLoader` / `PlusSkeleton`, `PlusEmptyState`, `PlusErrorState`. |
| **Dependencies** | Flutter SDK only |
| **Testing** | `test/src/async/plus_async_view_test.dart`; design: `doc/async_view_design.md` |
| **Status** | **Completed** |

### PlusEmptyState

| Field | Detail |
| --- | --- |
| **Purpose** | Consistent empty UI for lists/search/etc. |
| **Public API** | `PlusEmptyState` |
| **Main functionality** | Title, description, icon/illustration, optional action; theme-aware; scrolls under tight height via internal `PlusStateLayout`. |
| **Dependencies** | Flutter SDK only |
| **Testing** | `test/src/states/plus_empty_state_test.dart` |
| **Status** | **Completed** |

### PlusErrorState

| Field | Detail |
| --- | --- |
| **Purpose** | Consistent failure UI with optional retry (no HTTP/error-model coupling). |
| **Public API** | `PlusErrorState` |
| **Main functionality** | Title, message, icon/illustration, optional retry; error-colored default icon; tight-height safe. |
| **Dependencies** | Flutter SDK only |
| **Testing** | `test/src/states/plus_error_state_test.dart` |
| **Status** | **Completed** |

### PlusLoader

| Field | Detail |
| --- | --- |
| **Purpose** | Compact theme-aware circular loader. |
| **Public API** | `PlusLoader` |
| **Main functionality** | Sized `CircularProgressIndicator` with semantics (`Loading`). |
| **Dependencies** | Flutter SDK only |
| **Testing** | `test/src/loaders/plus_loader_test.dart` |
| **Status** | **Completed** |

### PlusSkeleton

| Field | Detail |
| --- | --- |
| **Purpose** | Composable shimmer placeholder (no preset layouts). |
| **Public API** | `PlusSkeleton` |
| **Main functionality** | Width/height/radius/colors/animation; respects `MediaQuery.disableAnimations`. |
| **Dependencies** | Flutter SDK only |
| **Testing** | `test/src/loaders/plus_skeleton_test.dart` |
| **Status** | **Completed** |

### Package foundation

| Field | Detail |
| --- | --- |
| **Purpose** | Shipable package skeleton and quality bar. |
| **Public API** | `package:ui_plus/ui_plus.dart` barrel |
| **Main functionality** | VGV analysis/CI, example host, README/CHANGELOG, Cursor rules, docs under `doc/`. |
| **Dependencies** | Runtime: Flutter SDK. Dev: `very_good_analysis`, `mocktail`. |
| **Testing** | Full suite currently **73** widget tests + example smoke test |
| **Status** | **Completed** |

**Internal (not exported, by design):** `PlusAsyncBody`, `PlusStateLayout`.

---

## v0.2.0 — Connectivity

Plugin-free connectivity **presentation**. Apps supply `bool` / `Stream<bool>` (prefer reachability). See `doc/connectivity.md`.

### PlusConnectivityConfig

| Field | Detail |
| --- | --- |
| **Purpose** | Shared appearance/behavior for banners. |
| **Public API** | `PlusConnectivityConfig`, `PlusConnectivityBannerPosition` |
| **Main functionality** | Offline/online copy, colors, position, debounce, auto-hide duration. |
| **Dependencies** | Flutter SDK only |
| **Testing** | Covered via banner/overlay/scaffold tests |
| **Status** | **Completed** |

### PlusConnectivityBanner

| Field | Detail |
| --- | --- |
| **Purpose** | Pure visual banner for online/offline messaging. |
| **Public API** | `PlusConnectivityBanner` |
| **Main functionality** | Stateless presentation driven by `isConnected` + config. |
| **Dependencies** | Flutter SDK only |
| **Testing** | `test/src/connectivity/plus_connectivity_banner_test.dart` |
| **Status** | **Completed** |

### PlusConnectivityOverlay

| Field | Detail |
| --- | --- |
| **Purpose** | Host lifecycle for banners without resizing body. |
| **Public API** | `PlusConnectivityOverlay`, `PlusConnectivityBannerBuilder` |
| **Main functionality** | Stack overlay; debounce; silent first status (no false “restored”); offline sticky; online auto-hide. |
| **Dependencies** | Flutter SDK only |
| **Testing** | `test/src/connectivity/plus_connectivity_overlay_test.dart` |
| **Status** | **Completed** |

### PlusOfflineState

| Field | Detail |
| --- | --- |
| **Purpose** | Full offline empty/error-style page content. |
| **Public API** | `PlusOfflineState` |
| **Main functionality** | Title/message/icon + retry or custom action; tight-height scroll-safe. |
| **Dependencies** | Flutter SDK only |
| **Testing** | `test/src/connectivity/plus_offline_state_test.dart` (incl. tight height) |
| **Status** | **Completed** |

### PlusConnectivityBuilder

| Field | Detail |
| --- | --- |
| **Purpose** | Swap online vs offline child trees from a bool. |
| **Public API** | `PlusConnectivityBuilder` |
| **Main functionality** | `onlineBuilder` / `offlineBuilder` branching. |
| **Dependencies** | Flutter SDK only |
| **Testing** | `test/src/connectivity/plus_connectivity_builder_test.dart` |
| **Status** | **Completed** |

### ScaffoldPlus connectivity integration

| Field | Detail |
| --- | --- |
| **Purpose** | Opt-in banner on the primary scaffold. |
| **Public API** | `connectivityBanner`, `isConnected`, `connectivityStream`, `connectivityBannerConfig`, `connectivityBannerBuilder` |
| **Main functionality** | Wraps body stack with overlay when enabled; independent of async `state`. |
| **Dependencies** | Flutter SDK only |
| **Testing** | Integration case in `scaffold_plus_test.dart` |
| **Status** | **Completed** |

---

# In Progress

_None._

---

# Planned

## v0.3.0 — Everyday Productivity

Goal: high-frequency UI helpers that add clear value beyond Flutter primitives. Prefer thin, opinionated helpers — **do not** wrap widgets that only rename SDK APIs.

### PlusSnackbar

| Field | Detail |
| --- | --- |
| **Purpose** | Consistent, theme-aware snackbar helpers for success/info/error feedback. |
| **Public API** | `PlusSnackbar` (static helpers and/or small config type — finalize at implementation) |
| **Main functionality** | Show/hide with sensible defaults (duration, action, semantics); optional messenger context helpers. |
| **Dependencies** | Flutter SDK only |
| **Testing** | Show/dismiss, theming, action callbacks, a11y labels |
| **Status** | **Planned** |

### PlusDialog / PlusConfirmDialog

| Field | Detail |
| --- | --- |
| **Purpose** | Standard alert and confirm flows without app-specific boilerplate. |
| **Public API** | `PlusDialog`, `PlusConfirmDialog` |
| **Main functionality** | Title/content/actions; confirm/cancel callbacks; Material 3 dialog theming. |
| **Dependencies** | Flutter SDK only |
| **Testing** | Render, actions, barrier dismiss, dark/light, text scale |
| **Status** | **Planned** |

### PlusBottomSheet

| Field | Detail |
| --- | --- |
| **Purpose** | Consistent modal/persistent bottom-sheet presentation helpers. |
| **Public API** | `PlusBottomSheet` (show helpers + optional content chrome) |
| **Main functionality** | Safe-area aware sheets with optional drag handle / title; avoid duplicating `showModalBottomSheet` unless API clearly simplifies. |
| **Dependencies** | Flutter SDK only |
| **Testing** | Present/dismiss, scroll content, theming |
| **Status** | **Planned** |

### PlusSearchField

| Field | Detail |
| --- | --- |
| **Purpose** | Common search input pattern for app bars and list filters. |
| **Public API** | `PlusSearchField` |
| **Main functionality** | Debounced `onChanged` (optional), clear button, hint, theming; no search engine coupling. |
| **Dependencies** | Flutter SDK only |
| **Testing** | Input, clear, debounce timing, semantics |
| **Status** | **Planned** |

### PlusRefreshIndicator (conditional)

| Field | Detail |
| --- | --- |
| **Purpose** | Only if it meaningfully simplifies pull-to-refresh wiring with async states. |
| **Public API** | `PlusRefreshIndicator` |
| **Main functionality** | Thin wrapper coordinating refresh + `PlusAsyncState` / callbacks. Skip if it is a pure rename of Flutter’s widget. |
| **Dependencies** | Flutter SDK only |
| **Testing** | Trigger, completion, error path |
| **Status** | **Planned** (gate: clear value vs SDK) |

### Shared style defaults (PlusTheme — evaluate)

| Field | Detail |
| --- | --- |
| **Purpose** | App-wide defaults for spacing/copy defaults across Plus widgets **only if** duplication becomes painful. |
| **Public API** | Optional `PlusTheme` / `ThemeExtension` |
| **Main functionality** | Inherited defaults without forcing a parallel design system. |
| **Dependencies** | Flutter SDK only |
| **Testing** | Theme inheritance, override precedence |
| **Status** | **Planned** (optional; not a blocker for other v0.3 items) |

---

## v0.4.0 — Responsive UI & Utilities

Goal: phone/tablet layout helpers that stay composable. Avoid a mega-scaffold with unrelated knobs.

### PlusResponsive

| Field | Detail |
| --- | --- |
| **Purpose** | Breakpoint-based builder for width classes. |
| **Public API** | `PlusResponsive` (+ optional breakpoint config) |
| **Main functionality** | `LayoutBuilder`/MediaQuery-based slots (compact / medium / expanded). |
| **Dependencies** | Flutter SDK only |
| **Testing** | Breakpoint switches under fixed constraints |
| **Status** | **Planned** |

### PlusAdaptiveScaffold (or layout shell)

| Field | Detail |
| --- | --- |
| **Purpose** | Adaptive navigation shell (nav bar ↔ rail/drawer) without replacing `ScaffoldPlus`. |
| **Public API** | `PlusAdaptiveScaffold` |
| **Main functionality** | Compose with or wrap `ScaffoldPlus`; destinations API; keep async/connectivity orthogonal. |
| **Dependencies** | Flutter SDK only |
| **Testing** | Narrow/wide layouts, destination selection |
| **Status** | **Planned** |

### PlusScrollToTop

| Field | Detail |
| --- | --- |
| **Purpose** | Convenience for list/scaffold scroll-to-top affordances. |
| **Public API** | `PlusScrollToTop` |
| **Main functionality** | Listen to scroll controller; expose FAB/button or callback. |
| **Dependencies** | Flutter SDK only |
| **Testing** | Visibility threshold, callback, controller attach/detach |
| **Status** | **Planned** |

### Layout utilities

| Field | Detail |
| --- | --- |
| **Purpose** | Small helpers (gaps, constrained content width) only when repeatedly useful across examples. |
| **Public API** | TBD (`PlusGap`, `PlusContentWidth`, …) — name at implementation time |
| **Main functionality** | Reduce boilerplate without inventing a layout framework. |
| **Dependencies** | Flutter SDK only |
| **Testing** | Constraint behavior |
| **Status** | **Planned** |

---

## v0.5.0 — Advanced Application UI

Goal: higher-value helpers that remain architecture-agnostic. Each item requires a written value case before coding.

### PlusNetworkImage (conditional)

| Field | Detail |
| --- | --- |
| **Purpose** | Loading/error/empty placeholders for remote images **only** if clearly better than composing existing Flutter/image packages. |
| **Public API** | `PlusNetworkImage` |
| **Main functionality** | Integrate with `PlusLoader` / `PlusErrorState` patterns; no forced image CDN client. |
| **Dependencies** | Prefer Flutter SDK; avoid mandatory third-party image caches unless companion package |
| **Testing** | Loading/error/success, semantics |
| **Status** | **Planned** (gate: clear value) |

### Sliver / nested-scroll helpers (conditional)

| Field | Detail |
| --- | --- |
| **Purpose** | Help common collapsing-header / nested scroll cases. |
| **Public API** | TBD |
| **Main functionality** | Only with documented use cases; no speculative sliver kit. |
| **Dependencies** | Flutter SDK only |
| **Testing** | Scroll coordination under constraints |
| **Status** | **Planned** (gate: use case) |

### Skeleton layout presets (optional)

| Field | Detail |
| --- | --- |
| **Purpose** | Optional list/card skeleton compositions built on `PlusSkeleton`. |
| **Public API** | e.g. `PlusSkeletonList`, `PlusSkeletonCard` |
| **Main functionality** | Convenience presets; core `PlusSkeleton` remains the primitive. |
| **Dependencies** | Flutter SDK only |
| **Testing** | Composition rendering, reduced motion |
| **Status** | **Planned** |

### Companion integrations (packages, not core)

| Field | Detail |
| --- | --- |
| **Purpose** | Map Bloc/Riverpod states → `PlusAsyncState` without polluting core. |
| **Public API** | Separate packages e.g. `ui_plus_bloc`, `ui_plus_riverpod` |
| **Main functionality** | Thin adapters only when a real integration API exists. |
| **Dependencies** | Live in companion packages |
| **Testing** | Adapter unit/widget tests in those packages |
| **Status** | **Future** until demand + concrete API |

---

## v1.0.0 — Stable Release

| Field | Detail |
| --- | --- |
| **Purpose** | Declare a stable public API suitable for pub.dev consumers. |
| **Public API** | Freeze current barrel exports; migration notes if needed |
| **Main functionality** | API review, full README/API docs, example screenshots, a11y/large-text pass, SDK constraint verification, package score, semantic versioning policy, CI green. |
| **Dependencies** | No new mandatory runtime deps |
| **Testing** | Full suite + example builds; optional golden/a11y audits |
| **Status** | **Planned** |

---

# Future Considerations

Candidates only — **not committed** to a milestone. Do not implement without an
explicit value case and approval.

### Discussed UI / UX candidates

| Candidate | Rough purpose |
| --- | --- |
| `PlusAsyncButton` | Button that reflects in-flight async action state |
| `PlusFeedback` | Unified success/info/error feedback helper |
| `PlusConfirmationDialog` | Confirm/cancel dialog (may consolidate with planned v0.3 dialog naming) |
| `PlusCountdown` | Timed countdown / resend affordance |
| `PlusDebouncer` | Debounce utility for UI events |
| `PlusThrottler` | Throttle utility for UI events |
| `PlusMaintenanceMode` | Full-screen / banner maintenance presentation |
| `PlusSessionExpired` | Session-expired interstitial / dialog pattern |
| `PlusPermissionState` | Permission denied/request UI state |
| `PlusErrorBoundary` | Widget-tree error catch UI (presentation only) |
| `PlusShowcase` | Feature highlight / coach-mark presentation |

### Other deferred ideas

- Optional reachability helper **as a separate package** (never a core plugin dependency).
- Shared `PlusTheme` / `ThemeExtension` if cross-widget defaults become painful.
- Analytics / telemetry hooks (likely out of scope forever for core).
- Code generation / mason bricks for feature folders.
- Decorative / marketing widget kits.
- Built-in DI or navigation frameworks.

Revisit only when they reduce real app boilerplate without violating architecture-agnostic or lightweight principles.

---

## Architecture decisions to preserve

| Decision | Rationale |
| --- | --- |
| Sealed `PlusAsyncState` only (no parallel bool API) | Single precedence story |
| Shared internal `PlusAsyncBody` | No duplicated async switching |
| `ScaffoldPlus` composes native `Scaffold` | `Scaffold.of` compatibility |
| `state == null` → `body`; else async wins (no assert) | Drop-in scaffold + opt-in async |
| Connectivity is presentation-only (`bool`/`Stream<bool>`) | Apps own reachability |
| Banner via `Stack` overlay | Body does not resize |
| Silent first connectivity status | No false “restored” on launch |
| Public import only via `lib/ui_plus.dart` | Stable surface |
| No empty folders for speculative features | Implement when scheduled |
| Keep `ScaffoldPlus` focused | New utilities as independent widgets/helpers |

---

## Current public export surface

From `lib/ui_plus.dart`:

- Async: `PlusAsyncState`, `PlusLoading`, `PlusSuccess`, `PlusFailure`, typedefs, `PlusAsyncView`
- Connectivity: `PlusConnectivityBanner`, `PlusConnectivityBuilder`, `PlusConnectivityConfig`, `PlusConnectivityBannerPosition`, `PlusConnectivityOverlay`, `PlusConnectivityBannerBuilder`, `PlusOfflineState`
- Loaders: `PlusLoader`, `PlusSkeleton`
- Scaffold: `ScaffoldPlus`
- States: `PlusEmptyState`, `PlusErrorState`

---

## Recommended implementation order (next)

1. **Publish / tag `0.2.0`** when approved (git tag + pub.dev if desired).
2. **Start v0.3.0 with `PlusSnackbar`** — highest everyday value, smallest API risk, validates overlay/helper patterns used by dialogs/sheets.
3. Then dialogs → `PlusBottomSheet` → `PlusSearchField`; evaluate `PlusRefreshIndicator` / `PlusTheme` only with a written value case.
4. Future Consideration candidates above remain unscheduled until explicitly approved.

---

## Working agreements

- One component (or tightly related pair) per task: API → impl → tests → example → docs → format/analyze/test.
- Do not implement speculative features outside the active milestone.
- Prefer Flutter SDK; justify any new dependency before adding it.
- Update this `plan.md` when milestone status changes.

**Related docs:** [README](README.md) · [CHANGELOG](CHANGELOG.md) · [doc/roadmap.md](doc/roadmap.md) · [doc/async_view_design.md](doc/async_view_design.md) · [doc/connectivity.md](doc/connectivity.md) · [`.cursor/rules/ui-plus.mdc`](.cursor/rules/ui-plus.mdc)
