import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/timetable_service.dart';
import '../styles/stats_content/card.dart';
import '../styles/stats_content/weekly_chart.dart';

class Status_page extends StatefulWidget {
  const Status_page({super.key});

  @override
  State<Status_page> createState() => _Status_pageState();
}

class _Status_pageState extends State<Status_page> {
  Map<String, dynamic>? _taskData;
  bool _isLoading = true;
  DateTime? _examDate; // exam date backend se ya hardcoded

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    print("DEBUG (TasksPage): Starting to load tasks...");

    try {
      final result = await fetchTasks().timeout(const Duration(seconds: 25), onTimeout: () {
        print("DEBUG (TasksPage): fetchTasks TIMED OUT after 25 seconds");
        return null;
      });

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
            const SnackBar(
              content: Text("Tasks load timed out! Check connection"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print("DEBUG (TasksPage): Load error: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading tasks: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Aaj ke tasks ka count
  int get todayTotal => _filteredTodayTasks.length;
  int get todayPending => _filteredTodayTasks.where((t) => !(t['completed'] ?? false)).length;
  int get todayCompleted => _filteredTodayTasks.where((t) => t['completed'] ?? false).length;

  List<dynamic> get _filteredTodayTasks {
    if (_taskData == null || _taskData!['tasks'] == null) return [];
    final allTasks = _taskData!['tasks'] as List<dynamic>;

    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return allTasks.where((t) => (t['date'] ?? '') == today).toList();
  }

  // Overall stats
  int get overallTotal => _taskData?['total'] ?? 0;
  int get overallPending => _taskData?['pending'] ?? 0;
  int get overallCompleted => _taskData?['completed'] ?? 0;

  // Day to exam (exam date hardcoded ya backend se le sakte hain)
  int get daysToExam {
    // Exam date hardcoded (app mein user se le sakte hain baad mein)
    DateTime examDate = DateTime(2026, 4, 13); // example: 13 April 2026
    return examDate.difference(DateTime.now()).inDays;
  }

  // Consistency (last 7 days mein kitne din tasks complete hue)
  double get consistency {
    // Yeh calculate karne ke liye tasks list se last 7 days check karna padega
    // Abhi dummy 75% return kar rahe hain, baad mein real logic add kar sakte hain
    return 75.0; // TODO: real calculation
  }

  // Daily Average (last 7 days average study hours)
  double get dailyAverage {
    // Dummy 2.5 hours
    return 2.5; // TODO: real calculation
  }

  // Focus Score (completed % last 7 days)
  double get focusScore {
    return 68.0; // TODO: real calculation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadTasks,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Column(
                children: [
                  // Stats Cards – aaj ke + overall mix
                  GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 4,
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 220,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 13,
                      mainAxisExtent: 120,
                    ),
                    itemBuilder: (context, index) {
                      final cards = [
                        statCard(
                          value: '$daysToExam days',
                          title: 'Day to exam',
                          color: [Colors.blue, Colors.lightBlueAccent],
                          icon: Icons.error_outline,
                        ),
                        statCard(
                          value: '${consistency.toStringAsFixed(0)}%',
                          title: 'Consistency',
                          color: [Colors.green, Colors.greenAccent],
                          icon: Icons.show_chart,
                        ),
                        statCard(
                          value: '${dailyAverage.toStringAsFixed(1)}h',
                          title: 'Daily Average',
                          color: [Colors.deepPurple, Colors.redAccent],
                          icon: Icons.calendar_month_outlined,
                        ),
                        statCard(
                          value: '${focusScore.toStringAsFixed(0)}%',
                          title: 'Focus Score',
                          color: [Colors.orange, Colors.red],
                          icon: Icons.workspace_premium_outlined,
                        ),
                      ];
                      return cards[index];
                    },
                  ),

                  const SizedBox(height: 20),

                  // Today's Stats Cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: SizedBox(
                      height: 120, // fixed height taaki cards ek line mein fit ho
                      child: ListView(
                        scrollDirection: Axis.horizontal, // ← Yeh important: left-right scroll
                        physics: const BouncingScrollPhysics(), // smooth swipe feel
                        children: [
                          const SizedBox(width: 8), // left padding
                          statCard(
                            value: '$todayTotal',
                            title: "Today's Total",
                            color: [Colors.blue, Colors.lightBlueAccent],
                            icon: Icons.task_alt,
                          ),
                          const SizedBox(width: 12), // cards ke beech space
                          statCard(
                            value: '$todayPending',
                            title: "Today's Pending",
                            color: [Colors.red, Colors.redAccent],
                            icon: Icons.pending_actions,
                          ),
                          const SizedBox(width: 12),
                          statCard(
                            value: '$todayCompleted',
                            title: "Today's Completed",
                            color: [Colors.green, Colors.greenAccent],
                            icon: Icons.check_circle_outline,
                          ),
                          const SizedBox(width: 8), // right padding
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Weekly Progress Chart
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Container(
                      height: 300,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12.withOpacity(0.5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Weekly Progress",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 12),
                          Expanded(child: WeeklyChart()), // Yeh widget same rahega
                        ],
                      ),
                    ),
                  ),

                  // Achievements
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12.withOpacity(0.5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Achievements",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text(
                                "Keep studying to unlock achievements!",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}