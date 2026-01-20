import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class SensorGauge extends StatelessWidget {
  final String title;
  final double value;
  final double minThreshold; // Start of Orange Zone
  final double maxThreshold; // Start of Red Zone
  final double axisMax; // Max value on dial
  final String unit;

  const SensorGauge({
    super.key,
    required this.title,
    required this.value,
    required this.minThreshold,
    required this.maxThreshold,
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
          height: 150,
          width: 150,

          child: SfRadialGauge(
            axes: <RadialAxis>[
              RadialAxis(
                minimum: 0,
                maximum: axisMax,
                showLabels: false,
                showTicks: false,
                startAngle: 180,
                endAngle: 0,
                canScaleToFit: true,
                axisLineStyle: const AxisLineStyle(
                  thickness: 0.2,
                  thicknessUnit: GaugeSizeUnit.factor,
                  cornerStyle: CornerStyle.bothCurve,
                ),
                ranges: <GaugeRange>[
                  // Green Zone
                  GaugeRange(
                    startValue: 0,
                    endValue: minThreshold,
                    color: Colors.greenAccent,
                    startWidth: 0.2,
                    endWidth: 0.2,
                    sizeUnit: GaugeSizeUnit.factor,
                  ),
                  // Orange Zone
                  GaugeRange(
                    startValue: minThreshold,
                    endValue: maxThreshold,
                    color: Colors.orangeAccent,
                    startWidth: 0.2,
                    endWidth: 0.2,
                    sizeUnit: GaugeSizeUnit.factor,
                  ),
                  // Red Zone
                  GaugeRange(
                    startValue: maxThreshold,
                    endValue: axisMax,
                    color: Colors.redAccent,
                    startWidth: 0.2,
                    endWidth: 0.2,
                    sizeUnit: GaugeSizeUnit.factor,
                  ),
                ],
                pointers: <GaugePointer>[
                  // UPDATED NEEDLE STYLE
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
                            fontSize: 22,
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
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
