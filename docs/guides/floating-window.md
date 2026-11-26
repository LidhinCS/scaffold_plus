# Floating window (PiP-style)

`PlusFloatingWindow` encodes an attach → navigate → float → resize/dismiss
pattern. Content starts inline on a page; when the user navigates away while
the session is **active**, it detaches into a draggable, resizable overlay
hosted at the app root.

!!! tip "Seen in Pulse Tasks"
    **Settings → Focus timer** — start the timer, switch tabs, then drag /
    resize / dismiss the floating chrome.

## Wire the host once

Place `PlusFloatingWindowHost` in `MaterialApp.builder` (can wrap
`PlusToastHost`):

```dart
MaterialApp(
  scaffoldMessengerKey: PlusToastHost.messengerKey,
  builder: (context, child) => PlusFloatingWindowHost(
    child: PlusToastHost(child: child!),
  ),
  home: const HomePage(),
);
```

## Page-local window

```dart
final controller = PlusFloatingWindowController();

PlusFloatingWindow(
  controller: controller,
  title: 'Focus timer',
  builder: (context, {required floating}) {
    return TimerView(compact: floating);
  },
);
```

| API | Role |
| --- | --- |
| `PlusFloatingWindowController` | `active`, `isFloating`, size/offset, `enterFloating` / `expand` / `dismiss` |
| `builder` | Same content for inline and overlay (`floating` flag) |
| `placeholder` | Optional inline chip while floating (default expand affordance) |
| `autoFloatOnRouteExit` | Default `true` — float when the route is no longer current |

## Behavior notes

- While on the owning route and not floating, `builder` renders inline.
- Leaving the route (or disposing the page) with an active session registers
  chrome + `builder(..., floating: true)` on the host.
- Drag the title bar; resize from the bottom-right handle (clamped to
  `minSize` / `maxSize` and screen bounds).
- **Expand** returns content to the page when that route is visible again.
  If the owning page is gone, dismiss or navigate back first.
- Inactive sessions (`dismiss` / never activated) do **not** float on
  navigation.

System Android/iOS PiP APIs and multi-window snap zones are out of scope for
this widget.
