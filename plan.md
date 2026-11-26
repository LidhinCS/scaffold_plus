# ui_plus (UI Plus) — Development Roadmap

> **Role:** Central development roadmap for `ui_plus`.  
> **Branding:** UI Plus — More power to your Flutter UI.  
> **Last verified against source:** 2026-11-26 (lib exports, tests, example, docs).  
> **Package version in `pubspec.yaml`:** `1.1.1`

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
7. Lightweight — only Flutter SDK + design packages (`material_ui`); no Bloc/Dio/etc.
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
| **v0.1.0** Core Foundation | Scaffold + async + state widgets | **Completed** | `0.1.0` |
| **v0.2.0** Connectivity | Plugin-free connectivity UI | **Completed** | `0.2.0` |
| **v0.3.0** Everyday Productivity | Snackbars, dialogs, sheets, search, refresh, theme | **Completed** | `0.3.0` |
| **v0.4.0** Unique application patterns | Async button, paged list, adaptive shell | **Completed** | `0.4.0` |
| **v0.5.0** Product gates + polish | Maintenance/session/permission, internet checker, toast host, Pulse Tasks, docs | **Completed** | `0.5.0` |
| **v0.6.0** material_ui + inline banner | Standalone Material + body connectivity banner | **Completed** | `0.6.0` |
| **v1.0.0** Stable Release | API freeze + pub.dev readiness | **Completed** | `1.0.0` |
| **v1.1.0** Floating window | PiP-style detachable overlay | **Completed** | `1.1.0` |
| **v1.1.1** Preview assets | README / pub.dev screenshot refresh | **Completed** | `1.1.1` |

**In Progress:** none.

**Uniqueness bar:** Prefer APIs that encode a multi-step app pattern (async
lifecycle, paging, adaptive navigation). Avoid thin wrappers around a single
Material widget.

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
| **Purpose** | Shippable package skeleton and quality bar. |
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
| **Public API** | `PlusConnectivityConfig`, `PlusConnectivityBannerPosition`, `PlusConnectivityBannerLayout` |
| **Main functionality** | Offline/online copy, colors, position, layout, debounce, auto-hide duration. |
| **Dependencies** | Flutter SDK + `material_ui` |
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
| **Purpose** | Host lifecycle for connectivity banners. |
| **Public API** | `PlusConnectivityOverlay`, `PlusConnectivityBannerBuilder` |
| **Main functionality** | Inline (default) or overlay layout; debounce; silent first status; offline sticky; online auto-hide. |
| **Dependencies** | Flutter SDK + `material_ui` |
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
| **Main functionality** | Wraps scaffold **body** (below app bar); default inline layout; independent of async `state`. |
| **Dependencies** | Flutter SDK + `material_ui` |
| **Testing** | Integration case in `scaffold_plus_test.dart` |
| **Status** | **Completed** |

---

## v0.3.0 — Everyday Productivity

### PlusSnackbar

| Field | Detail |
| --- | --- |
| **Purpose** | Consistent, theme-aware snackbar helpers for success/info/error feedback. |
| **Public API** | `PlusSnackbar`, `PlusSnackbarTone`, `PlusToastHost` |
| **Main functionality** | `show` / `success` / `info` / `error` / `hide` / `clear`; Material 3 tones; optional action; clears current by default. Optional context-free calls via `PlusToastHost` / `messengerKey`. |
| **Dependencies** | Flutter SDK only |
| **Testing** | `test/src/feedback/plus_snackbar_test.dart`, `plus_toast_host_test.dart` |
| **Status** | **Completed** |

### PlusDialog / PlusConfirmationDialog

| Field | Detail |
| --- | --- |
| **Purpose** | Standard alert and confirm flows without app-specific boilerplate. |
| **Public API** | `PlusDialog`, `PlusConfirmationDialog` |
| **Main functionality** | Alert `show`/`alert`; confirmation returns `bool`; optional destructive confirm. |
| **Dependencies** | Flutter SDK only |
| **Testing** | `test/src/dialogs/plus_dialog_test.dart`, `plus_confirmation_dialog_test.dart` |
| **Status** | **Completed** |

### PlusBottomSheet

