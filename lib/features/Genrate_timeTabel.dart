import 'package:flutter/material.dart';

import '../styles/add_new_tt/Main_card.dart';
import '../styles/add_new_tt/note_card.dart';

class GenrateTimetabel extends StatelessWidget {
  const GenrateTimetabel({super.key});

  @override
  Widget build(BuildContext context) {
    return  SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Column(
                      children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    gradient: LinearGradient(colors: [Color(0xFF8F58FA), Color(
                        0xFF4B20C5)])
                  ),
                  child: Image.asset("assets/brainn.png",),
                  ),
                        SizedBox(height: 3,),
                        Text("AI Timetable Generator",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22),),
                        Text("Smart scheduling for better results",),
                        SizedBox(height: 20,),
                        StudyInputCard(),
                        SizedBox(height: 20,),
                        NoteCard(),
                      ],
                    ),
              ),
            ),
          ),
    );
  }
}
