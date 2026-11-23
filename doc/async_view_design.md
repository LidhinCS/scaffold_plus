# PlusAsyncView / ScaffoldPlus state model

## Decision

Use a **public sealed** `PlusAsyncState<T>` (`PlusLoading`, `PlusSuccess`,
`PlusFailure`) as the only async input. Do **not** ship a parallel
boolean/`data`/`error` API.

Empty content is **not** a sealed variant. Callers supply
`isEmpty: (data) => ...` so emptiness stays domain-specific.

## Shared renderer

`PlusAsyncView` and `ScaffoldPlus` both delegate to an internal
`PlusAsyncBody` (not exported). State-handling logic is not duplicated.

`PlusAsyncView` does **not** depend on `ScaffoldPlus`.
`ScaffoldPlus` composes Flutter's native `Scaffold` and optionally hosts
`PlusAsyncBody` as its body.

## Trade-offs

| Approach | Pros | Cons |
| --- | --- | --- |
| Booleans (`isLoading`, `data`, `error`) | Familiar; easy ad-hoc wiring | Ambiguous combos (`isLoading` + `error`); callers invent precedence |
| Sealed state (chosen) | Exhaustive; one active branch; maps cleanly from Bloc/Riverpod/etc. | Callers map library-specific states once |
| Dual APIs | Convenience for both styles | Two sources of truth; higher maintenance |

## Precedence

Exact match order inside `PlusAsyncBody`:

1. **`PlusLoading`**
   - `loadingBuilder` if provided
   - else if `useSkeleton` → `skeletonBuilder` or default `PlusSkeleton` layout
   - else centered `PlusLoader`
2. **`PlusFailure`** → `errorBuilder` (default: `PlusErrorState` + optional `onRetry`)
3. **`PlusSuccess`**
   - If `isEmpty?.(data) == true` → `emptyBuilder` (default: `PlusEmptyState`)
   - Else → success builder

Loading never competes with failure or success. Empty only applies to success
data.

## ScaffoldPlus body rules

- `state == null` → render Flutter-style `body`
- `state != null` → async rendering wins; `body` is ignored (no assert/throw)

## Architecture notes

- Core stays architecture-agnostic: no Bloc/Riverpod imports.
- Apps map their async types into `PlusAsyncState` at the UI boundary.
- Optional companion packages may add helpers later; not required for v0.1.