| Field | Detail |
| --- | --- |
| **Purpose** | Consistent modal bottom-sheet presentation helpers. |
| **Public API** | `PlusBottomSheet` |
| **Main functionality** | `show` / `showScrollable` with optional title, drag handle, safe area, height factor. |
| **Dependencies** | Flutter SDK only |
| **Testing** | `test/src/sheets/plus_bottom_sheet_test.dart` |
| **Status** | **Completed** |

### PlusSearchField

| Field | Detail |
| --- | --- |
| **Purpose** | Common search input pattern for app bars and list filters. |
| **Public API** | `PlusSearchField` |
| **Main functionality** | Optional debounced `onChanged`, clear button, hint, Material 3 theming; no search engine coupling. |
| **Dependencies** | Flutter SDK only |
| **Testing** | `test/src/inputs/plus_search_field_test.dart` |
| **Status** | **Completed** |

### PlusRefreshIndicator

| Field | Detail |
| --- | --- |
| **Purpose** | Theme-aware pull-to-refresh with optional error handling. |
| **Public API** | `PlusRefreshIndicator` |
| **Main functionality** | Material `RefreshIndicator` defaults + `onError` so failures can dismiss cleanly. |
| **Dependencies** | Flutter SDK only |
| **Testing** | `test/src/refresh/plus_refresh_indicator_test.dart` |
| **Status** | **Completed** |

### PlusTheme

| Field | Detail |
| --- | --- |
| **Purpose** | App-wide defaults for Plus helpers without a parallel design system. |
| **Public API** | `PlusTheme` |
| **Main functionality** | `ThemeExtension` for snackbar duration, search debounce, state/sheet paddings; `PlusTheme.of`. |
| **Dependencies** | Flutter SDK only |
| **Testing** | `test/src/theme/plus_theme_test.dart` |
| **Status** | **Completed** |

---

## v0.4.0 — Unique application patterns

Goal: ship helpers that encode real app patterns Flutter does not provide
out of the box — not renamed Material widgets.

### PlusAsyncButton

| Field | Detail |
| --- | --- |
| **Purpose** | Button that owns in-flight async action UX (lock, loading, optional success flash). |
| **Public API** | `PlusAsyncButton`, `PlusAsyncButtonVariant` |
| **Main functionality** | Awaits `Future` on press; disables while loading; optional success child / error callback. |
| **Dependencies** | Flutter SDK only |
| **Testing** | `test/src/actions/plus_async_button_test.dart` |
| **Status** | **Completed** |

### PlusPagedList

| Field | Detail |
| --- | --- |
| **Purpose** | Infinite / paged list shell with load-more threshold and footer states. |
| **Public API** | `PlusPagedList` |
| **Main functionality** | Apps own data + flags; widget triggers `onLoadMore`, shows loading / error / end footers. |
| **Dependencies** | Flutter SDK only |
| **Testing** | `test/src/lists/plus_paged_list_test.dart` |
| **Status** | **Completed** |

### PlusAdaptiveScaffold

| Field | Detail |
| --- | --- |
| **Purpose** | Adaptive navigation shell (nav bar ↔ rail) without replacing `ScaffoldPlus`. |
| **Public API** | `PlusAdaptiveScaffold`, `PlusNavigationDestination` |
| **Main functionality** | Breakpoint-driven chrome; destinations API; body stays orthogonal to async/connectivity. |
| **Dependencies** | Flutter SDK only |
| **Testing** | `test/src/scaffold/plus_adaptive_scaffold_test.dart` |
| **Status** | **Completed** |

---

## v0.5.0 — Product gates + polish

### PlusMaintenanceMode

| Field | Detail |
| --- | --- |
| **Purpose** | Full-page maintenance presentation; opt-in on `ScaffoldPlus`. |
| **Public API** | `PlusMaintenanceMode`; `ScaffoldPlus.maintenanceMode` / `maintenanceBuilder` |
| **Main functionality** | App-owned flag; replaces body and suppresses FAB; priority over async/`body`. |
| **Dependencies** | Flutter SDK only |
| **Testing** | `test/src/states/plus_maintenance_mode_test.dart`, scaffold cases |
| **Status** | **Completed** |

### PlusPermissionState

| Field | Detail |
| --- | --- |
| **Purpose** | Full-page permission denied / request UI; opt-in on `ScaffoldPlus`. |
| **Public API** | `PlusPermissionState`; `ScaffoldPlus.permissionDenied` / `permissionBuilder` |
| **Main functionality** | App-owned status; primary + optional secondary actions; after maintenance in precedence. |
| **Dependencies** | Flutter SDK only (no permission plugin) |
| **Testing** | `test/src/states/plus_permission_state_test.dart`, scaffold cases |
| **Status** | **Completed** |

