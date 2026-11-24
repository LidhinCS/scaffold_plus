import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:ui_plus/src/theme/plus_theme.dart';

/// A Material 3 search field with optional debounce and clear action.
///
/// Does not perform search itself — emit queries through [onChanged] /
/// [onSubmitted] and handle filtering in the app layer.
///
/// {@tool snippet}
/// ```dart
/// PlusSearchField(
///   hintText: 'Search items',
///   debounceDuration: const Duration(milliseconds: 300),
///   onChanged: (query) => filterItems(query),
/// )
/// ```
/// {@end-tool}
class PlusSearchField extends StatefulWidget {
  /// Creates a search text field.
  ///
  /// When the resolved debounce duration is greater than zero, [onChanged] is
  /// invoked after the user stops typing for that duration. [onSubmitted] is
  /// never debounced.
  ///
  /// When [debounceDuration] is null, [PlusTheme.searchDebounceDuration] is
  /// used (defaults to [Duration.zero]).
  const new({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText = 'Search',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.debounceDuration,
    this.enabled = true,
    this.autofocus = false,
    this.readOnly = false,
    this.textInputAction = TextInputAction.search,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.style,
    this.hintStyle,
    this.fillColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 12,
    ),
    this.prefixIcon = Icons.search,
    this.clearIcon = Icons.close,
    this.clearButtonSemanticLabel = 'Clear search',
    this.decoration,
  });

  /// Optional external controller. When null, an internal controller is used.
  final TextEditingController? controller;

  /// Optional focus node.
  final FocusNode? focusNode;

  /// Placeholder text when empty.
  final String hintText;

  /// Called when the query changes (optionally debounced).
  final ValueChanged<String>? onChanged;

  /// Called when the user submits the field.
  final ValueChanged<String>? onSubmitted;

  /// Called after the clear button clears the field.
  final VoidCallback? onClear;

  /// Debounce window for [onChanged].
  ///
  /// Null uses [PlusTheme.searchDebounceDuration].
  final Duration? debounceDuration;

  /// Whether the field accepts input.
  final bool enabled;

  /// Whether to focus on first build.
  final bool autofocus;

  /// Whether the field is read-only.
  final bool readOnly;

  /// Keyboard action button.
  final TextInputAction textInputAction;

  /// Keyboard type.
  final TextInputType keyboardType;

  /// Text capitalization behavior.
  final TextCapitalization textCapitalization;

  /// Input text style.
  final TextStyle? style;

  /// Hint text style.
  final TextStyle? hintStyle;

  /// Fill color for the default decoration.
  final Color? fillColor;

  /// Corner radius for the default outline.
  final BorderRadius borderRadius;

  /// Content padding for the default decoration.
  final EdgeInsetsGeometry contentPadding;

  /// Leading icon. Pass `null` to hide.
  final IconData? prefixIcon;

  /// Clear icon shown when the field is non-empty.
  final IconData clearIcon;

  /// Semantics label for the clear button.
  final String clearButtonSemanticLabel;

  /// Fully custom [InputDecoration]. When non-null, replaces the default
  /// decoration (including prefix/clear icons unless you add them yourself).
  final InputDecoration? decoration;

  @override
  State<PlusSearchField> createState() => _PlusSearchFieldState();
}

class _PlusSearchFieldState extends State<PlusSearchField> {
  TextEditingController? _ownedController;
  Timer? _debounce;

  TextEditingController get _controller =>
      widget.controller ?? _ownedController!;

  bool get _hasText => _controller.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _ownedController = TextEditingController();
    }
    _controller.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(covariant PlusSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_handleControllerChanged);
      if (oldWidget.controller == null) {
        _ownedController
          ?..removeListener(_handleControllerChanged)
          ..dispose();
        _ownedController = null;
      }
      if (widget.controller == null) {
        _ownedController = TextEditingController(
          text: oldWidget.controller?.text,
        );
      }
      _controller.addListener(_handleControllerChanged);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.removeListener(_handleControllerChanged);
    _ownedController?.dispose();
    super.dispose();
  }

  void _handleControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Duration _resolvedDebounce(BuildContext context) {
    return widget.debounceDuration ??
        PlusTheme.of(context).searchDebounceDuration;
  }

  void _emitChanged(String value) {
    final onChanged = widget.onChanged;
    if (onChanged == null) {
      return;
    }

    _debounce?.cancel();
    final debounce = _resolvedDebounce(context);
    if (debounce <= Duration.zero) {
      onChanged(value);
      return;
    }

    _debounce = Timer(debounce, () {
      onChanged(value);
    });
  }

  void _clear() {
    _debounce?.cancel();
    _controller.clear();
    widget.onChanged?.call('');
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final defaultDecoration = InputDecoration(
      hintText: widget.hintText,
      hintStyle:
          widget.hintStyle ??
          theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
      filled: true,
      fillColor: widget.fillColor ?? colorScheme.surfaceContainerHighest,
      contentPadding: widget.contentPadding,
      prefixIcon: widget.prefixIcon == null ? null : Icon(widget.prefixIcon),
      suffixIcon: _hasText
          ? IconButton(
              tooltip: widget.clearButtonSemanticLabel,
              onPressed: widget.enabled ? _clear : null,
              icon: Icon(widget.clearIcon),
            )
          : null,
      border: OutlineInputBorder(
        borderRadius: widget.borderRadius,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: widget.borderRadius,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: widget.borderRadius,
        borderSide: BorderSide(color: colorScheme.primary),
      ),
    );

    return TextField(
      controller: _controller,
      focusNode: widget.focusNode,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      readOnly: widget.readOnly,
      textInputAction: widget.textInputAction,
      keyboardType: widget.keyboardType,
      textCapitalization: widget.textCapitalization,
      style: widget.style,
      onChanged: _emitChanged,
      onSubmitted: widget.onSubmitted,
      decoration: widget.decoration ?? defaultDecoration,
    );
  }
}
