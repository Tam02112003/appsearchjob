import 'package:appsearchjob/utils/auth.dart';
import 'package:flutter/material.dart';
import 'sign_in_screen.dart';

class OtpScreen extends StatefulWidget {
  final String email;

  const OtpScreen({super.key, required this.email});

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final otpController = TextEditingController();

  void _confirmOtp() async {
    final otp = otpController.text;

    if (otp.isNotEmpty) {
      try {
        await AuthService().confirmSignUp(widget.email, otp);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignInScreen()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xác thực OTP thất bại: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập mã OTP')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nhập OTP'),backgroundColor: Colors.blue,),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hướng dẫn người dùng nhập mã OTP
            Text(
              'Vui lòng nhập mã OTP đã gửi đến email ${widget.email}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),

            // TextField để nhập mã OTP
            TextField(
              controller: otpController,
              decoration: InputDecoration(
                labelText: 'Mã OTP',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),

            // Nút xác thực OTP
            ElevatedButton(
              onPressed: _confirmOtp,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                backgroundColor: Colors.blue,
                textStyle: const TextStyle(fontSize: 16),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check), // Biểu tượng xác nhận
                  SizedBox(width: 8),
                  Text('Xác thực OTP'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}