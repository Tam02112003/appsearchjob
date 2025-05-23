import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/application_class.dart';
import '../models/job_class.dart';

class ApiService {
  final String baseUrl;

  ApiService(this.baseUrl);

  Future<List<dynamic>> fetchItems() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load items');
    }
  }

  Future<List<dynamic>> getMyJobs(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl?userId=$userId'));

    if (response.statusCode == 200) {
      return json.decode(response.body)['body'];
    } else {
      throw Exception('Failed to load jobs');
    }
  }

  // Hàm mới để lấy các đơn ứng tuyển của một người dùng
  Future<List<JobApplication>> getApplicationsByUserId(String userId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/applications?userId=$userId'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body)['body'];
      return jsonList.map((json) => JobApplication.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load applications');
    }
  }

  Future<void> createItem(Map<String, dynamic> item) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(item),
    );

    if (response.statusCode != 201) {
      print('Error: ${response.body}'); // In ra thông báo lỗi
      throw Exception('Failed to create item');
    }
  }

  Future<void> updateItem(String id, Map<String, dynamic> item) async {
    // Tạo một bản sao của item để tránh thay đổi dữ liệu gốc
    final itemToUpdate = Map<String, dynamic>.from(item);

    // Xóa khóa chính (jobId) nếu có trong item
    itemToUpdate
        .remove('jobId'); // Chỉ cần chắc chắn rằng jobId không có trong item

    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(itemToUpdate), // Gửi dữ liệu đã loại bỏ jobId
    );

    if (response.statusCode != 200) {
      print('Error: ${response.body}'); // In ra thông báo lỗi
      throw Exception('Failed to update item');
    }
  }

  Future<void> deleteItem(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete item');
    }
  }

// Hàm gửi đơn ứng tuyển với jobId được thêm vào URL
  Future<void> sendApplication(JobApplication application) async {
    final url = Uri.parse(
        '$baseUrl/applications/${application.jobId}'); // Thêm jobId vào URL
    final body = jsonEncode(application.toJson());

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: body,
    );

    if (response.statusCode != 201) {
      print('Error: ${response.statusCode}, ${response.body}');
      throw Exception('Failed to send application');
    }
  }

  Future<void> hideJobPost(String jobId) async {
    // Gửi yêu cầu ẩn bài viết đến server
    final response = await http.post(
      Uri.parse(
          'https://bj2ee0qhkb.execute-api.ap-southeast-1.amazonaws.com/JobStage/hide-job-post'),
      body: jsonEncode({'jobId': jobId}),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer your_token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to hide job post');
    }
  }

  Future<void> restoreJobPost(String jobId) async {
    final response = await http.post(
      Uri.parse(
          'https://bj2ee0qhkb.execute-api.ap-southeast-1.amazonaws.com/JobStage/restore-job-post'),
      body: jsonEncode({'jobId': jobId}),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer your_token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to restore job post');
    }
  }

  Future<List<JobApplication>> getMyJobApplications(String userId) async {
    final response = await http.get(
      Uri.parse(
          'https://bj2ee0qhkb.execute-api.ap-southeast-1.amazonaws.com/JobStage/my-appliactions?userId=$userId'),
      headers: {
        'Authorization': 'Bearer your_token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['data'];
      return data.map((job) => JobApplication.fromJson(job)).toList();
    } else {
      throw Exception('Failed to load job applications');
    }
  }

  Future<void> updateApplicationStatus(
      String applicationId, String status) async {
    const String url = 'https://bj2ee0qhkb.execute-api.ap-southeast-1.amazonaws.com/JobStage/applications';
    final Map<String, dynamic> body = {
      'applicationId': applicationId, // Thêm applicationId vào body nếu cần
      'response': status,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer your_token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        // In ra mã trạng thái và nội dung phản hồi khi có lỗi
        print('Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to update application status');
      }
    } catch (e) {
      // In ra lỗi nếu có ngoại lệ
      print('Exception occurred: $e');
      throw Exception('Failed to update application status');
    }
  }

  Future<JobPost?> getJobPostById(String jobId) async {
    final response = await http.get(
      Uri.parse('https://bj2ee0qhkb.execute-api.ap-southeast-1.amazonaws.com/JobStage/job/$jobId'),
      headers: {
        'Authorization': 'Bearer your_token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return JobPost(
        id: data['jobId'],
        title: data['title'],
        description: data['description'],
        company: data['company'],
        location: data['location'],
        salary: data['salary']?.toDouble() ?? 0.0,
        userId: data['userId'],
        deadline: data['deadline'] != null ? DateTime.parse(data['deadline']) : null,
        isHidden: data['isHidden'] ?? false,
      );
    } else {
      // In thêm thông tin lỗi trả về từ API
      print('API response: ${response.statusCode}, body: ${response.body}');
      throw Exception('Failed to load job post');
    }
  }
}
