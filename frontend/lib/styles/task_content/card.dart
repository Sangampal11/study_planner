import 'package:flutter/material.dart';

class statcard extends StatelessWidget {
  final String value;
  final String title;
  final Color valuecolor;
  const statcard({super.key, required this.value, required this.title, required this.valuecolor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: valuecolor),
          ),
          SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.black54)),
        ],
      ),
    );
  }
}

