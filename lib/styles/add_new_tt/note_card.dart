import 'package:flutter/material.dart';

class NoteCard extends StatelessWidget {
  const NoteCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
        color: Color(0xFFE5F5F6)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset("assets/brainn.png", color: Colors.blue, scale: 1.5),
              Text(
                "AI Will Generate (Class-Specific)",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Text('''📚 NCERT book reading tasks
✍️ Class-appropriate exercises
⚡ Weak subjects get more focus
🎯 Exam milestone reminders
📖 Textbook-based assignments'''),
        ],
      ),
    );
  }
}
