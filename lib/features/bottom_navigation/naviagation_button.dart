import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const CustomBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  Widget _navItem(
      IconData icon, String label, int index) {
    final bool isActive = selectedIndex == index;

    return GestureDetector(
      onTap: () => onItemSelected(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFF7F3DFF).withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 22,
              color: isActive
                  ? const Color(0xFF7F3DFF)
                  : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isActive
                  ? const Color(0xFF7F3DFF)
                  : Colors.grey,
              fontWeight:
              isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home, "Home", 0),
            _navItem(Icons.calendar_month, "Schedule", 1),
            _navItem(Icons.punch_clock, "Focus", 2),
            _navItem(Icons.task, "Tasks", 3),
            _navItem(Icons.show_chart, "Stats", 4),
          ],
        ),
      ),
    );
  }
}
