import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:ui_plus/ui_plus.dart';
import 'package:ui_plus_example/features/components/component_demo_page.dart';
import 'package:ui_plus_example/features/components/component_entries.dart';

/// Hub that lists individual `ui_plus` components and opens live demos.
class ComponentsPage extends StatelessWidget {
  /// Creates the components hub.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldPlus<void>(
      appBar: AppBar(
        title: const Text('Components'),
        actions: [
          IconButton(
            tooltip: 'About',
            onPressed: () {
              unawaited(
                PlusDialog.alert(
                  context,
                  title: 'Component gallery',
                  message:
                      'Each entry opens a live demo of a public ui_plus '
                      'widget and notes what it is good for. The Tasks / '
                      'Activity tabs show the same APIs composed in a real '
                      'flow.',
                  primaryLabel: 'Got it',
                ),
              );
            },
            icon: const Icon(Icons.info_outline_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Browse widgets one at a time — tap an entry to try its '
              'capabilities.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          for (final group in componentCatalog) ...[
            _GroupHeader(group.title),
            for (final entry in group.entries)
              ListTile(
                leading: Icon(entry.icon),
                title: Text(entry.name),
                subtitle: Text(entry.ability),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ComponentDemoPage(entry: entry),
                    ),
                  );
                },
              ),
          ],
        ],
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const new(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall
            ?.copyWith(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}
