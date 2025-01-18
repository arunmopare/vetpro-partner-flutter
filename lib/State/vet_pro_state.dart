import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter_background/flutter_background.dart';
import 'package:vetpro/Constants/Constants.dart';
import 'package:workmanager/workmanager.dart';

class VetProState extends ChangeNotifier {
  bool _checkedIn = false;
  Duration _elapsedTime = Duration.zero;
  Timer? _timer;
  String _userName = "User Name";
  String _userEmail = "user@example.com";
  String _token = "";

  bool get checkedIn => _checkedIn;

  Duration get elapsedTime => _elapsedTime;

  String get userName => _userName;

  String get userEmail => _userEmail;

  String get token => _token;

  Future<void> toggleCheckIn() async {
    _checkedIn = !_checkedIn;

    if (_checkedIn) {
      // get location permission
      Location location = Location();
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) return;
      }

      // Check for location permission
      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          throw Exception("Location permission denied.");
        }
      }

      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        _elapsedTime += Duration(seconds: 1);
        notifyListeners();
      });
      // Start background task
      enableBackgroundExecution();
      Workmanager().registerPeriodicTask(
        "1",
        "backgroundLocationTask",
        frequency: Duration(minutes: 15),
      );
    } else {
      // Cancel background task
      Workmanager().cancelAll();
      _timer?.cancel();
      _elapsedTime = Duration.zero;
    }
    notifyListeners();
  }

  Future<void> enableBackgroundExecution() async {
    const androidConfig = FlutterBackgroundAndroidConfig(
      notificationTitle: "Location Tracking",
      notificationText: "Tracking location in the background",
      enableWifiLock: true,
    );

    bool hasPermissions =
        await FlutterBackground.initialize(androidConfig: androidConfig);
    if (hasPermissions) {
      await FlutterBackground.enableBackgroundExecution();
    }
  }

  void updateUserProfile(String name, String email) {
    _userName = name;
    _userEmail = email;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(Constants.BASE_API_URL + '/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['accessToken'];
        // _userName = data['username'];
        // _userEmail = data['email'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token);
        // await prefs.setString('userName', _userName);
        // await prefs.setString('userEmail', _userEmail);

        notifyListeners();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<void> loadUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token') ?? "";
    _userName = prefs.getString('userName') ?? "User Name";
    _userEmail = prefs.getString('userEmail') ?? "user@example.com";
    notifyListeners();
  }

  bool get isLoggedIn => _token.isNotEmpty;

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _token = "";
    notifyListeners();
  }
}
