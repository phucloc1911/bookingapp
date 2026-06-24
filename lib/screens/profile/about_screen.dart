import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFF0066FF).withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.travel_explore_rounded, size: 80, color: Color(0xFF0066FF)),
            ),
            const SizedBox(height: 20),
            const Text("Reservo App", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0066FF))),
            const SizedBox(height: 8),
            Text("Phiên bản 1.0.0", style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 40),
            const Text("Ứng dụng đặt phòng khách sạn hàng đầu.\nMang đến trải nghiệm lưu trú tuyệt vời nhất.", textAlign: TextAlign.center, style: TextStyle(height: 1.5)),
            const SizedBox(height: 40),
            TextButton(onPressed: () {}, child: const Text("Điều khoản sử dụng")),
            TextButton(onPressed: () {}, child: const Text("Chính sách bảo mật")),
            const Spacer(),
            Text("© 2026 Reservo. All rights reserved.", style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}