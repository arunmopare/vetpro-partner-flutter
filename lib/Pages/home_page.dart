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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFF6600).withOpacity(0.1),
              Colors.white,
              Color(0xFFFF6600).withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section with Gradient
                Container(
                  margin: EdgeInsets.all(16.0),
                  padding: EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFFF6600),
                        Color(0xFFFF8833),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFFF6600).withOpacity(0.3),
                        blurRadius: 15,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.waving_hand,
                              color: Colors.white, size: 28),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Welcome Back!',
                              style: TextStyle(
                                fontSize: 28.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          // Logout button
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.logout, color: Colors.white),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    title: Text('Logout'),
                                    content: Text(
                                        'Are you sure you want to logout?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          state.logout();
                                          Navigator.of(context)
                                              .pushReplacementNamed('/login');
                                        },
                                        child: Text(
                                          'Logout',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              tooltip: 'Logout',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        state.userName.isNotEmpty ? state.userName : 'Partner',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      SizedBox(height: 12.0),
                      Text(
                        'Your one-stop solution for managing veterinary visits and client interactions.',
                        style: TextStyle(
                          fontSize: 15.0,
                          color: Colors.white.withOpacity(0.95),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.0),
                // Quick Actions Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        children: [
                          _quickActionCard(
                            context: context,
                            icon: Icons.add_circle_outline,
                            title: 'Add Visit',
                            subtitle: 'Create new entry',
                            gradient: [Color(0xFFFF6600), Color(0xFFFF8833)],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AddVisitEntryPage()),
                              );
                            },
                          ),
                          _quickActionCard(
                            context: context,
                            icon: Icons.list_alt,
                            title: 'View Visits',
                            subtitle: 'Browse entries',
                            gradient: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => VisitEntryListPage()),
                              );
                            },
                          ),
                          _quickActionCard(
                            context: context,
                            icon: Icons.support_agent,
                            title: 'Support',
                            subtitle: 'Get help',
                            gradient: [Color(0xFF9C27B0), Color(0xFFBA68C8)],
                            onTap: _launchSupportURL,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.0),
                // Stats Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Overview',
                        style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Container(
                        padding: EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _statItem(
                              icon: Icons.calendar_today,
                              label: 'This Week',
                              value: '-',
                              color: Color(0xFFFF6600),
                            ),
                            _buildDivider(),
                            _statItem(
                              icon: Icons.trending_up,
                              label: 'This Month',
                              value: '-',
                              color: Color(0xFF4CAF50),
                            ),
                            _buildDivider(),
                            _statItem(
                              icon: Icons.star,
                              label: 'Total Visits',
                              value: '-',
                              color: Color(0xFF2196F3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey.withOpacity(0.3),
    );
  }

  Widget _statItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _quickActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradient,
    required Function onTap,
  }) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 32.0),
              ),
              SizedBox(height: 12.0),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4.0),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.white.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
