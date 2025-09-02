import 'package:flutter/material.dart';

class TeacherGlobalLayout extends StatelessWidget {
  final bool showBack;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool useSafeArea;
  final Future<void> Function()? onRefresh;
  final bool forceScrollable;
  final PreferredSizeWidget? appBar;
  final bool useScaffold;
  final Widget? header;
  final Widget? bottom;
  final bool safeAreaTop;
  final bool safeAreaBottom;
  final Duration transitionDuration;
  final Curve transitionCurve;
  final bool enableTransitions;

  const TeacherGlobalLayout({
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
    this.transitionDuration = const Duration(milliseconds: 300),
    this.transitionCurve = Curves.easeInOut,
    this.enableTransitions = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = child;

    if (enableTransitions) {
      content = AnimatedSwitcher(
        duration: transitionDuration,
        switchInCurve: transitionCurve,
        switchOutCurve: transitionCurve,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: animation.drive(
                Tween<Offset>(
                  begin: const Offset(0.0, 0.03),
                  end: Offset.zero,
                ).chain(CurveTween(curve: transitionCurve)),
              ),
              child: child,
            ),
          );
        },
        child: content,
      );
    }

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

    final bool effectiveTop = useScaffold
        ? safeAreaTop
        : (header != null ? false : safeAreaTop);

    final body = useSafeArea
        ? SafeArea(top: effectiveTop, bottom: safeAreaBottom, child: content)
        : content;

    Widget finalWidget;

    if (useScaffold) {
      finalWidget = Scaffold(
        appBar: appBar,
        backgroundColor: Colors.white,
        body: body,
      );
    } else {
      finalWidget = Material(
        color: Colors.white,
        child: Column(
          children: [
            if (header != null)
              AnimatedContainer(
                duration: transitionDuration,
                curve: transitionCurve,
                child: header!,
              ),
            Expanded(child: body),
            if (bottom != null)
              AnimatedContainer(
                duration: transitionDuration,
                curve: transitionCurve,
                child: bottom!,
              ),
          ],
        ),
      );
    }

    if (enableTransitions) {
      return AnimatedContainer(
        duration: transitionDuration,
        curve: transitionCurve,
        child: finalWidget,
      );
    }

    return finalWidget;
  }
}

class SmoothPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final Duration duration;
  final Curve curve;

  SmoothPageRoute({
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) => child,
         transitionDuration: duration,
         reverseTransitionDuration: duration,
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           const begin = Offset(1.0, 0.0);
           const end = Offset.zero;
           final tween = Tween(
             begin: begin,
             end: end,
           ).chain(CurveTween(curve: curve));
           final offsetAnimation = animation.drive(tween);

           return SlideTransition(
             position: offsetAnimation,
             child: FadeTransition(opacity: animation, child: child),
           );
         },
       );
}

extension SmoothNavigation on NavigatorState {
  Future<T?> pushSmooth<T extends Object?>(Widget page) {
    return push<T>(SmoothPageRoute(child: page));
  }

  Future<T?> pushReplacementSmooth<T extends Object?, TO extends Object?>(
    Widget page, {
    TO? result,
  }) {
    return pushReplacement<T, TO>(SmoothPageRoute(child: page), result: result);
  }
}

class AnimatedTabContent extends StatefulWidget {
  final Widget child;
  final int currentIndex;

  const AnimatedTabContent({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  @override
  State<AnimatedTabContent> createState() => _AnimatedTabContentState();
}

class _AnimatedTabContentState extends State<AnimatedTabContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.02),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedTabContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(position: _slideAnimation, child: widget.child),
    );
  }
}