### PlusSessionExpired

| Field | Detail |
| --- | --- |
| **Purpose** | Full-page session-expired UI; opt-in on `ScaffoldPlus`. |
| **Public API** | `PlusSessionExpired`; `ScaffoldPlus.sessionExpired` / `sessionExpiredBuilder` |
| **Main functionality** | App-owned auth flag; after maintenance, before permission. |
| **Dependencies** | Flutter SDK only |
| **Testing** | `test/src/states/plus_session_expired_test.dart`, scaffold cases |
| **Status** | **Completed** |

### Async pull-to-refresh

| Field | Detail |
| --- | --- |
| **Purpose** | Opt-in refresh on async success / empty without manual wrapping. |
| **Public API** | `ScaffoldPlus.onRefresh` / `onRefreshError`; `PlusAsyncView` equivalents |
| **Main functionality** | Wraps success/empty in `PlusRefreshIndicator` via shared `PlusAsyncBody`. |
| **Dependencies** | Flutter SDK only |
| **Testing** | Scaffold + `PlusAsyncView` refresh cases |
| **Status** | **Completed** |

Also in **0.5.0:** `PlusInternetChecker`, `PlusToastHost`, Pulse Tasks example,
docs site, pub.dev screenshots.

---

## v0.6.0 — material_ui + inline connectivity

### material_ui migration

| Field | Detail |
| --- | --- |
| **Purpose** | Align with Flutter 3.47+ standalone Material package. |
| **Public API** | Same widgets; import `package:material_ui/material_ui.dart` |
| **Main functionality** | All package + example imports migrated; dependency on `material_ui`. |
| **Dependencies** | `material_ui` |
| **Testing** | Full suite green under Flutter 3.47+ |
| **Status** | **Completed** |

### Inline connectivity banner

| Field | Detail |
| --- | --- |
| **Purpose** | Offline banner that does not cover app bar / body controls. |
| **Public API** | `PlusConnectivityBannerLayout` on `PlusConnectivityConfig` |
| **Main functionality** | Default `inline` in body; optional `overlay` Stack; `ScaffoldPlus` injects into body. |
| **Dependencies** | Flutter SDK + `material_ui` |
| **Testing** | Overlay + `ScaffoldPlus` placement tests |
| **Status** | **Completed** |

---

## v1.0.0 — Stable Release

| Field | Detail |
| --- | --- |
| **Purpose** | Declare a stable public API suitable for pub.dev consumers. |
| **Public API** | Freeze `lib/ui_plus.dart` barrel; no intentional removals vs `0.6.0` |
| **Main functionality** | API review, README versioning policy, docs/example sync, a11y/text-scale coverage on state widgets, SDK `>=3.47` + `material_ui`, screenshots/topics, analyze/test green. |
| **Dependencies** | Flutter SDK + `material_ui` only |
| **Testing** | Full suite + example analyze/tests |
| **Status** | **Completed** |

---

## v1.1.0 — Floating window (PiP-style overlay)

### PlusFloatingWindowHost / Controller / Window

| Field | Detail |
| --- | --- |
| **Purpose** | Multi-step attach → navigate → float → resize/dismiss pattern without system PiP APIs. |
| **Public API** | `PlusFloatingWindowHost`, `PlusFloatingWindowHostScope`, `PlusFloatingWindowController`, `PlusFloatingWindow`, `PlusFloatingWindowContentBuilder` |
| **Main functionality** | Root host under `MaterialApp.builder`; page-local window with builder/placeholder; auto-float on route exit when active; drag + corner resize with min/max and screen clamps; expand/dismiss. |
| **Dependencies** | Flutter SDK + `material_ui` |
| **Testing** | `test/src/floating/plus_floating_window_test.dart` |
| **Example / docs** | Pulse Tasks Settings Focus timer; `docs/guides/floating-window.md` |
| **Status** | **Completed** |

---

# In Progress

_None._

---

# Planned

## Deferred responsive utilities

Thin breakpoint builders / gaps only if a concrete value case appears later.
Prefer opinionated shells (`PlusAdaptiveScaffold`) over `LayoutBuilder` renames.

---

