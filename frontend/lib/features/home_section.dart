import 'package:flutter/material.dart';
import 'package:hubby/styles/homepage_content/cards.dart';
import '../styles/homepage_content/Action_card.dart';

class homePage extends StatefulWidget {
  final VoidCallback? onGenrate;
  final VoidCallback? onTimetable;
  final VoidCallback? onTasks;
  final VoidCallback? onFocus;
  final VoidCallback? onAnalytics;
  const homePage({super.key, required this.onGenrate, this.onTimetable, this.onTasks, this.onFocus, this.onAnalytics});

  @override
  State<homePage> createState() => homePageState();
}

class homePageState extends State<homePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔹 STATS GRID
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 4,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 220,
                  mainAxisExtent: 100,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.0,
                ),
                itemBuilder: (context, index) {
                  final cards = [
                    statCard(
                      title: 'Day to exam',
                      color: [Colors.orange, Colors.red],
                      icon: Icons.error_outline,
                      value: '0',
                    ),
                    statCard(
                      title: 'Minutes today',
                      color: [Colors.blue, Colors.lightBlue],
                      icon: Icons.access_time,
                      value: '0',
                    ),
                    statCard(
                      title: 'Task pending',
                      color: [Colors.purple, Colors.pink],
                      icon: Icons.check_box,
                      value: '0',
                    ),
                    statCard(
                      title: 'Focus Sessions',
                      color: [Colors.green, Colors.teal],
                      icon: Icons.timer,
                      value: '0',
                    ),
                  ];
                  return cards[index];
                },
              ),

              const SizedBox(height: 24),

              const Text(
                "Quick Actions",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              /// 🔹 ACTION BUTTON GRID
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 4,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.6, // safe height
                ),
                itemBuilder: (context, index) {
                  final actionCards = [
                    ActionCard(
                      title: "Timetable",
                      subtitile: "View schedule",
                      icon: Icons.calendar_today,
                      color: Colors.blue,

                      onpressed: () {
                        widget.onTimetable!();
                      },
                    ),
                    ActionCard(
                      title: "Tasks",
                      subtitile: "Manage tasks",
                      icon: Icons.task_alt,
                      color: Colors.purple,

                      onpressed: () {
                        widget.onTasks!();
                      },
                    ),
                    ActionCard(
                      title: "Start Focus",
                      subtitile: "Begin studying",
                      icon: Icons.timer,
                      color: Colors.green,
                      filled: true,

                      onpressed: () {
                        widget.onFocus!();
                      },
                    ),
                    ActionCard(
                      title: "Analytics",
                      subtitile: "View stats",
                      icon: Icons.show_chart,
                      color: Colors.orange,

                      onpressed: () {
                        widget.onAnalytics!();
                      },
                    ),
                  ];
                  return actionCards[index];
                },
              ),

              SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: double.infinity,
                  height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white,
                        blurRadius: 16,
                        offset: Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey.shade100,
                        child: ClipOval(
                          child: Image.asset(
                            'assets/launch_icon/launch_icon.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: 50),
                      const Text(
                        "Create Your Timetable",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      const Text(
                        "AI will optimize your study schedule",
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                      SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          widget.onGenrate!();
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            Color(0xff6e43da),
                          ),

                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        child: Text(
                          "Genrate Time Table",
                          style: TextStyle(color: Colors.white),
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
    );
  }
}
