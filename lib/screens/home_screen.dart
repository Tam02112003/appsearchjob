import 'package:appsearchjob/utils/auth.dart';
import 'package:flutter/material.dart';
import 'package:appsearchjob/models/theme_class.dart';
import 'package:appsearchjob/screens/add_job_screen.dart';
import 'package:appsearchjob/screens/job_detail_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/job_class.dart';
import '../services/api_service.dart';
import 'my_application_screen.dart';
import 'my_applications_screen_td.dart';
import 'my_job_post_screen.dart';

class JobSearchApp extends StatelessWidget {
  const JobSearchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recruiter Screen',
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
  final ApiService _apiService = ApiService(
      'https://bj2ee0qhkb.execute-api.ap-southeast-1.amazonaws.com/JobStage/job');
  List<JobPost> _jobPosts = [];
  List<JobPost> _filteredJobPosts = [];
  String username = 'Đang tải...';
  String _searchQuery = '';
  bool _isAdmin = false; // Biến lưu trạng thái người dùng là admin
  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadJobPosts();
    _checkAdminStatus(); // Kiểm tra quyền admin
  }

  Future<void> _checkAdminStatus() async {
    final isAdmin = await _authService.isUserInGroup("admin");
    setState(() {
      _isAdmin = isAdmin; // Cập nhật trạng thái admin
    });
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
        _jobPosts =
            posts.map<JobPost>((json) => JobPost.fromJson(json)).toList();
        _filteredJobPosts = _jobPosts; // Khởi tạo danh sách đã lọc
      });
    } catch (e) {
      print('Error loading job posts: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading job posts: $e')),
      );
    }
  }

  // Hàm kiểm tra xem người dùng có trong nhóm admin không
  Future<bool> _isUserInAdminGroup() async {
    final userGroups =
        await _authService.getUserGroups(); // Giả định bạn có hàm này
    return userGroups.contains("admin");
  }

  Future<void> _refreshJobPosts() async {
    await _loadJobPosts();
  }

  void _filterJobPosts(String query) {
    setState(() {
      _searchQuery = query;
      _filteredJobPosts = _jobPosts.where((job) {
        final titleMatch =
            job.title.toLowerCase().contains(query.toLowerCase());
        final companyMatch =
            job.company.toLowerCase().contains(query.toLowerCase());
        final locationMatch =
            job.location.toLowerCase().contains(query.toLowerCase());
        final salaryMatch = job.salary.toString().contains(query);
        return titleMatch || companyMatch || locationMatch || salaryMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text('Tìm kiếm việc làm',
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.cyanAccent,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.work),
            onPressed: () async {
              final userId = await _authService.getCurrentUserId();
              if (userId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JobApplicationsPage(
                      userId: userId,
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Không thể lấy userId.')),
                );
              }
            },
          ),
          IconButton(
              icon: const Icon(Icons.list),
              onPressed: () async {
                final userId = await _authService.getCurrentUserId();
                if (userId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MyJobPostsScreen(
                              userId: userId,
                              onRefresh: _loadJobPosts,
                            )),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Không thể lấy userId.')),
                  );
                }
              }),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const JobPostScreen()),
              );
              if (result == true) {
                _refreshJobPosts();
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshJobPosts,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(
                background: Image.asset(
                  'assets/banner.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SearchBarDelegate(
                isDarkMode: isDarkMode,
                onSearch: _filterJobPosts, // Gọi hàm lọc khi tìm kiếm
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  final jobPost = _filteredJobPosts[index];
                  // Chỉ hiển thị bài viết nếu không bị ẩn hoặc nếu là admin
                  if (jobPost.isHidden && !_isAdmin) {
                    return SizedBox.shrink(); // Không hiển thị gì
                  }
                  return JobCard(
                    job: jobPost,
                    isDarkMode: isDarkMode,
                    onRefresh: _refreshJobPosts,
                    isAdmin: _isAdmin,
                  );
                },
                childCount: _filteredJobPosts.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final bool isDarkMode;
  final Function(String) onSearch;

  _SearchBarDelegate({required this.isDarkMode, required this.onSearch});

  @override
  double get minExtent => 80.0; // Chiều cao tối thiểu của thanh tìm kiếm

  @override
  double get maxExtent => 80.0; // Chiều cao tối đa của thanh tìm kiếm

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: isDarkMode ? Colors.grey[900] : Colors.white,
      child: TextField(
        onChanged: onSearch, // Gọi hàm lọc khi người dùng nhập
        decoration: InputDecoration(
          hintText: 'Tìm kiếm theo tiêu đề, công ty, địa điểm, lương...',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide:
                BorderSide(color: isDarkMode ? Colors.white : Colors.blue),
          ),
          prefixIcon: Icon(Icons.search,
              color: isDarkMode ? Colors.white : Colors.blue),
        ),
        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
      ),
    );
  }

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true; // Xây dựng lại nếu có thay đổi
  }
}

