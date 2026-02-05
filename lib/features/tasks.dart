import 'package:flutter/material.dart';

import '../styles/task_content/card.dart';

class Tasks_page extends StatefulWidget {
  const Tasks_page({super.key});

  @override
  State<Tasks_page> createState() => _Tasks_pageState();
}

class _Tasks_pageState extends State<Tasks_page> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: 3,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 140,
                mainAxisExtent: 60,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                final cards = [
                  statcard(value: '0', title: 'Total', valuecolor: Colors.blue,),
                  statcard(value: '0', title: 'Pending', valuecolor: Colors.red,),
                  statcard(value: '0', title: 'Completed', valuecolor: Colors.green,),
                ];
                return cards[index];
              },
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                children: [
                  filterchip("All Tasks", true),
                  const SizedBox(width: 10),
                  filterchip("Pending", false),
                  const SizedBox(width: 10),
                  filterchip("Completed", false),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                  colors: [Color(0xFF2D5CFF), Color(0xFF9A2DFF)],
                ),
              ),
              child: const Center(
                child: Text(
                  "+  Add New Task",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50),
            Container(
              width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Icon(Icons.check_box_outlined,color: Colors.grey,size: 32)),
            SizedBox(height: 8,),
            Text("No tasks yet",style: TextStyle(fontSize: 20,color: Colors.grey.shade600,fontWeight: FontWeight.bold),),
            SizedBox(height: 8,),
            Text("Add your first task to get started",style: TextStyle(color: Colors.grey),)
          ],
        ),
      ),
    );
  }
  Widget filterchip(String text,bool active){
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: active? Colors.blue : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Text(text,style: TextStyle(color: active? Colors.white : Colors.black,fontWeight: FontWeight.bold),),
    );
  }
}
