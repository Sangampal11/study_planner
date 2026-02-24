import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/timetable_service.dart';
import '../styles/task_content/card.dart';

class TasksPage extends StatefulWidget {
  final VoidCallback? onAddTask;
  final String? initialFilter;// Chapter filter ke liye
  const TasksPage({super.key, this.onAddTask, this.initialFilter, });

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  Map<String, dynamic>? _taskData;
  bool _isLoading = true;
  String _selectedFilter = 'All Tasks';

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    print("DEBUG (TasksPage): Starting to load tasks...");

    final result = await fetchTasks();
    if (mounted) {
      print("DEBUG (TasksPage): fetchTasks result: $result");
      setState(() {
        _taskData = result;
        _isLoading = false;
      });
      if (result != null) {
        print("DEBUG (TasksPage): Total tasks received: ${result['total'] ?? 0}");
        print("DEBUG (TasksPage): Tasks list length: ${result['tasks']?.length ?? 0}");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load tasks"), backgroundColor: Colors.red),
        );
      }
    }
  }

  List<dynamic> get _filteredTasks {
    if (_taskData == null || _taskData!['tasks'] == null) {
      print("DEBUG (TasksPage): No task data available");
      return [];
    }
    final allTasks = _taskData!['tasks'] as List<dynamic>;
    print("DEBUG (TasksPage): Total tasks loaded: ${allTasks.length}");

    // Aaj ki date clean format mein
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    print("DEBUG (TasksPage): Today's clean date: $today");

    // Date match ko safe bana (trim + split T for time zone)
    List<dynamic> todayTasks = allTasks.where((t) {
      String taskDateRaw = (t['date'] ?? '').toString().trim();
      // Agar "2026-02-15T18:04:53.418+00:00" format hai to sirf date le
      String cleanTaskDate = taskDateRaw.split('T')[0];
      bool match = cleanTaskDate == today;
      print("DEBUG: Task date raw: $taskDateRaw → clean: $cleanTaskDate → match: $match");
      return match;
    }).toList();

    print("DEBUG (TasksPage): Found ${todayTasks.length} tasks for today after safe match");

    // Chapter filter
    List<dynamic> filtered = todayTasks;
    if (widget.initialFilter != null && widget.initialFilter!.isNotEmpty) {
      filtered = filtered.where((t) {
        final title = t['title'] ?? '';
        return title.contains(widget.initialFilter!);
      }).toList();
    }

    // Pending/Completed
    if (_selectedFilter == 'Pending') {
      return filtered.where((t) => !(t['completed'] ?? false)).toList();
    } else if (_selectedFilter == 'Completed') {
      return filtered.where((t) => t['completed'] ?? false).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final total = _filteredTasks.length;
    final pending = _filteredTasks.where((t)=> !(t['completed']??false)).length;
    final completed = _filteredTasks.where((t)=> t['completed']??true).length;

    print("DEBUG (TasksPage): Building UI - Total: $total, Pending: $pending, Completed: $completed");

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadTasks,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Stats Cards
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 3,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 140,
                    mainAxisExtent: 60,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    final cards = [
                      statcard(value: '$total', title: 'Total', valuecolor: Colors.blue),
                      statcard(value: '$pending', title: 'Pending', valuecolor: Colors.red),
                      statcard(value: '$completed', title: 'Completed', valuecolor: Colors.green),
                    ];
                    return cards[index];
                  },
                ),

                // Filter Chips
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildFilterChip("All Tasks", _selectedFilter == "All Tasks", () => setState(() => _selectedFilter = "All Tasks")),
                      const SizedBox(width: 10),
                      _buildFilterChip("Pending", _selectedFilter == "Pending", () => setState(() => _selectedFilter = "Pending")),
                      const SizedBox(width: 10),
                      _buildFilterChip("Completed", _selectedFilter == "Completed", () => setState(() => _selectedFilter = "Completed")),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Add New Task Button
                InkWell(
                  onTap: widget.onAddTask,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2D5CFF), Color(0xFF9A2DFF)],
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        "+  Add New Task",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Tasks List (Expanded ke andar – overflow fix)
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _filteredTasks.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: const Icon(Icons.check_box_outlined, color: Colors.grey, size: 32),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No tasks yet",
                          style: TextStyle(fontSize: 20, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Generate timetable to see tasks here",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                      : ListView.builder(
                    itemCount: _filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = _filteredTasks[index];
                      print("DEBUG (TasksPage): Rendering task: ${task['title']}");

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: Checkbox(
                            value: task['completed'] ?? false,
                            activeColor: Colors.green,
                            onChanged: (bool? value) {
                              // TODO: Backend update call
                              setState(() {
                                task['completed'] = value;
                              });
                            },
                          ),
                          title: Text(
                            task['title'] ?? 'Untitled Task',
                            style: TextStyle(
                              decoration: (task['completed'] ?? false) ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,  // ← Overflow fix
                            children: [
                              Text("${task['date'] ?? ''} • ${task['start_time'] ?? ''} - ${task['end_time'] ?? ''}"),
                              if (task['subject'] != null) Text("Subject: ${task['subject']}"),
                              if (task['chapter'] != null) Text("Chapter: ${task['chapter']}"),
                              if (task['description'] != null) Text(
                                task['description'],
                                maxLines: 3,  // ← Overflow fix
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () {
                              // TODO: Delete call
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String text, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: active ? Colors.blue : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
          boxShadow: active ? [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 8)] : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: active ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}