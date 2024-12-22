import 'package:appsearchjob/models/job_class.dart';
import 'package:appsearchjob/models/theme_class.dart';
import 'package:appsearchjob/screens/job_detail_screen.dart';
import 'package:appsearchjob/screens/sign_in_screen.dart';
import 'package:appsearchjob/services/api_service.dart';
import 'package:appsearchjob/utils/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DefaultScreen extends StatelessWidget {
  const DefaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context); // Truy cập vào ThemeProvider

    return MaterialApp(
      title: 'Job Search App',
      theme: ThemeData(
        brightness: themeProvider.isDarkMode ? Brightness.dark : Brightness.light,
        primaryColor: const Color(0xFF4A90E2),
        scaffoldBackgroundColor: themeProvider.isDarkMode ? Colors.black54 : const Color(0xFFF1F1F1),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF4A90E2),
          titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(backgroundColor: const Color(0xFF4A90E2)),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: JobSearchScreen(
        isDarkMode: themeProvider.isDarkMode,
        onThemeChanged: (isDark) {
          themeProvider.toggleTheme(); // Gọi hàm để chuyển đổi chế độ
        },
      ),
    );
  }
}

class JobSearchScreen extends StatelessWidget {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService('https://bj2ee0qhkb.execute-api.ap-southeast-1.amazonaws.com/JobStage/job');
  List<JobPost> _jobPosts = [];
  String username = 'Đang tải...';


  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  JobSearchScreen({super.key, required this.isDarkMode, required this.onThemeChanged});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tìm kiếm việc làm'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SignInScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
            onPressed: () {
              onThemeChanged(isDarkMode); // Chuyển đổi chế độ
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 150,
            child: FittedBox(
              child: Image.asset(
                'assets/banner.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm việc làm...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide(color: isDarkMode ? Colors.white : const Color(0xFF4A90E2)),
                ),
                prefixIcon: Icon(Icons.search, color: isDarkMode ? Colors.white : const Color(0xFF4A90E2)),
                filled: true,
                fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
              ),
              style: const TextStyle(color: Colors.black),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: Text(
                      'Remote',
                      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black), // Điều chỉnh màu chữ
                    ),
                    onSelected: (selected) {},
                    selected: false,
                    selectedColor: const Color(0xFF4A90E2),
                    backgroundColor: isDarkMode ? Colors.grey[700] : Colors.grey[200],
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: Text(
                      'Marketing Manager',
                      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black), // Điều chỉnh màu chữ
                    ),
                    onSelected: (selected) {},
                    selected: false,
                    selectedColor: const Color(0xFF4A90E2),
                    backgroundColor: isDarkMode ? Colors.grey[700] : Colors.grey[200],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _jobPosts.length,
              itemBuilder: (context, index) {
                return JobCard(job: _jobPosts[index], isDarkMode: isDarkMode);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class JobCard extends StatelessWidget {
  final JobPost job;
  final bool isDarkMode;

  const JobCard({super.key, required this.job, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      color: isDarkMode ? Colors.grey[850] : Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        // leading:
        // ClipOval(
        //   child: Image.asset(
        //     job.imageUrl,
        //     width: 50,
        //     height: 50,
        //     fit: BoxFit.cover,
        //   ),
        // ),
        title: Text(
          job.title,
          style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black),
        ),
        subtitle: Text(
          job.description,
          style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
        ),
        trailing: TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => JobDetailScreen(job: job)),
            );
          },
          style: TextButton.styleFrom(
            backgroundColor: isDarkMode ? Colors.grey[700] : Colors.blue, // Màu nền
            padding: EdgeInsets.symmetric(horizontal: 16.0), // Thêm padding nếu cần
          ),
          child: Text('Xem chi tiết',style: TextStyle(color: isDarkMode ? Colors.yellowAccent : Colors.yellowAccent),
        ),
        ),
      ),
    );
  }
}