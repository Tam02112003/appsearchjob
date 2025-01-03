class JobApplication {
  final String id;
  final String education; // Trình độ học vấn
  final String experience; // Kinh nghiệm làm việc
  final String? image; // Đường dẫn đến hình ảnh
  final String jobId; // ID công việc
  final String name; // Tên người nộp đơn
  final String phone; // Số điện thoại
  final String userId; // ID người nộp đơn
  final String status; // Trạng thái đơn ứng tuyển

  JobApplication({
    required this.id,
    required this.education,
    required this.experience,
    this.image,
    required this.jobId,
    required this.name,
    required this.phone,
    required this.userId, // Thêm userId
    required this.status, // Thêm trường trạng thái
  });

  // Phương thức chuyển đổi từ JSON sang đối tượng
  factory JobApplication.fromJson(Map<String, dynamic> json) {
    return JobApplication(
      id: json['applicationId'],
      education: json['education'],
      experience: json['experience'],
      image: json['image'] as String?, // Đảm bảo kiểu là String?,
      jobId: json['jobId'],
      name: json['name'],
      phone: json['phone'],
      userId: json['userId'], // Thêm userId
      status: json['application_status'], // Thêm trường trạng thái
    );
  }

  // Phương thức chuyển đổi từ đối tượng sang JSON
  Map<String, dynamic> toJson() {
    return {
      'applicationId': id,
      'education': education,
      'experience': experience,
      'image': image,
      'jobId': jobId,
      'name': name,
      'phone': phone,
      'userId': userId, // Thêm userId
      'application_status': status
    };
  }
}