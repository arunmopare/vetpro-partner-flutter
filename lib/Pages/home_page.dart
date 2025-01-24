import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vetpro/Pages/profile_page.dart';
import 'package:vetpro/State/vet_pro_state.dart';
import 'add_visit_entry.dart'; // Import the new AddVisitEntryPage

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

// Home Page with Timer and Check-In Button

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<VetProState>(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              onPressed: state.toggleCheckIn,
              child: Text(
                state.checkedIn ? 'Check Out' : 'Check In',
                style: TextStyle(fontSize: 18),
              ),
            ),
            if (state.checkedIn)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text(
                  _formatTime(state.elapsedTime),
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }
}
