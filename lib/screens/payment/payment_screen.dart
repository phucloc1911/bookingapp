import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bookingapp/screens/booking/my_booking_screen.dart'; // Sửa lại đường dẫn import nếu cần

class PaymentGatewayScreen extends StatefulWidget {
  final Map<String, dynamic>
  bookingData; // Dữ liệu đơn phòng mang từ trang trước sang
  final String
  paymentMethod; // 'Ví MoMo', 'VNPAY QR / Thẻ ATM', hoặc 'Ví ZaloPay'

  const PaymentGatewayScreen({
    super.key,
    required this.bookingData,
    required this.paymentMethod,
  });

  @override
  State<PaymentGatewayScreen> createState() => _PaymentGatewayScreenState();
}

class _PaymentGatewayScreenState extends State<PaymentGatewayScreen> {
  int _secondsRemaining = 300; // Đếm ngược 5 phút (300 giây)
  Timer? _timer;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer?.cancel();
        _showTimeoutDialog();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Format giây thành chuỗi 05:00
  String get _formattedTime {
    int minutes = _secondsRemaining ~/ 60;
    int seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Hàm tự động thêm dấu chấm vào tiền
  String _formatCurrency(double amount) {
    return "${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ";
  }

  // Khi hết giờ thanh toán
  void _showTimeoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Hết gian thanh toán",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
        ),
        content: const Text(
          "Đơn giữ phòng của bạn đã hết hạn. Vui lòng đặt lại phòng mới.",
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Trở về trang trước
            },
            child: const Text("Đã hiểu"),
          ),
        ],
      ),
    );
  }

  // HÀM XỬ LÝ THANH TOÁN THÀNH CÔNG -> ĐẨY LÊN FIREBASE
  Future<void> _processPaymentSuccess() async {
    setState(() {
      _isVerifying = true; // Hiện hiệu ứng đang xác thực ngân hàng
    });

    // Giả lập thời gian chờ server ngân hàng phản hồi (2.5 giây)
    await Future.delayed(const Duration(milliseconds: 2500));

    try {
      // Đẩy dữ liệu đơn phòng lên Firebase với trạng thái ĐÃ XÁC NHẬN
      widget.bookingData['status'] = 'Confirmed';
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bookingData['id'])
          .set(widget.bookingData);

      if (!mounted) return;
      _timer?.cancel();

      // Hiện bảng Ting Ting thành công
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
                  size: 60,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Thanh toán thành công!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Đơn phòng #${widget.bookingData['id'].toString().substring(0, 6).toUpperCase()} đã được thanh toán qua ${widget.paymentMethod}.",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    // Bay thẳng về trang Lịch sử đặt phòng
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MyBookingScreen(),
                      ),
                      (route) => route.isFirst,
                    );
                  },
                  child: const Text(
                    "XEM VÉ ĐẶT PHÒNG",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi lưu đơn hàng: $e")));
    } finally {
      if (mounted)
        setState(() {
          _isVerifying = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF0066FF);
    double amount = (widget.bookingData['totalPrice'] ?? 0.0).toDouble();
    String orderCode =
        "RESERVO${widget.bookingData['id'].toString().substring(0, 6).toUpperCase()}";

    // =========================================================================
    // CẤU HÌNH TÀI KHOẢN THẬT CỦA BẠN Ở ĐÂY:
    // =========================================================================
    String bankId = "MB"; // Ngân hàng MB Bank
    String accountNo = "0868833573";
    String accountName = "NGUYEN PHUC LOC";

    // Tạo link VietQR động (Quét được bằng cả app Ngân Hàng lẫn app MoMo!)
    String qrUrl =
        "https://img.vietqr.io/image/$bankId-$accountNo-compact2.png?amount=${amount.toInt()}&addInfo=$orderCode&accountName=${Uri.encodeComponent(accountName)}";

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: primaryBlue,
        title: Text(
          "Cổng thanh toán ${widget.paymentMethod}",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isVerifying
          ? _buildVerifyingState()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // THẺ ĐẾM NGƯỢC THỜI GIAN
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              color: Colors.deepOrange,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Thời gian giữ phòng còn lại:",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          _formattedTime,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // KHỐI HIỂN THỊ MÃ QR THANH TOÁN
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Quét mã bằng app Ngân hàng / ${widget.paymentMethod}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Hệ thống tự động duyệt đơn sau 3 - 5 giây",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 16),

                        // HÌNH QR CODE ĐỘNG
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              qrUrl,
                              height: 220,
                              width: 220,
                              fit: BoxFit.contain,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const SizedBox(
                                      height: 220,
                                      width: 220,
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  },
                              errorBuilder: (context, error, stackTrace) =>
                                  const SizedBox(
                                    height: 220,
                                    width: 220,
                                    child: Center(
                                      child: Icon(
                                        Icons.qr_code_2,
                                        size: 100,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 10),

                        // THÔNG TIN CHUYỂN KHOẢN CHI TIẾT
                        // THÔNG TIN CHUYỂN KHOẢN CHI TIẾT
                        _buildInfoRow(
                          "Số tiền thanh toán:",
                          _formatCurrency(amount),
                          isBold: true,
                          valueColor: Colors.black,
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          widget.paymentMethod == 'Ví MoMo'
                              ? "Số điện thoại MoMo:"
                              : "Số tài khoản MB Bank:",
                          accountNo,
                          isBold: true,
                          valueColor: Colors.black,
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          "Chủ tài khoản:",
                          accountName,
                          isBold: true,
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          "Nội dung chuyển khoản:",
                          orderCode,
                          isBold: true,
                          valueColor: Colors.black,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // NÚT XÁC NHẬN ĐÃ CHUYỂN KHOẢN
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0066FF),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(
                        Icons.check_circle_outline,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "TÔI ĐÃ CHUYỂN KHOẢN THÀNH CÔNG",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      onPressed: _processPaymentSuccess,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Hủy và chọn phương thức khác",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Màn hình loading giả lập xác thực ngân hàng
  Widget _buildVerifyingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Color(0xFF0066FF)),
          const SizedBox(height: 24),
          const Text(
            "Đang liên kết với ngân hàng...",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Vui lòng không tắt màn hình trong lúc này",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 15 : 13,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}
