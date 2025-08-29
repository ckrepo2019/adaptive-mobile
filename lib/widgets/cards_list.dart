import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../../models/items.dart';
import '../../../utils/image_utils.dart';
import '../../../utils/progress_utils.dart';
import '../../../widgets/ui_widgets.dart';
import '../../../utils/palette_utils.dart';

enum CardVariant { assignment, progress }

const String kDefaultSubjectIcon =
    'assets/images/student-home/default-class.png';

class CardsList<T> extends StatelessWidget {
  final String? headerTitle;
  final dynamic headerIcon;
  final String? pillText;
  final String? ctaLabel;
  final VoidCallback? onCta;
  final List<T> items;
  final EdgeInsetsGeometry? padding;
  final double itemSpacing;
  final Widget Function(
    BuildContext context,
    T item,
    int index,
    Set<int> usedAccents,
  )?
  itemBuilder;
  final CardVariant? variant;
  final void Function(AssignmentItem item)? onAssignmentTap;
  final void Function(ClassProgressItem item)? onProgressTap;
  final Widget? emptyPlaceholder;
  final String? emptyText;

  const CardsList({
    super.key,
    this.headerTitle,
    this.headerIcon,
    this.pillText,
    this.ctaLabel,
    this.onCta,
    required this.items,
    this.padding,
    this.itemSpacing = 12,
    this.itemBuilder,
    this.variant,
    this.onAssignmentTap,
    this.onProgressTap,
    this.emptyPlaceholder,
    this.emptyText,
  });

  @override
  Widget build(BuildContext context) {
    final usedAccents = <int>{};

    Widget? iconWidget;
    if (headerIcon is IconData) {
      iconWidget = Icon(
        headerIcon as IconData,
        color: Colors.black87,
        size: 22,
      );
    } else if (headerIcon is String && (headerIcon as String).isNotEmpty) {
      iconWidget = Image.asset(
        headerIcon as String,
        width: 22,
        height: 22,
        fit: BoxFit.contain,
      );
    }

    final headerVisible =
        (headerTitle != null && headerTitle!.trim().isNotEmpty) ||
        iconWidget != null ||
        pillText != null;

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (headerVisible) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (iconWidget != null) ...[
                  iconWidget,
                  const SizedBox(width: 8),
                ],
                if (headerTitle != null && headerTitle!.trim().isNotEmpty)
                  Expanded(
                    child: Text(
                      headerTitle!,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      softWrap: true,
                      overflow: TextOverflow.visible,
                      maxLines: null,
                    ),
                  )
                else
                  const Spacer(),
                if (pillText != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1F4FF),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      pillText!,
                      style: GoogleFonts.poppins(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF3DBBE4),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: itemSpacing),
          ],
          if (items.isEmpty)
            (emptyPlaceholder ??
                Text(
                  emptyText ?? 'No items',
                  style: GoogleFonts.poppins(color: Colors.black45),
                ))
          else
            for (int i = 0; i < items.length; i++) ...[
              _buildRow(context, items[i], i, usedAccents),
              if (i != items.length - 1) SizedBox(height: itemSpacing),
            ],
          if (ctaLabel != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0055FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 8,
                  shadowColor: const Color(0xFF0055FF).withOpacity(0.4),
                ),
                onPressed: onCta,
                child: Text(
                  ctaLabel!,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRow(
    BuildContext context,
    T item,
    int index,
    Set<int> usedAccents,
  ) {
    if (itemBuilder != null) {
      return itemBuilder!(context, item, index, usedAccents);
    }

    switch (variant) {
      case CardVariant.assignment:
        return _AssignmentCard(
          item: item as AssignmentItem,
          onTap: onAssignmentTap,
        );
      case CardVariant.progress:
        return _ClassProgressCard(
          item: item as ClassProgressItem,
          onTap: onProgressTap,
          usedAccents: usedAccents,
        );
      case null:
        return const SizedBox.shrink();
    }
  }
}

class _AssignmentCard extends StatefulWidget {
  final AssignmentItem item;
  final void Function(AssignmentItem item)? onTap;

  const _AssignmentCard({required this.item, this.onTap});

