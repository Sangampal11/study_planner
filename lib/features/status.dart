import 'package:flutter/material.dart';
import 'package:hubby/styles/stats_content/weekly_chart.dart';

import '../styles/stats_content/card.dart';

class Status_page extends StatefulWidget {
  const Status_page({super.key});

  @override
  State<Status_page> createState() => _Status_pageState();
}

class _Status_pageState extends State<Status_page> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Column(
            children: [
              GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: 4,
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 220,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 13,
                  mainAxisExtent: 120,
                ),
                itemBuilder: (context, index) {
                  final cards = [
                    statCard(
                      value: '0h',
                      title: 'Day to exam',
                      color: [Colors.blue, Colors.lightBlueAccent],
                      icon: Icons.error_outline,
                    ),
                    statCard(
                      value: '0%',
                      title: 'Consistency',
                      color: [Colors.green, Colors.greenAccent],
                      icon: Icons.show_chart,
                    ),
                    statCard(
                      value: '0.0h',
                      title: 'Daily Average',
                      color: [Colors.deepPurple, Colors.redAccent],
                      icon: Icons.calendar_month_outlined,
                    ),
                    statCard(
                      value: '0%',
                      title: 'Focus Score',
                      color: [Colors.orange, Colors.red],
                      icon: Icons.workspace_premium_outlined,
                    ),
                  ];
                  return cards[index];
                },
              ),
        
              SizedBox(height: 20),
        
        
              Padding(
                padding: EdgeInsets.all(12),
                child: Container(
                  height: 300,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12.withOpacity(0.5),
                        blurRadius: 10,
                      ),
                    ]
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Weekly Progress",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      WeeklyChart(),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12.withOpacity(0.5),
                        blurRadius: 10,
                      )
                    ]
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Achievements",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
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
                      )
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
