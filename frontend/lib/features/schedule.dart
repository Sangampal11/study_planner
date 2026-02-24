import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/timetable_service.dart';// TasksPage import kar le

class SchedulePage extends StatefulWidget {
  final VoidCallback? gotoTaskPage;
  const SchedulePage({super.key, required this.gotoTaskPage});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  Map<String, dynamic>? _taskData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    final result = await fetchTasks();
    if (mounted) {
      setState(() {
        _taskData = result;
        _isLoading = false;
      });
      print("DEBUG (SchedulePage): Tasks loaded - total: ${result?['total'] ?? 0}");
    }
    if (result != null && result['tasks'] != null) {
      final uniqueSubjects = (result['tasks'] as List<dynamic>).map((t) => t['subject'] ?? 'Unknown').toSet().toList();
      print("DEBUG (SchedulePage): Unique subjects from DB: $uniqueSubjects");
    }
  }


  // Subject-wise group karo (case-insensitive + trim)
  Map<String, List<dynamic>> get _subjectGrouped {
    if (_taskData == null || _taskData!['tasks'] == null) return {};
    final allTasks = _taskData!['tasks'] as List<dynamic>;

    Map<String, List<dynamic>> grouped = {};
    for (var task in allTasks) {
      String subject = (task['subject'] ?? 'Unknown Subject').trim().toLowerCase();  // ← trim + lowercase for grouping
      String displaySubject = (task['subject'] ?? 'Unknown Subject').trim();  // original name for display

      // Grouping ke liye lowercase key use kar
      grouped.putIfAbsent(subject, () => []).add(task);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _subjectGrouped;
    final subjectsLower = grouped.keys.toList()..sort(); // lowercase keys sort

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : subjectsLower.isEmpty
          ? const Center(
        child: Text(
          "No subjects yet\nGenerate timetable first",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: subjectsLower.length,
        itemBuilder: (context, index) {
          String subjectLower = subjectsLower[index];
          List<dynamic> tasks = grouped[subjectLower]!;

          // Original subject name dikhane ke liye pehla task se le lo (sahi name)
          String displaySubject = tasks.isNotEmpty ? (tasks[0]['subject'] ?? 'Unknown Subject').trim() : subjectLower;

          // Date-wise sort kar do tasks
          tasks.sort((a, b) {
            String dateA = a['date'] ?? '9999-99-99';
            String dateB = b['date'] ?? '9999-99-99';
            return dateA.compareTo(dateB);
          });

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF7F3DFF),
                child: Text(
                  displaySubject.isNotEmpty ? displaySubject[0].toUpperCase() : 'U',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(
                displaySubject,  // ← Original subject name dikhaayega
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text("${tasks.length} tasks • Tap to expand"),
              childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: tasks.map((task) {
                String dateStr = task['date'] ?? 'No Date';
                String formattedDate = dateStr;
                if (dateStr != 'No Date' && dateStr.contains('-')) {
                  try {
                    final date = DateTime.parse(dateStr);
                    formattedDate = DateFormat('dd MMM yyyy (EEE)').format(date);
                  } catch (_) {}
                }

                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.schedule, size: 20, color: Color(0xFF7F3DFF)),
                  title: Text(
                    task['title'] ?? 'Task',
                    style: const TextStyle(fontSize: 16),
                  ),
                  subtitle: Text(
                    "$formattedDate • ${task['start_time'] ?? 'N/A'} - ${task['end_time'] ?? 'N/A'}",
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF7F3DFF)),
                  onTap: widget.gotoTaskPage,
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}