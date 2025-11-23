import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/alert_model.dart';
import '../models/incident_model.dart';
import '../services/alert_repository.dart';
import '../services/incident_repository.dart';
import '../services/mock_api_service.dart';
import '../panic_handler.dart';
import 'chat_screen.dart';
import 'incident_map_screen.dart';
import 'safety_mode_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> _emergencyResources = [];
  bool _isLoadingResources = false;

  @override
  void initState() {
    super.initState();
    _loadEmergencyResources();
  }

  Future<void> _loadEmergencyResources() async {
    setState(() {
      _isLoadingResources = true;
    });

    try {
      final response = await MockApiService.fetchEmergencyResources();
      if (response['success'] == true) {
        setState(() {
          _emergencyResources = List<Map<String, dynamic>>.from(response['resources']);
        });
      }
    } catch (e) {
      debugPrint('Error loading resources: $e');
    } finally {
      setState(() {
        _isLoadingResources = false;
      });
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadEmergencyResources,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome card
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.person, size: 48, color: Colors.blue),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome, ${user?.email ?? 'User'}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text('Stay safe and secure'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Quick actions
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      icon: Icons.warning,
                      title: 'Panic',
                      color: Colors.red,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PanicHandlerWidget(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionCard(
                      icon: Icons.map,
                      title: 'Map',
                      color: Colors.blue,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const IncidentMapScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      icon: Icons.chat,
                      title: 'Chat',
                      color: Colors.green,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChatScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionCard(
                      icon: Icons.history,
                      title: 'History',
                      color: Colors.orange,
                      onTap: () {
                        _showHistory();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Recent alerts
              const Text(
                'Recent Alerts',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              FutureBuilder<List<AlertModel>>(
                future: AlertRepository.getAllAlerts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final alerts = snapshot.data ?? [];
                  if (alerts.isEmpty) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No alerts yet'),
                      ),
                    );
                  }

                  return Column(
                    children: alerts.take(3).map((alert) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(Icons.warning, color: Colors.red),
                          title: Text('Alert - ${alert.status}'),
                          subtitle: Text(
                            '${alert.timestamp.day}/${alert.timestamp.month}/${alert.timestamp.year} ${alert.timestamp.hour}:${alert.timestamp.minute.toString().padLeft(2, '0')}',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SafetyModeScreen(alert: alert),
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Emergency resources
              const Text(
                'Emergency Resources',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (_isLoadingResources)
                const Center(child: CircularProgressIndicator())
              else if (_emergencyResources.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No resources available'),
                  ),
                )
              else
                ..._emergencyResources.map((resource) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(
                        _getResourceIcon(resource['type']),
                        color: Colors.red,
                      ),
                      title: Text(resource['name']),
                      subtitle: Text(resource['phone']),
                      trailing: IconButton(
                        icon: const Icon(Icons.phone),
                        onPressed: () {
                          // In production, this would dial the number
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Calling ${resource['phone']}'),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getResourceIcon(String type) {
    switch (type) {
      case 'hotline':
        return Icons.phone;
      case 'police':
        return Icons.local_police;
      case 'medical':
        return Icons.medical_services;
      case 'support':
        return Icons.support_agent;
      default:
        return Icons.info;
    }
  }

  void _showHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Incident History',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<IncidentModel>>(
                future: IncidentRepository.getAllIncidents(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final incidents = snapshot.data ?? [];
                  if (incidents.isEmpty) {
                    return const Center(
                      child: Text('No incidents recorded'),
                    );
                  }

                  return ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: incidents.length,
                    itemBuilder: (context, index) {
                      final incident = incidents[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Icon(
                            Icons.location_on,
                            color: _getIncidentColor(incident.type),
                          ),
                          title: Text('${incident.type.toUpperCase()} Incident'),
                          subtitle: Text(
                            '${incident.timestamp.day}/${incident.timestamp.month}/${incident.timestamp.year}',
                          ),
                          trailing: Chip(
                            label: Text(incident.status),
                            backgroundColor: incident.status == 'active'
                                ? Colors.red.shade100
                                : Colors.green.shade100,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
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
}

