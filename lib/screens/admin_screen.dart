import 'package:appsearchjob/models/job_class.dart';
import 'package:appsearchjob/models/theme_class.dart';
import 'package:appsearchjob/screens/job_detail_screen.dart';
import 'package:appsearchjob/screens/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import 'edit_job_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Job Search App',
      theme: ThemeData(
        brightness: themeProvider.isDarkMode ? Brightness.dark : Brightness.light,
        primaryColor: const Color(0xFF4A90E2),
        scaffoldBackgroundColor: themeProvider.isDarkMode ? Colors.black54 : const Color(0xFFF1F1F1),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF4A90E2),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
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
        title: const Text('Chào mừng ADMIN'),
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
              widget.onThemeChanged(!widget.isDarkMode);
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
                return JobCard(job: jobPost, isDarkMode: widget.isDarkMode,
                  onRefresh: () {  },);
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
  final ApiService _apiService = ApiService(
      'https://bj2ee0qhkb.execute-api.ap-southeast-1.amazonaws.com/JobStage/job');
  final VoidCallback onRefresh;

  JobCard({
    super.key,
    required this.job,
    required this.isDarkMode,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.purple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Card(

        margin: const EdgeInsets.all(12.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        elevation: 4,
        color: Colors.white.withAlpha(204),
        child:

        Padding(
          padding: const EdgeInsets.all(16.0),
          child:
          Row(
            children: [
              // Nút thêm hành động
              Align(
                alignment: Alignment.centerRight,
                child: PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: isDarkMode ? Colors.black : Colors.black),
                  onSelected: (value) async {
                    if (value == 'edit') {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditJobScreen(jobPost: job),
                        ),
                      );
                      if (result == true) {
                        onRefresh();
                      }
                    } else if (value == 'delete') {
                      await _deleteJobPost(job.id, context);
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
              // Hình ảnh bài đăng
              CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage('assets/congviec.jpg'),
              ),
              const SizedBox(width: 16.0), // Khoảng cách giữa hình ảnh và văn bản
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tiêu đề công việc
                    Text(
                      job.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: isDarkMode ? Colors.black : Colors.black,
                      ),
                      maxLines: 2, // Giới hạn số dòng
                      overflow: TextOverflow.ellipsis, // Hiển thị dấu "..." nếu quá dài
                    ),
                    const SizedBox(height: 8.0), // Khoảng cách giữa tiêu đề và công ty
                    // Công ty
                    Text(
                      job.company,
                      style: TextStyle(
                        color: isDarkMode ? Colors.black54 : Colors.black87,
                      ),
                      maxLines: 1, // Giới hạn số dòng
                      overflow: TextOverflow.ellipsis, // Hiển thị dấu "..." nếu quá dài
                    ),

                    const SizedBox(height: 12.0), // Khoảng cách giữa mô tả và thông tin khác
                    // Thông tin khác (VD: vị trí, lương)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            job.location,
                            style: TextStyle(
                              color: isDarkMode ? Colors.black54 : Colors.black87,
                            ),
                            maxLines: 2, // Giới hạn số dòng
                            overflow: TextOverflow.ellipsis, // Hiển thị dấu "..." nếu quá dài
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${job.salary.toStringAsFixed(0)} VND / Giờ', // Hiển thị tiền VND
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.black : Colors.black,
                        fontSize: 19,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    // Nút xem chi tiết
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => JobDetailScreen(job: job),
                            ),
                          );
                        },
                        child: Text('Xem Chi Tiết'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          backgroundColor: isDarkMode ? Colors.blueGrey : Colors.blue,
                          iconColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteJobPost(String id, BuildContext context) async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa bài đăng này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      try {
        await _apiService.deleteItem(id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xóa bài đăng')),
        );
        onRefresh();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xóa bài đăng thất bại: $e')),
        );
      }
    }
  }
}