  @override
  State<_AssignmentCard> createState() => _AssignmentCardState();
}

class _AssignmentCardState extends State<_AssignmentCard> {
  static final Map<String, bool> _assetOkCache = {};
  static const String kDefaultFallback =
      'assets/images/default-images/default-classes.jpg';

  Color _accent = Colors.redAccent;
  late String _subjectKey;
  late String _iconPath;

  @override
  void initState() {
    super.initState();
    _subjectKey = _makeSubjectKey(
      widget.item.subjectData,
      widget.item.subjectIcon,
      widget.item.subject,
    );
    _initFromItem();
  }

  @override
  void didUpdateWidget(covariant _AssignmentCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.subject != widget.item.subject ||
        oldWidget.item.subjectIcon != widget.item.subjectIcon) {
      _subjectKey = _makeSubjectKey(
        widget.item.subjectData,
        widget.item.subjectIcon,
        widget.item.subject,
      );
      _initFromItem();
    }
  }

  void _initFromItem() {
    final provided = (widget.item.subjectIcon ?? '').trim();
    _iconPath = provided.isNotEmpty ? provided : kDefaultFallback;

    final cached = SubjectAccentCache.get(_subjectKey);
    if (cached != null) {
      setState(() => _accent = cached);
      return;
    }

    if (!isNetworkPath(_iconPath)) {
      _upgradeIfExists(_iconPath);
    }

    _computeAccentFromImage(_iconPath);
  }

  Future<void> _upgradeIfExists(String path) async {
    final cached = _assetOkCache[path];
    if (cached == true) return;

    if (cached == false) {
      if (mounted) {
        setState(() => _iconPath = kDefaultFallback);
        _computeAccentFromImage(kDefaultFallback);
      }
      return;
    }

    try {
      await rootBundle.load(path);
      _assetOkCache[path] = true;
    } catch (_) {
      _assetOkCache[path] = false;
      if (mounted) {
        setState(() => _iconPath = kDefaultFallback);
        _computeAccentFromImage(kDefaultFallback);
      }
    }
  }

  Future<void> _computeAccentFromImage(String path) async {
    final cached = SubjectAccentCache.get(_subjectKey);
    if (cached != null) {
      if (!mounted) return;
      setState(() => _accent = cached);
      return;
    }

    final palette = await PaletteUtils.paletteFromPath(path, maxColors: 5);
    if (!mounted || palette.isEmpty) return;

    final chosen = palette.first;
    setState(() => _accent = chosen);
    SubjectAccentCache.set(_subjectKey, chosen);
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return InkCardShell(
      leftAccent: _accent,
      onTap: widget.onTap == null ? null : () => widget.onTap!(item),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            maxLines: null,
            overflow: TextOverflow.visible,
          ),
          Text(
            item.subject,
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54),
            softWrap: true,
            overflow: TextOverflow.visible,
            maxLines: null,
          ),
          const SizedBox(height: 25),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  alignment: WrapAlignment.start,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: Colors.black54,
                    ),
                    Text(
                      item.date,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.black54,
                        height: 1.2,
                      ),
                      softWrap: true,
                      overflow: TextOverflow.visible,
                      maxLines: null,
                    ),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.access_time_outlined,
                      size: 14,
                      color: Colors.black54,
                    ),
                    Text(
                      item.duration,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.black54,
                        height: 1.2,
                      ),
                      softWrap: true,
                      overflow: TextOverflow.visible,
                      maxLines: null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ClassProgressCard extends StatefulWidget {
  final ClassProgressItem item;
  final void Function(ClassProgressItem item)? onTap;
  final Set<int>? usedAccents;

  const _ClassProgressCard({required this.item, this.onTap, this.usedAccents});

  @override
  State<_ClassProgressCard> createState() => _ClassProgressCardState();
}

class _ClassProgressCardState extends State<_ClassProgressCard> {
  static final Map<String, bool> _assetOkCache = {};
  late String _iconPath;
  late Color _accent;
  late String _subjectKey;
  static const String kDefaultFallback =
      'assets/images/default-images/default-classes.jpg';

  @override
  void initState() {
    super.initState();
    _initFromItem();
  }

