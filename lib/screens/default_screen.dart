import 'package:appsearchjob/models/job_class.dart';
import 'package:appsearchjob/models/theme_class.dart';
import 'package:appsearchjob/screens/job_detail_screen.dart';
import 'package:appsearchjob/screens/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';

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

  const JobSearchScreen({super.key, required this.isDarkMode, required this.onThemeChanged});

  @override
  _JobSearchScreenState createState() => _JobSearchScreenState();
}

class _JobSearchScreenState extends State<JobSearchScreen> {
  List<JobPost> _jobPosts = [];
  List<JobPost> _filteredJobPosts = [];
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
        // Lọc bỏ các bài viết bị ẩn
        _jobPosts = posts.map<JobPost>((json) => JobPost.fromJson(json)).where((job) => !job.isHidden).toList();
        _filteredJobPosts = _jobPosts; // Khởi tạo danh sách đã lọc bằng danh sách không ẩn
      });
    } catch (e) {
      print('Lỗi khi tải bài viết: $e');
    }
  }

  Future<void> _onRefresh() async {
    await _loadJobPosts(); // Tải lại dữ liệu khi kéo xuống
  }

  void _filterJobPosts(String query) {
    setState(() {
      _filteredJobPosts = _jobPosts.where((job) {
        final titleMatch = job.title.toLowerCase().contains(query.toLowerCase());
        final companyMatch = job.company.toLowerCase().contains(query.toLowerCase());
        final locationMatch = job.location.toLowerCase().contains(query.toLowerCase());

        return titleMatch || companyMatch || locationMatch;
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

                return salaryMatch && deadlineMatch;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tìm kiếm việc làm'),
        actions: [
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
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: Column(
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
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: _filterJobPosts, // Gọi hàm lọc khi người dùng nhập
                      decoration: InputDecoration(
                        hintText: 'Tìm theo tên bài đăng,địa điểm, công ty',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide(color: widget.isDarkMode ? Colors.white : const Color(0xFF4A90E2)),
                        ),
                        prefixIcon: Icon(Icons.search, color: widget.isDarkMode ? Colors.white : const Color(0xFF4A90E2)),
                        filled: true,
                        fillColor: widget.isDarkMode ? Colors.grey[800] : Colors.white,
                      ),
                      style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black),
                    ),
                  ),
                  const SizedBox(width: 10), // Khoảng cách giữa TextField và nút lọc
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: _openFilterScreen,
                    color: widget.isDarkMode ? Colors.white : const Color(0xFF4A90E2),
                  ),
                ],
              ),
            ),
        Expanded(
          child: _filteredJobPosts.isEmpty
              ? Center(
            child: Text(
              'Không có bài viết nào.',
              style: TextStyle(
                fontSize: 18,
                color: widget.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          )
              : ListView.builder(
            itemCount: _filteredJobPosts.length,
            itemBuilder: (context, index) {
              final jobPost = _filteredJobPosts[index];
              return JobCard(
                job: jobPost,
                isDarkMode: widget.isDarkMode,
                onRefresh: _onRefresh,
              );
            },
          ),
      ),
    ],
    )));
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
              style: const TextStyle(color: Colors.white),
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
  final VoidCallback onRefresh;

  const JobCard({
    super.key,
    required this.job,
    required this.isDarkMode,
    required this.onRefresh,
  });

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
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        elevation: 4,
        color: Colors.white.withAlpha(204),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                    Text('Công ty: '+
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
                          child: Text('Địa điểm: '+
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
                          const TextSpan(
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
                          child: const Text('Xem Chi Tiết'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            backgroundColor:
                            isDarkMode ? Colors.blueGrey : Colors.blue,
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