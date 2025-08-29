import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import 'image_utils.dart';

class DominantColorUtils {
  static final Map<String, Color?> _cache = {};

  static Future<Color?> fromPath(
    String path, {
    int sampleW = 48,
    int sampleH = 48,
  }) async {
    final key = '$path@$sampleW:$sampleH';
    if (_cache.containsKey(key)) return _cache[key];

    try {
      final provider = imageProviderFor(path);
      final resized = provider is ResizeImage
          ? provider
          : ResizeImage(provider, width: sampleW, height: sampleH);

      final ui.Image img = await loadUiImage(resized);
      final byteData = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (byteData == null) return _cache[key] = null;

      final bytes = byteData.buffer.asUint8List();

      int r = 0, g = 0, b = 0, a = 0, count = 0;
      for (int i = 0; i + 3 < bytes.length; i += 4) {
        final rr = bytes[i];
        final gg = bytes[i + 1];
        final bb = bytes[i + 2];
        final aa = bytes[i + 3];
        if (aa < 16) continue;
        r += rr;
        g += gg;
        b += bb;
        a += aa;
        count++;
      }

      if (count == 0) return _cache[key] = null;

      final color = Color.fromARGB(
        (a ~/ count).clamp(0, 255),
        r ~/ count,
        g ~/ count,
        b ~/ count,
      );

      return _cache[key] = color;
    } catch (_) {
      return _cache[key] = null;
    }
  }

  static Future<void> warmup(
    Iterable<String> paths, {
    int sampleW = 48,
    int sampleH = 48,
  }) async {
    await Future.wait(
      paths.map((p) => fromPath(p, sampleW: sampleW, sampleH: sampleH)),
    );
  }

  static void clear() => _cache.clear();
}
