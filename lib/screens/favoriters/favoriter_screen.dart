import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bookingapp/models/room.dart';
import 'package:bookingapp/screens/search/room_detail_screen.dart';

class FavoriterScreen extends StatefulWidget {
  const FavoriterScreen({super.key});

  @override
  State<FavoriterScreen> createState() => _FavoriterScreenState();
}

class _FavoriterScreenState extends State<FavoriterScreen> {
  // CÁC BIẾN QUẢN LÝ BỘ LỌC
  String _selectedType = 'Tất cả';
  String _selectedRating = 'Tất cả'; // Mặc định hiển thị tất cả, khi chọn sẽ áp dụng logic 5 Sao, 4.5+,...
  String _selectedSort = 'Phổ biến nhất';
  String _searchQuery = ''; 

  // QUẢN LÝ TRẠNG THÁI XÓA
  bool _isManageMode = false; 
  final Set<String> _selectedIds = {}; 

  Future<void> _deleteSelectedRooms() async {
    final batch = FirebaseFirestore.instance.batch();
    
    for (String id in _selectedIds) {
      final docRef = FirebaseFirestore.instance.collection('favorites').doc(id);
      batch.delete(docRef);
    }

    await batch.commit(); 

    setState(() {
      _selectedIds.clear(); 
      _isManageMode = false; 
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa các mục được chọn khỏi danh sách yêu thích')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0, 
        automaticallyImplyLeading: true,
        title: const Text(
          'Yêu thích', 
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _isManageMode = !_isManageMode; 
                if (!_isManageMode) {
                  _selectedIds.clear(); 
                }
              });
            },
            child: Text(
              _isManageMode ? 'Hủy' : 'Quản lý', 
              style: TextStyle(
                color: _isManageMode ? Colors.redAccent : Colors.blue, 
                fontSize: 16,
                fontWeight: _isManageMode ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // --- Thanh tìm kiếm ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              height: 45,
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(24.0)),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Tìm kiếm trong mục yêu thích',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12.0),
                ),
              ),
            ),
          ),

          // --- Bộ lọc nhanh ---
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Row(
              children: [
                _buildFilterChip('Loại hình', _selectedType, () {
                  _showBottomSheetMenu('Chọn loại hình', ['Tất cả', 'Khách sạn', 'Homestay', 'Resort', 'Biệt thự'], _selectedType, (value) {
                    setState(() { _selectedType = value; }); 
                  });
                }),
                const SizedBox(width: 16),
                _buildFilterChip('Xếp hạng', _selectedRating, () {
                  // 🟢 Đồng bộ danh sách chọn cho khớp với logic filter bên dưới
                  _showBottomSheetMenu('Chọn xếp hạng tối thiểu', ['Tất cả', '5 Sao', '4.5+', '4.0+', '3.0+'], _selectedRating, (value) {
                    setState(() { _selectedRating = value; });
                  });
                }),
                const SizedBox(width: 16),
                _buildFilterChip('Sắp xếp', _selectedSort, () {
                   _showBottomSheetMenu('Sắp xếp theo', ['Phổ biến nhất', 'Giá thấp - cao', 'Giá cao - thấp', 'Đánh giá cao'], _selectedSort, (value) {
                    setState(() { _selectedSort = value; });
                  });
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // 🟢 STREAM BUILDER
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('favorites').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Không có mục yêu thích nào.'));
                }

                // Chuyển đổi dữ liệu từ Firestore và gán ID
                var rawData = snapshot.data!.docs.map((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  data['id'] = doc.id;
                  return data;
                }).toList();

                // 🟢 1. LOGIC LỌC DỮ LIỆU TÍCH HỢP ĐỦ THEO SAO VÀ TỪ KHÓA
                var filteredRooms = rawData.where((data) {
                  // Lọc theo tìm kiếm văn bản
                  final title = (data['title'] ?? '').toString().toLowerCase();
                  bool matchesSearch = title.contains(_searchQuery);

                  // Lọc theo loại hình nơi ở
                  final type = (data['type'] ?? '').toString();
                  bool matchesType = _selectedType == 'Tất cả' || type == _selectedType;

                  // 🟢 LOGIC LỌC THEO SỐ SAO (RATING) CHÍNH XÁC
                  final rating = (data['rating'] ?? 0.0).toDouble();
                  bool matchesRating = true;
                  
                  if (_selectedRating == '5 Sao') {
                    matchesRating = rating == 5.0; // Chỉ lấy phòng đạt tối đa 5 sao tròn
                  } else if (_selectedRating == '4.5+') {
                    matchesRating = rating >= 4.5;
                  } else if (_selectedRating == '4.0+') {
                    matchesRating = rating >= 4.0;
                  } else if (_selectedRating == '3.0+') {
                    matchesRating = rating >= 3.0;
                  }

                  return matchesSearch && matchesType && matchesRating;
                }).toList();

                // 🟢 2. LOGIC SẮP XẾP DỮ LIỆU
                if (_selectedSort == 'Giá thấp - cao') {
                  filteredRooms.sort((a, b) => (a['price'] ?? 0.0).compareTo(b['price'] ?? 0.0));
                } else if (_selectedSort == 'Giá cao - thấp') {
                  filteredRooms.sort((a, b) => (b['price'] ?? 0.0).compareTo(a['price'] ?? 0.0));
                } else if (_selectedSort == 'Đánh giá cao') {
                  filteredRooms.sort((a, b) => (b['rating'] ?? 0.0).compareTo(a['rating'] ?? 0.0));
                }

                // 🟢 3. TRẢ VỀ GIAO DIỆN SAU KHI ĐÃ LỌC & SẮP XẾP
                if (filteredRooms.isEmpty) {
                  return const Center(
                    child: Text(
                      'Không tìm thấy phòng phù hợp với bộ lọc.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                  itemCount: filteredRooms.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, 
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 0.75,
                  ),
                  itemBuilder: (context, index) {
                    return _buildFavoriteCard(filteredRooms[index]);
                  },
                );
              }
            ),
          ),

          // --- THANH CÔNG CỤ XÓA HÀNG LOẠT ---
          if (_isManageMode)
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Đã chọn: ${_selectedIds.length} mục', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    ElevatedButton(
                      onPressed: _selectedIds.isNotEmpty ? _deleteSelectedRooms : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[300],
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text('Xóa mục đã chọn', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showBottomSheetMenu(String title, List<String> options, String currentValue, Function(String) onSelected) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(padding: const EdgeInsets.all(16.0), child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
              ...options.map((option) => ListTile(
                title: Text(option, style: TextStyle(fontWeight: option == currentValue ? FontWeight.bold : FontWeight.normal, color: option == currentValue ? Colors.blueAccent : Colors.black87)),
                trailing: option == currentValue ? const Icon(Icons.check, color: Colors.blueAccent) : null,
                onTap: () { onSelected(option); Navigator.pop(context); },
              )),
              const SizedBox(height: 10),
            ],
          ),
        );
      }
    );
  }

  Widget _buildFilterChip(String title, String subtitle, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            Row(
              children: [
                Text(subtitle, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down, size: 14, color: Colors.black54),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteCard(Map<String, dynamic> data) {
    final roomId = data['id'];
    final bool isSelected = _selectedIds.contains(roomId); 
    
    // Tạo Object Room thông qua factory json mẫu của bạn
    final Room currentRoom = Room.fromJson(data);

    return GestureDetector(
      onTap: () {
        if (_isManageMode) {
          setState(() {
            if (isSelected) {
              _selectedIds.remove(roomId);
            } else {
              _selectedIds.add(roomId);
            }
          });
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RoomDetailScreen(room: currentRoom),
            ),
          );
        }
      },
      child: Dismissible(
        key: Key(roomId), 
        direction: _isManageMode ? DismissDirection.none : DismissDirection.endToStart, 
        background: Container(
          decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12.0)),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20.0),
          child: const Text('XÓA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        onDismissed: (direction) {
          FirebaseFirestore.instance.collection('favorites').doc(roomId).delete();
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            border: isSelected ? Border.all(color: Colors.blueAccent, width: 2) : null,
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(11.0)),
                      child: currentRoom.imageUrl.isNotEmpty
                          ? Image.network(currentRoom.imageUrl, fit: BoxFit.cover)
                          : Container(color: Colors.blue.shade100, child: const Icon(Icons.image, color: Colors.white)),
                    ),
                    if (!_isManageMode)
                      const Positioned(top: 8, right: 8, child: Icon(Icons.favorite, color: Colors.redAccent, size: 20)),
                    if (_isManageMode)
                      Positioned(
                        top: 4, left: 4, 
                        child: Checkbox(
                          value: isSelected, 
                          activeColor: Colors.blueAccent,
                          shape: const CircleBorder(),
                          onChanged: (value) {
                            setState(() { 
                              if (value == true) {
                                _selectedIds.add(roomId);
                              } else {
                                _selectedIds.remove(roomId);
                              }
                            });
                          }
                        )
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(currentRoom.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 12),
                            Text(currentRoom.rating.toStringAsFixed(1), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${currentRoom.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ / đêm", 
                      style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 11)
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}