import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Thư viện format tiền tệ và ngày tháng (nếu chưa có thì cứ để yên code tự chạy chuẩn)

class MyBookingScreen extends StatefulWidget {
  const MyBookingScreen({super.key});

  @override
  State<MyBookingScreen> createState() => _MyBookingScreenState();
}

class _MyBookingScreenState extends State<MyBookingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF0066FF);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        title: const Text("Lịch sử đặt phòng", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: "Sắp tới"),
            Tab(text: "Hoàn thành"),
            Tab(text: "Đã hủy"),
          ],
        ),
      ),
      body: currentUser == null
          ? _buildNotLoggedInState()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildBookingList(statusFilter: ['Pending', 'Confirmed']),
                _buildBookingList(statusFilter: ['Completed']),
                _buildBookingList(statusFilter: ['Cancelled']),
              ],
            ),
    );
  }

  // 1. Hàm quét danh sách Booking từ Firebase Firestore theo tab trạng thái
  Widget _buildBookingList({required List<String> statusFilter}) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .where('userId', isEqualTo: currentUser?.uid)
          .where('status', whereIn: statusFilter)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Đã xảy ra lỗi: ${snapshot.error}"));
        }

        // Nếu người dùng chưa có đơn đặt phòng nào
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState();
        }

        final docs = snapshot.data!.docs;

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            return _buildBookingCard(data, docs[index].id);
          },
        );
      },
    );
  }

  // 2. Giao diện từng thẻ Booking Card
  Widget _buildBookingCard(Map<String, dynamic> data, String docId) {
    // Chuyển format giá tiền cho đẹp
    double totalPrice = (data['totalPrice'] ?? 0.0).toDouble();
    String formattedPrice = "${totalPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ";
    
    // Xử lý màu nhãn trạng thái
    String status = data['status'] ?? 'Pending';
    Color statusColor = Colors.orange;
    String statusText = "Chờ xác nhận";

    if (status == 'Confirmed') {
      statusColor = Colors.blue;
      statusText = "Đã xác nhận";
    } else if (status == 'Completed') {
      statusColor = Colors.green;
      statusText = "Đã hoàn thành";
    } else if (status == 'Cancelled') {
      statusColor = Colors.red;
      statusText = "Đã hủy";
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dòng trên cùng: Loại phòng & Trạng thái
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                      child: Icon(
                        data['itemType'] == 'Homestay' ? Icons.house_siding : Icons.hotel,
                        color: const Color(0xFF0066FF),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Mã đặt: #${docId.substring(0, 6).toUpperCase()}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                  child: Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                )
              ],
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),

            // Dòng thông tin ngày tháng check-in / check-out
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Check-in: ${data['checkIn']?.toString().split('T')[0] ?? 'N/A'}  ➔  Check-out: ${data['checkOut']?.toString().split('T')[0] ?? 'N/A'}",
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Tổng tiền & Nút thao tác
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Tổng thanh toán:", style: TextStyle(fontSize: 11, color: Colors.grey)),
                    Text(formattedPrice, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                  ],
                ),
                if (status == 'Pending' || status == 'Confirmed')
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => _showCancelDialog(docId),
                    child: const Text("Hủy phòng", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // 3. Hiệu ứng trống khi chưa có đơn nào
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text("Chưa có đơn đặt phòng nào", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 6),
          Text("Đơn đặt phòng của bạn sẽ xuất hiện tại đây", style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  // 4. Giao diện khi người dùng chưa đăng nhập
  Widget _buildNotLoggedInState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text("Vui lòng đăng nhập để xem đơn đặt phòng", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // 5. Bảng hỏi xác nhận Hủy phòng
  void _showCancelDialog(String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Xác nhận hủy phòng"),
        content: const Text("Bạn có chắc chắn muốn hủy đơn đặt phòng này không?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Không", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(context);
              // Cập nhật trạng thái trên Firebase thành Cancelled
              await FirebaseFirestore.instance.collection('bookings').doc(docId).update({'status': 'Cancelled'});
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã hủy đơn đặt phòng!")));
            },
            child: const Text("Hủy ngay", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}