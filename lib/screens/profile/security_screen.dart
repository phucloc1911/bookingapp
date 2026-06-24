import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  Future<void> _resetPassword(BuildContext context) async {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email != null) {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đã gửi link đổi mật khẩu đến $email")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0066FF),
        title: const Text("Bảo mật tài khoản", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSecurityOption(Icons.lock_reset_rounded, "Đổi mật khẩu", "Chúng tôi sẽ gửi link đặt lại mật khẩu qua email của bạn.", () => _resetPassword(context)),
          const SizedBox(height: 12),
          _buildSecurityOption(Icons.fingerprint_rounded, "Xác thực sinh trắc học", "Đăng nhập bằng vân tay/FaceID", () {}),
          const SizedBox(height: 30),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            icon: const Icon(Icons.delete_forever),
            label: const Text("Yêu cầu xóa tài khoản", style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {}, // Tính năng nâng cao, có thể phát triển sau
          )
        ],
      ),
    );
  }

  Widget _buildSecurityOption(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF0066FF).withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: const Color(0xFF0066FF))),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}