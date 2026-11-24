import 'package:material_ui/material_ui.dart';
import 'package:ui_plus/src/theme/plus_theme.dart';

/// Modal bottom-sheet helpers with consistent chrome.
///
/// Adds optional title, padding, and safe-area defaults on top of
/// [showModalBottomSheet] without forcing a rigid layout for every use case.
///
/// {@tool snippet}
/// ```dart
/// await PlusBottomSheet.show(
///   context,
///   title: 'Share',
///   builder: (context) => ListTile(
///     title: const Text('Copy link'),
///     onTap: () => Navigator.pop(context),
///   ),
/// );
/// ```
/// {@end-tool}
abstract final class PlusBottomSheet {
  /// Shows a modal bottom sheet.
  ///
  /// When [title] is non-null, a padded title row is placed above [builder]
  /// content. [showDragHandle] defaults to true (Material 3).
  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    String? title,
    TextStyle? titleTextStyle,
    bool showDragHandle = true,
    bool isScrollControlled = false,
    bool useSafeArea = true,
    bool isDismissible = true,
    bool enableDrag = true,
    Color? backgroundColor,
    Color? barrierColor,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
    BoxConstraints? constraints,
    AnimationController? transitionAnimationController,
    Offset? anchorPoint,
    bool useRootNavigator = false,
    EdgeInsetsGeometry? contentPadding,
  }) {
    final resolvedPadding =
        contentPadding ?? PlusTheme.of(context).bottomSheetContentPadding;

    return showModalBottomSheet<T>(
      context: context,
      showDragHandle: showDragHandle,
      isScrollControlled: isScrollControlled,
      useSafeArea: useSafeArea,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: backgroundColor,
      barrierColor: barrierColor,
      elevation: elevation,
      shape: shape,
      clipBehavior: clipBehavior,
      constraints: constraints,
      transitionAnimationController: transitionAnimationController,
      anchorPoint: anchorPoint,
      useRootNavigator: useRootNavigator,
      builder: (sheetContext) {
        return _PlusBottomSheetChrome(
          title: title,
          titleTextStyle: titleTextStyle,
          contentPadding: resolvedPadding,
          child: builder(sheetContext),
        );
      },
    );
  }

  /// Shows a scroll-controlled sheet sized as a fraction of the screen height.
  ///
  /// Useful for forms or long lists. [heightFactor] defaults to `0.7`.
  static Future<T?> showScrollable<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    String? title,
    TextStyle? titleTextStyle,
    double heightFactor = 0.7,
    bool showDragHandle = true,
    bool useSafeArea = true,
    bool isDismissible = true,
    bool enableDrag = true,
    Color? backgroundColor,
    Color? barrierColor,
    bool useRootNavigator = false,
    EdgeInsetsGeometry? contentPadding,
  }) {
    assert(
      heightFactor > 0 && heightFactor <= 1,
      'heightFactor must be in the range (0, 1].',
    );

    final resolvedPadding =
        contentPadding ?? PlusTheme.of(context).bottomSheetContentPadding;

    return showModalBottomSheet<T>(
      context: context,
      showDragHandle: showDragHandle,
      isScrollControlled: true,
      useSafeArea: useSafeArea,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: backgroundColor,
      barrierColor: barrierColor,
      useRootNavigator: useRootNavigator,
      builder: (sheetContext) {
        final height = MediaQuery.sizeOf(sheetContext).height * heightFactor;
        return SizedBox(
          height: height,
          child: _PlusBottomSheetChrome(
            title: title,
            titleTextStyle: titleTextStyle,
            contentPadding: resolvedPadding,
            expandChild: true,
            child: builder(sheetContext),
          ),
        );
      },
    );
  }
}

class _PlusBottomSheetChrome extends StatelessWidget {
  const new({
    required this.child,
    required this.contentPadding,
    this.title,
    this.titleTextStyle,
    this.expandChild = false,
  });

  final Widget child;
  final String? title;
  final TextStyle? titleTextStyle;
  final EdgeInsetsGeometry contentPadding;
  final bool expandChild;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleWidget = title == null
        ? null
        : Text(
            title!,
            style:
                titleTextStyle ??
                theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
          );

    final body = expandChild ? Expanded(child: child) : child;

    return Padding(
      padding: contentPadding,
      child: Column(
        mainAxisSize: expandChild ? MainAxisSize.max : MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (titleWidget != null) ...[titleWidget, const SizedBox(height: 12)],
          body,
        ],
      ),
    );
  }
}
