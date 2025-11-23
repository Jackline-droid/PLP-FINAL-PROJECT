import 'package:hive_flutter/hive_flutter.dart';
import '../models/incident_model.dart';

class IncidentRepository {
  static const String _boxName = 'incidents';

  static Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(IncidentModelAdapter());
    }
  }

  static Future<Box<IncidentModel>> getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox<IncidentModel>(_boxName);
    }
    return Hive.box<IncidentModel>(_boxName);
  }

  static Future<void> saveIncident(IncidentModel incident) async {
    final box = await getBox();
    await box.put(incident.id, incident);
  }

  static Future<List<IncidentModel>> getAllIncidents() async {
    final box = await getBox();
    return box.values.toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  static Future<List<IncidentModel>> getActiveIncidents() async {
    final allIncidents = await getAllIncidents();
    return allIncidents.where((incident) => incident.status == 'active').toList();
  }

  static Future<IncidentModel?> getIncidentById(String id) async {
    final box = await getBox();
    return box.get(id);
  }

  static Future<void> updateIncidentStatus(String id, String status) async {
    final box = await getBox();
    final incident = box.get(id);
    if (incident != null) {
      final updatedIncident = IncidentModel(
        id: incident.id,
        timestamp: incident.timestamp,
        latitude: incident.latitude,
        longitude: incident.longitude,
        fuzzedLatitude: incident.fuzzedLatitude,
        fuzzedLongitude: incident.fuzzedLongitude,
        type: incident.type,
        description: incident.description,
        status: status,
      );
      await box.put(id, updatedIncident);
    }
  }
}

