import 'package:flutter/material.dart';

@immutable
class NavItem {
  final IconData icon;
  const NavItem({required this.icon});
}

class FancyStudentNavBar extends StatefulWidget {
  final List<NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onChanged;

  /// Compact bar height
  final double height;

  /// Theme
  final Color barColor;
  final Color activeColor;
  final Color iconColor;

  const FancyStudentNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onChanged,
    this.height = 64, // slimmer bar
    this.barColor = const Color(0xFF161616),
    this.activeColor = const Color(0xFF2B50FF),
    this.iconColor = Colors.white,
  }) : assert(items.length >= 2);

  @override
  State<FancyStudentNavBar> createState() => _FancyStudentNavBarState();
}

class _FancyStudentNavBarState extends State<FancyStudentNavBar>
    with SingleTickerProviderStateMixin {
  // ------- Layout tokens -------
  static const double _outerPad = 16.0;
  static const double _barRadius = 22.0;

  // Bubble + icon (bigger)
  static const double _haloSize = 66.0;
  static const double _bubbleSize = 56.0;
  static const double _iconActiveSize = 26.0;
  static const double _iconBaseSize = 24.0;

  // How far the bubble rises above the bar top
  static const double _bubbleOverlap = 40.0; // was 30.0

  // Scoop geometry (deeper dip)
  static const double _scoopWidth = 86.0;
  static const double _scoopDepth = 34.0; // was 22.0
  static const double _kArc = 0.55;
  late final AnimationController _ctrl;
  late final Animation<double> _t;
  int _from = 0;

  @override
  void initState() {
    super.initState();
    _from = widget.currentIndex;
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _t = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
  }

  @override
  void didUpdateWidget(covariant FancyStudentNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      _from = oldWidget.currentIndex;
      _ctrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;

    return SafeArea(
      minimum: const EdgeInsets.only(bottom: 8),
      child: LayoutBuilder(
        builder: (context, c) {
          final totalW = c.maxWidth;
          final innerW = totalW - _outerPad * 2;
          final h = widget.height;
          final slot = innerW / items.length;

          double centerXOf(int i) => slot * i + slot / 2;

          return SizedBox(
            height: h + (_haloSize - _bubbleOverlap) + 6,
            child: AnimatedBuilder(
              animation: _t,
              builder: (_, __) {
                final cx = Tween<double>(
                  begin: centerXOf(_from),
                  end: centerXOf(widget.currentIndex),
                ).transform(_t.value);

                return Stack(
                  alignment: Alignment.bottomCenter,
                  clipBehavior: Clip.none,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: _outerPad,
                      ),
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        clipBehavior: Clip.none,
                        children: [
                          // ---- Bar ----
                          Container(
                            height: h,
                            decoration: BoxDecoration(
                              color: widget.barColor,
                              borderRadius: BorderRadius.circular(_barRadius),
                            ),
                            child: CustomPaint(
                              painter: _ScoopPainter(
                                scoopCenterX: cx,
                                height: h,
                                radius: _barRadius,
                                width: _scoopWidth,
                                depth: _scoopDepth,
                                kArc: _kArc,
                              ),
                              child: Row(
                                children: List.generate(items.length, (i) {
                                  final active = (i == widget.currentIndex);
                                  return Expanded(
                                    child: InkResponse(
                                      onTap: () => widget.onChanged(i),
                                      radius: 28,
                                      highlightShape: BoxShape.circle,
                                      child: AnimatedOpacity(
                                        opacity: active
                                            ? 0.0
                                            : 1.0, // hide under bubble
                                        duration: const Duration(
                                          milliseconds: 150,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          child: Icon(
                                            items[i].icon,
                                            color: widget.iconColor.withOpacity(
                                              0.78,
                                            ),
                                            size: _iconBaseSize,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),

                          // ---- Bubble ----
                          Positioned(
                            bottom: h - _bubbleOverlap,
                            left: cx - (_haloSize / 2),
                            child: _Bubble(
                              icon: items[widget.currentIndex].icon,
                              color: widget.activeColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _Bubble({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Container(
          width: _FancyStudentNavBarState._haloSize,
          height: _FancyStudentNavBarState._haloSize,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: _FancyStudentNavBarState._bubbleSize,
          height: _FancyStudentNavBarState._bubbleSize,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.35),
                blurRadius: 16,
                spreadRadius: 2,
                offset: const Offset(0, 6),
              ),
            ],
          ),
        ),
        Center(
          child: Icon(
            icon,
            color: Colors.white,
            size: _FancyStudentNavBarState._iconActiveSize,
          ),
        ),
      ],
    );
  }
}

/// White scoop rendered as a near-perfect circular arc (smooth shoulders).
class _ScoopPainter extends CustomPainter {
  final double scoopCenterX; // inner coords
  final double height;
  final double radius;

  final double width; // opening width
  final double depth; // sagitta
  final double kArc; // 0.55 ≈ circular

  const _ScoopPainter({
    required this.scoopCenterX,
    required this.height,
    required this.radius,
    required this.width,
    required this.depth,
    required this.kArc,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Clip to the rounded bar
    final clip = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, height),
      Radius.circular(radius),
    );
    canvas.save();
    canvas.clipRRect(clip);

    final cx = scoopCenterX.clamp(0.0, size.width);
    final left = cx - width / 2;
    final right = cx + width / 2;

    // Control points chosen to approximate a perfect circular arc:
    // P0 = (left, 0)  -> P2 = (cx, depth)
    // C1 = P0 + (k*w, 0)
    // C2 = P2 - (k*w, 0)
    // Then mirror to the right.
    final k = kArc; // 0.55 ~ circle
    final dx = width * k;

    final p = Path()
      ..moveTo(left, 0)
      ..cubicTo(
        left + dx,
        0, // C1
        cx - dx,
        depth, // C2
        cx,
        depth, // P2
      )
      ..cubicTo(
        cx + dx,
        depth, // C3
        right - dx,
        0, // C4
        right,
        0, // P3
      )
      ..lineTo(right, -40)
      ..lineTo(left, -40)
      ..close();

    final white = Paint()..color = Colors.white;
    canvas.drawPath(p, white);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ScoopPainter old) =>
      old.scoopCenterX != scoopCenterX ||
      old.height != height ||
      old.radius != radius ||
      old.width != width ||
      old.depth != depth ||
      old.kArc != kArc;
}
