import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class SensorGauge extends StatelessWidget {
  final String title;
  final double value;
  final double subThreshold; // Start of Orange Zone
  final double threshold; // Start of Red Zone
  final double axisMax; // Max value on dial
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

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. The Gauge (Top)
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
                  // Green Zone
                  GaugeRange(
                    startValue: 0,
                    endValue: subThreshold,
                    startWidth: 0.2,
                    endWidth: 0.2,
                    sizeUnit: GaugeSizeUnit.factor,
                    color: Colors.greenAccent,
                  ),
                  // Orange Zone
                  GaugeRange(
                    startValue: subThreshold,
                    endValue: threshold,
                    startWidth: 0.2,
                    endWidth: 0.2,
                    sizeUnit: GaugeSizeUnit.factor,
                    color: Colors.orangeAccent,
                  ),
                  // Red Zone
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
                  NeedlePointer(
                    value: value,
                    needleColor: Colors.white,
                    tailStyle: const TailStyle(
                      length: 0.15, // Shorter tail
                      width: 5,
                      color: Colors.white,
                    ),
                    needleLength: 0.6,
                    needleStartWidth: 1,
                    needleEndWidth: 4, // Thinner needle
                    knobStyle: const KnobStyle(
                      knobRadius: 0.05, // Smaller knob
                      color: Colors.white,
                      borderColor: Colors.white,
                      borderWidth: 0.02,
                    ),
                    animationType: AnimationType.ease,
                    enableAnimation: true,
                  ),
                ],
                annotations: <GaugeAnnotation>[
                  // Value Text inside the gauge
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
                    positionFactor:
                        0.6, // Moved slightly lower to clear the needle
                  ),
                ],
              ),
            ],
          ),
        ),

        // 2. The Title (Bottom)
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
