import 'package:flutter/material.dart';

class Cards extends StatelessWidget {
  final String value;
  final String title;
  final Color color;
  const Cards({super.key, required this.value, required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
            )
          ]
        ),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            children: [
              Text(value,style: TextStyle(
                fontSize: 20,
                color: color,
                fontWeight: FontWeight.bold
              ),),
              SizedBox(height: 2,),
              Text(title,style: TextStyle(
                fontSize: 12,
                color: Colors.grey
              ),)
            ]
          ),
        ),
      ),
    );
  }
}
