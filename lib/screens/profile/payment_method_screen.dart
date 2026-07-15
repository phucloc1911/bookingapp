import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  // Biến lưu phương thức đang được chọn
  String _selectedMethod = 'momo';
  bool _isLoading = false;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadSavedPaymentMethod();
  }

  // 1. Hàm tự động tải phương thức đã lưu từ Firebase về
  Future<void> _loadSavedPaymentMethod() async {
    if (currentUser != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      if (doc.exists &&
          doc.data() != null &&
          doc.data()!.containsKey('defaultPaymentMethod')) {
        setState(() {
          _selectedMethod = doc.data()!['defaultPaymentMethod'];
        });
      }
    }
  }

  // Hàm lưu phương thức lên Firebase
  Future<void> _savePaymentMethod() async {
    if (currentUser == null) return;

    setState(() {
      _isLoading = true;
    });
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .set(
            {'defaultPaymentMethod': _selectedMethod},
            SetOptions(merge: true),
          ); // Dùng merge để không bị xóa mất tên, sđt cũ

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Đã lưu phương thức thanh toán mặc định!"),
        ),
      );
      Navigator.pop(context); // Trở về trang Account
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi khi lưu: $e")));
    } finally {
      if (mounted)
        setState(() {
          _isLoading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF0066FF);

    return Scaffold(
      backgroundColor: const Color(
        0xFFF5F7FA,
      ), // Tone xám xanh siêu nhạt đồng bộ
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        title: const Text(
          "Phương thức thanh toán",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Chọn phương thức mặc định cho các đơn đặt phòng tiếp theo của bạn:",
              style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.4),
            ),
            const SizedBox(height: 20),

            // DANH SÁCH 4 PHƯƠNG THỨC THANH TOÁN
            const SizedBox(height: 14),

            _buildPaymentCard(
              id: 'vnpay',
              title: 'VNPAY QR / Thẻ ATM',
              subtitle: 'Quét mã VietQR hoặc dùng thẻ nội địa',
              iconData: Icons.qr_code_scanner_rounded,
              iconColor: primaryBlue,
              badgeText: 'Phổ biến',
              badgeColor: Colors.blue.shade50,
              badgeTextColor: primaryBlue,
            ),

            const SizedBox(height: 14),

            _buildPaymentCard(
              id: 'hotel_pay',
              title: 'Thanh toán tại khách sạn',
              subtitle: 'Trả tiền mặt hoặc quẹt thẻ khi nhận phòng',
              iconData: Icons.storefront_rounded,
              iconColor: Colors.orange.shade700,
              badgeText: 'Miễn phí hủy',
              badgeColor: Colors.orange.shade50,
              badgeTextColor: Colors.orange.shade800,
            ),

            const SizedBox(height: 40),

            // NÚT LƯU THAY ĐỔI
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _isLoading ? null : _savePaymentMethod,
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        "LƯU PHƯƠNG THỨC MẶC ĐỊNH",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget vẽ từng thẻ thanh toán bo tròn xịn sò
  Widget _buildPaymentCard({
    required String id,
    required String title,
    required String subtitle,
    required IconData iconData,
    required Color iconColor,
    String? badgeText,
    Color? badgeColor,
    Color? badgeTextColor,
  }) {
    final bool isSelected = _selectedMethod == id;
    const Color primaryBlue = Color(0xFF0066FF);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = id;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          // Nếu được chọn thì hiện viền xanh đậm xịn sò
          border: Border.all(
            color: isSelected ? primaryBlue : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? primaryBlue.withOpacity(0.12)
                  : Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon phương thức
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(iconData, color: iconColor, size: 28),
            ),
            const SizedBox(width: 14),

            // Tên và mô tả
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (badgeText != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: badgeColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badgeText,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: badgeTextColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            // Nút Radio tick chọn
            Radio<String>(
              value: id,
              groupValue: _selectedMethod,
              activeColor: primaryBlue,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedMethod = value;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