class JobCard extends StatelessWidget {
  final JobPost job;
  final bool isDarkMode;
  final ApiService _apiService = ApiService(
      'https://bj2ee0qhkb.execute-api.ap-southeast-1.amazonaws.com/JobStage/job');
  final VoidCallback onRefresh;
  final bool isAdmin; // Thêm biến để kiểm tra quyền admin

  JobCard({
    super.key,
    required this.job,
    required this.isDarkMode,
    required this.onRefresh,
    required this.isAdmin, // Nhận biến từ ngoài
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
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        elevation: 4,
        color: Colors.white.withAlpha(204),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage('assets/congviec.jpg'),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: isDarkMode ? Colors.black : Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      job.company,
                      style: TextStyle(
                        color: isDarkMode ? Colors.black54 : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            job.location,
                            style: TextStyle(
                              color:
                                  isDarkMode ? Colors.black54 : Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${job.salary.toStringAsFixed(0)} VND / Giờ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.black : Colors.black,
                        fontSize: 19,
                      ),
                    ),

                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: isDarkMode ? Colors.black54 : Colors.black87,
                        ),
                        children: [
                          TextSpan(
                              text: 'Hạn nộp hồ sơ: ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold)), // Tiêu đề
                          TextSpan(
                            text: job.deadline != null
                                ? DateFormat('dd-MM-yyyy HH:mm').format(
                                    job.deadline!) // Định dạng ngày và giờ
                                : 'Chưa có hạn nộp', // Hiển thị nếu không có hạn nộp
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10.0),
                    // Hiển thị trạng thái ẩn cho admin
                    if (isAdmin)
                      Text(
                        job.isHidden ? 'Trạng thái: Đã ẩn' : 'Trạng thái: Hiện',
                        style: TextStyle(
                          color: job.isHidden ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    const SizedBox(height: 10.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
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
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            backgroundColor:
                                isDarkMode ? Colors.blueGrey : Colors.blue,
                            iconColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0), // Khoảng cách giữa hai nút
                        if (isAdmin) // Chỉ hiển thị nếu là admin
                          ElevatedButton(
                            onPressed: () async {
                              // Hiển thị hộp thoại xác nhận
                              final bool? shouldHide = await showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Xác Nhận'),
                                    content: Text(
                                        'Bạn có chắc chắn muốn ẩn bài viết này không?'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(
                                              false); // Trả về false khi nhấn "Không"
                                        },
                                        child: Text('Không'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(
                                              true); // Trả về true khi nhấn "Có"
                                        },
                                        child: Text('Có'),
                                      ),
                                    ],
                                  );
                                },
                              );

                              // Kiểm tra kết quả từ hộp thoại
                              if (shouldHide == true) {
                                // Xử lý ẩn bài viết
                                await _apiService
                                    .hideJobPost(job.id); // Hàm xử lý ẩn
                                onRefresh(); // Cập nhật danh sách
                              }
                            },
                            child: Text('Ẩn Bài Viết'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              backgroundColor: Colors.red,
                              iconColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                          ),
                        const SizedBox(width: 8.0), // Khoảng cách giữa hai nút
                        if (isAdmin) // Chỉ hiển thị nếu là admin
                          ElevatedButton(
                            onPressed: () async {
                              // Hiển thị hộp thoại xác nhận
                              final bool? shouldRestore =
                                  await showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Xác Nhận'),
                                    content: Text(
                                        'Bạn có chắc chắn muốn khôi phục bài viết này không?'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(
                                              false); // Trả về false khi nhấn "Không"
                                        },
                                        child: Text('Không'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(
                                              true); // Trả về true khi nhấn "Có"
                                        },
                                        child: Text('Có'),
                                      ),
                                    ],
                                  );
                                },
                              );

                              // Kiểm tra kết quả từ hộp thoại
                              if (shouldRestore == true) {
                                // Xử lý khôi phục bài viết
                                await _apiService.restoreJobPost(
                                    job.id); // Hàm xử lý khôi phục
                                onRefresh(); // Cập nhật danh sách
                              }
                            },
                            child: Text('Khôi Phục Bài Viết'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              backgroundColor: Colors.green,
                              iconColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                          ),
                      ],
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
}
