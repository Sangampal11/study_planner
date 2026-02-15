import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../styles/add_new_tt/Main_card.dart';

Future<Map<String, dynamic>?> generateAndSaveTimetable({
  required String examDate,
  required double dailyHours,
  required List<SubjectModel> subjects,
  required String classLevel,
}) async {
  try {
    final body = {
      'exam_date': examDate,
      'daily_hours': dailyHours,
      'subjects': subjects.map((s) => {
        'name': s.name,
        'strength': s.strength,
      }).toList(),
      'class_level': classLevel.trim(),
    };

    print('DEBUG: Sending body to backend: ${jsonEncode(body)}');

    final response = await http.post(
      Uri.parse('$baseUrl/api/generate-timetable/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    print('DEBUG: Response status: ${response.statusCode}');
    print('DEBUG: Response body: ${response.body}');

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  } catch (e) {
    print('Error: $e');
    return null;
  }
}

Future<Map<String, dynamic>?> fetchTasks() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/api/tasks/'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Fetch failed: ${response.statusCode} - ${response.body}');
      return null;
    }
  } catch (e) {
    print('Error fetching tasks: $e');
    return null;
  }
}