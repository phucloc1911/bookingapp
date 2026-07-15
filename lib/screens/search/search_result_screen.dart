import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bookingapp/models/room.dart';

import 'package:bookingapp/screens/search/room_detail_screen.dart';

class SearchResultScreen extends StatelessWidget {
  final String keyword;

  const SearchResultScreen({super.key, required this.keyword});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Kết quả tìm kiếm",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("rooms").snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text("Không có dữ liệu"));
          }
          final rooms = snapshot.data!.docs;
          final result = rooms.where((doc) {
            final data = doc.data() as Map<String, dynamic>;

            final name = data["name"].toString().toLowerCase();

            final address = data["address"].toString().toLowerCase();

            return name.contains(keyword.toLowerCase()) ||
                address.contains(keyword.toLowerCase());
          }).toList();
          if (result.isEmpty) {
            return const Center(
              child: Text(
                "Không tìm thấy kết quả",
                style: TextStyle(fontSize: 18),
              ),
            );
          }
          return ListView.builder(
            itemCount: result.length,
            itemBuilder: (context, index) {
              final data = result[index].data() as Map<String, dynamic>;

              final roomData = result[index].data() as Map<String, dynamic>;

              final roomId = result[index].id;

              final String name = roomData["name"] ?? "";

              final String location = roomData["address"] ?? "";

              final int price = (roomData["price"] ?? 0).toInt();

              final String imageUrl = roomData["imageUrl"] ?? "";

              final String description = roomData["description"] ?? "";

              final List<String> gallery = roomData["gallery"] != null
                  ? List<String>.from(roomData["gallery"])
                  : [];

              final List<String> amenities = roomData["amenities"] != null
                  ? List<String>.from(roomData["amenities"])
                  : [];

              double priceVal = (roomData["price"] ?? 0).toDouble();

              double p2 = (roomData["price2Beds"] ?? priceVal).toDouble();

              double p3 = (roomData["price3Beds"] ?? priceVal).toDouble();

              final String type = roomData["type"] ?? "";
              return _buildRoomCard(
                context,

                name,

                location,

                price,

                imageUrl,

                roomId,

                type,

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
}

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
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
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
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
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
                          builder: (_) => RoomDetailScreen(room: selectedRoom),
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