## Future — Advanced Application UI

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

# Future Considerations

Candidates only — **not committed** to a milestone. Do not implement without an
explicit value case and approval.

### Discussed UI / UX candidates

| Candidate | Rough purpose |
| --- | --- |
| `PlusFeedback` | Unified success/info/error feedback helper |
| `PlusCountdown` | Timed countdown / resend affordance |
| `PlusDebouncer` | Debounce utility for UI events |
| `PlusThrottler` | Throttle utility for UI events |
| `PlusErrorBoundary` | Widget-tree error catch UI (presentation only) |
| `PlusShowcase` | Feature highlight / coach-mark presentation |

### Other deferred ideas

- Optional reachability helper **as a separate package** (never a core plugin dependency).
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
| Connectivity presentation + optional built-in probe; custom wins | No connectivity plugin; apps can still own reachability |
| Banner default inline in scaffold body | Below app bar; does not cover controls; overlay opt-in |
| Silent first connectivity status | No false “restored” on launch |
| Public import only via `lib/ui_plus.dart` | Stable surface |
| No empty folders for speculative features | Implement when scheduled |
| Keep `ScaffoldPlus` focused | New utilities as independent widgets/helpers |
| Product states: maintenance → session → permission → async/`body`; FAB off | Clear precedence; no accidental actions |
| No permission / connectivity plugins in core | Built-in HTTP/browser probe or app-supplied bools/streams |

---

## Current public export surface

From `lib/ui_plus.dart`:

- Async: `PlusAsyncState`, `PlusLoading`, `PlusSuccess`, `PlusFailure`, typedefs, `PlusAsyncView`
- Connectivity: `PlusConnectivityBanner`, `PlusConnectivityBuilder`, `PlusConnectivityConfig`, `PlusConnectivityBannerPosition`, `PlusConnectivityBannerLayout`, `PlusConnectivityOverlay`, `PlusConnectivityBannerBuilder`, `PlusOfflineState`, `PlusInternetChecker`, `PlusInternetCheckerConfig`
- Actions: `PlusAsyncButton`, `PlusAsyncButtonVariant`
- Dialogs: `PlusDialog`, `PlusConfirmationDialog`
- Feedback: `PlusSnackbar`, `PlusSnackbarTone`
- Floating: `PlusFloatingWindowHost`, `PlusFloatingWindowHostScope`,
  `PlusFloatingWindowController`, `PlusFloatingWindow`,
  `PlusFloatingWindowContentBuilder`
- Inputs: `PlusSearchField`
- Lists: `PlusPagedList`
- Loaders: `PlusLoader`, `PlusSkeleton`
- Refresh: `PlusRefreshIndicator`
- Scaffold: `ScaffoldPlus`, `PlusAdaptiveScaffold`, `PlusNavigationDestination`
- Sheets: `PlusBottomSheet`
- States: `PlusEmptyState`, `PlusErrorState`, `PlusMaintenanceMode`,
  `PlusPermissionState`, `PlusSessionExpired`
- Theme: `PlusTheme`

---

## Recommended implementation order (next)

1. Publish / tag `1.1.1` on pub.dev when approved.
2. Confirm GitHub Pages docs include the floating-window guide.
3. Further minors: Advanced UI / companion packages only with a written
   uniqueness value case (see Planned / Future Considerations).

---

## Working agreements

- One component (or tightly related pair) per task: API → impl → tests → example → docs → format/analyze/test.
- Do not implement speculative features outside the active milestone.
- Prefer Flutter SDK; justify any new dependency before adding it.
- Update this `plan.md` when milestone status changes.
- The `example/` app is **Pulse Tasks** (Bloc showcase), not a widget catalog.
  Example-only deps (`flutter_bloc`, `equatable`) must never enter core
  `ui_plus`.

**Related docs:** [README](README.md) · [CHANGELOG](CHANGELOG.md) · [Docs site](https://lidhincs.github.io/ui_plus/) · [Pulse Tasks walkthrough](https://lidhincs.github.io/ui_plus/example/pulse-tasks/) · [example/README.md](example/README.md) · [doc/roadmap.md](doc/roadmap.md) · [doc/async_view_design.md](doc/async_view_design.md) · [doc/connectivity.md](doc/connectivity.md) · [`.cursor/rules/ui-plus.mdc`](.cursor/rules/ui-plus.mdc)
