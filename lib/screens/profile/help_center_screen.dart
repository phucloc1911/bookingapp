import 'package:flutter/material.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0066FF),
        title: const Text("Trung tâm trợ giúp", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Câu hỏi thường gặp", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 16),
            _buildFAQTile("Làm sao để hủy phòng đã đặt?", "Bạn có thể vào 'Lịch sử đặt phòng', chọn đơn hàng và nhấn 'Hủy đặt phòng'. Miễn phí hủy trước 24h."),
            _buildFAQTile("Tôi có thể đổi ngày nhận phòng không?", "Vui lòng liên hệ trực tiếp với khách sạn qua nút 'Gọi điện' trong chi tiết đơn đặt phòng để được hỗ trợ."),
            _buildFAQTile("Reservo có hỗ trợ xuất hóa đơn VAT không?", "Có. Vui lòng tick vào ô 'Yêu cầu xuất hóa đơn' ở bước Thanh toán."),
            const SizedBox(height: 30),
            const Text("Liên hệ trực tiếp", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildContactCard(Icons.headset_mic_rounded, "Chat ngay", Colors.blue)),
                const SizedBox(width: 16),
                Expanded(child: _buildContactCard(Icons.email_rounded, "Gửi Email", Colors.orange)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFAQTile(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        children: [Padding(padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16), child: Text(answer, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)))],
      ),
    );
  }

  Widget _buildContactCard(IconData icon, String title, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}