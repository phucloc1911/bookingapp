import 'package:bookingapp/screens/profile/payment_method_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:bookingapp/screens/auth/login_screen.dart';
import '../profile/edit_profile_screen.dart';
import '../profile/about_screen.dart';
import '../profile/help_center_screen.dart';
import '../profile/security_screen.dart';
import 'package:bookingapp/screens/favoriters/favoriter_screen.dart';

import '../admin/admin_dashboard_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  // Hàm xử lý Đăng xuất
  Future<void> _signOut() async {
    // Hiện bảng hỏi xác nhận cho chuyên nghiệp
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Đăng xuất",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text("Bạn có chắc chắn muốn đăng xuất khỏi Reservo?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Đăng xuất",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await GoogleSignIn.instance.signOut();
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;
      // Trở về trang Đăng nhập và xóa sạch lịch sử trang
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi đăng xuất: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Màu xanh chuẩn theo file image_bfe115.jpg
    const Color primaryBlue = Color(0xFF0066FF);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Màu nền xám xanh siêu nhạt
      body: SingleChildScrollView(
        child: Column(
          children: [
            // CỤM HEADER & THẺ PROFILE OVERLAP
            Stack(
              clipBehavior: Clip.none,
              children: [
                // 1. Nền xanh phía trên (Cắt ngang vát nhẹ)
                Container(
                  height: 230,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: primaryBlue,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(32),
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 10.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Tài khoản",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.notifications_none_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 2. Thẻ Profile trắng nằm đè lên
                Padding(
                  padding: const EdgeInsets.only(top: 110, left: 20, right: 20),
                  child: FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(currentUser?.uid)
                        .get(),
                    builder: (context, snapshot) {
                      String name = "Đang tải...";
                      String email = currentUser?.email ?? "Không có email";
                      bool isAdmin = false;
                      String phone = "Chưa cập nhật";

                      if (snapshot.hasData && snapshot.data!.exists) {
                        final data =
                            snapshot.data!.data() as Map<String, dynamic>;
                        name =
                            data['name'] ??
                            currentUser?.displayName ??
                            "Người dùng Reservo";
                        phone = data['phoneNumber'] ?? "Chưa cập nhật";
                        if (data['role'] == 'admin') {
                          isAdmin = true;
                        }
                      }

                      return Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                // Avatar
                                CircleAvatar(
                                  radius: 36,
                                  backgroundColor: primaryBlue.withOpacity(0.1),
                                  backgroundImage: currentUser?.photoURL != null
                                      ? NetworkImage(currentUser!.photoURL!)
                                      : null,
                                  child: currentUser?.photoURL == null
                                      ? const Icon(
                                          Icons.person,
                                          size: 36,
                                          color: primaryBlue,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 16),

                                // Thông tin
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        email,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Divider(height: 1),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // DANH SÁCH CHỨC NĂNG (MENU)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 10),
                    child: Text(
                      "HỒ SƠ CỦA TÔI",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  _buildOptionGroup([
                    _buildTile(
                      Icons.person_outline_rounded,
                      "Chỉnh sửa thông tin",
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EditProfileScreen(),
                          ),
                        );
                      },
                    ),
                    _buildTile(
                      Icons.bookmark_border_rounded,
                      "Lịch sử đặt phòng",
                      () {},
                    ),
                    _buildTile(
                      Icons.favorite_border_rounded,
                      "Khách sạn yêu thích",
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FavoriterScreen(),
                          ),
                        );
                      },
                    ),
                  ]),

                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 10),
                    child: Text(
                      "CÀI ĐẶT & HỖ TRỢ",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  _buildOptionGroup([
                    _buildTile(
                      Icons.credit_card_rounded,
                      "Phương thức thanh toán",
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PaymentMethodScreen(),
                          ),
                        );
                      },
                    ),
                    _buildTile(Icons.security_rounded, "Bảo mật tài khoản", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SecurityScreen(),
                        ),
                      );
                    }),
                    _buildTile(
                      Icons.help_outline_rounded,
                      "Trung tâm trợ giúp",
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HelpCenterScreen(),
                          ),
                        );
                      },
                    ),
                    _buildTile(
                      Icons.info_outline_rounded,
                      "Về Reservo App",
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AboutScreen(),
                          ),
                        );
                      },
                    ),
                  ]),
                  const SizedBox(height: 30),

                  // 🟢 NÚT ĐẶC QUYỀN CHỈ HIỆN CHO ADMIN
                  // =======================================================
                  // 🟢 KHỐI MENU DÀNH RIÊNG CHO ADMIN (Tự động kiểm tra quyền)
                  // =======================================================
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(currentUser?.uid)
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!.exists) {
                        final data =
                            snapshot.data!.data() as Map<String, dynamic>;
                        // Kiểm tra nếu có trường role là admin thì mới hiện
                        if (data['role'] == 'admin') {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 4, bottom: 10),
                                child: Text(
                                  "QUẢN TRỊ VIÊN",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ),
                              _buildOptionGroup([
                                _buildTile(
                                  Icons.admin_panel_settings,
                                  "Bảng điều khiển Admin",
                                  () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const AdminDashboardScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ]),
                              const SizedBox(height: 30),
                            ],
                          );
                        }
                      }
                      // Nếu không phải admin, trả về một khoảng trống tàng hình (không hiện gì cả)
                      return const SizedBox.shrink();
                    },
                  ),
                  // =======================================================

                  // NÚT ĐĂNG XUẤT ĐỎ NỔI BẬT
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.redAccent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: Colors.red.shade200,
                            width: 1.5,
                          ),
                        ),
                      ),

                      icon: const Icon(Icons.logout_rounded, size: 22),
                      label: const Text(
                        "Đăng xuất khỏi tài khoản",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: _signOut,
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget hỗ trợ hiển thị 3 con số thống kê nhanh
  Widget _buildQuickStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0066FF),
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  // Widget Gom nhóm các Item lại vào chung 1 khối trắng bo tròn
  Widget _buildOptionGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  // Widget từng dòng Menu
  Widget _buildTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF0066FF).withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF0066FF), size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }
}
