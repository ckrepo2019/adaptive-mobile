// lib/utils/casting.dart

/// Best-effort conversion to int from dynamic values.
int? asInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

/// Best-effort conversion to String (trimmed). Returns '' if null.
String asString(dynamic v) => (v ?? '').toString().trim();

/// Best-effort conversion to bool from common truthy/falsey forms.
bool? asBool(dynamic v) {
  if (v == null) return null;
  if (v is bool) return v;
  final s = v.toString().toLowerCase().trim();
  if (s == 'true' || s == '1' || s == 'yes') return true;
  if (s == 'false' || s == '0' || s == 'no') return false;
  return null;
}
