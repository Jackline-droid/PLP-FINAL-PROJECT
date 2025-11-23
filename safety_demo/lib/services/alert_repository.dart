import 'package:hive_flutter/hive_flutter.dart';
import '../models/alert_model.dart';

class AlertRepository {
  static const String _boxName = 'alerts';

  static Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(AlertModelAdapter());
    }
  }

  static Future<Box<AlertModel>> getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox<AlertModel>(_boxName);
    }
    return Hive.box<AlertModel>(_boxName);
  }

  static Future<void> saveAlert(AlertModel alert) async {
    final box = await getBox();
    await box.put(alert.id, alert);
  }

  static Future<List<AlertModel>> getAllAlerts() async {
    final box = await getBox();
    return box.values.toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  static Future<AlertModel?> getAlertById(String id) async {
    final box = await getBox();
    return box.get(id);
  }

  static Future<void> updateAlertStatus(String id, String status) async {
    final box = await getBox();
    final alert = box.get(id);
    if (alert != null) {
      final updatedAlert = AlertModel(
        id: alert.id,
        timestamp: alert.timestamp,
        latitude: alert.latitude,
        longitude: alert.longitude,
        fuzzedLatitude: alert.fuzzedLatitude,
        fuzzedLongitude: alert.fuzzedLongitude,
        status: status,
        message: alert.message,
      );
      await box.put(id, updatedAlert);
    }
  }
}

