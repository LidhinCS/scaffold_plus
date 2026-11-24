import 'package:material_ui/material_ui.dart';

/// Visual style for [PlusAsyncButton].
enum PlusAsyncButtonVariant {
  /// [FilledButton].
  filled,

  /// [FilledButton.tonal].
  tonal,

  /// [OutlinedButton].
  outlined,

  /// [TextButton].
  text,

  /// [ElevatedButton].
  elevated,
}

/// A Material button that owns in-flight async action UX.
///
/// Unlike a plain `onPressed` callback, [onPressed] returns a [Future]. While
/// that future is pending the button shows a loading indicator, stays disabled
/// (preventing double-submit), then optionally flashes a success child before
/// returning to idle. Errors are forwarded to [onError] when provided;
/// otherwise they are rethrown.
///
/// {@tool snippet}
/// ```dart
/// PlusAsyncButton(
///   onPressed: () async => await saveDraft(),
///   onError: (error, stack) {
///     PlusSnackbar.error(context: context, message: 'Save failed');
///   },
///   child: const Text('Save'),
/// )
/// ```
/// {@end-tool}
class PlusAsyncButton extends StatefulWidget {
  /// Creates an async-aware button.
  const new({
    required this.onPressed,
    required this.child,
    super.key,
    this.variant = PlusAsyncButtonVariant.filled,
    this.style,
    this.loadingChild,
    this.successChild,
    this.successDuration = const Duration(milliseconds: 900),
    this.onError,
    this.enabled = true,
  });

  /// Invoked on press. The button stays locked until the future completes.
  final Future<void> Function() onPressed;

  /// Idle-state label / content.
  final Widget child;

  /// Material button variant.
  final PlusAsyncButtonVariant variant;

  /// Optional style override passed to the underlying Material button.
  final ButtonStyle? style;

  /// Shown while [onPressed] is in flight. Defaults to a small progress
  /// indicator sized for button content.
  final Widget? loadingChild;

  /// Optional content shown briefly after a successful press.
  final Widget? successChild;

  /// How long to show [successChild] before returning to idle.
  final Duration successDuration;

  /// Called when [onPressed] throws. When null, the error is rethrown.
  final void Function(Object error, StackTrace stackTrace)? onError;

  /// When false, the button is disabled even when idle.
  final bool enabled;

  @override
  State<PlusAsyncButton> createState() => _PlusAsyncButtonState();
}

class _PlusAsyncButtonState extends State<PlusAsyncButton> {
  bool _loading = false;
  bool _showingSuccess = false;

  bool get _busy => _loading || _showingSuccess;

  Future<void> _handlePressed() async {
    if (_busy || !widget.enabled) {
      return;
    }

    setState(() {
      _loading = true;
      _showingSuccess = false;
    });

    try {
      await widget.onPressed();
      if (!mounted) {
        return;
      }

      if (widget.successChild != null) {
        setState(() {
          _loading = false;
          _showingSuccess = true;
        });
        await Future<void>.delayed(widget.successDuration);
        if (!mounted) {
          return;
        }
        setState(() => _showingSuccess = false);
      } else {
        setState(() => _loading = false);
      }
    } catch (error, stackTrace) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _showingSuccess = false;
      });
      final handler = widget.onError;
      if (handler != null) {
        handler(error, stackTrace);
        return;
      }
      rethrow;
    }
  }

  Color _indicatorColor(ColorScheme colorScheme) {
    return switch (widget.variant) {
      PlusAsyncButtonVariant.filled => colorScheme.onPrimary,
      PlusAsyncButtonVariant.tonal => colorScheme.onSecondaryContainer,
      PlusAsyncButtonVariant.elevated => colorScheme.primary,
      PlusAsyncButtonVariant.outlined ||
      PlusAsyncButtonVariant.text => colorScheme.primary,
    };
  }

  Widget _resolveChild(ColorScheme colorScheme) {
    if (_loading) {
      return widget.loadingChild ??
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _indicatorColor(colorScheme),
            ),
          );
    }
    if (_showingSuccess && widget.successChild != null) {
      return widget.successChild!;
    }
    return widget.child;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final onPressed = (!_busy && widget.enabled) ? _handlePressed : null;
    final child = _resolveChild(colorScheme);

    return switch (widget.variant) {
      PlusAsyncButtonVariant.filled => FilledButton(
        onPressed: onPressed,
        style: widget.style,
        child: child,
      ),
      PlusAsyncButtonVariant.tonal => FilledButton.tonal(
        onPressed: onPressed,
        style: widget.style,
        child: child,
      ),
      PlusAsyncButtonVariant.outlined => OutlinedButton(
        onPressed: onPressed,
        style: widget.style,
        child: child,
      ),
      PlusAsyncButtonVariant.text => TextButton(
        onPressed: onPressed,
        style: widget.style,
        child: child,
      ),
      PlusAsyncButtonVariant.elevated => ElevatedButton(
        onPressed: onPressed,
        style: widget.style,
        child: child,
      ),
    };
  }
}
