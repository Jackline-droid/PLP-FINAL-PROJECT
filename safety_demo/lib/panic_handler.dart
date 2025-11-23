import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/location_service.dart';
import 'services/alert_repository.dart';
import 'services/incident_repository.dart';
import 'models/alert_model.dart';
import 'models/incident_model.dart';
import 'screens/safety_mode_screen.dart';

class PanicHandlerWidget extends StatefulWidget {
  const PanicHandlerWidget({super.key});

  @override
  State<PanicHandlerWidget> createState() => _PanicHandlerWidgetState();
}

class _PanicHandlerWidgetState extends State<PanicHandlerWidget> {
  static const platform = MethodChannel('com.example.safety_demo/panic_channel');

  String _panicStatus = "Waiting for panic trigger...";
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _setupPanicHandler();
  }

  Future<void> _initializeServices() async {
    if (_isInitialized) return;
    
    try {
      await AlertRepository.init();
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('Error initializing services: $e');
    }
  }

  void _setupPanicHandler() {
    platform.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'panicTriggered':
          await _handlePanicTriggered();
          return "Panic handled by Flutter!";
        default:
          debugPrint('Flutter received unknown method: ${call.method}');
          throw PlatformException(
              code: 'UNAVAILABLE',
              message: 'Method not implemented for Flutter.');
      }
    });
  }

  Future<void> _handlePanicTriggered() async {
    debugPrint('Flutter received: panicTriggered');
    
    setState(() {
      _panicStatus = "PANIC TRIGGERED! Processing...";
    });

    try {
      // Get current location
      final position = await LocationService.getCurrentLocation();
      
      double? latitude;
      double? longitude;
      double? fuzzedLatitude;
      double? fuzzedLongitude;

      if (position != null) {
        latitude = position.latitude;
        longitude = position.longitude;
        
        // Fuzzify location for privacy
        final fuzzed = LocationService.fuzzifyLocation(latitude, longitude);
        fuzzedLatitude = fuzzed['latitude'];
        fuzzedLongitude = fuzzed['longitude'];
      }

      // Create alert model
      final alert = AlertModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        latitude: latitude,
        longitude: longitude,
        fuzzedLatitude: fuzzedLatitude,
        fuzzedLongitude: fuzzedLongitude,
        status: 'triggered',
        message: 'Panic button activated',
      );

      // Save alert to local database
      await AlertRepository.saveAlert(alert);

      // Also create an incident record
      if (latitude != null && longitude != null) {
        final incident = IncidentModel(
          id: alert.id,
          timestamp: alert.timestamp,
          latitude: latitude,
          longitude: longitude,
          fuzzedLatitude: fuzzedLatitude!,
          fuzzedLongitude: fuzzedLongitude!,
          type: 'panic',
          description: 'Panic button activated',
          status: 'active',
        );
        await IncidentRepository.saveIncident(incident);
      }

      debugPrint('Alert saved: ${alert.id}');

      // Navigate to Safety Mode screen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => SafetyModeScreen(alert: alert),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error handling panic: $e');
      setState(() {
        _panicStatus = "Error: $e";
      });
    }
  }

  // Manual trigger for testing (button on UI)
  Future<void> _manualTrigger() async {
    await _handlePanicTriggered();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety Demo App'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.security,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              Text(
                _panicStatus,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 32),
              const Text(
                'Press volume button 3 times quickly to trigger panic mode',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isInitialized ? _manualTrigger : null,
                icon: const Icon(Icons.warning),
                label: const Text('Test Panic Button'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/chat');
                },
                icon: const Icon(Icons.chat),
                label: const Text('Open Chat'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
