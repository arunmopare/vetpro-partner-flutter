import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vetpro/Constants/Constants.dart';
import 'package:vetpro/Pages/add_visit_entry.dart';
import 'package:vetpro/Pages/login_screen.dart';
import 'package:vetpro/Pages/visit_entry_list.dart';
import 'package:vetpro/Widgets/auth-guard.dart';
import 'package:workmanager/workmanager.dart';
import 'Pages/home_page.dart';
import 'State/vet_pro_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token') ?? '';
  // Send location data to backend
  final response = await http.post(
    Uri.parse(Constants.BASE_API_URL + '/location'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      'latitude': locationData.latitude,
      'longitude': locationData.longitude,
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
              title: 'VetPro Partner',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                useMaterial3: true,
                primaryColor: Color(0xFFFF6600),
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Color(0xFFFF6600),
                  primary: Color(0xFFFF6600),
                  secondary: Color(0xFFFF8833),
                  surface: Colors.white,
                  background: Color(0xFFF5F5F5),
                ),
                scaffoldBackgroundColor: Colors.white,
                fontFamily: 'Roboto',
                textTheme: TextTheme(
                  displayLarge: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                  displayMedium: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                  displaySmall: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                  headlineMedium: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                  titleLarge: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                  bodyLarge: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF555555),
                  ),
                  bodyMedium: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF6600),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                inputDecorationTheme: InputDecorationTheme(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFFFF6600), width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                cardTheme: CardTheme(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Colors.white,
                ),
                appBarTheme: AppBarTheme(
                  elevation: 0,
                  centerTitle: true,
                  backgroundColor: Color(0xFFFF6600),
                  foregroundColor: Colors.white,
                  titleTextStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              initialRoute: state.isLoggedIn ? '/home' : '/login',
              routes: {
                '/login': (context) => LoginScreen(),
                '/home': (context) => AuthGuard(child: VetProHome()),
                '/add-visit': (context) =>
                    AuthGuard(child: AddVisitEntryPage()),
                '/my-visits': (context) =>
                    AuthGuard(child: VisitEntryListPage()),
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
  final _pages = [
    HomePage(),
    AddVisitEntryPage(),
    VisitEntryListPage(),
    // ProfilePage()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Color(0xFFFF6600),
          unselectedItemColor: Color(0xFF999999),
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 12,
          ),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline),
              activeIcon: Icon(Icons.add_circle),
              label: 'Add Visit',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt_outlined),
              activeIcon: Icon(Icons.list_alt),
              label: 'My Visits',
            ),
          ],
        ),
      ),
    );
  }
}
