import 'package:flutter/material.dart';

class statCard extends StatelessWidget {
  final String title;
  final List<Color> color;
  final String value;
  final IconData icon;

  const statCard({
    super.key,
    required this.title,
    required this.color,
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: color,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // 🔥 key
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(height: 4),

          FittedBox( // 🔥 overflow guard
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 5),

          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
