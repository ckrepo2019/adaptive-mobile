// lib/views/student/home/student_global_layout.dart
import 'package:flutter/material.dart';

class StudentGlobalLayout extends StatelessWidget {
  final bool showBack;
  final Widget child;

  /// Default padding for the page. Pass EdgeInsets.zero to disable.
  final EdgeInsetsGeometry? padding;

  final bool useSafeArea;

  /// Pull-to-refresh handler.
  final Future<void> Function()? onRefresh;

  /// Wrap non-scrollable child in a scroll view when refreshing.
  final bool forceScrollable;

  /// Optional app bar for Scaffold mode.
  final PreferredSizeWidget? appBar;

  /// NEW: When false, do NOT create a Scaffold. Useful inside tab shells.
  final bool useScaffold;

  /// NEW: Optional header rendered above content in non-Scaffold mode.
  final Widget? header;

  /// NEW: Optional bottom widget in non-Scaffold mode (rarely needed).
  final Widget? bottom;
  final bool safeAreaTop;
  final bool safeAreaBottom;
  final Color backgroundColor;

  const StudentGlobalLayout({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    this.useSafeArea = true,
    this.safeAreaTop = true,
    this.safeAreaBottom = true,
    this.showBack = false,
    this.onRefresh,
    this.forceScrollable = false,
    this.appBar,
    this.useScaffold = true,
    this.header,
    this.bottom,
    this.backgroundColor = Colors.white,
  });
  @override
  Widget build(BuildContext context) {
    Widget content = child;

    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    if (onRefresh != null) {
      if (forceScrollable) {
        content = SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: content,
        );
      }
      content = RefreshIndicator(
        onRefresh: onRefresh!,
        displacement: 48,
        edgeOffset: 0,
        color: Theme.of(context).colorScheme.primary,
        child: content,
      );
    }

    // If we're embedding with a header, avoid double top SafeArea by default.
    final bool effectiveTop = useScaffold
        ? safeAreaTop
        : (header != null ? false : safeAreaTop);

    final body = useSafeArea
        ? SafeArea(top: effectiveTop, bottom: safeAreaBottom, child: content)
        : content;

    if (useScaffold) {
    return Scaffold(
      appBar: appBar,
      backgroundColor: backgroundColor,
      body: body,
    );
  }

  return Material(
    color: backgroundColor,
    child: Column(
      children: [
        if (header != null) header!,
        Expanded(child: body),
        if (bottom != null) bottom!,
      ],
    ),
  );

  }
}
