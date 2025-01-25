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
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(16.0)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 50, color: Theme.of(context).primaryColor),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.userName,
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          state.userEmail,
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            // Account Details Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.0),
                  Card(
                    elevation: 4.0,
                    child: ListTile(
                      leading: Icon(Icons.edit, color: Theme.of(context).primaryColor),
                      title: Text('Edit Profile'),
                      subtitle: Text('Update your personal information'),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        state.updateUserProfile("New Name", "newemail@example.com");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Profile updated successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                    ),
                  ),
                  Card(
                    elevation: 4.0,
                    child: ListTile(
                      leading: Icon(Icons.notifications, color: Theme.of(context).primaryColor),
                      title: Text('Notifications'),
                      subtitle: Text('Manage notification settings'),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // Add functionality for managing notifications
                      },
                    ),
                  ),
                  Card(
                    elevation: 4.0,
                    child: ListTile(
                      leading: Icon(Icons.lock, color: Theme.of(context).primaryColor),
                      title: Text('Privacy Settings'),
                      subtitle: Text('Manage your privacy preferences'),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // Add functionality for managing privacy settings
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            // App Settings Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'App Settings',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.0),
                  Card(
                    elevation: 4.0,
                    child: ListTile(
                      leading: Icon(Icons.info, color: Theme.of(context).primaryColor),
                      title: Text('About App'),
                      subtitle: Text('Learn more about this application'),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // Add functionality for "About App"
                      },
                    ),
                  ),
                  Card(
                    elevation: 4.0,
                    child: ListTile(
                      leading: Icon(Icons.help, color: Theme.of(context).primaryColor),
                      title: Text('Help & Support'),
                      subtitle: Text('Get help or report an issue'),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // Add functionality for "Help & Support"
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            // Logout Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: () {
                  // Log out logic
                  state.logout();
                  Navigator.of(context).pushReplacementNamed('/login');
                },
                icon: Icon(Icons.logout, color: Colors.white),
                label: Text(
                  "Log Out",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}
