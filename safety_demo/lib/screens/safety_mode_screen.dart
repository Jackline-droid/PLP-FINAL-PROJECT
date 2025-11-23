import 'package:flutter/material.dart';
import '../models/alert_model.dart';

class SafetyModeScreen extends StatelessWidget {
  final AlertModel alert;

  const SafetyModeScreen({
    super.key,
    required this.alert,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      appBar: AppBar(
        title: const Text('Safety Mode'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // Prevent back button
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 80,
                color: Colors.red,
              ),
              const SizedBox(height: 24),
              const Text(
                'EMERGENCY ALERT ACTIVATED',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Alert Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow('Time', _formatTime(alert.timestamp)),
                      if (alert.latitude != null && alert.longitude != null) ...[
                        const SizedBox(height: 8),
                        _buildDetailRow('Location', 
                          '${alert.latitude!.toStringAsFixed(6)}, ${alert.longitude!.toStringAsFixed(6)}'),
                      ],
                      if (alert.fuzzedLatitude != null && alert.fuzzedLongitude != null) ...[
                        const SizedBox(height: 8),
                        _buildDetailRow('Fuzzed Location', 
                          '${alert.fuzzedLatitude!.toStringAsFixed(6)}, ${alert.fuzzedLongitude!.toStringAsFixed(6)}'),
                      ],
                      const SizedBox(height: 8),
                      _buildDetailRow('Status', alert.status.toUpperCase()),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Your location has been logged and encrypted.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  // Navigate to chat screen
                  Navigator.pushNamed(context, '/chat');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Open Emergency Chat'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  // Exit safety mode (in production, this might require authentication)
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Exit Safety Mode'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} - ${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}

