import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'firebase_options.dart';
import 'panic_handler.dart';
import 'screens/chat_screen.dart';
import 'screens/safety_mode_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/incident_map_screen.dart';
import 'services/alert_repository.dart';
import 'services/chat_repository.dart';
import 'services/incident_repository.dart';
import 'models/alert_model.dart';
import 'models/chat_message_model.dart';
import 'models/incident_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive adapters
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(AlertModelAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(ChatMessageModelAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(IncidentModelAdapter());
  }
  
  // Initialize repositories
  await AlertRepository.init();
  await ChatRepository.init();
  await IncidentRepository.init();
  
  runApp(const SafetyDemoApp());
}

class SafetyDemoApp extends StatelessWidget {
  const SafetyDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Safety Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Show loading while checking auth state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          // If user is logged in, show dashboard; otherwise show auth screen
          if (snapshot.hasData) {
            return const DashboardScreen();
          } else {
            return const AuthScreen();
          }
        },
      ),
      routes: {
        '/auth': (context) => const AuthScreen(),
        '/home': (context) => const DashboardScreen(),
        '/panic': (context) => const PanicHandlerWidget(),
        '/chat': (context) => const ChatScreen(),
        '/map': (context) => const IncidentMapScreen(),
      },
      onGenerateRoute: (settings) {
        // Handle SafetyModeScreen with alert parameter
        if (settings.name == '/safety' && settings.arguments is AlertModel) {
          return MaterialPageRoute(
            builder: (context) => SafetyModeScreen(alert: settings.arguments as AlertModel),
          );
        }
        return null;
      },
    );
  }
}
