import 'dart:async';

import 'package:flutter/material.dart';

class TimerCard extends StatefulWidget {
  final Function(int) onFocusUpdate;
  const TimerCard({super.key, required this.onFocusUpdate});

  @override
  State<TimerCard> createState() => _TimerCardState();
}

class _TimerCardState extends State<TimerCard> {
  int selectMinutes = 25;
  int remainingsecond = 25 * 60;
  Timer? timer;
  bool isRunning = false;
  int focussec = 0;

  double get process => remainingsecond / (selectMinutes * 60);

  String get timeText {
    final m = remainingsecond ~/ 60;
    final s = remainingsecond % 60;

    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  void startTimer() {
    if (isRunning) return;

    setState(() {
      isRunning = true;
    });

    timer = Timer.periodic(Duration(seconds: 1), (t) {
      if (remainingsecond == 0) {
        t.cancel();
        setState(() => isRunning = false);
      } else {
        setState(() {
          remainingsecond--;
          focussec++;
        });
        widget.onFocusUpdate(focussec);
      }
    });
  }

  int get FocusTime => focussec ~/ 60;
  void resetTimer() {
    timer?.cancel();
    setState(() {
      isRunning = false;
      remainingsecond = selectMinutes * 60;
    });
  }

  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void selectDuration(int minutes) {
    if (isRunning) return;
    setState(() {
      selectMinutes = minutes;
      remainingsecond = minutes * 60;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Container(
        padding: EdgeInsets.all(30),
        width: double.infinity,
        height: 700,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            colors: [Color(0xFF7F3DFF), Color(0xFF4B20C5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Subject",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            _box("Select subject"),

            const SizedBox(height: 30),
            const Text(
              "Duration",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [_chip(25), _chip(30), _chip(45), _chip(50)],
            ),
            const SizedBox(height: 30),
            Center(
              child: Text(
                timeText,
                style: const TextStyle(
                  fontSize: 52,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(height: 20),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 190,
                    height: 190,
                    child: CircularProgressIndicator(
                      value: process,
                      strokeWidth: 10,
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                  Column(
                    children: [
                      Image.asset("assets/circle_rounded.png"),
                      SizedBox(height: 10),
                      Text(
                        "100%",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text("Focus", style: TextStyle(color: Colors.white60)),
                    ],
                  ),
                ],
              ),
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.play_arrow),
                  onPressed: startTimer,
                  label: Text("Start"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: IconButton(
                    onPressed: resetTimer,
                    icon: Icon(Icons.refresh),
                    color: Colors.white,
                    iconSize: 28,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(int minutes) {
    final active = selectMinutes == minutes;
    return GestureDetector(
      onTap: () {
        selectDuration(minutes);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8.0),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.black12,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Text(
          "${minutes}m",
          style: TextStyle(
            color: active ? Colors.deepPurple : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

Widget _box(String text) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white12),
    ),
    child: InkWell(
      onTap: () {
        print("Box tapped");
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text, style: TextStyle(color: Colors.white)),
          Icon(Icons.arrow_drop_down, color: Colors.white),
        ],
      ),
    ),
  );
}
