class JobApplication {
  final String education; // Trình độ học vấn
  final String experience; // Kinh nghiệm làm việc
  final String image; // Đường dẫn đến hình ảnh
  final String jobId; // ID công việc
  final String name; // Tên người nộp đơn
  final String phone; // Số điện thoại
  final String userId; // ID người nộp đơn

  JobApplication({
    required this.education,
    required this.experience,
    required this.image,
    required this.jobId,
    required this.name,
    required this.phone,
    required this.userId, // Thêm userId
  });

  // Phương thức chuyển đổi từ JSON sang đối tượng
  factory JobApplication.fromJson(Map<String, dynamic> json) {
    return JobApplication(
      education: json['education'],
      experience: json['experience'],
      image: json['image'],
      jobId: json['jobId'],
      name: json['name'],
      phone: json['phone'],
      userId: json['userId'], // Thêm userId
    );
  }

  // Phương thức chuyển đổi từ đối tượng sang JSON
  Map<String, dynamic> toJson() {
    return {
      'education': education,
      'experience': experience,
      'image': image,
      'jobId': jobId,
      'name': name,
      'phone': phone,
      'userId': userId, // Thêm userId
    };
  }
}