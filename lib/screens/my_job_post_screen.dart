import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:appsearchjob/models/theme_class.dart'; // Đảm bảo đã import ThemeProvider
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/job_class.dart';
import '../services/api_service.dart';
import 'ApplicationsScreen.dart';
import 'edit_job_screen.dart';

class MyJobPostsScreen extends StatefulWidget {
  final String userId;
  final VoidCallback onRefresh; // Thêm tham số này

  MyJobPostsScreen({super.key, required this.userId, required this.onRefresh});

  @override
  _MyJobPostsScreenState createState() => _MyJobPostsScreenState();
}

class _MyJobPostsScreenState extends State<MyJobPostsScreen> {
  late Future<List<JobPost>> _futureJobPosts;

  @override
  void initState() {
    super.initState();
    _futureJobPosts = fetchJobPosts(widget.userId);
  }

  Future<List<JobPost>> fetchJobPosts(String userId) async {
    final url = Uri.parse(
        'https://bj2ee0qhkb.execute-api.ap-southeast-1.amazonaws.com/JobStage/job?userId=$userId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => JobPost.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load job posts');
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  void _refreshJobPosts() {
    setState(() {
      _futureJobPosts = fetchJobPosts(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Các bài đăng tuyển của tôi'),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<List<JobPost>>(
        future: _futureJobPosts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            var jobPosts = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: jobPosts.isEmpty
                  ? const Center(child: Text('Chưa có bài đăng tuyển nào.'))
                  : ListView.builder(
                itemCount: jobPosts.length,
                itemBuilder: (context, index) {
                  return JobPostCard(
                    jobPost: jobPosts[index],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ApplicationsScreen(
                            jobId: jobPosts[index].id,
                          ),
                        ),
                      );
                    },
                    onRefresh: _refreshJobPosts, // Gọi hàm refresh
                    isDarkMode: false, // Điều chỉnh nếu cần
                  );
                },
              ),
            );
          } else {
            return const Center(child: Text('Không có dữ liệu.'));
          }
        },
      ),
    );
  }
}

class JobPostCard extends StatelessWidget {
  final JobPost jobPost;
  final VoidCallback onTap;
  final bool isDarkMode;
  final ApiService _apiService = ApiService('https://bj2ee0qhkb.execute-api.ap-southeast-1.amazonaws.com/JobStage/job');
  final VoidCallback onRefresh;

  JobPostCard({
    super.key,
    required this.jobPost,
    required this.onTap,
    required this.onRefresh,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 3,
      child:Container(
    decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Colors.blue, Colors.purple],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    ),
      child:ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        title: Text(
          jobPost.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Công ty: ${jobPost.company}'),
            Text('Địa điểm: ${jobPost.location}'),
            Text('Lương: \ ${jobPost.salary.toStringAsFixed(0)} VND / giờ'),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  color: isDarkMode ? Colors.white54 : Colors.black87,
                ),
                children: [
                  TextSpan(text: 'Hạn nộp hồ sơ: ', style: TextStyle(fontWeight: FontWeight.bold)), // Tiêu đề
                  TextSpan(
                    text: jobPost.deadline != null
                        ? DateFormat('dd-MM-yyyy HH:mm').format(jobPost.deadline!) // Định dạng ngày và giờ
                        : 'Chưa có hạn nộp', // Hiển thị nếu không có hạn nộp
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: isDarkMode ? Colors.white : Colors.black),
          onSelected: (value) async {
            if (value == 'edit') {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditJobScreen(jobPost: jobPost)),
              );
              if (result == true) {
                onRefresh(); // Tải lại danh sách sau khi chỉnh sửa
              }
            } else if (value == 'delete') {
              await _deleteJobPost(jobPost.id, context);
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
        onTap: onTap,
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã xóa bài đăng')));
        onRefresh(); // Tải lại danh sách bài đăng
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Xóa bài đăng thất bại: $e')));
      }
    }
  }
}