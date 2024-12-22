import 'package:appsearchjob/screens/edit_job_screen.dart';
import 'package:appsearchjob/utils/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:appsearchjob/models/theme_class.dart';
import 'package:appsearchjob/screens/add_job_screen.dart';
import 'package:appsearchjob/screens/job_detail_screen.dart';
import 'package:appsearchjob/screens/my_application_screen.dart';
import '../models/job_class.dart';
import '../services/api_service.dart';

class JobSearchApp extends StatelessWidget {
  const JobSearchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Job Search App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      debugShowCheckedModeBanner: false,
      home: JobSearchScreen(),
    );
  }
}

class JobSearchScreen extends StatefulWidget {
  JobSearchScreen({super.key});

  @override
  _JobSearchScreenState createState() => _JobSearchScreenState();
}

class _JobSearchScreenState extends State<JobSearchScreen> {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService('https://bj2ee0qhkb.execute-api.ap-southeast-1.amazonaws.com/JobStage/job');
  List<JobPost> _jobPosts = [];
  String username = 'Đang tải...';

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadJobPosts();
  }

  Future<void> _loadUserName() async {
    final name = await _authService.getCurrentUsername();
    setState(() {
      username = name ?? 'Người dùng';
    });
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

  void _refreshJobPosts() {
    _loadJobPosts(); // Gọi lại hàm tải dữ liệu
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text('Tìm kiếm việc làm', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.cyanAccent,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Hành động cho thông báo
            },
          ),
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyApplicationsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const JobPostScreen()),
              );
              if (result == true) {
                _refreshJobPosts(); // Tải lại danh sách bài đăng
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 150,
            child: FittedBox(
              child: Image.asset('assets/banner.png', fit: BoxFit.cover),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm việc làm...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0)),
                prefixIcon: Icon(Icons.search, color: isDarkMode ? Colors.white : Colors.blue),
                filled: true,
                fillColor: isDarkMode ? Colors.grey[900] : Colors.white,
              ),
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _jobPosts.length,
              itemBuilder: (context, index) {
                final jobPost = _jobPosts[index];
                return JobCard(job: jobPost, isDarkMode: isDarkMode, onRefresh: _refreshJobPosts);
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
  final ApiService _apiService = ApiService('https://bj2ee0qhkb.execute-api.ap-southeast-1.amazonaws.com/JobStage/job');
  final VoidCallback onRefresh;

   JobCard({super.key, required this.job, required this.isDarkMode, required this.onRefresh});

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
          // Điều hướng đến JobDetailScreen khi nhấp vào bài đăng
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JobDetailScreen(job: job),
            ),
          );
        },
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: isDarkMode ? Colors.white : Colors.black),
          onSelected: (value) async {
            if (value == 'edit') {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditJobScreen(jobPost: job), // Truyền jobPost đúng
                ),
              );
              if (result == true) {
                onRefresh(); // Gọi lại hàm tải dữ liệu
              }
            } else if (value == 'delete') {
              // Xử lý xóa bài đăng
              await _deleteJobPost(job.id, context); // Gọi hàm xóa với ID bài đăng
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem<String>(
              value: 'edit',
              child: Text('Chỉnh sửa'),
            ),
            const PopupMenuItem<String>(
              value: 'delete',
              child: Text('Xóa'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteJobPost(String id, BuildContext context) async {
    // Hiển thị hộp thoại xác nhận trước khi xóa
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa bài đăng này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Đóng dialog và không xóa
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), // Đồng ý xóa
            child: Text('Xóa'),
          ),
        ],
      ),
    );

    // Kiểm tra nếu người dùng xác nhận xóa
    if (confirmDelete == true) {
      try {
        await _apiService.deleteItem(id); // Gọi hàm xóa từ ApiService
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xóa bài đăng')),
        );
        onRefresh(); // Cập nhật danh sách bài đăng
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xóa bài đăng thất bại: $e')),
        );
      }
    }
  }
}