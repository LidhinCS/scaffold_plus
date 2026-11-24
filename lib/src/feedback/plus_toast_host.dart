import 'package:material_ui/material_ui.dart';

/// Registers the nearest [ScaffoldMessenger] so snackbars can show
/// without a [BuildContext] (toastification-style).
///
/// Prefer wiring it through [MaterialApp.builder] so the host sits under the
/// app [Theme] and the root messenger:
///
/// ```dart
/// MaterialApp(
///   scaffoldMessengerKey: PlusToastHost.messengerKey, // optional
///   builder: (context, child) => PlusToastHost(child: child!),
///   home: const HomePage(),
/// )
/// ```
///
/// Context-free usage:
///
/// ```dart
/// PlusSnackbar.success(message: 'Saved');
/// ```
///
/// Contextual calls keep working without this host:
/// `PlusSnackbar.success(context: context, message: '…')`.
class PlusToastHost extends StatefulWidget {
  /// Creates a toast host that binds the ambient [ScaffoldMessenger].
  const new({required this.child, super.key});

  /// Shared key you may pass to [MaterialApp.scaffoldMessengerKey].
  ///
  /// When set on [MaterialApp], context-free snackbars also resolve through
  /// this key even if [PlusToastHost] is not in the tree.
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  /// Subtree that should receive snackbars (typically `builder`'s child).
  final Widget child;

  /// Whether a messenger is currently available for context-free calls.
  static bool get isAvailable =>
      PlusToastBinding.messenger != null || messengerKey.currentState != null;

  /// Clears the host binding. For tests only.
  @visibleForTesting
  static void debugReset() => PlusToastBinding.debugReset();

  @override
  State<PlusToastHost> createState() => _PlusToastHostState();
}

class _PlusToastHostState extends State<PlusToastHost> {
  ScaffoldMessengerState? _attached;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final next = ScaffoldMessenger.maybeOf(context);
    if (!identical(_attached, next)) {
      PlusToastBinding.detach(_attached);
      _attached = next;
      PlusToastBinding.attach(next);
    }
  }

  @override
  void dispose() {
    PlusToastBinding.detach(_attached);
    _attached = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Binding between [PlusToastHost] / [PlusToastHost.messengerKey] and
/// snackbar helpers.
abstract final class PlusToastBinding {
  static ScaffoldMessengerState? _messenger;

  /// Currently attached messenger from [PlusToastHost], if any.
  static ScaffoldMessengerState? get messenger {
    final attached = _messenger;
    if (attached != null && attached.mounted) {
      return attached;
    }
    return null;
  }

  /// Attaches [messenger] for context-free snackbars.
  static void attach(ScaffoldMessengerState? messenger) {
    if (messenger == null) {
      return;
    }
    _messenger = messenger;
  }

  /// Clears the binding when [messenger] is the active one.
  static void detach(ScaffoldMessengerState? messenger) {
    if (messenger == null) {
      return;
    }
    if (identical(_messenger, messenger)) {
      _messenger = null;
    }
  }

  /// Test helper to reset global state.
  @visibleForTesting
  static void debugReset() {
    _messenger = null;
  }

  /// Resolves a messenger for context-free or contextual snackbars.
  static ScaffoldMessengerState resolve([BuildContext? context]) {
    if (context != null) {
      return ScaffoldMessenger.of(context);
    }

    final attached = messenger;
    if (attached != null) {
      return attached;
    }

    final fromKey = PlusToastHost.messengerKey.currentState;
    if (fromKey != null) {
      return fromKey;
    }

    throw FlutterError.fromParts(<DiagnosticsNode>[
      ErrorSummary('PlusSnackbar was called without a BuildContext.'),
      ErrorDescription(
        'No PlusToastHost messenger is available. Either pass a BuildContext, '
        'wrap your app with PlusToastHost via MaterialApp.builder, or set '
        'MaterialApp.scaffoldMessengerKey to PlusToastHost.messengerKey.',
      ),
    ]);
  }
}
