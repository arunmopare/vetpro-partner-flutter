import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

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

  void toggleCheckIn() {
    _checkedIn = !_checkedIn;
    if (_checkedIn) {
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        _elapsedTime += Duration(seconds: 1);
        notifyListeners();
      });
    } else {
      _timer?.cancel();
      _elapsedTime = Duration.zero;
    }
    notifyListeners();
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
        Uri.parse('https://your-backend-api.com/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _userName = data['name'];
        _userEmail = data['email'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token);
        await prefs.setString('userName', _userName);
        await prefs.setString('userEmail', _userEmail);

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
}
