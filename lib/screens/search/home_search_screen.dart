import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'search_result_screen.dart';

class HomeSearchScreen extends StatefulWidget {
  const HomeSearchScreen({super.key});

  @override
  State<HomeSearchScreen> createState() => _HomeSearchScreenState();
}

class _HomeSearchScreenState extends State<HomeSearchScreen> {
  String query = "";
  final List<String> popularPlaces = [
    "Đà Lạt",
    "Đà Nẵng",
    "Nha Trang",
    "Vũng Tàu",
    "Phú Quốc",
    "Hà Nội",
    "TP Hồ Chí Minh",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: TextField(
          autofocus: true,

          onChanged: (value) {
            setState(() {
              query = value;
            });
          },

          onSubmitted: (value) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SearchResultScreen(keyword: value),
              ),
            );
          },

          decoration: const InputDecoration(
            hintText: "Bạn muốn tìm phòng ở đâu?",
            border: InputBorder.none,
          ),
        ),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection("rooms").get(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text("Không có dữ liệu"));
          }

          final rooms = snapshot.data!.docs;
          final search = query.trim();

          if (search.isEmpty) {
            return const Center(
              child: Text(
                "Hãy nhập tên khách sạn hoặc địa điểm",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final placeSuggestions = popularPlaces.where((place) {
            return place.toLowerCase().contains(search.toLowerCase());
          }).toList();
          final result = rooms.where((doc) {
            final data = doc.data() as Map<String, dynamic>;

            final name = (data["name"] ?? "").toString().toLowerCase();

            final address = (data["address"] ?? "").toString().toLowerCase();

            final type = (data["type"] ?? "").toString().toLowerCase();

            return name.contains(search.toLowerCase()) ||
                address.contains(search.toLowerCase()) ||
                type.contains(search.toLowerCase());
          }).toList();

          if (result.isEmpty && placeSuggestions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 70, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text(
                    "Không tìm thấy kết quả",
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ĐỊA ĐIỂM
              if (placeSuggestions.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    "Địa điểm",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),

              ...placeSuggestions.map((place) {
                return ListTile(
                  leading: const Icon(Icons.location_on, color: Colors.red),
                  title: Text(place),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SearchResultScreen(keyword: place),
                      ),
                    );
                  },
                );
              }),

              if (placeSuggestions.isNotEmpty) const Divider(),

              // DANH SÁCH KHÁCH SẠN
              ...result.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final image = data["imageUrl"] ?? "";

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            SearchResultScreen(keyword: data["name"]),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                          ),
                          child: image.isNotEmpty
                              ? Image.network(
                                  image,
                                  width: 90,
                                  height: 80,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 90,
                                  height: 80,
                                  color: Colors.blue[50],
                                  child: const Icon(Icons.hotel),
                                ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data["name"],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(data["address"]),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}
