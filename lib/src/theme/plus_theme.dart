import 'package:flutter/material.dart';

/// Shared defaults for UI Plus components.
///
/// Register via [ThemeData.extensions]:
///
/// ```dart
/// ThemeData(
///   extensions: const [
///     PlusTheme(
///       snackbarDuration: Duration(seconds: 3),
///       searchDebounceDuration: Duration(milliseconds: 300),
///     ),
///   ],
/// )
/// ```
///
/// Read with [PlusTheme.of]. Missing values fall back to built-in defaults.
@immutable
class PlusTheme extends ThemeExtension<PlusTheme> {
  /// Creates shared UI Plus theme values.
  const new({
    this.snackbarDuration = const Duration(seconds: 4),
    this.searchDebounceDuration = Duration.zero,
    this.statePadding = const EdgeInsets.all(24),
    this.bottomSheetContentPadding = const EdgeInsets.fromLTRB(16, 0, 16, 16),
  });

  /// Default duration for `PlusSnackbar` when callers omit duration.
  final Duration snackbarDuration;

  /// Default debounce for `PlusSearchField` when callers omit debounce.
  final Duration searchDebounceDuration;

  /// Default padding for empty / error / offline state layouts.
  final EdgeInsetsGeometry statePadding;

  /// Default content padding for `PlusBottomSheet` chrome.
  final EdgeInsetsGeometry bottomSheetContentPadding;

  /// Built-in defaults used when no [PlusTheme] is registered.
  static const PlusTheme defaults = PlusTheme();

  /// Returns the ambient [PlusTheme], or [defaults] when unset.
  static PlusTheme of(BuildContext context) {
    return Theme.of(context).extension<PlusTheme>() ?? defaults;
  }

  @override
  PlusTheme copyWith({
    Duration? snackbarDuration,
    Duration? searchDebounceDuration,
    EdgeInsetsGeometry? statePadding,
    EdgeInsetsGeometry? bottomSheetContentPadding,
  }) {
    return PlusTheme(
      snackbarDuration: snackbarDuration ?? this.snackbarDuration,
      searchDebounceDuration:
          searchDebounceDuration ?? this.searchDebounceDuration,
      statePadding: statePadding ?? this.statePadding,
      bottomSheetContentPadding:
          bottomSheetContentPadding ?? this.bottomSheetContentPadding,
    );
  }

  @override
  PlusTheme lerp(ThemeExtension<PlusTheme>? other, double t) {
    if (other is! PlusTheme) {
      return this;
    }
    return PlusTheme(
      snackbarDuration: t < 0.5 ? snackbarDuration : other.snackbarDuration,
      searchDebounceDuration: t < 0.5
          ? searchDebounceDuration
          : other.searchDebounceDuration,
      statePadding: EdgeInsetsGeometry.lerp(
        statePadding,
        other.statePadding,
        t,
      )!,
      bottomSheetContentPadding: EdgeInsetsGeometry.lerp(
        bottomSheetContentPadding,
        other.bottomSheetContentPadding,
        t,
      )!,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PlusTheme &&
            runtimeType == other.runtimeType &&
            snackbarDuration == other.snackbarDuration &&
            searchDebounceDuration == other.searchDebounceDuration &&
            statePadding == other.statePadding &&
            bottomSheetContentPadding == other.bottomSheetContentPadding;
  }

  @override
  int get hashCode => Object.hash(
    snackbarDuration,
    searchDebounceDuration,
    statePadding,
    bottomSheetContentPadding,
  );
}
