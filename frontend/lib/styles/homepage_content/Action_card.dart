import 'package:flutter/material.dart';

class ActionCard extends StatelessWidget {
  final String title;
  final String subtitile;
  final IconData icon;
  final Color color;
  final bool filled;
  final VoidCallback onpressed;
  const ActionCard({
    super.key,
    required this.title,
    required this.subtitile,
    required this.icon,
    required this.color,
    required this.onpressed,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onpressed,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: filled ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color:Colors.white,
              blurRadius: 8,
              offset: Offset(0, 4),
            )
          ]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: filled?Colors.white:color.withOpacity(0.2),
              child: Icon(icon,color: filled?color:color),
            ),
            const Spacer(),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: filled ? Colors.white : Colors.black,
              ),
            ),
            Text(
              subtitile,
              style: TextStyle(
                color: filled ? Colors.white70 : Colors.black54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
