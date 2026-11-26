import 'package:material_ui/material_ui.dart';
import 'package:ui_plus/ui_plus.dart';
import 'package:ui_plus_example/features/components/component_entries.dart';

/// Pushed route that hosts a single component demo.
class ComponentDemoPage extends StatelessWidget {
  /// Creates a demo page for [entry].
  const new({required this.entry, super.key});

  /// Catalog entry to present.
  final ComponentEntry entry;

  @override
  Widget build(BuildContext context) {
    return ScaffoldPlus<void>(
      appBar: AppBar(title: Text(entry.name)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Text(entry.ability, style: Theme.of(context).textTheme.titleMedium),
          if (entry.details != null) ...[
            const SizedBox(height: 8),
            Text(
              entry.details!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 20),
          entry.demoBuilder(context),
        ],
      ),
    );
  }
}
