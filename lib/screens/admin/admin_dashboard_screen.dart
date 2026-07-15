import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bookingapp/screens/admin/admin_manage_places_screen.dart'; // Sửa lại đường dẫn của bạn
import 'package:bookingapp/screens/admin/admin_manage_reviews_screen.dart'; // Chỉnh lại đường dẫn cho đúng

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor:
            Colors.redAccent, // Admin cho màu Đỏ cho ngầu và phân biệt
        title: const Text(
          "BẢNG ĐIỀU KHIỂN ADMIN",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thẻ thống kê nhanh
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    "Doanh thu",
                    "15.5M",
                    Icons.attach_money,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    "Đơn mới",
                    "12",
                    Icons.receipt_long,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            const Text(
              "QUẢN LÝ HỆ THỐNG",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 12),

            // Các nút chức năng Admin
            // Các nút chức năng Admin
            _buildAdminMenu(Icons.hotel, "Quản lý Phòng / Homestay", () {
              // 🟢 GỌI TRANG QUẢN LÝ Ở ĐÂY:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminManagePlacesScreen(),
                ),
              );
            }),
            _buildAdminMenu(Icons.star_half, "Quản lý Đánh giá", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminManageReviewsScreen(),
                ),
              );
            }),

            const SizedBox(height: 24),
            const Text(
              "TẤT CẢ ĐƠN ĐẶT PHÒNG",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 12),

            // DANH SÁCH TOÀN BỘ ĐƠN HÀNG CỦA MỌI NGƯỜI
            StreamBuilder<QuerySnapshot>(
              // Lấy TẤT CẢ đơn từ Firebase (Sắp xếp mới nhất lên đầu)
              stream: FirebaseFirestore.instance
                  .collection('bookings')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());

                final docs = snapshot.data!.docs;
                if (docs.isEmpty)
                  return const Text("Chưa có đơn hàng nào trên hệ thống.");

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.red.shade50,
                          child: const Icon(Icons.receipt, color: Colors.red),
                        ),
                        title: Text(
                          "${data['itemTitle']} - ${data['status']}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "ID User: ${data['userId']}\nTổng tiền: ${data['totalPrice']} đ",
                        ),
                        // 🟢 THAY THẾ KHÚC trailing CŨ BẰNG ĐOẠN NÀY
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 1. NÚT CẬP NHẬT TRẠNG THÁI (MỚI)
                            PopupMenuButton<String>(
                              icon: const Icon(
                                Icons.edit_calendar,
                                color: Colors.blue,
                              ),
                              tooltip: "Cập nhật trạng thái",
                              onSelected: (String newStatus) {
                                // Lệnh cập nhật lên Firebase
                                FirebaseFirestore.instance
                                    .collection('bookings')
                                    .doc(docs[index].id)
                                    .update({'status': newStatus});

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Đã đổi trạng thái thành: $newStatus",
                                    ),
                                  ),
                                );
                              },
                              itemBuilder: (BuildContext context) => [
                                const PopupMenuItem(
                                  value: 'Pending',
                                  child: Text(
                                    "Chờ thanh toán (Pending)",
                                    style: TextStyle(color: Colors.orange),
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'Confirmed',
                                  child: Text(
                                    "Đã thanh toán (Confirmed)",
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'Completed',
                                  child: Text(
                                    "Đã trả phòng (Completed)",
                                    style: TextStyle(color: Colors.green),
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'Cancelled',
                                  child: Text(
                                    "Đã hủy (Cancelled)",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),

                            // 2. NÚT XÓA ĐƠN HÀNG (GIỮ NGUYÊN)
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                // Thêm xác nhận trước khi xóa cho an toàn
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text("Xác nhận xóa"),
                                    content: const Text(
                                      "Xóa đơn hàng này khỏi hệ thống?",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: const Text(
                                          "Hủy",
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),
                                        onPressed: () {
                                          Navigator.pop(ctx);
                                          FirebaseFirestore.instance
                                              .collection('bookings')
                                              .doc(docs[index].id)
                                              .delete();
                                        },
                                        child: const Text(
                                          "Xóa",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminMenu(IconData icon, String title, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
