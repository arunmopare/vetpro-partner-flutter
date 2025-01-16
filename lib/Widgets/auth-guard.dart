import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vetpro/State/vet_pro_state.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<VetProState>(context);

    return FutureBuilder(
      future: state.loadUserDetails(), // Ensure user details are loaded
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (state.token.isEmpty) {
          // Redirect to login if token is missing
          Future.microtask(() => Navigator.pushReplacementNamed(context, '/login'));
          return SizedBox.shrink(); // Empty widget while redirecting
        }
        return child; // Render the protected page
      },
    );
  }
}
