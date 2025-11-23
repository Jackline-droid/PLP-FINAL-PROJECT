import 'package:hive/hive.dart';

part 'incident_model.g.dart';

@HiveType(typeId: 2)
class IncidentModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime timestamp;

  @HiveField(2)
  final double latitude;

  @HiveField(3)
  final double longitude;

  @HiveField(4)
  final double fuzzedLatitude;

  @HiveField(5)
  final double fuzzedLongitude;

  @HiveField(6)
  final String type; // 'panic', 'manual', 'emergency'

  @HiveField(7)
  final String? description;

  @HiveField(8)
  final String status; // 'active', 'resolved', 'archived'

  IncidentModel({
    required this.id,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.fuzzedLatitude,
    required this.fuzzedLongitude,
    required this.type,
    this.description,
    this.status = 'active',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'fuzzedLatitude': fuzzedLatitude,
      'fuzzedLongitude': fuzzedLongitude,
      'type': type,
      'description': description,
      'status': status,
    };
  }

  factory IncidentModel.fromJson(Map<String, dynamic> json) {
    return IncidentModel(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      latitude: json['latitude'],
      longitude: json['longitude'],
      fuzzedLatitude: json['fuzzedLatitude'],
      fuzzedLongitude: json['fuzzedLongitude'],
      type: json['type'],
      description: json['description'],
      status: json['status'],
    );
  }
}

