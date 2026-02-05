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
      Schedule(),
      Focus_page(),
      Tasks_page(),
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
            Container(
              width: 36,
              height:36,
              decoration:BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Color(0x4C353535),
                    offset: Offset(0, 1)
                  )
                ],
                gradient: LinearGradient(colors: [Color(0xFF7F3DFF), Color(
                    0xFF4B20C5)]),
                borderRadius: BorderRadius.circular(12),
              ),
                child: Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 20,
                )
            ),
            SizedBox(width: 5,),
            Text("Study Planner",style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),),
            Spacer(),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Color(0xff6e43da),
                borderRadius:BorderRadius.circular(12)
              ),
              child: IconButton(onPressed: (){}, icon: Icon(Icons.notifications_none_outlined,color: Colors.white,))
            )
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
