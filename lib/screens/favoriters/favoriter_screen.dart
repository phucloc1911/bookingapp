import 'package:flutter/material.dart';

class FavoriterScreen extends StatefulWidget {
  const FavoriterScreen({super.key});

  @override
  State<FavoriterScreen> createState() => _FavoriterScreenState();
}

class _FavoriterScreenState extends State<FavoriterScreen> {
  // 1. CÁC BIẾN QUẢN LÝ TRẠNG THÁI BỘ LỌC
  String _selectedType = 'Tất cả';
  String _selectedRating = '4.5+';
  String _selectedSort = 'Phổ biến nhất';

  // 2. BIẾN QUẢN LÝ CHẾ ĐỘ XÓA
  bool _isManageMode = false; // Theo dõi xem có đang bật chế độ Quản lý (hiện Checkbox) không

  // 3. DANH SÁCH DỮ LIỆU PHÒNG (Dùng List để quản lý trạng thái chọn và Xóa)
  final List<Map<String, dynamic>> _favoriteRooms = [
    {'id': '1', 'title': 'Pine Hill Home...', 'rating': '4.8/5', 'price': '\$430/night', 'color': Colors.green[200], 'isSelected': false},
    {'id': '2', 'title': 'Sea Breeze Resort', 'rating': '4.7/5', 'price': '\$550/night', 'color': Colors.blue[200], 'isSelected': false},
    {'id': '3', 'title': 'Aura City Loft', 'rating': '4.7/5', 'price': '\$380/night', 'color': Colors.orange[200], 'isSelected': false},
    {'id': '4', 'title': 'A cozy cabin', 'rating': '4.7/5', 'price': '\$350/night', 'color': Colors.brown[200], 'isSelected': false},
    {'id': '5', 'title': 'A modern City Apartment', 'rating': '4.9/5', 'price': '\$120/night', 'color': Colors.grey[300], 'isSelected': false},
  ];

  // Hàm đếm xem có bao nhiêu phòng đang được tích chọn
  int get _selectedCount => _favoriteRooms.where((room) => room['isSelected'] == true).length;

  // Hàm xử lý Xóa các mục đã chọn
  void _deleteSelectedRooms() {
    setState(() {
      // Xóa tất cả các phần tử có isSelected = true
      _favoriteRooms.removeWhere((room) => room['isSelected'] == true);
      _isManageMode = false; // Xóa xong thì tắt chế độ quản lý
    });
    
    // Hiện thông báo (SnackBar) nhỏ ở dưới đáy
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã xóa các mục được chọn khỏi danh sách')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
      // ==========================================
      // APPBAR
      // ==========================================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0, 
        automaticallyImplyLeading: true,
        title: Text(
          'Yêu thích (${_favoriteRooms.length})', // Số lượng tự động cập nhật
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _isManageMode = !_isManageMode; // Đảo ngược trạng thái
                
                // Nếu người dùng bấm "Hủy" (tắt chế độ quản lý), thì xóa hết các dấu tích
                if (!_isManageMode) {
                  for (var room in _favoriteRooms) {
                    room['isSelected'] = false;
                  }
                }
              });
            },
            child: Text(
              _isManageMode ? 'Hủy' : 'Chọn tất cả', // Thay đổi chữ trên nút
              style: TextStyle(
                color: _isManageMode ? Colors.redAccent : Colors.blue, 
                fontSize: 16,
                fontWeight: _isManageMode ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),

      // ==========================================
      // BODY
      // ==========================================
      body: Column(
        children: [
          // --- Thanh tìm kiếm ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              height: 45,
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(24.0)),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm trong mục yêu thích',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12.0),
                ),
              ),
            ),
          ),

          // --- Bộ lọc nhanh ngang ---
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

          // --- Danh sách dạng Lưới (Grid) ---
          Expanded(
            child: _favoriteRooms.isEmpty 
              ? const Center(child: Text('Không có mục yêu thích nào'))
              : GridView.builder(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                  itemCount: _favoriteRooms.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, 
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 0.75,
                  ),
                  itemBuilder: (context, index) {
                    return _buildFavoriteCard(_favoriteRooms[index]);
                  },
              ),
          ),

          // --- THANH QUẢN LÝ (CHỈ HIỆN KHI BẬT CHẾ ĐỘ QUẢN LÝ) ---
          if (_isManageMode)
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Đã chọn: $_selectedCount mục', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    ElevatedButton(
                      // Nếu chưa chọn mục nào thì khóa nút bấm lại (null)
                      onPressed: _selectedCount > 0 ? _deleteSelectedRooms : null,
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

  // ==========================================
  // CÁC HÀM HỖ TRỢ VẼ GIAO DIỆN
  // ==========================================

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

  // Hàm vẽ Thẻ Phòng (Cập nhật để hỗ trợ Checkbox)
  Widget _buildFavoriteCard(Map<String, dynamic> room) {
    return GestureDetector(
      // Cho phép bấm vào thẻ để chọn khi đang ở chế độ quản lý
      onTap: () {
        if (_isManageMode) {
          setState(() {
            room['isSelected'] = !room['isSelected'];
          });
        }
      },
      child: Dismissible(
        key: Key(room['id']), 
        // Khi bật chế độ quản lý thì khóa tính năng vuốt ngang lại
        direction: _isManageMode ? DismissDirection.none : DismissDirection.endToStart, 
        
        // Giao diện khi vuốt xóa từng cái một
        background: Container(
          decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12.0)),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20.0),
          child: const Text('XÓA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        
        // Sự kiện khi người dùng vuốt xong để xóa 1 thẻ
        onDismissed: (direction) {
          setState(() {
            _favoriteRooms.removeWhere((r) => r['id'] == room['id']);
          });
        },

        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            // Đổi màu viền nếu thẻ đang được chọn
            border: room['isSelected'] ? Border.all(color: Colors.blueAccent, width: 2) : null,
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Container(decoration: BoxDecoration(color: room['color'], borderRadius: const BorderRadius.vertical(top: Radius.circular(11.0)))),
                    
                    // Nút Trái tim (Chỉ hiện khi KHÔNG ở chế độ Quản lý)
                    if (!_isManageMode)
                      const Positioned(top: 8, right: 8, child: Icon(Icons.favorite, color: Colors.redAccent, size: 20)),
                    
                    // Ô Checkbox (Chỉ hiện khi ĐANG ở chế độ Quản lý)
                    if (_isManageMode)
                      Positioned(
                        top: 4, 
                        left: 4, 
                        child: Checkbox(
                          value: room['isSelected'], 
                          activeColor: Colors.blueAccent,
                          shape: const CircleBorder(), // Ô checkbox hình tròn nhìn hiện đại hơn
                          onChanged: (value) {
                            setState(() { room['isSelected'] = value ?? false; });
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
                        Expanded(child: Text(room['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 12),
                            Text(room['rating'], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.pool, size: 10, color: Colors.grey[600]),
                        const SizedBox(width: 2),
                        Text('Pool', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                        const SizedBox(width: 6),
                        Icon(Icons.wifi, size: 10, color: Colors.grey[600]),
                        const SizedBox(width: 2),
                        Text('Free Wifi', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(room['price'], style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 12)),
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