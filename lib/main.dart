import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Pages/home_page.dart';
import 'Pages/profile_page.dart';
import 'State/vet_pro_state.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (_) => VetProState(),
    child: VetProApp(),
  ));
}

class VetProApp extends StatelessWidget {
  const VetProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VetPro',
      theme: ThemeData(
        primaryColor: Color(0xFFFF6600),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Color(0xFFFF6600),
          secondary: Colors.white,
        ),
      ),
      home: VetProHome(),
    );
  }
}

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
