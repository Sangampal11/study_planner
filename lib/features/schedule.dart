import 'package:flutter/material.dart';

class Schedule extends StatefulWidget {
  const Schedule({super.key});

  @override
  State<Schedule> createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Center(
      child: Column(
        children: [
          SizedBox(
            height: 30,
          ),
          CircleAvatar(child: Icon(Icons.calendar_month,),radius: 30,),
          SizedBox(
            height: 20,
          ),
          Text("No Timetable",style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold
          ),),

          Text("Generate a timetable first from the Home tab"),
        ],
      ),
    ));
  }
}
