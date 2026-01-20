import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for DateFormat
import '../../domain/entities/sensor_data_entity.dart';

class SensorChart extends StatelessWidget {
  final String title;
  final List<SensorData> data;
  final bool isTemperature;
  final Color lineColor;

  const SensorChart({
    super.key,
    required this.title,
    required this.data,
    required this.isTemperature,
    required this.lineColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: data.isEmpty
                  ? const Center(child: Text("Waiting for data..."))
                  : LineChart(
                      LineChartData(
                        // 1. TOOLTIP SETUP (Hover Effect)
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipColor: (touchedSpot) => Colors.blueGrey,
                            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                              return touchedBarSpots.map((barSpot) {
                                // Get time for this spot
                                final index = barSpot.x.toInt();
                                final date = data[index].timestamp;
                                final timeStr = DateFormat(
                                  'HH:mm:ss',
                                ).format(date);

                                return LineTooltipItem(
                                  // Show Time AND Value
                                  "$timeStr\n${barSpot.y.toStringAsFixed(1)}",
                                  const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }).toList();
                            },
                          ),
                        ),

                        gridData: const FlGridData(show: true),

                        // 2. AXIS TITLES SETUP
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true, // Enable X-Axis Labels
                              reservedSize: 30, // Space for text
                              // Logic to prevent overcrowding labels
                              // If we have 100 points, show label every 20 points.
                              // If we have 10 points, show label every 2 points.
                              interval: data.length > 5
                                  ? (data.length / 5).floorToDouble()
                                  : 1.0,

                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                // Safety check
                                if (index >= 0 && index < data.length) {
                                  final date = data[index].timestamp;
                                  // Format: "14:30"
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      DateFormat('HH:mm').format(date),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),

                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.5),
                          ),
                        ),
                        minY: 0,
                        maxY: isTemperature ? 50 : 100,
                        lineBarsData: [
                          LineChartBarData(
                            spots: data.asMap().entries.map((e) {
                              return FlSpot(
                                e.key.toDouble(),
                                isTemperature
                                    ? e.value.temperature
                                    : e.value.humidity,
                              );
                            }).toList(),
                            isCurved: true,
                            color: lineColor,
                            barWidth: 3,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: lineColor.withOpacity(0.2),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
