import '../models/items.dart';

/// Builds a consistent assignment title line like:
/// "<subject> <type> <title>"
String assignmentTitleLine(AssignmentItem item) {
  return '${item.subject} ${item.type} ${item.title}'.trim();
}
