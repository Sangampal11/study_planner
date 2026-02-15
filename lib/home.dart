import 'package:flutter/material.dart';
import 'package:hubby/features/Genrate_timeTabel.dart';
import 'package:hubby/features/tasks.dart';

import 'features/bottom_navigation/naviagation_button.dart';
import 'features/focus.dart';
import 'features/home_section.dart';
import 'features/schedule.dart';
import 'features/status.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, });
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedIndex = 0;
  late List<Widget> pages;

  void initState(){
    super.initState();
    pages =  [
      homePage(
        onGenrate: () {
          print("Generate button clicked");
          setState(() {
            selectedIndex = 5;
          });
        },
        onTimetable: () {
          print("Timetable button clicked");
          setState(() {
            selectedIndex = 1;
          });
        },
        onAnalytics: (){
          setState(() {
            selectedIndex=4;
          });
        },
        onFocus: (){
          setState(() {
            selectedIndex=2;
          });
        },
        onTasks: (){
          setState(() {
            selectedIndex=3;
          });
        },
      ),
      SchedulePage(gotoTaskPage: () {
        setState(() {
          selectedIndex=3;
        });
      },),
      Focus_page(),
      TasksPage(onAddTask: () {
        setState(() {
          selectedIndex=5;
        });
      },),
      Status_page(),
      GenrateTimetabel()
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Color(0xFF7F3DFF),
        title: Row(
          children: [
            // ... icon same
            Text(
              selectedIndex == 0 ? "Study Planner" :
              selectedIndex == 1 ? "Schedule" :
              selectedIndex == 2 ? "Focus" :
              selectedIndex == 3 ? "Tasks" :
              selectedIndex == 4 ? "Stats" :
              "Generate Timetable",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            Spacer(),
            // ... notification icon
          ],
        ),
      ),
      body: pages[selectedIndex],
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: selectedIndex,
        onItemSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
      ),
    );
  }
}
