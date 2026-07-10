import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart'; // Import thư viện shimmer
import 'package:bookingapp/models/room.dart'; // Nhớ Import trang BookingScreen để xài cho nút "Xem phòng"
import 'package:bookingapp/screens/booking/booking_screen.dart'; // Sửa lại đường dẫn nếu cần
import 'package:bookingapp/screens/search/room_detail_screen.dart'; // Sửa lại đường dẫn nơi bạn lưu file

class SearchScreen extends StatelessWidget {
  final String categoryType;

  const SearchScreen({super.key, required this.categoryType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        title: Text(
          'Danh sách $categoryType',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: StreamBuilder<QuerySnapshot>(
        // 🟢 ĐÃ CHUYỂN VỀ BẢNG 'rooms' CHO KHỚP VỚI FIREBASE CỦA BẠN
        stream: FirebaseFirestore.instance
            .collection('rooms')
            .where('type', isEqualTo: categoryType)
            .snapshots(),
        builder: (context, snapshot) {
          // 1. TRẠNG THÁI ĐANG TẢI (Hiện khung xương Shimmer)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: 3,
              itemBuilder: (context, index) {
                return const RoomSkeleton();
              },
            );
          }

          // 2. Nếu có lỗi xảy ra
          if (snapshot.hasError) {
            return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
          }

          // 3. Nếu Không có dữ liệu
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off_rounded,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Hiện chưa có $categoryType nào.',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          // 4. TRẠNG THÁI CÓ DỮ LIỆU: Đổ ra danh sách thẻ phòng thật
          final rooms = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final roomData = rooms[index].data() as Map<String, dynamic>;
              final roomId = rooms[index].id;

              final String name = roomData['name'] ?? 'Chưa cập nhật tên';
              // 🟢 Dùng trường 'address' thay vì 'location' để chuẩn với Firebase
              final String location =
                  roomData['address'] ?? 'Chưa cập nhật địa chỉ';

              // Ép kiểu an toàn cho giá tiền
              final int price = (roomData['price'] ?? 0).toInt();

              final String imageUrl = roomData['imageUrl'] ?? '';
              final String description =
                  roomData['description'] ?? 'Chưa có mô tả cho phòng này';
              final List<String> gallery = roomData['gallery'] != null
                  ? List<String>.from(roomData['gallery'])
                  : [];
              final List<String> amenities = roomData['amenities'] != null
                  ? List<String>.from(roomData['amenities'])
                  : [];
              double priceVal = (roomData['price'] ?? 0).toDouble();
              double p2 = (roomData['price2Beds'] ?? priceVal).toDouble();
              double p3 = (roomData['price3Beds'] ?? priceVal).toDouble();
              return _buildRoomCard(
                context,
                name,
                location,
                price,
                imageUrl,
                roomId,
                categoryType,
                description,
                gallery,
                amenities,
                p2,
                p3,
              );
            },
          );
        },
      ),
    );
  }

  // --- WIDGET XÂY DỰNG GIAO DIỆN TỪNG THẺ PHÒNG THẬT ---
  Widget _buildRoomCard(
    BuildContext context,
    String name,
    String location,
    int price,
    String imageUrl,
    String roomId,
    String itemType,
    String description,
    List<String> gallery,
    List<String> amenities,
    double price2Beds,
    double price3Beds,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Khối 1: Ảnh đại diện từ mạng (URL)
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16.0),
            ),
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildImagePlaceholder(),
                  )
                : _buildImagePlaceholder(),
          ),

          // Khối 2: Thông tin chữ
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Giá mỗi đêm từ',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),

                    ElevatedButton(
                      onPressed: () {
                        // 1. GÓI DỮ LIỆU THÀNH ĐỐI TƯỢNG ROOM TRƯỚC
                        final selectedRoom = Room(
                          id: roomId,
                          title: name,
                          type: itemType,
                          rating: 5.0, // Mặc định 5 sao
                          price: price.toDouble(),
                          imageUrl: imageUrl,
                          description: description,
                          gallery: gallery,
                          amenities: amenities,
                          price2Beds: price2Beds,
                          price3Beds: price3Beds,
                        );

                        // 2. TRUYỀN ĐỐI TƯỢNG ROOM SANG TRANG BOOKING
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                RoomDetailScreen(room: selectedRoom),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Xem phòng',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 180,
      width: double.infinity,
      color: Colors.blue[50],
      child: Icon(Icons.apartment_rounded, size: 60, color: Colors.blue[200]),
    );
  }
}

// ==============================================================
// WIDGET KHUNG XƯƠNG (SKELETON) ĐƯỢC TÁCH RA ĐỂ TÁI SỬ DỤNG
// ==============================================================
class RoomSkeleton extends StatelessWidget {
  const RoomSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 180,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 18,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(height: 18, width: 200, color: Colors.white),
                  const SizedBox(height: 16),

                  Container(height: 14, width: 150, color: Colors.white),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(height: 12, width: 80, color: Colors.white),
                          const SizedBox(height: 8),
                          Container(
                            height: 20,
                            width: 120,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      Container(
                        height: 40,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ],
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