  @override
  void didUpdateWidget(covariant _ClassProgressCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.iconAsset != widget.item.iconAsset ||
        oldWidget.item.subject != widget.item.subject) {
      _initFromItem();
    }
  }

  void _initFromItem() {
    final provided = widget.item.iconAsset.trim();
    _iconPath = provided.isNotEmpty ? provided : kDefaultFallback;
    _subjectKey = _makeSubjectKey(
      widget.item.subject,
      _iconPath,
      widget.item.title,
    );

    final cached = SubjectAccentCache.get(_subjectKey);
    _accent = cached ?? widget.item.accent;

    if (!isNetworkPath(_iconPath)) {
      _upgradeIfExists(_iconPath);
    }
    _computeAccentFromImage(_iconPath);
  }

  Future<void> _upgradeIfExists(String path) async {
    final cached = _assetOkCache[path];
    if (cached == true) return;

    if (cached == false) {
      if (mounted) {
        setState(() => _iconPath = kDefaultFallback);
        _computeAccentFromImage(kDefaultFallback);
      }
      return;
    }

    try {
      await rootBundle.load(path);
      _assetOkCache[path] = true;
    } catch (_) {
      _assetOkCache[path] = false;
      if (mounted) {
        setState(() => _iconPath = kDefaultFallback);
        _computeAccentFromImage(kDefaultFallback);
      }
    }
  }

  Future<void> _computeAccentFromImage(String path) async {
    final cached = SubjectAccentCache.get(_subjectKey);
    if (cached != null) {
      if (!mounted) return;
      setState(() => _accent = cached);
      widget.usedAccents?.add(PaletteUtils.rgbKey(cached));
      return;
    }

    final palette = await PaletteUtils.paletteFromPath(path, maxColors: 5);
    if (!mounted || palette.isEmpty) return;

    final chosen =
        PaletteUtils.pickDistinct(
          palette,
          widget.usedAccents ?? const <int>{},
          minDistance: 40,
        ) ??
        palette.first;

    if (!mounted) return;
    setState(() => _accent = chosen);
    widget.usedAccents?.add(PaletteUtils.rgbKey(chosen));
    SubjectAccentCache.set(_subjectKey, chosen);
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final p = clamp01(item.progress);

    return InkCardShell(
      leftAccent: _accent,
      onTap: widget.onTap == null ? null : () => widget.onTap!(item),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image(
              image: imageProviderFor(_iconPath),
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) {
                if (_iconPath != kDefaultFallback) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    setState(() => _iconPath = kDefaultFallback);
                    _computeAccentFromImage(kDefaultFallback);
                  });
                }
                return Image.asset(kDefaultFallback, fit: BoxFit.cover);
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        maxLines: null,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Text(
                      percentText(p),
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 12,
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E0E0),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: p,
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: _accent,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment((p * 2) - 1, 0),
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.10),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: Border.all(color: _accent, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  twoLevelLabel(
                    item.firstHierarchy,
                    item.firstHierarchyLabel,
                    item.secondHierarchy,
                    item.secondHierarchyLabel,
                  ),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SubjectAccentCache {
  SubjectAccentCache._();
  static final Map<String, Color> _cache = {};

  static Color? get(String key) => _cache[key];
  static void set(String key, Color color) => _cache[key] = color;
  static void clear() => _cache.clear();
}

String _makeSubjectKey(
  Map<String, dynamic>? subject,
  String? iconPath,
  String subjectName,
) {
  final id = _subjectIdFrom(subject);
  if (id != null) return 'id:$id';
  final icon = (iconPath ?? '').trim();
  if (icon.isNotEmpty) return 'icon:$icon';
  return 'name:${subjectName.trim()}';
}

int? _subjectIdFrom(Map<String, dynamic>? m) {
  if (m == null) return null;
  const candidates = [
    'subject_ID',
    'subjectId',
    'subject_id',
    'subjectID',
    'id',
  ];
  for (final k in candidates) {
    final v = m[k];
    if (v == null) continue;
    if (v is int) return v;
    if (v is num) return v.toInt();
    final parsed = int.tryParse(v.toString());
    if (parsed != null) return parsed;
  }
  return null;
}
