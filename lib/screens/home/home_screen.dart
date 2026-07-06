import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bookingapp/screens/auth/login_screen.dart';
import 'package:bookingapp/screens/favoriters/favoriter_screen.dart';
import 'package:bookingapp/screens/auth/account_screen.dart';
import 'package:bookingapp/services/gg_map.dart';
import 'package:bookingapp/screens/booking/my_booking_screen.dart'; //
import 'package:bookingapp/screens/booking/booking_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(25.0)),
        ),
        centerTitle: false,
        titleSpacing: 10.0,
        title: Image.asset(
          'assets/images/logofull.png',
          height: 100,
          fit: BoxFit.contain,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70.0),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.0),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Bạn muốn tìm phòng ở đâu?',
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.search, color: Colors.blueAccent),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14.0),
                ),
              ),
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: PageView(
                children: [
                  _buildBannerCard(
                    Colors.blue[400]!,
                    'Sale Hè Rực Rỡ\nGiảm đến 50% Khách Sạn',
                  ),
                  _buildBannerCard(
                    Colors.teal[400]!,
                    'Homestay Đà Lạt\nChỉ từ 199k/đêm',
                  ),
                  _buildBannerCard(
                    Colors.orange[400]!,
                    'Hoàn tiền 10%\nkhi thanh toán qua Thẻ',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Khám phá loại hình lưu trú',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.8,
                children: [
                  _buildCategoryIcon(Icons.hotel, 'Khách sạn', Colors.blue),
                  _buildCategoryIcon(
                    Icons.house_siding,
                    'Homestay',
                    Colors.green,
                  ),
                  _buildCategoryIcon(
                    Icons.holiday_village,
                    'Resort',
                    Colors.orange,
                  ),
                  _buildCategoryIcon(
                    Icons.local_offer,
                    'Khuyến mãi',
                    Colors.redAccent,
                  ),
                  _buildCategoryIcon(
                    Icons.map,
                    'Bản đồ',
                    Colors.indigo,
                    onTap: () {
                      openGoogleMap();
                    },
                  ),
                  _buildCategoryIcon(Icons.more_horiz, 'Xem thêm', Colors.grey),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Phòng nổi bật giá tốt',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  _buildRoomCard(
                    context,
                    'room_muongthanh_01',
                    'Khách sạn Mường Thanh',
                    'Đà Nẵng',
                    '850.000 đ',
                    850000,
                    Colors.blue[200]!,
                  ),
                  _buildRoomCard(
                    context,
                    'room_chillhomestay_01',
                    'Chill Homestay',
                    'Đà Lạt',
                    '350.000 đ',
                    350000,
                    Colors.green[200]!,
                  ),
                  _buildRoomCard(
                    context,
                    'room_vinpearl_01',
                    'Vinpearl Resort',
                    'Nha Trang',
                    '2.500.000 đ',
                    2500000,
                    Colors.orange[200]!,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("Nút Add được bấm!");
        },
        backgroundColor: Colors.blueAccent, // Cùng màu với theme app
        child: const Icon(Icons.add, color: Colors.white),
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: (int index) {
          switch (index) {
            case 0: // Nút Home
              // Thường không làm gì vì đang ở Home rồi
              print("Đang ở màn hình Home");
              break;

            case 1: // Nút Favorites (Yêu thích)
              // Chuyển sang trang Favorites
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoriterScreen(),
                ),
              );
              break;

            case 2: // Nút My Booking (Lịch sử đặt phòng)
              print("Đã bấm vào My Booking");
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyBookingScreen(),
                ),
              );
              break;

            case 3: // Nút Account (Tài khoản)
              // 1. Kiểm tra xem Firebase đã ghi nhận có người đăng nhập chưa
              final user = FirebaseAuth.instance.currentUser;

              if (user != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccountScreen(),
                  ),
                );
              } else {
                // CHƯA ĐĂNG NHẬP: Bắt về trang Login
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: "Favorites",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: "My Booking",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Account",
          ),
        ],
      ),
    );
  }

  Widget _buildBannerCard(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16.0),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // Thêm {VoidCallback? onTap} vào trong ngoặc để hàm có thể nhận sự kiện bấm
  Widget _buildCategoryIcon(
    IconData icon,
    String title,
    Color color, {
    VoidCallback? onTap,
  }) {
    // Bọc toàn bộ ô icon bằng GestureDetector (hoặc InkWell) để bắt sự kiện chạm
    return GestureDetector(
      onTap: onTap, // Gắn lệnh onTap truyền từ ngoài vào đây
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Khối chứa Icon
          Container(
            height:
                60, // Kích thước khung icon (bạn có thể chỉnh lại cho khớp với code cũ)
            width: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),

          // Chữ bên dưới Icon
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Thêm {required BuildContext context, required double priceValue} để truyền sang
  Widget _buildRoomCard(
    BuildContext context,
    String id,
    String title,
    String location,
    String price,
    double priceValue,
    Color imgColor,
  ) {
    return GestureDetector(
      onTap: () {
        // KHI BẤM VÀO PHÒNG -> MỞ TRANG ĐẶT PHÒNG NGAY
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BookingScreen(
              itemId: id,
              itemTitle: title,
              itemType: 'Hotel',
              pricePerNight: priceValue,
              imgColor: imgColor,
            ),
          ),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: imgColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12.0),
                ),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.image, color: Colors.white, size: 40),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        location,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    price,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
