import 'package:appsearchjob/utils/auth.dart';
import 'package:flutter/material.dart';
import 'package:appsearchjob/models/theme_class.dart';
import 'package:appsearchjob/screens/add_job_screen.dart';
import 'package:appsearchjob/screens/job_detail_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/job_class.dart';
import '../services/api_service.dart';
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
      home: const JobSearchScreen(),
    );
  }
}

class JobSearchScreen extends StatefulWidget {
  const JobSearchScreen({super.key});

  @override
  _JobSearchScreenState createState() => _JobSearchScreenState();
}

class _JobSearchScreenState extends State<JobSearchScreen> {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService('https://bj2ee0qhkb.execute-api.ap-southeast-1.amazonaws.com/JobStage/job');
  List<JobPost> _jobPosts = [];
  List<JobPost> _filteredJobPosts = [];
  String username = 'Đang tải...';
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadJobPosts();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    final isAdmin = await _authService.isUserInGroup("admin");
    setState(() {
      _isAdmin = isAdmin;
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
        _jobPosts = posts.map<JobPost>((json) => JobPost.fromJson(json)).toList();
        _filteredJobPosts = _jobPosts;
      });
    } catch (e) {
      print('Error loading job posts: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading job posts: $e')));
    }
  }

  Future<void> _refreshJobPosts() async {
    await _loadJobPosts();
  }

  void _filterJobPosts(String query) {
    setState(() {

      _filteredJobPosts = _jobPosts.where((job) {
        final titleMatch = job.title.toLowerCase().contains(query.toLowerCase());
        final companyMatch = job.company.toLowerCase().contains(query.toLowerCase());
        final locationMatch = job.location.toLowerCase().contains(query.toLowerCase());
        return titleMatch || companyMatch || locationMatch ;
      }).toList();
    });
  }

  void _openFilterScreen() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return FilterScreen(
          onApplyFilters: (String title, String location, double minSalary, double maxSalary, DateTime? deadline) {
            setState(() {
              _filteredJobPosts = _jobPosts.where((job) {

                final salaryMatch = job.salary >= minSalary && job.salary <= maxSalary;
                final deadlineMatch = deadline == null || (job.deadline != null && job.deadline!.isBefore(deadline));

                return  salaryMatch && deadlineMatch;
              }).toList();
            });
            Navigator.pop(context); // Đóng BottomSheet
          },
        );
      },
    );
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
            icon: const Icon(Icons.work),
            onPressed: () async {
              final userId = await _authService.getCurrentUserId();
              if (userId != null) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => JobApplicationsPage(userId: userId)));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không thể lấy userId.')));
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () async {
              final userId = await _authService.getCurrentUserId();
              if (userId != null) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => MyJobPostsScreen(userId: userId, onRefresh: _loadJobPosts)));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không thể lấy userId.')));
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const JobPostScreen()));
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
                background: Image.asset('assets/banner.png', fit: BoxFit.cover),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SearchBarDelegate(
                isDarkMode: isDarkMode,
                onSearch: _filterJobPosts,
                onFilter: _openFilterScreen, // Gọi hàm mở màn hình lọc
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                  final jobPost = _filteredJobPosts[index];
                  if (jobPost.isHidden && !_isAdmin) {
                    return const SizedBox.shrink();
                  }
                  return JobCard(job: jobPost, isDarkMode: isDarkMode, onRefresh: _refreshJobPosts, isAdmin: _isAdmin);
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
  final VoidCallback onFilter;

  _SearchBarDelegate({required this.isDarkMode, required this.onSearch, required this.onFilter});

  @override
  double get minExtent => 80.0;

  @override
  double get maxExtent => 80.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: isDarkMode ? Colors.grey[900] : Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: onSearch,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo tiêu đề, công ty, địa điểm',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.blue),
                ),
                prefixIcon: Icon(Icons.search, color: isDarkMode ? Colors.white : Colors.blue),
              ),
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: onFilter, // Gọi hàm mở màn hình lọc
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

class FilterScreen extends StatefulWidget {
  final Function(String, String, double, double, DateTime?) onApplyFilters;

