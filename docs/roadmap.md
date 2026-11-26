# Roadmap

Authoritative source: [`plan.md`](https://github.com/LidhinCS/ui_plus/blob/main/plan.md)
in the repository.

## Milestones

| Version | Theme | Status |
| --- | --- | --- |
| v0.1.0 | Core Foundation | Released |
| v0.2.0 | Connectivity | Released |
| v0.3.0 | Everyday Productivity | Released |
| v0.4.0 | Unique application patterns | Released |
| v0.5.0 | Product gates + polish | Released |
| v0.6.0 | material_ui + inline connectivity banner | Released |
| v1.0.0 | API freeze + pub.dev readiness | Released |
| v1.1.0 | Floating window (PiP-style overlay) | Released |
| v1.1.1 | Preview screenshots (toast, float, dialog, session) | Released |

## Uniqueness bar

Prefer APIs that encode a multi-step app pattern (async lifecycle, paging,
adaptive navigation, product gates) over thin wrappers around a single Material
widget.

## Example policy

The `example/` app is **Pulse Tasks** (Bloc showcase), not a widget catalog.
Example-only dependencies (`flutter_bloc`, `equatable`) never enter core
`ui_plus`.

## See also

- [Pulse Tasks](example/pulse-tasks.md)
- [CHANGELOG](https://github.com/LidhinCS/ui_plus/blob/main/CHANGELOG.md)
