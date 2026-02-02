import '../../domain/entities/config_entities.dart';

class ThresholdsModel extends ThresholdsEntity {
  ThresholdsModel({
    required super.subTemp,
    required super.thresTemp,
    required super.subHum,
    required super.thresHum,
  });

  // MAP JSON (snake_case from FastAPI) -> DART (camelCase)
  factory ThresholdsModel.fromJson(Map<String, dynamic> json) {
    return ThresholdsModel(
      subTemp: json['temp_min']?.toDouble() ?? 0.0,
      thresTemp: json['temp_max']?.toDouble() ?? 0.0,
      subHum: json['humidity_min']?.toDouble() ?? 0.0,
      thresHum: json['humidity_max']?.toDouble() ?? 0.0,
    );
  }

  // MAP DART -> JSON (for PUT request)
  Map<String, dynamic> toJson() {
    return {
      'temp_min': subTemp,
      'temp_max': thresTemp,
      'humidity_min': subHum,
      'humidity_max': thresHum,
    };
  }
}
