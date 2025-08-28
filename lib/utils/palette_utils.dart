// ignore_for_file: deprecated_member_use, unused_local_variable

import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'image_utils.dart'; // imageProviderFor, loadUiImage

/// Tiny palette extractor + distinct color picker.
/// Strategy:
/// 1) Downsample to ~48x48
/// 2) Quantize to 12-bit buckets (4 bits per channel) to build a histogram
/// 3) Return top-N buckets as Colors (averaged)
class PaletteUtils {
  /// Extract up to [maxColors] dominant-ish colors from an image path or URL.
  static Future<List<Color>> paletteFromPath(
    String path, {
    int maxColors = 5,
  }) async {
    try {
      final provider = imageProviderFor(path);
      final resized = provider is ResizeImage
          ? provider
          : ResizeImage(provider, width: 48, height: 48);

      final ui.Image img = await loadUiImage(resized);
      final bd = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (bd == null) return const [];

      final bytes = bd.buffer.asUint8List();
      // 12-bit quantization: 4 bits per channel -> 4096 buckets
      final counts = <int, int>{};
      final sums = <int, List<int>>{}; // bucket -> [rSum,gSum,bSum,aSum]

      for (int i = 0; i + 3 < bytes.length; i += 4) {
        final r = bytes[i];
        final g = bytes[i + 1];
        final b = bytes[i + 2];
        final a = bytes[i + 3];
        if (a < 16) continue; // ignore near-transparent

        final r4 = r >> 4, g4 = g >> 4, b4 = b >> 4;
        final bucket = (r4 << 8) | (g4 << 4) | b4;

        counts[bucket] = (counts[bucket] ?? 0) + 1;
        final s = sums.putIfAbsent(bucket, () => [0, 0, 0, 0]);
        s[0] += r;
        s[1] += g;
        s[2] += b;
        s[3] += a;
      }

      final entries = counts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value)); // freq desc

      final colors = <Color>[];
      for (final e in entries.take(maxColors)) {
        final s = sums[e.key]!;
        final c = Color.fromARGB(
          (s[3] ~/ e.value).clamp(0, 255),
          (s[0] ~/ e.value),
          (s[1] ~/ e.value),
          (s[2] ~/ e.value),
        );
        colors.add(c);
      }
      return colors;
    } catch (_) {
      return const [];
    }
  }

  /// Pick the first color in [palette] whose distance to every color in [used]
  /// is >= [minDistance]. If none qualifies, return the first palette color.
  static Color? pickDistinct(
    List<Color> palette,
    Set<int> used, {
    int minDistance = 40, // Euclidean in RGB (0..255)
  }) {
    Color? first;
    for (final c in palette) {
      first ??= c;
      final rgb = (c.red << 16) | (c.green << 8) | c.blue;
      bool ok = true;
      for (final u in used) {
        final ur = (u >> 16) & 0xFF;
        final ug = (u >> 8) & 0xFF;
        final ub = u & 0xFF;
        final dr = (c.red - ur);
        final dg = (c.green - ug);
        final db = (c.blue - ub);
        final dist = (dr * dr + dg * dg + db * db).toDouble();
        if (dist < (minDistance * minDistance)) {
          ok = false;
          break;
        }
      }
      if (ok) return c;
    }
    return first;
  }

  /// Encode a color (ignore alpha) as int for set membership
  static int rgbKey(Color c) => (c.red << 16) | (c.green << 8) | c.blue;
}
