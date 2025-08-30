import 'package:flutter/material.dart';

class GlobalAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GlobalAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBack = false,
    this.onBack,
    this.onNotificationsTap,
    this.onProfileTap,
    this.sidePadding,
    this.titleSize,
    this.subtitleSize,
    this.iconSize,
    this.showNotifications = true,
    this.showProfile = true,
    this.centerTitle = false,
  });

  final String title;
  final String? subtitle; // 🔹 New optional subtitle
  final bool showBack;
  final VoidCallback? onBack;
  final VoidCallback? onNotificationsTap;
  final VoidCallback? onProfileTap;

  final double? sidePadding;
  final double? titleSize;
  final double? subtitleSize; // 🔹 control subtitle font size
  final double? iconSize;

  final bool showNotifications;
  final bool showProfile;
  final bool centerTitle; // ✅

  static const double _overlapPx = 6.0;

  double _clampNum(double v, double min, double max) =>
      v < min ? min : (v > max ? max : v);

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final w = mq.size.width;

    final double sp = sidePadding ?? _clampNum(w * 0.05, 16, 24);
    final double tSize = titleSize ?? _clampNum(w * 0.065, 20, 28);
    final double iSize = iconSize ?? _clampNum(w * 0.060, 20, 26);
    final double iconPad = _clampNum(w * 0.01, 6, 10);

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: centerTitle,
      titleSpacing: sp,
      automaticallyImplyLeading: false,
      iconTheme: const IconThemeData(color: Colors.black),
      leadingWidth: showBack ? (sp + 44) : 0,
      leading: showBack
          ? Padding(
              padding: EdgeInsets.only(left: sp),
              child: IconButton(
                splashRadius: 24,
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.black,
                ),
                onPressed: onBack ?? () => Navigator.maybePop(context),
              ),
            )
          : null,
      title: Text(
        title,
        style: TextStyle(
          fontSize: tSize,
          fontWeight: FontWeight.w800,
          color: Colors.black,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: centerTitle ? TextAlign.center : TextAlign.left,
      ),
      actions: (showNotifications || showProfile)
          ? [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: sp),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showNotifications)
                      InkWell(
                        onTap: onNotificationsTap,
                        borderRadius: BorderRadius.circular(12),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            minWidth: 44,
                            minHeight: 44,
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(iconPad),
                            child: Image.asset(
                              'assets/images/student-home/ci_bell-notification.png',
                              width: iSize,
                              height: iSize,
                            ),
                          ),
                        ),
                      ),
                    if (showProfile)
                      Transform.translate(
                        offset: const Offset(-_overlapPx, 0),
                        child: InkWell(
                          onTap: onProfileTap,
                          borderRadius: BorderRadius.circular(12),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              minWidth: 44,
                              minHeight: 44,
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(iconPad),
                              child: Image.asset(
                                'assets/images/student-home/profile-icon.png',
                                width: iSize,
                                height: iSize,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ]
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
