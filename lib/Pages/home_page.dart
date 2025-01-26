import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher
import 'package:vetpro/Pages/profile_page.dart';
import 'package:vetpro/State/vet_pro_state.dart';
import 'add_visit_entry.dart';
import 'visit_entry_list.dart';

class VetProHome extends StatefulWidget {
  const VetProHome({super.key});

  @override
  _VetProHomeState createState() => _VetProHomeState();
}

class _VetProHomeState extends State<VetProHome> {
  int _selectedIndex = 0;

  final _pages = [
    HomePage(),
    VisitEntryListPage(),
    ProfilePage(),
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
            icon: Icon(Icons.list),
            label: 'My Visits',
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

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _launchSupportURL() async {
    var uri = Uri.https('www.linkedin.com', '/in/arun-mopare');
    await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<VetProState>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('VetPro - Home'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              padding: EdgeInsets.all(16.0),
              color: Color.fromARGB(255, 255, 255, 255),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome to Vet Pro Partner!',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Your one-stop solution for managing veterinary visits and client interactions.',
                    style: TextStyle(
                        fontSize: 16.0,
                        color: const Color.fromARGB(179, 0, 0, 0)),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            // Quick Actions Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _quickActionCard(
                        icon: Icons.add,
                        title: 'Add Visit',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddVisitEntryPage()),
                          );
                        },
                      ),
                      _quickActionCard(
                        icon: Icons.list,
                        title: 'View Visits',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => VisitEntryListPage()),
                          );
                        },
                      ),
                      _quickActionCard(
                        icon: Icons.person,
                        title: 'Profile',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProfilePage()),
                          );
                        },
                      ),
                      _quickActionCard(
                        icon: Icons.support_agent,
                        title: 'Contact Support',
                        onTap: _launchSupportURL,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            // Check-In Section
            // Padding(
            //   padding: EdgeInsets.symmetric(horizontal: 16.0),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Text(
            //         'Daily Activity',
            //         style: TextStyle(
            //           fontSize: 18.0,
            //           fontWeight: FontWeight.bold,
            //         ),
            //       ),
            //       SizedBox(height: 8.0),
            //       Card(
            //         elevation: 4.0,
            //         child: Padding(
            //           padding: EdgeInsets.all(16.0),
            //           child: Column(
            //             crossAxisAlignment: CrossAxisAlignment.start,
            //             children: [
            //               ElevatedButton(
            //                 style: ElevatedButton.styleFrom(
            //                   padding: EdgeInsets.symmetric(
            //                     horizontal: 40,
            //                     vertical: 15,
            //                   ),
            //                 ),
            //                 onPressed: state.toggleCheckIn,
            //                 child: Text(
            //                   state.checkedIn ? 'Check Out' : 'Check In',
            //                   style: TextStyle(fontSize: 18),
            //                 ),
            //               ),
            //               if (state.checkedIn)
            //                 Padding(
            //                   padding: const EdgeInsets.only(top: 20.0),
            //                   child: Text(
            //                     _formatTime(state.elapsedTime),
            //                     style: TextStyle(
            //                       fontSize: 24,
            //                       fontWeight: FontWeight.bold,
            //                     ),
            //                   ),
            //                 ),
            //             ],
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _quickActionCard({
    required IconData icon,
    required String title,
    required Function onTap,
  }) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30.0,
            backgroundColor: Color(0xFFFF6600).withOpacity(0.2),
            child: Icon(icon, color: Color(0xFFFF6600), size: 30.0),
          ),
          SizedBox(height: 8.0),
          Text(title, style: TextStyle(fontSize: 14.0)),
        ],
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
