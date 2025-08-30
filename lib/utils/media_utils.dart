/// Media/asset helpers.
class MediaUtils {
  static String? pickImageUrl(Map<String, dynamic> m) {
    final v = m['thumbnail_url'] ?? m['image'] ?? m['cover'] ?? '';
    final s = (v is String) ? v.trim() : '';
    return s.isEmpty ? null : s;
  }
}
