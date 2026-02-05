import 'package:flutter/material.dart';
import 'package:hubby/styles/focus_content/timer_card.dart';

import '../styles/focus_content/cards.dart';

class Focus_page extends StatefulWidget {
  const Focus_page({super.key});

  @override
  State<Focus_page> createState() => _Focus_pageState();
}

class _Focus_pageState extends State<Focus_page> {
  int focusedSeconds = 0;

  int get focusedMinutes => focusedSeconds ~/ 60;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            GridView.builder(
              itemCount: 2,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                mainAxisExtent: 100,
                mainAxisSpacing: 12,
                crossAxisSpacing: 5,
              ),
              itemBuilder: (context, index) {
                final cards = [
                  Cards(value: focusedMinutes.toString(), title: "Minutes today",color: Colors.blueAccent,),
                  Cards(value: "${focusedMinutes}m", title: "Total time",color: Colors.green,),
                ];
                return cards[index];
              },
            ),
        
            TimerCard(onFocusUpdate: (second) {
              setState(() {
                focusedSeconds = second--;
              }); },),
          ],
        ),
      ),
    );
  }
}
