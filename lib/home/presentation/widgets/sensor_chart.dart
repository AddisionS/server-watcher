import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
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
            AspectRatio(
              aspectRatio: 1.70,
              child: data.isEmpty
                  ? const Center(child: Text("Waiting for data..."))
                  : LineChart(
                      LineChartData(
                        // --- NEW CODE START ---
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipItems:
                                (List<LineBarSpot> touchedBarSpots) {
                                  return touchedBarSpots.map((barSpot) {
                                    return LineTooltipItem(
                                      // The text to display (Value)
                                      barSpot.y.toStringAsFixed(1),
                                      const TextStyle(
                                        color: Colors
                                            .white, // <--- TEXT COLOR IS HERE
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  }).toList();
                                },
                          ),
                        ),

                        // --- NEW CODE END ---
                        gridData: const FlGridData(show: true),
                        titlesData: const FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
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
