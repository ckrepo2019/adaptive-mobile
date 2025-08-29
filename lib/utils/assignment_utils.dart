import '../models/items.dart';

String assignmentTitleLine(AssignmentItem item) {
  return '${item.subject} ${item.type} ${item.title}'.trim();
}
