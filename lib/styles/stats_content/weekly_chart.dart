import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class WeeklyChart extends StatelessWidget {
  const WeeklyChart({super.key});

  @override
  Widget build(BuildContext context) {
    final days = ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'];

    return Padding(
      padding: EdgeInsets.only(right: 15,top: 12),
      child: SizedBox(
        height: 220,
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: 6,
            minY: 0,
            maxY: 4,

            // 👉 vertical grid line (grey strip feel)
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              verticalInterval: 1,
              getDrawingVerticalLine: (value) {
                return FlLine(
                  color: Colors.grey.withOpacity(0.2),
                  strokeWidth: 1,
                );
              },
              drawHorizontalLine: true,
              horizontalInterval: 1,
            ),

            // 👉 Tooltip
            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    return LineTooltipItem(
                      "${days[spot.x.toInt()]}\nhours : ${spot.y.toInt()}",
                      const TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }).toList();
                },
              ),
              getTouchedSpotIndicator: (barData, spotIndexes) {
                return spotIndexes.map((index) {
                  return TouchedSpotIndicatorData(
                    FlLine(
                      color: Colors.grey.withOpacity(0.4),
                      strokeWidth: 8, // 👈 wide vertical bar
                    ),
                    FlDotData(show: false),
                  );
                }).toList();
              },
            ),

            titlesData: FlTitlesData(
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  reservedSize: 28,
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    if (value % 1 != 0) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(days[value.toInt()]),
                    );
                  },
                ),
              ),
            ),

            borderData: FlBorderData(
              show: true,
              border: Border(
                left: BorderSide(color: Colors.grey.shade400),
                bottom: BorderSide(color: Colors.grey.shade400),
              ),
            ),

            lineBarsData: [
              LineChartBarData(
                isCurved: true,
                color: Colors.blue,
                barWidth: 3,
                dotData: FlDotData(show: true),
                spots: const [
                  FlSpot(0, 1),
                  FlSpot(1, 2),
                  FlSpot(2, 1.5),
                  FlSpot(3, 3),
                  FlSpot(4, 2),
                  FlSpot(5, 2.2),
                  FlSpot(6, 2.8),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
