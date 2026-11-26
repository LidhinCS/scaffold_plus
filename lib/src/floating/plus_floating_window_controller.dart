import 'package:material_ui/material_ui.dart';

/// Builds floating-window content.
///
/// [floating] is `true` when the content is shown in the overlay chrome.
typedef PlusFloatingWindowContentBuilder = Widget Function(
  BuildContext context, {
  required bool floating,
});

/// Controls activation, floating state, size, and offset for a floating window.
///
/// Prefer calling [activate] before navigating away so the host can keep the
/// session alive after the owning route is disposed.
class PlusFloatingWindowController extends ChangeNotifier {
  /// Creates a floating-window controller.
  new({
    Size initialSize = const Size(280, 200),
    Offset initialOffset = const Offset(16, 96),
    this.minSize = const Size(180, 140),
    this.maxSize = const Size(420, 520),
  }) : _size = initialSize,
       _offset = initialOffset;

  /// Minimum floating window size.
  final Size minSize;

  /// Maximum floating window size.
  final Size maxSize;

  PlusFloatingWindowContentBuilder? _builder;
  String? _title;
  var _active = false;
  var _floating = false;
  Size _size;
  Offset _offset;
  VoidCallback? _onDismiss;
  ValueChanged<bool>? _onFloatingChanged;

  /// Whether the session should survive navigation (float when leaving).
  bool get active => _active;

  /// Whether content is currently shown in the host overlay.
  bool get isFloating => _floating;

  /// Optional chrome title.
  String? get title => _title;

  /// Content builder registered with [activate].
  PlusFloatingWindowContentBuilder? get builder => _builder;

  /// Current floating window size.
  Size get size => _size;

  /// Current floating window top-left offset (in host coordinates).
  Offset get offset => _offset;

  /// Callback invoked after [dismiss].
  VoidCallback? get onDismiss => _onDismiss;

  /// Callback invoked when [isFloating] changes.
  ValueChanged<bool>? get onFloatingChanged => _onFloatingChanged;

  /// Starts (or updates) a floating session.
  ///
  /// When [floating] is true, the host shows the overlay immediately.
  void activate({
    required PlusFloatingWindowContentBuilder builder,
    String? title,
    bool floating = false,
    VoidCallback? onDismiss,
    ValueChanged<bool>? onFloatingChanged,
  }) {
    _builder = builder;
    _title = title;
    _onDismiss = onDismiss;
    _onFloatingChanged = onFloatingChanged;
    _active = true;
    _setFloating(floating);
    notifyListeners();
  }

  /// Marks the session inactive and clears floating content.
  void dismiss() {
    if (!_active && !_floating && _builder == null) {
      return;
    }
    _active = false;
    _floating = false;
    _builder = null;
    _title = null;
    final dismiss = _onDismiss;
    _onDismiss = null;
    _onFloatingChanged = null;
    notifyListeners();
    dismiss?.call();
  }

  /// Shows the overlay (PiP) while keeping [active] true.
  void enterFloating() {
    if (!_active || _builder == null) {
      return;
    }
    _setFloating(true);
    notifyListeners();
  }

  /// Hides the overlay and returns content to the owning page when present.
  void expand() {
    if (!_floating) {
      return;
    }
    _setFloating(false);
    notifyListeners();
  }

  /// Updates floating offset (clamping is applied by the host).
  void updateOffset(Offset offset) {
    if (_offset == offset) {
      return;
    }
    _offset = offset;
    notifyListeners();
  }

  /// Updates floating size, clamped to [minSize] / [maxSize].
  void updateSize(Size size) {
    final clamped = Size(
      size.width.clamp(minSize.width, maxSize.width),
      size.height.clamp(minSize.height, maxSize.height),
    );
    if (_size == clamped) {
      return;
    }
    _size = clamped;
    notifyListeners();
  }

  void _setFloating(bool value) {
    if (_floating == value) {
      return;
    }
    _floating = value;
    _onFloatingChanged?.call(value);
  }
}