  const FilterScreen({required this.onApplyFilters});

  @override
  _FilterScreenState createState() => _FilterScreenState();

}

class _FilterScreenState extends State<FilterScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  double _minSalary = 0;
  double _maxSalary = 100000; // Giả sử 100,000 là mức lương tối đa
  DateTime? _selectedDeadline;


  Future<void> _selectDeadline(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDeadline) {
      setState(() {
        _selectedDeadline = picked;
      });
    }
  }

  void _resetFilters() {
    setState(() {
      _minSalary = 0;
      _maxSalary = 100000; // Đặt lại mức lương tối đa
      _selectedDeadline = null; // Đặt lại hạn nộp hồ sơ
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Lọc Công Việc',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Text(
            'Mức Lương: ${_minSalary.toStringAsFixed(0)} VND - ${_maxSalary.toStringAsFixed(0)} VND',
            style: const TextStyle(fontSize: 16),
          ),
          RangeSlider(
            values: RangeValues(_minSalary, _maxSalary),
            min: 0,
            max: 100000,
            divisions: 100,
            labels: RangeLabels(
              _minSalary.toStringAsFixed(0),
              _maxSalary.toStringAsFixed(0),
            ),
            onChanged: (RangeValues values) {
              setState(() {
                _minSalary = values.start;
                _maxSalary = values.end;
              });
            },
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () => _selectDeadline(context),
            child: Text(
              _selectedDeadline == null
                  ? 'Chọn Hạn Nộp Hồ Sơ'
                  : 'Hạn Nộp Hồ Sơ: ${DateFormat('dd-MM-yyyy').format(_selectedDeadline!)}',
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              widget.onApplyFilters(
                _titleController.text,
                _locationController.text,
                _minSalary,
                _maxSalary,
                _selectedDeadline,
              );
            },
            child: const Text('Áp Dụng Bộ Lọc'),
          ),
          TextButton(
            onPressed: _resetFilters,
            child: const Text('Đặt Lại Bộ Lọc', style: TextStyle(color: Colors.red)),
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
  final bool isAdmin;

  JobCard({super.key, required this.job, required this.isDarkMode, required this.onRefresh, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Row(
              children: [
                const CircleAvatar(
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
                      Text(
                        job.location,
                        style: TextStyle(
                          color: isDarkMode ? Colors.black54 : Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
                            const TextSpan(text: 'Hạn nộp hồ sơ: ', style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: job.deadline != null ? DateFormat('dd-MM-yyyy HH:mm').format(job.deadline!) : 'Chưa có hạn nộp'),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10.0),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => JobDetailScreen(job: job)));
                            },
                            child: const Text('Xem Chi Tiết'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              backgroundColor: isDarkMode ? Colors.blueGrey : Colors.blue,
                              iconColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                          ),
                          if (isAdmin)
                            PopupMenuButton<String>(
                              iconColor: isDarkMode ? Colors.black : Colors.black,
                              onSelected: (String value) async {
                                if (value == 'hide') {
                                  final bool? shouldHide = await _showConfirmationDialog(context, 'Bạn có chắc chắn muốn ẩn bài viết này không?');
                                  if (shouldHide == true) {
                                    await _apiService.hideJobPost(job.id);
                                    onRefresh();
                                  }
                                } else if (value == 'restore') {
                                  final bool? shouldRestore = await _showConfirmationDialog(context, 'Bạn có chắc chắn muốn khôi phục bài viết này không?');
                                  if (shouldRestore == true) {
                                    await _apiService.restoreJobPost(job.id);
                                    onRefresh();
                                  }
                                }
                              },
                              itemBuilder: (BuildContext context) => [
                                const PopupMenuItem(value: 'hide', child: Text('Ẩn Bài Viết')),
                                const PopupMenuItem(value: 'restore', child: Text('Khôi Phục Bài Viết')),
                              ],
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
      ),
    );
  }

  Future<bool?> _showConfirmationDialog(BuildContext context, String message) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác Nhận'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Không'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Có'),
            ),
          ],
        );
      },
    );
  }
}