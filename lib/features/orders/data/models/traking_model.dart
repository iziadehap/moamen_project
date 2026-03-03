import 'package:latlong2/latlong.dart';

class BatteryLevelTime {
  final int batteryLevel;
  final DateTime time;
  final LatLng location;

  BatteryLevelTime({
    required this.batteryLevel,
    required this.time,
    required this.location,
  });

  factory BatteryLevelTime.fromJson(Map<String, dynamic> json) {
    return BatteryLevelTime(
      batteryLevel: json['battery_level'] as int,
      time: DateTime.parse(json['time'] as String),
      location: LatLng(
        (json['location']['lat'] as num).toDouble(),
        (json['location']['lng'] as num).toDouble(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'battery_level': batteryLevel,
      'time': time.toIso8601String(),
      'location': {'lat': location.latitude, 'lng': location.longitude},
    };
  }

  BatteryLevelTime copyWith({
    int? batteryLevel,
    DateTime? time,
    LatLng? location,
  }) {
    return BatteryLevelTime(
      batteryLevel: batteryLevel ?? this.batteryLevel,
      time: time ?? this.time,
      location: location ?? this.location,
    );
  }
}

class TrakingModel {
  final String id;
  final List<String> ordersId;
  final List<BatteryLevelTime> batteryLevelTimes;

  TrakingModel({
    required this.id,
    required this.ordersId,
    required this.batteryLevelTimes,
  });

  factory TrakingModel.fromJson(Map<String, dynamic> json) {
    return TrakingModel(
      id: json['id'] as String,
      ordersId: (json['orders_id'] as List<dynamic>).cast<String>(),
      batteryLevelTimes: (json['battery_level_times'] as List<dynamic>)
          .map((e) => BatteryLevelTime.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orders_id': ordersId,
      'battery_level_times': batteryLevelTimes.map((e) => e.toJson()).toList(),
    };
  }

  TrakingModel copyWith({
    String? id,
    List<String>? ordersId,
    List<BatteryLevelTime>? batteryLevelTimes,
  }) {
    return TrakingModel(
      id: id ?? this.id,
      ordersId: ordersId ?? this.ordersId,
      batteryLevelTimes: batteryLevelTimes ?? this.batteryLevelTimes,
    );
  }
}
