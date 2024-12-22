import 'package:appsearchjob/models/job_class.dart';
import 'package:appsearchjob/models/theme_class.dart';
import 'package:appsearchjob/screens/job_detail_screen.dart';
import 'package:appsearchjob/screens/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/api_service.dart';
import '../utils/auth.dart';

class DefaultScreen extends StatelessWidget {
  const DefaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

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
          themeProvider.toggleTheme();
        },
      ),
    );
  }
}

class JobSearchScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  JobSearchScreen({super.key, required this.isDarkMode, required this.onThemeChanged});

  @override
  _JobSearchScreenState createState() => _JobSearchScreenState();
}

class _JobSearchScreenState extends State<JobSearchScreen> {
  List<JobPost> _jobPosts = [];
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService('https://bj2ee0qhkb.execute-api.ap-southeast-1.amazonaws.com/JobStage/job');

  @override
  void initState() {
    super.initState();
    _loadJobPosts(); // Tải dữ liệu ngay khi khởi tạo
  }

  Future<void> _loadJobPosts() async {
    try {
      final posts = await _apiService.fetchItems();
      setState(() {
        _jobPosts = posts.map<JobPost>((json) => JobPost.fromJson(json)).toList();
      });
    } catch (e) {
      print('Error loading job posts: $e');
    }
  }

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
            icon: Icon(widget.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
            onPressed: () {
              widget.onThemeChanged(widget.isDarkMode);
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
                  borderSide: BorderSide(color: widget.isDarkMode ? Colors.white : const Color(0xFF4A90E2)),
                ),
                prefixIcon: Icon(Icons.search, color: widget.isDarkMode ? Colors.white : const Color(0xFF4A90E2)),
                filled: true,
                fillColor: widget.isDarkMode ? Colors.grey[800] : Colors.white,
              ),
              style: const TextStyle(color: Colors.black),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _jobPosts.length,
              itemBuilder: (context, index) {
                final jobPost = _jobPosts[index];
                return JobCard(job: jobPost, isDarkMode: widget.isDarkMode);
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      elevation: 5,
      color: isDarkMode ? Colors.grey[800] : Colors.white,
      child: ListTile(
        title: Text(
          job.title,
          style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black),
        ),
        subtitle: Text(
          job.description,
          style: TextStyle(color: isDarkMode ? Colors.white54 : Colors.black54),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JobDetailScreen(job: job),
            ),
          );
        },
      ),
    );
  }
}