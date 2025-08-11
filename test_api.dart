import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> main() async {
  const baseURL = 'http://127.0.0.1:8000/api/flutter';

  // === 2) GET-USER ===
  final getUserRes = await http.get(
    Uri.parse('$baseURL/get-user/202500002?usertype_ID=4'),
    headers: {
      'Accept': 'application/json',
      'Authorization':
          'Bearer 21|Du73fPLqNP0tWtQ7cpRBASvWn5hanP3bKcflAT2Ya33544ed',
    },
  );
  print('\n/get-user status: ${getUserRes.statusCode}');
  _printPretty('/get-user body', getUserRes.body);

  // === 3) STUDENT-HOME ===
  final studentHomeRes = await http.get(
    Uri.parse('$baseURL/student-home/202500002'),
    headers: {
      'Accept': 'application/json',
      'Authorization':
          'Bearer 21|Du73fPLqNP0tWtQ7cpRBASvWn5hanP3bKcflAT2Ya33544ed',
    },
  );

  print('\n/student-home status: ${studentHomeRes.statusCode}');
  _printPretty('/student-home body', studentHomeRes.body);

  // Save to file
  final file = File('student_home.txt');
  await file.writeAsString(studentHomeRes.body);
  print('✅ Saved student-home response to student_home.txt');
}

void _printPretty(String label, String raw) {
  try {
    final parsed = jsonDecode(raw);
    final pretty = const JsonEncoder.withIndent('  ').convert(parsed);
    print('$label:\n$pretty');
  } catch (_) {
    print('$label:\n$raw');
  }
}
