import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <--- Đã thêm thư viện Firebase Auth

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false; // Thêm biến này để làm hiệu ứng xoay xoay khi đang gửi mail

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Quên mật khẩu? ", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(
              "Đừng lo! Hãy nhập email bạn đã đăng ký, chúng tôi sẽ gửi liên kết để đặt lại mật khẩu.",
              style: TextStyle(fontSize: 15, color: Colors.grey[600], height: 1.4),
            ),
            const SizedBox(height: 35),

            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email đã đăng ký', 
                prefixIcon: const Icon(Icons.email_outlined), 
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))
              ),
            ),
            const SizedBox(height: 35),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent, 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                ),
                onPressed: _isLoading ? null : () async {
                  final email = _emailController.text.trim();
                  if (email.isEmpty || !email.contains('@')) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng nhập email hợp lệ!")));
                    return;
                  }

                  // Bật trạng thái loading
                  setState(() { _isLoading = true; });

                  try {
                    // Gọi Firebase gửi mail thật
                    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

                    if (!context.mounted) return;
                    // Hiện Popup thông báo thành công
                    showDialog(
                      context: context, 
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: const Icon(Icons.mark_email_read, color: Colors.green, size: 55),
                        content: Text(
                          "Đã gửi liên kết khôi phục tới\n'$email'\nVui lòng kiểm tra hộp thư (kể cả mục Spam).",
                          textAlign: TextAlign.center,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Tắt Dialog
                              Navigator.pop(context); // Lùi về trang Login
                            }, 
                            child: const Text("Quay lại đăng nhập", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold))
                          )
                        ],
                      )
                    );
                  } on FirebaseAuthException catch (e) {
                    if (!context.mounted) return;
                    String errorMessage = "Đã xảy ra lỗi!";
                    if (e.code == 'user-not-found') {
                      errorMessage = "Email này chưa được đăng ký trong hệ thống.";
                    } else if (e.code == 'invalid-email') {
                      errorMessage = "Định dạng email không hợp lệ.";
                    }
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
                  } finally {
                    // Tắt trạng thái loading
                    if (mounted) {
                      setState(() { _isLoading = false; });
                    }
                  }
                },
                child: _isLoading 
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("GỬI YÊU CẦU", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}