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
| Next | Product-state polish, `PlusToastHost`, docs + Pulse Tasks example | In source (`Unreleased`) |
| v1.0.0 | API freeze + pub.dev readiness | Planned |

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
