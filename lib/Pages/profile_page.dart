import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vetpro/State/vet_pro_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // Load user details on page initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VetProState>(context, listen: false).loadUserDetails();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<VetProState>(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFF6600).withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header with Gradient
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
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: CircleAvatar(
                          radius: 46,
                          backgroundColor: Color(0xFFFF6600).withOpacity(0.2),
                          child: Icon(Icons.person,
                              size: 50, color: Color(0xFFFF6600)),
                        ),
                      ),
                      SizedBox(width: 20.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.userName,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 6.0),
                            Row(
                              children: [
                                Icon(Icons.email,
                                    size: 16,
                                    color: Colors.white.withOpacity(0.9)),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    state.userEmail,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8.0),
                // Account Details Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      SizedBox(height: 12.0),
                      _buildSettingCard(
                        context: context,
                        icon: Icons.edit_outlined,
                        title: 'Edit Profile',
                        subtitle: 'Coming soon',
                        gradientColors: [Color(0xFFFF6600), Color(0xFFFF8833)],
                        enabled: false,
                      ),
                      SizedBox(height: 12.0),
                      _buildSettingCard(
                        context: context,
                        icon: Icons.notifications_outlined,
                        title: 'Notifications',
                        subtitle: 'Coming soon',
                        gradientColors: [Color(0xFF2196F3), Color(0xFF42A5F5)],
                        enabled: false,
                      ),
                      SizedBox(height: 12.0),
                      _buildSettingCard(
                        context: context,
                        icon: Icons.lock_outlined,
                        title: 'Privacy Settings',
                        subtitle: 'Coming soon',
                        gradientColors: [Color(0xFF9C27B0), Color(0xFFBA68C8)],
                        enabled: false,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.0),
                // App Settings Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'App Settings',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      SizedBox(height: 12.0),
                      _buildSettingCard(
                        context: context,
                        icon: Icons.info_outlined,
                        title: 'About App',
                        subtitle: 'Version 1.0.0',
                        gradientColors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                        enabled: false,
                      ),
                      SizedBox(height: 12.0),
                      _buildSettingCard(
                        context: context,
                        icon: Icons.help_outline,
                        title: 'Help & Support',
                        subtitle: 'Coming soon',
                        gradientColors: [Color(0xFFFFA726), Color(0xFFFFB74D)],
                        enabled: false,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.0),
                // Logout Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red[400]!, Colors.red[600]!],
                      ),
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: Text('Logout'),
                            content: Text('Are you sure you want to logout?'),
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, color: Colors.white, size: 22),
                          SizedBox(width: 8),
                          Text(
                            "Log Out",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
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

  Widget _buildSettingCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
    bool enabled = true,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: Container(
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
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (!enabled)
                Icon(
                  Icons.lock_outline,
                  size: 18,
                  color: Colors.grey[400],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
