import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vetpro/State/vet_pro_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<VetProState>(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFFFF6600),
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            SizedBox(height: 20),
            Text(
              state.userName,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              state.userEmail,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFFFFFFF)),
              onPressed: () {
                // Update user profile (for now, use dummy data)
                state.updateUserProfile("New Name", "newemail@example.com");
              },
              child: Text("Update Profile"),
            ),
          ],
        ),
      ),
    );
  }
}