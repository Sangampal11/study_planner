import 'package:flutter/material.dart';

class statCard extends StatelessWidget {
  final String value;
  final IconData icon;
  final String title;
  final List<Color> color;
  const statCard({super.key, required this.value, required this.icon, required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(colors: color,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon,color: Colors.white,),
          SizedBox(height: 5,),
          Text(value,style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold,color: Colors.white),),
          SizedBox(height: 2,),
          Text(title,style: TextStyle(fontSize: 15,color: Colors.white),),
        ],
      ),
    );
  }
}
