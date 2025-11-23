import 'package:hive/hive.dart';

part 'alert_model.g.dart';

@HiveType(typeId: 0)
class AlertModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime timestamp;

  @HiveField(2)
  final double? latitude;

  @HiveField(3)
  final double? longitude;

  @HiveField(4)
  final double? fuzzedLatitude;

  @HiveField(5)
  final double? fuzzedLongitude;

  @HiveField(6)
  final String status; // 'triggered', 'sent', 'acknowledged'

  @HiveField(7)
  final String? message;

  AlertModel({
    required this.id,
    required this.timestamp,
    this.latitude,
    this.longitude,
    this.fuzzedLatitude,
    this.fuzzedLongitude,
    this.status = 'triggered',
    this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'fuzzedLatitude': fuzzedLatitude,
      'fuzzedLongitude': fuzzedLongitude,
      'status': status,
      'message': message,
    };
  }

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      latitude: json['latitude'],
      longitude: json['longitude'],
      fuzzedLatitude: json['fuzzedLatitude'],
      fuzzedLongitude: json['fuzzedLongitude'],
      status: json['status'],
      message: json['message'],
    );
  }
}

