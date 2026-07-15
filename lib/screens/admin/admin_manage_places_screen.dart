import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminManagePlacesScreen extends StatefulWidget {
  const AdminManagePlacesScreen({super.key});

  @override
  State<AdminManagePlacesScreen> createState() =>
      _AdminManagePlacesScreenState();
}

class _AdminManagePlacesScreenState extends State<AdminManagePlacesScreen> {
  // Biến cho Form thêm mới
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _price2Ctrl = TextEditingController(); // Giá 2 giường
  final _price3Ctrl = TextEditingController(); // Giá 3 giường
  String _selectedType = 'Khách sạn';

  // Biến lưu danh sách tiện nghi Admin chọn
  final List<String> _selectedAmenities = [];
  final List<String> _allAmenities = [
    "Wifi Miễn phí",
    "Đỗ xe",
    "Hồ bơi",
    "Máy lạnh",
    "Nhà hàng",
    "Lễ tân 24/7",
  ];
  final _galleryCtrl = TextEditingController();
  // Hàm mở Dialog Form
  void _showAddDialog() {
    _selectedAmenities.clear(); // Xóa dữ liệu cũ khi mở form mới
    _descCtrl.clear();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          // Dùng StatefulBuilder để Checkbox trong Dialog có thể check/uncheck được
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                "Thêm nơi lưu trú mới",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ... (Giữ nguyên các TextField Nhập tên, địa chỉ, giá, link ảnh của bạn ở đây) ...
                    TextField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: "Tên địa điểm",
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedType, // Biến này lưu giá trị đang chọn
                      decoration: const InputDecoration(
                        labelText: "Loại hình lưu trú",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      items: ['Khách sạn', 'Homestay', 'Resort'].map((
                        String type,
                      ) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(
                            type,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setDialogState(() {
                            _selectedType =
                                newValue; // Cập nhật khi Admin chọn dòng khác
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _addressCtrl,
                      decoration: const InputDecoration(labelText: "Địa chỉ"),
                    ),
                    TextField(
                      controller: _priceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Giá một đêm",
                      ),
                    ),
                    TextField(
                      controller: _priceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Giá 1 giường / 1 đêm",
                      ),
                    ),

                    TextField(
                      controller: _price2Ctrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Giá 2 giường / 1 đêm",
                      ),
                    ),
                    TextField(
                      controller: _price3Ctrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Giá 3 giường / 1 đêm",
                      ),
                    ),
                    TextField(
                      controller: _imageCtrl,
                      decoration: const InputDecoration(
                        labelText: "Link ảnh đại diện chính",
                      ),
                    ),

                    TextField(
                      controller: _galleryCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText:
                            "Link các ảnh phụ (cách nhau bằng dấu phẩy ,)",
                      ),
                    ),

                    TextField(
                      controller: _descCtrl,
                      maxLines: 3, // Cho phép nhập dài 3 dòng
                      decoration: const InputDecoration(
                        labelText: "Mô tả chi tiết phòng",
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      "Tiện nghi nổi bật:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Wrap(
                      children: _allAmenities.map((amenity) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              value: _selectedAmenities.contains(amenity),
                              onChanged: (bool? checked) {
                                setDialogState(() {
                                  if (checked == true) {
                                    _selectedAmenities.add(amenity);
                                  } else {
                                    _selectedAmenities.remove(amenity);
                                  }
                                });
                              },
                            ),
                            Text(amenity, style: const TextStyle(fontSize: 12)),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Hủy"),
                ),
                ElevatedButton(
                  onPressed: _saveRoomToFirebase,
                  child: const Text("Lưu Lên App"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _saveRoomToFirebase() async {
    if (_nameCtrl.text.isEmpty || _priceCtrl.text.isEmpty) return;

    try {
      await FirebaseFirestore.instance.collection('rooms').add({
        'name': _nameCtrl.text.trim(),
        'type': _selectedType,
        'address': _addressCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'price': double.tryParse(_priceCtrl.text.trim()) ?? 0,
        'imageUrl': _imageCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'amenities': _selectedAmenities,

        'starRating': 5.0, // Tạm fix cứng 5 sao
        'createdAt': FieldValue.serverTimestamp(),
        // Xử lý chuỗi gallery thành 1 cái mảng (List)
        'gallery': _galleryCtrl.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        'price2Beds': double.tryParse(_price2Ctrl.text.trim()) ?? 0,
        'price3Beds': double.tryParse(_price3Ctrl.text.trim()) ?? 0,
      });

      if (!mounted) return;
      Navigator.pop(context); // Tắt dialog
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Đã thêm thành công!")));

      // Xóa form cũ
      _nameCtrl.clear();
      _addressCtrl.clear();
      _priceCtrl.clear();
      _imageCtrl.clear();
      _descCtrl.clear();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    }
  }

  // Hàm xóa dữ liệu
  void _deleteRoom(String docId) {
    FirebaseFirestore.instance.collection('rooms').doc(docId).delete();
  }

  // 1. Hàm tiện ích dọn dẹp Form (để tái sử dụng cho gọn)
  void _clearForm() {
    _nameCtrl.clear();
    _addressCtrl.clear();
    _priceCtrl.clear();
    _imageCtrl.clear();
    _descCtrl.clear();
    _galleryCtrl.clear();
    _selectedAmenities.clear();
    _price2Ctrl.clear();
    _price3Ctrl.clear();
  }

  // 2. Hàm mở Dialog Chỉnh sửa
  void _showEditDialog(String docId, Map<String, dynamic> data) {
    // Đổ dữ liệu cũ vào form
    _nameCtrl.text = data['name'] ?? '';
    _addressCtrl.text = data['address'] ?? '';
    _selectedType = data['type'] ?? 'Khách sạn';
    _priceCtrl.text = (data['price'] ?? 0).toString();
    _price2Ctrl.text = (data['price2Beds'] ?? data['price'] ?? 0).toString();
    _price3Ctrl.text = (data['price3Beds'] ?? data['price'] ?? 0).toString();

    _imageCtrl.text = data['imageUrl'] ?? '';
    _descCtrl.text = data['description'] ?? '';

    // Đổ danh sách ảnh phụ
    if (data['gallery'] != null) {
      _galleryCtrl.text = (data['gallery'] as List).join(', ');
    } else {
      _galleryCtrl.clear();
    }

    // Đổ danh sách tiện nghi
    _selectedAmenities.clear();
    if (data['amenities'] != null) {
      _selectedAmenities.addAll(List<String>.from(data['amenities']));
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                "Sửa thông tin lưu trú",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: "Tên địa điểm",
                      ),
                    ),
                    TextField(
                      controller: _addressCtrl,
                      decoration: const InputDecoration(labelText: "Địa chỉ"),
                    ),

                    TextField(
                      controller: _priceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Giá 1 giường / 1 đêm",
                      ),
                    ),
                    TextField(
                      controller: _price2Ctrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Giá 2 giường / 1 đêm",
                      ),
                    ),
                    TextField(
                      controller: _price3Ctrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Giá 3 giường / 1 đêm",
                      ),
                    ),

