/// Person/name helpers.
class NameUtils {
  /// Builds a full display name from a teacher/person map.
  /// Supports keys: firstname/first_name, middlename/middle_name, lastname/last_name, name.
  static String formatTeacher(dynamic teacher) {
    if (teacher is Map) {
      final f = (teacher['firstname'] ?? teacher['first_name'] ?? '')
          .toString()
          .trim();
      final m = (teacher['middlename'] ?? teacher['middle_name'] ?? '')
          .toString()
          .trim();
      final l = (teacher['lastname'] ?? teacher['last_name'] ?? '')
          .toString()
          .trim();

      final parts = [
        f,
        if (m.isNotEmpty) m,
        l,
      ].where((s) => s.isNotEmpty).toList();
      if (parts.isNotEmpty) return parts.join(' ');

      final name = (teacher['name'] ?? '').toString().trim();
      if (name.isNotEmpty) return name;
    }
    return '';
  }
}
