import 'dart:math'; // Import math for PI
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class SensorGauge extends StatelessWidget {
  final String title;
  final double value;
  final double subThreshold;
  final double threshold;
  final double axisMax;
  final String unit;

  const SensorGauge({
    super.key,
    required this.title,
    required this.value,
    required this.subThreshold,
    required this.threshold,
    required this.axisMax,
    required this.unit,
  });

  // Helper to calculate the rotation angle in Radians
  double _getRotationAngle(double currentValue) {
    // 1. Define gauge constraints (Must match RadialAxis)
    const double startAngle = 160;
    const double endAngle = 20;

    // 2. Calculate Total Sweep Angle
    // Logic: 160 -> 360 is 200 deg. 0 -> 20 is 20 deg. Total = 220.
    const double totalSweep = (360 - startAngle) + endAngle;

    // 3. Calculate current angle in degrees based on value
    final double currentAngleDegree =
        startAngle + (currentValue / axisMax) * totalSweep;

    // 4. Convert to Radians and adjust by +90 degrees
    // We add 90 degrees so the bottom of the text points towards the center
    return (currentAngleDegree + 90) * (pi / 180);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 250,
          width: 250,
          child: SfRadialGauge(
            axes: <RadialAxis>[
              RadialAxis(
                minimum: 0,
                maximum: axisMax,
                showLabels: false,
                showTicks: false,
                startAngle: 160,
                endAngle: 20,
                canScaleToFit: true,
                axisLineStyle: const AxisLineStyle(
                  thickness: 0.2,
                  thicknessUnit: GaugeSizeUnit.factor,
                ),
                ranges: <GaugeRange>[
                  GaugeRange(
                    startValue: 0,
                    endValue: subThreshold,
                    startWidth: 0.2,
                    endWidth: 0.2,
                    sizeUnit: GaugeSizeUnit.factor,
                    color: Colors.greenAccent,
                  ),
                  GaugeRange(
                    startValue: subThreshold,
                    endValue: threshold,
                    startWidth: 0.2,
                    endWidth: 0.2,
                    sizeUnit: GaugeSizeUnit.factor,
                    color: Colors.orangeAccent,
                  ),
                  GaugeRange(
                    startValue: threshold,
                    endValue: axisMax,
                    startWidth: 0.2,
                    endWidth: 0.2,
                    sizeUnit: GaugeSizeUnit.factor,
                    color: Colors.redAccent,
                  ),
                ],
                pointers: <GaugePointer>[
                  // 1. NEEDLE
                  NeedlePointer(
                    value: value,
                    needleColor: Colors.white,
                    tailStyle: const TailStyle(
                      length: 0.15,
                      width: 5,
                      color: Colors.white,
                    ),
                    needleLength: 0.6,
                    needleStartWidth: 1,
                    needleEndWidth: 4,
                    knobStyle: const KnobStyle(
                      knobRadius: 0.05,
                      color: Colors.white,
                      borderColor: Colors.white,
                      borderWidth: 0.02,
                    ),
                    animationType: AnimationType.ease,
                    enableAnimation: true,
                  ),

                  // --- SUB-THRESHOLD (Orange) ---

                  // 2. Triangle (Auto-rotates)
                  MarkerPointer(
                    value: subThreshold,
                    markerType: MarkerType.invertedTriangle,
                    markerHeight: 12,
                    markerWidth: 12,
                    color: Colors.orangeAccent,
                    markerOffset: -25,
                  ),

                  // 3. Text (Manually Rotated)
                  WidgetPointer(
                    value: subThreshold,
                    offset: -45, // Push further out
                    child: Transform.rotate(
                      angle: _getRotationAngle(subThreshold),
                      child: Text(
                        subThreshold.toStringAsFixed(0),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // --- THRESHOLD (Red) ---

                  // 4. Triangle
                  MarkerPointer(
                    value: threshold,
                    markerType: MarkerType.invertedTriangle,
                    markerHeight: 12,
                    markerWidth: 12,
                    color: Colors.redAccent,
                    markerOffset: -25,
                  ),

                  // 5. Text (Manually Rotated)
                  WidgetPointer(
                    value: threshold,
                    offset: -45,
                    child: Transform.rotate(
                      angle: _getRotationAngle(threshold),
                      child: Text(
                        threshold.toStringAsFixed(0),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
                annotations: <GaugeAnnotation>[
                  GaugeAnnotation(
                    widget: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          value.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            unit,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    angle: 90,
                    positionFactor: 0.6,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white54,
          ),
        ),
      ],
    );
  }
}
