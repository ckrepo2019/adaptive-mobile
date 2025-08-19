/// Media/asset helpers.
class MediaUtils {
  /// Picks a usable image URL from a subject/record map.
  /// Checks 'thumbnail_url', then 'image', then 'cover'.
  static String? pickImageUrl(Map<String, dynamic> m) {
    final v = m['thumbnail_url'] ?? m['image'] ?? m['cover'] ?? '';
    final s = (v is String) ? v.trim() : '';
    return s.isEmpty ? null : s;
  }
}
