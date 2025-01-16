import 'package:flutter/material.dart';
import 'dart:async';

class VetProState extends ChangeNotifier {
  bool _checkedIn = false;
  Duration _elapsedTime = Duration.zero;
  Timer? _timer;
  String _userName = "User Name";
  String _userEmail = "user@example.com";

  bool get checkedIn => _checkedIn;
  Duration get elapsedTime => _elapsedTime;
  String get userName => _userName;
  String get userEmail => _userEmail;

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
}
