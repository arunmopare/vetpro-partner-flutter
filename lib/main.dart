import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:vetpro/Constants/Constants.dart';
import 'package:vetpro/Pages/login_screen.dart';
import 'package:vetpro/Widgets/auth-guard.dart';
import 'package:workmanager/workmanager.dart';
import 'Pages/home_page.dart';
import 'Pages/profile_page.dart';
import 'State/vet_pro_state.dart';

void main() {
  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  runApp(ChangeNotifierProvider(
    create: (_) => VetProState(),
    child: VetProApp(),
  ));
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Task execution logic here
    if (task == "backgroundLocationTask") {
      await sendLocationToBackend();
    }
    return Future.value(true);
  });
}

Future<void> sendLocationToBackend() async {
  Location location = Location();

  bool serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await location.requestService();
    if (!serviceEnabled) return;
  }

  PermissionStatus permissionGranted = await location.hasPermission();
  if (permissionGranted == PermissionStatus.denied) {
    permissionGranted = await location.requestPermission();
    if (permissionGranted != PermissionStatus.granted) return;
  }

  LocationData locationData = await location.getLocation();

  // Send location data to backend
  final response = await http.post(
    Uri.parse(Constants.BASE_API_URL + '/location'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'latitude': locationData.latitude,
      'longitude': locationData.longitude,
      'timestamp': DateTime.now().toIso8601String(),
    }),
  );

  if (response.statusCode != 200) {
    print("Failed to send location: ${response.body}");
  }
}

class VetProApp extends StatefulWidget {
  const VetProApp({super.key});

  @override
  _VetProAppState createState() => _VetProAppState();
}

class _VetProAppState extends State<VetProApp> {
  late Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    // Initialize the future to load user details
    _loadFuture =
        Provider.of<VetProState>(context, listen: false).loadUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text('Error loading user details'),
              ),
            ),
          );
        }

        return Consumer<VetProState>(
          builder: (context, state, child) {
            return MaterialApp(
              title: 'VetPro',
              theme: ThemeData(
                primaryColor: Color(0xFFFF6600),
                colorScheme: ColorScheme.fromSwatch().copyWith(
                  primary: Color(0xFFFF6600),
                  secondary: Colors.white,
                ),
              ),
              initialRoute: state.isLoggedIn ? '/home' : '/login',
              routes: {
                '/login': (context) => LoginScreen(),
                '/home': (context) => AuthGuard(child: VetProHome()),
              },
            );
          },
        );
      },
    );
  }
}

class VetProHome extends StatefulWidget {
  const VetProHome({super.key});

  @override
  _VetProHomeState createState() => _VetProHomeState();
}

class _VetProHomeState extends State<VetProHome> {
  int _selectedIndex = 0;
  final _pages = [HomePage(), ProfilePage()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Color(0xFFFF6600),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
