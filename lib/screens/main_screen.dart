import 'package:appsearchjob/models/theme_class.dart';
import 'package:appsearchjob/screens/account_screen.dart';
import 'package:appsearchjob/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const JobSearchScreen(),
    const AccountScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Image.asset(
          'assets/logo.png',
          height: 100,
        ),
        backgroundColor: themeProvider.isDarkMode ? Colors.grey[900] : Colors.white,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: themeProvider.isDarkMode ? Colors.grey[800] : Colors.white,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.home, 0),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.person, 1),
            label: 'Tài khoản',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: themeProvider.isDarkMode ? Colors.white : Colors.black,
        onTap: _onItemTapped,
      ),
      backgroundColor: themeProvider.isDarkMode ? Colors.black54 : Colors.white,
    );
  }

  // Hàm tạo icon với viền
  Widget _buildIcon(IconData icon, int index) {
    final isSelected = _selectedIndex == index;

    return Container(
      width: 40, // Chiều rộng của icon
      height: 40, // Chiều cao của icon
      child: Center(
        child: Icon(
          icon,
          color: isSelected ? Colors.blue : (Provider.of<ThemeProvider>(context).isDarkMode ? Colors.white : Colors.black),
        ),
      ),
    );
  }
}