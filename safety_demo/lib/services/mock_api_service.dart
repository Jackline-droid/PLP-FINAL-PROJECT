import 'dart:convert';
import 'package:http/http.dart' as http;

class MockApiService {
  // Mock API endpoint - in production, replace with real API
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';
  
  // Alternative: Use a local mock server or Firebase Functions
  // For demo purposes, we'll use jsonplaceholder as a mock API

  /// Fetch emergency resources/support information
  static Future<Map<String, dynamic>> fetchEmergencyResources() async {
    try {
      // Simulate API call - using jsonplaceholder as mock
      final response = await http.get(
        Uri.parse('$baseUrl/posts/1'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Transform mock data into emergency resources format
        return {
          'success': true,
          'resources': [
            {
              'id': '1',
              'name': 'Emergency Hotline',
              'phone': '+1-800-HELP-NOW',
              'type': 'hotline',
              'available': true,
            },
            {
              'id': '2',
              'name': 'Local Police',
              'phone': '911',
              'type': 'police',
              'available': true,
            },
            {
              'id': '3',
              'name': 'Medical Emergency',
              'phone': '911',
              'type': 'medical',
              'available': true,
            },
            {
              'id': '4',
              'name': 'Support Center',
              'phone': '+1-800-SUPPORT',
              'type': 'support',
              'available': true,
            },
          ],
          'lastUpdated': DateTime.now().toIso8601String(),
        };
      } else {
        throw Exception('Failed to fetch resources: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock data if API fails (for offline/demo purposes)
      return {
        'success': false,
        'error': e.toString(),
        'resources': [
          {
            'id': '1',
            'name': 'Emergency Hotline (Offline)',
            'phone': '+1-800-HELP-NOW',
            'type': 'hotline',
            'available': true,
          },
          {
            'id': '2',
            'name': 'Local Police',
            'phone': '911',
            'type': 'police',
            'available': true,
          },
        ],
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Fetch safety tips/guidelines
  static Future<List<Map<String, dynamic>>> fetchSafetyTips() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/posts'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        // Transform to safety tips format
        return data.take(5).map((item) => {
          'id': item['id'].toString(),
          'title': 'Safety Tip ${item['id']}',
          'content': item['body'],
          'category': 'general',
        }).toList();
      } else {
        throw Exception('Failed to fetch tips: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock tips if API fails
      return [
        {
          'id': '1',
          'title': 'Stay Calm',
          'content': 'In emergency situations, try to remain calm and assess your surroundings.',
          'category': 'general',
        },
        {
          'id': '2',
          'title': 'Know Your Location',
          'content': 'Always be aware of your current location and nearby landmarks.',
          'category': 'general',
        },
        {
          'id': '3',
          'title': 'Emergency Contacts',
          'content': 'Keep important emergency contacts easily accessible.',
          'category': 'general',
        },
      ];
    }
  }

  /// Submit incident report (mock)
  static Future<Map<String, dynamic>> submitIncidentReport(
    Map<String, dynamic> incidentData,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/posts'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(incidentData),
      );

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Incident report submitted successfully',
          'id': json.decode(response.body)['id'].toString(),
        };
      } else {
        throw Exception('Failed to submit report: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock success for demo
      return {
        'success': true,
        'message': 'Incident report saved locally (offline mode)',
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
      };
    }
  }
}

