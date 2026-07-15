import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bookingapp/screens/admin/admin_manage_places_screen.dart';
import 'package:bookingapp/screens/admin/admin_manage_reviews_screen.dart';
import 'package:bookingapp/services/firestore_service.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
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
            StreamBuilder<QuerySnapshot>(
              stream: firestoreService.getAllBookingsForAdmin(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return const Text("Lỗi tải dữ liệu thống kê");
                }

                double totalRevenue = 0;
                int newOrdersCount = 0;

                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  for (var doc in snapshot.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    String status = data['status'] ?? 'Pending';
                    double price = (data['totalPrice'] ?? 0).toDouble();

                    if (status == 'Pending') {
                      newOrdersCount++;
                    } else if (status == 'Confirmed' || status == 'Completed') {
                      totalRevenue += price;
                    }
                  }
                }

                String formattedRevenue;
                if (totalRevenue >= 1000000) {
                  formattedRevenue =
                      "${(totalRevenue / 1000000).toStringAsFixed(1)}M";
                } else if (totalRevenue > 0) {
                  formattedRevenue =
                      "${totalRevenue.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ";
                } else {
                  formattedRevenue = "0 đ";
                }

                return Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        "Doanh thu",
                        formattedRevenue,
                        Icons.attach_money,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        "Đơn mới",
                        "$newOrdersCount",
                        Icons.receipt_long,
                        Colors.blue,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            const Text(
              "QUẢN LÝ HỆ THỐNG",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 12),

            _buildAdminMenu(Icons.hotel, "Quản lý Phòng / Homestay", () {
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

            StreamBuilder<QuerySnapshot>(
              // Sử dụng Service thay cho Firebase trực tiếp
              stream: firestoreService.getAllBookingsForAdmin(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Text("Chưa có đơn hàng nào trên hệ thống.");
                }

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
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PopupMenuButton<String>(
                              icon: const Icon(
                                Icons.edit_calendar,
                                color: Colors.blue,
                              ),
                              tooltip: "Cập nhật trạng thái",
                              onSelected: (String newStatus) {
                                // Sử dụng Service thay cho Firebase trực tiếp
                                firestoreService.updateBookingStatus(
                                  docs[index].id,
                                  newStatus,
                                );

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
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              onPressed: () {
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
                                          // Sử dụng Service thay cho Firebase trực tiếp
                                          firestoreService.deleteBooking(
                                            docs[index].id,
                                          );
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
