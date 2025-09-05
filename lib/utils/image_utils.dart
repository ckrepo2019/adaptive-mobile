import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

bool isNetworkPath(String path) {
  final p = path.trim().toLowerCase();
  return p.startsWith('http://') || p.startsWith('https://');
}

ImageProvider<Object> imageProviderFor(String path) {
  final p = path.trim();
  return isNetworkPath(p) ? NetworkImage(p) : AssetImage(p);
}

Future<bool> assetExists(String assetPath) async {
  try {
    await rootBundle.load(assetPath);
    return true;
  } catch (_) {
    return false;
  }
}

Widget buildIconImage(
  String path, {
  double w = 26,
  double h = 26,
  String? fallbackAsset,
  BoxFit fit = BoxFit.contain,
}) {
  if (isNetworkPath(path)) {
    return Image.network(
      path,
      width: w,
      height: h,
      fit: fit,
      errorBuilder: (_, __, ___) => (fallbackAsset == null)
          ? const SizedBox.shrink()
          : Image.asset(fallbackAsset, width: w, height: h, fit: fit),
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : const SizedBox.shrink(),
      gaplessPlayback: true,
      filterQuality: FilterQuality.low,
    );
  }
  return Image.asset(path, width: w, height: h, fit: fit);
}

Future<ui.Image> loadUiImage(ImageProvider provider) {
  final completer = Completer<ui.Image>();
  final stream = provider.resolve(const ImageConfiguration());
  late final ImageStreamListener listener;

  listener = ImageStreamListener(
    (ImageInfo info, bool _) {
      completer.complete(info.image);
      stream.removeListener(listener);
    },
    onError: (Object error, StackTrace? stackTrace) {
      completer.completeError(error, stackTrace);
      stream.removeListener(listener);
    },
  );

  stream.addListener(listener);
  return completer.future;
}

Future<Color?> averageColorFromImage(
  String path, {
  int sampleW = 48,
  int sampleH = 48,
}) async {
  try {
    final provider = imageProviderFor(path);
    final resized = provider is ResizeImage
        ? provider
        : ResizeImage(provider, width: sampleW, height: sampleH);

    final uiImage = await loadUiImage(resized);
    final byteData = await uiImage.toByteData(
      format: ui.ImageByteFormat.rawRgba,
    );
    if (byteData == null) return null;

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
    if (count == 0) return null;

    return Color.fromARGB(
      (a ~/ count).clamp(0, 255),
      r ~/ count,
      g ~/ count,
      b ~/ count,
    );
  } catch (_) {
    return null;
  }
}
