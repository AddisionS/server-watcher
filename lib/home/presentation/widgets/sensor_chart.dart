import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    final theme = Theme.of(context);

    // Removed elevation and shape so it inherits the global AppTheme Card style
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(
          24.0,
        ), // Increased padding for premium feel
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 20),
            Expanded(
              child: data.isEmpty
                  ? Center(
                      child: Text(
                        "Waiting for data...",
                        style: theme.textTheme.bodyMedium,
                      ),
                    )
                  : LineChart(
                      LineChartData(
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipColor: (touchedSpot) =>
                                theme.colorScheme.outline,
                            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                              return touchedBarSpots.map((barSpot) {
                                final index = barSpot.x.toInt();
                                final date = data[index].timestamp;
                                final timeStr = DateFormat(
                                  'HH:mm',
                                ).format(date);
                                return LineTooltipItem(
                                  "Time: $timeStr\n Val: ${barSpot.y.toStringAsFixed(1)}",
                                  TextStyle(
                                    color: theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }).toList();
                            },
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: theme.colorScheme.outline.withValues(
                              alpha: 0.5,
                            ),
                            strokeWidth: 1,
                            dashArray: [5, 5],
                          ),
                        ),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              interval: data.length > 5
                                  ? (data.length / 5).floorToDouble()
                                  : 1.0,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index >= 0 && index < data.length) {
                                  final date = data[index].timestamp;
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      DateFormat('HH:mm').format(date),
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(fontSize: 10),
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: 10,
                                  ),
                                );
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
                        borderData: FlBorderData(show: false),
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
                              color: lineColor.withValues(alpha: 0.1),
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
