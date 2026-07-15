import 'package:bookingapp/screens/booking/my_booking_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Các import của bạn
import 'package:bookingapp/screens/auth/login_screen.dart';
import 'package:bookingapp/screens/favoriters/favoriter_screen.dart';
import 'package:bookingapp/screens/auth/account_screen.dart';
import 'package:bookingapp/services/gg_map.dart';
import 'package:bookingapp/screens/search/search_screen.dart';
import 'package:bookingapp/models/room.dart';
import 'package:bookingapp/screens/search/room_detail_screen.dart'; // Sửa lại đường dẫn nơi bạn lưu file
import 'package:bookingapp/screens/search/home_search_screen.dart';

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
              child: TextField(
                readOnly: true,

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeSearchScreen()),
                  );
                },

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

            // --- DANH MỤC CATEGORY TỪ NHÁNH DEV-TRI ---
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
                  _buildCategoryIcon(
                    Icons.hotel,
                    'Khách sạn',
                    Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const SearchScreen(categoryType: 'Khách sạn'),
                        ),
                      );
                    },
                  ),
                  _buildCategoryIcon(
                    Icons.house_siding,
                    'Homestay',
                    Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const SearchScreen(categoryType: 'Homestay'),
                        ),
                      );
                    },
                  ),
                  _buildCategoryIcon(
                    Icons.holiday_village,
                    'Resort',
                    Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const SearchScreen(categoryType: 'Resort'),
                        ),
                      );
                    },
                  ),
                  _buildCategoryIcon(
                    Icons.map,
                    'Bản đồ',
                    Colors.indigo,
                    onTap: () {
                      openGoogleMap();
                    },
                  ),
                ],
              ),
            ),

            // -------------------------------------
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
            // --- GIAO DIỆN ĐỘNG: LẤY DỮ LIỆU TỪ FIREBASE TỪ ADMIN ĐẨY XUỐNG ---
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('rooms')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "Hệ thống đang cập nhật phòng mới...",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                final docs = snapshot.data!.docs;

                return SizedBox(
                  height: 210, // Tăng nhẹ chiều cao để chứa ảnh đẹp hơn
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final placeData =
                          docs[index].data() as Map<String, dynamic>;
                      final placeId = docs[index].id;

                      // Dùng hàm format tiền bạn đã có ở các file trước
                      String priceStr =
                          "${(placeData['price'] as num).toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ";

                      // 🟢 1. LẤY MÔ TẢ TỪ FIREBASE
                      String description =
                          placeData['description'] ??
                          'Chưa có mô tả cho phòng này';
                      final List<String> gallery = placeData['gallery'] != null
                          ? List<String>.from(placeData['gallery'])
                          : [];
                      final List<String> amenities =
                          placeData['amenities'] != null
                          ? List<String>.from(placeData['amenities'])
                          : [];
                      double priceVal = (placeData['price'] ?? 0).toDouble();
                      double p2 = (placeData['price2Beds'] ?? priceVal)
                          .toDouble();
                      double p3 = (placeData['price3Beds'] ?? priceVal)
                          .toDouble();
                      return _buildDynamicRoomCard(
                        context: context,
                        id: placeId,
                        title: placeData['name'] ?? 'Chưa có tên',
                        location: placeData['address'] ?? 'Đang cập nhật',
                        price: priceStr,
                        priceValue: (placeData['price'] ?? 0).toDouble(),
                        imageUrl: placeData['imageUrl'] ?? '',
                        itemType: placeData['type'] ?? 'Hotel',
                        description: description,
                        gallery: gallery,
                        amenities: amenities,
                        price2Beds: p2,
                        price3Beds: p3,
                      );
                    },
                  ),
                );
              },
            ),
            // -----------------------------------------------------------------
            const SizedBox(height: 40),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: (int index) {
          switch (index) {
            case 0:
              print("Đang ở màn hình Home");
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoriterScreen(),
                ),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyBookingScreen(),
                ),
              );
              break;
            case 3:
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccountScreen(),
                  ),
                );
              } else {
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

  // --- HÀM BUILD ICON CATEGORY VỚI HIỆU ỨNG CHẠM (INKWELL) TỪ NHÁNH DEV-TRI ---
  Widget _buildCategoryIcon(
    IconData icon,
    String title,
    Color color, {
    VoidCallback? onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16.0),
            child: Container(
              height: 60,
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
          ),
        ),
        const SizedBox(height: 8),
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
    );
  }

  // --- HÀM BUILD CARD ĐẶT PHÒNG TỪ NHÁNH DEV-TRI ---
  Widget _buildRoomCard(
    String title,
    String location,
    String price,
    Color imgColor,
  ) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
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
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 2),
                    Text(
                      location,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
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
    );
  }
}

// Hàm Build Card MỚI có chức năng load ảnh từ mạng (URL)
Widget _buildDynamicRoomCard({
  required BuildContext context,
  required String id,
  required String title,
  required String location,
  required String price,
  required double priceValue,
  required String imageUrl,
  required String itemType,
  required String description,
  required List<String> gallery,
  required List<String> amenities,
  required double price2Beds,
  required double price3Beds,
}) {
  return GestureDetector(
    onTap: () {
      // 1. GÓI DỮ LIỆU THÀNH ĐỐI TƯỢNG ROOM
      final selectedRoom = Room(
        id: id,
        title: title,
        type: itemType,
        rating: 5.0,
        price: priceValue,
        imageUrl: imageUrl,
        description: description,
        gallery: gallery,
        amenities: amenities,
        price2Beds: price2Beds,
        price3Beds: price3Beds,
      );

      // 2. NÉM QUA BOOKING SCREEN
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RoomDetailScreen(
            room: selectedRoom, // 🟢 Đã chuẩn OOP!
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
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Khối chứa ảnh tải từ mạng
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12.0),
            ),
            child: SizedBox(
              height: 100,
              width: 160,
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.blue[100],
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.blue[200],
                      child: const Icon(
                        Icons.image,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
            ),
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
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        location,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