                    TextField(
                      controller: _imageCtrl,
                      decoration: const InputDecoration(
                        labelText: "Link ảnh đại diện chính",
                      ),
                    ),
                    TextField(
                      controller: _galleryCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText:
                            "Link các ảnh phụ (cách nhau bằng dấu phẩy ,)",
                      ),
                    ),
                    TextField(
                      controller: _descCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: "Mô tả chi tiết phòng",
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Tiện nghi nổi bật:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Wrap(
                      children: _allAmenities.map((amenity) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              value: _selectedAmenities.contains(amenity),
                              onChanged: (bool? checked) {
                                setDialogState(() {
                                  if (checked == true) {
                                    _selectedAmenities.add(amenity);
                                  } else {
                                    _selectedAmenities.remove(amenity);
                                  }
                                });
                              },
                            ),
                            Text(amenity, style: const TextStyle(fontSize: 12)),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _clearForm();
                  },
                  child: const Text(
                    "Hủy",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _updateRoomInFirebase(docId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                  ),
                  child: const Text(
                    "Cập nhật",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 3. Hàm đẩy dữ liệu đã sửa lên Firebase
  // 3. Hàm đẩy dữ liệu đã sửa lên Firebase
  Future<void> _updateRoomInFirebase(String docId) async {
    if (_nameCtrl.text.isEmpty || _priceCtrl.text.isEmpty) return;

    try {
      await FirebaseFirestore.instance.collection('rooms').doc(docId).update({
        'name': _nameCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),

        'price': double.tryParse(_priceCtrl.text.trim()) ?? 0,
        'price2Beds': double.tryParse(_price2Ctrl.text.trim()) ?? 0,
        'price3Beds': double.tryParse(_price3Ctrl.text.trim()) ?? 0,
        'type': _selectedType,
        'imageUrl': _imageCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'amenities': _selectedAmenities,
        'gallery': _galleryCtrl.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
      });

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Đã cập nhật thành công!")));
      _clearForm(); // Cập nhật xong thì xóa sạch form
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi cập nhật: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Quản lý Lưu trú",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.redAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('rooms')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
            return const Center(
              child: Text("Chưa có dữ liệu nào. Bấm + để thêm."),
            );

          final docs = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return Card(
                child: ListTile(
                  leading: (data['imageUrl'] != null && data['imageUrl'] != '')
                      ? Image.network(
                          data['imageUrl'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => const Icon(Icons.image),
                        )
                      : const Icon(Icons.hotel, size: 40),
                  title: Text(
                    data['name'] ?? 'Chưa có tên',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "${data['type']} - ${data['price']} đ\n${data['address'] ?? ''}",
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Nút Sửa
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showEditDialog(
                          docs[index].id,
                          data,
                        ), // Truyền ID và dữ liệu vào form Sửa
                      ),
                      // Nút Xóa
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          // Thêm bảng hỏi xác nhận cho an toàn (Tránh bấm nhầm)
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("Xác nhận xóa"),
                              content: const Text(
                                "Bạn có chắc chắn muốn xóa phòng này khỏi hệ thống?",
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
                                    _deleteRoom(docs[index].id);
                                  },
                                  child: const Text(
                                    "Xóa ngay",
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        backgroundColor: Colors.blueAccent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Thêm mới",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
