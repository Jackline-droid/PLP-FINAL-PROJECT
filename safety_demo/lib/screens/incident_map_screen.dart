import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/incident_model.dart';
import '../services/location_service.dart';
import '../services/incident_repository.dart';

class IncidentMapScreen extends StatefulWidget {
  const IncidentMapScreen({super.key});

  @override
  State<IncidentMapScreen> createState() => _IncidentMapScreenState();
}

class _IncidentMapScreenState extends State<IncidentMapScreen> {
  Position? _currentPosition;
  List<IncidentModel> _incidents = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadIncidents();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final position = await LocationService.getCurrentLocation();
      if (position != null) {
        setState(() {
          _currentPosition = position;
        });
      } else {
        setState(() {
          _errorMessage = 'Could not get location. Please enable location permissions.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error getting location: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadIncidents() async {
    final incidents = await IncidentRepository.getAllIncidents();
    setState(() {
      _incidents = incidents;
    });
  }

  Future<void> _createIncidentFromCurrentLocation() async {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please wait for location to be determined')),
      );
      return;
    }

    final fuzzed = LocationService.fuzzifyLocation(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
    );

    final incident = IncidentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      latitude: _currentPosition!.latitude,
      longitude: _currentPosition!.longitude,
      fuzzedLatitude: fuzzed['latitude']!,
      fuzzedLongitude: fuzzed['longitude']!,
      type: 'manual',
      description: 'Manual incident report',
    );

    await IncidentRepository.saveIncident(incident);
    await _loadIncidents();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incident saved successfully')),
      );
    }
  }

  // Map coordinates to pixel positions on a mock map
  // This is a simplified mapping - in reality, you'd use proper map projection
  Offset _coordinateToPixel(double lat, double lon, Size mapSize) {
    // Mock city bounds (adjust these to match your static map image)
    const double minLat = 40.0;
    const double maxLat = 41.0;
    const double minLon = -74.0;
    const double maxLon = -73.0;

    // Normalize coordinates to 0-1 range
    final normalizedLat = (lat - minLat) / (maxLat - minLat);
    final normalizedLon = (lon - minLon) / (maxLon - minLon);

    // Convert to pixel coordinates (flip Y axis for screen coordinates)
    final x = normalizedLon * mapSize.width;
    final y = (1 - normalizedLat) * mapSize.height;

    return Offset(x, y);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Incident Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _getCurrentLocation();
              _loadIncidents();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null && _currentPosition == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_off, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _getCurrentLocation,
                        child: const Text('Request Location Permission'),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    // Mock map background (using a colored container with grid)
                    // Supports static map image if available at assets/images/mock_map.png
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                      ),
                      child: Image.asset(
                        'assets/images/mock_map.png',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback to grid if image not found
                          return CustomPaint(
                            painter: GridPainter(),
                          );
                        },
                      ),
                    ),
                    // Overlay markers
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final mapSize = Size(
                          constraints.maxWidth,
                          constraints.maxHeight,
                        );
                        return Stack(
                          children: [
                            // Current location marker
                            if (_currentPosition != null)
                              Positioned(
                                left: _coordinateToPixel(
                                  _currentPosition!.latitude,
                                  _currentPosition!.longitude,
                                  mapSize,
                                ).dx -
                                    12,
                                top: _coordinateToPixel(
                                  _currentPosition!.latitude,
                                  _currentPosition!.longitude,
                                  mapSize,
                                ).dy -
                                    12,
                                child: const Icon(
                                  Icons.my_location,
                                  color: Colors.blue,
                                  size: 24,
                                ),
                              ),
                            // Incident markers (using fuzzed coordinates)
                            ..._incidents.map((incident) {
                              final pos = _coordinateToPixel(
                                incident.fuzzedLatitude,
                                incident.fuzzedLongitude,
                                mapSize,
                              );
                              return Positioned(
                                left: pos.dx - 10,
                                top: pos.dy - 10,
                                child: GestureDetector(
                                  onTap: () {
                                    _showIncidentDetails(incident);
                                  },
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: _getIncidentColor(incident.type),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.location_on,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        );
                      },
                    ),
                    // Info panel
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Incidents: ${_incidents.length}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_currentPosition != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Your Location: ${_currentPosition!.latitude.toStringAsFixed(6)}, ${_currentPosition!.longitude.toStringAsFixed(6)}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createIncidentFromCurrentLocation,
        icon: const Icon(Icons.add_location),
        label: const Text('Report Incident'),
      ),
    );
  }


  Color _getIncidentColor(String type) {
    switch (type) {
      case 'panic':
        return Colors.red;
      case 'emergency':
        return Colors.orange;
      case 'manual':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _showIncidentDetails(IncidentModel incident) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Incident ${incident.type.toUpperCase()}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Time: ${_formatDateTime(incident.timestamp)}'),
            const SizedBox(height: 8),
            Text('Real Location: ${incident.latitude.toStringAsFixed(6)}, ${incident.longitude.toStringAsFixed(6)}'),
            const SizedBox(height: 8),
            Text('Fuzzed Location: ${incident.fuzzedLatitude.toStringAsFixed(6)}, ${incident.fuzzedLongitude.toStringAsFixed(6)}'),
            if (incident.description != null) ...[
              const SizedBox(height: 8),
              Text('Description: ${incident.description}'),
            ],
            const SizedBox(height: 8),
            Text('Status: ${incident.status}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

// Grid painter for mock map background
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1;

    const gridSpacing = 50.0;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += gridSpacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += gridSpacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

