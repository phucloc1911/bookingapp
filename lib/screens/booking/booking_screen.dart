import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bookingapp/screens/booking/my_booking_screen.dart';
import 'package:bookingapp/screens/payment/payment_screen.dart';

class BookingScreen extends StatefulWidget {
  final String itemId;
  final String itemTitle;
  final String itemType; // 'Hotel', 'Homestay', hoặc 'Resort'
  final double pricePerNight;
  final Color imgColor;

  const BookingScreen({
    super.key,
    required this.itemId,
    required this.itemTitle,
    required this.itemType,
    required this.pricePerNight,
    this.imgColor = Colors.blueAccent,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime _checkInDate = DateTime.now().add(const Duration(days: 1));
  DateTime _checkOutDate = DateTime.now().add(const Duration(days: 2));
  String _paymentMethod = 'Thanh toán tại khách sạn';
  bool _isLoading = false;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadDefaultPayment();
  }

  // Tự động tải phương thức thanh toán mặc định từ trang PaymentMethod lúc nãy
  Future<void> _loadDefaultPayment() async {
    if (currentUser != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      if (doc.exists && doc.data()?['defaultPaymentMethod'] != null) {
        String methodId = doc.data()!['defaultPaymentMethod'];
        setState(() {
          if (methodId == 'momo')
            _paymentMethod = 'Ví MoMo';
          else if (methodId == 'vnpay')
            _paymentMethod = 'VNPAY QR / Thẻ ATM';
          else if (methodId == 'zalopay')
            _paymentMethod = 'Ví ZaloPay';
          else
            _paymentMethod = 'Thanh toán tại khách sạn';
        });
      }
    }
  }

  // Hàm tự động thêm dấu chấm vào hàng nghìn (VD: 850000 -> 850.000)
  String _formatCurrency(double amount) {
    return "${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ";
  }

  // Tính số ngày ở
  int get _nights {
    final difference = _checkOutDate.difference(_checkInDate).inDays;
    return difference > 0 ? difference : 1;
  }

  // Tính tổng tiền
  double get _totalPrice => widget.pricePerNight * _nights;

  // Chọn ngày Check-in & Check-out bằng bộ chọn lịch của Flutter
  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(start: _checkInDate, end: _checkOutDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF0066FF)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _checkInDate = picked.start;
        _checkOutDate = picked.end;
      });
    }
  }

  // HÀM QUAN TRỌNG NHẤT: Đẩy đơn đặt phòng lên Firebase
  // HÀM QUAN TRỌNG NHẤT: Kiểm tra trùng lịch trước khi đặt phòng
  // HÀM QUAN TRỌNG NHẤT: Kiểm tra trùng lịch -> Mới cho Thanh toán/Lưu đơn
  Future<void> _confirmBooking() async {
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng đăng nhập để đặt phòng!")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // =========================================================================
      // BƯỚC 1: QUÉT FIREBASE KIỂM TRA LỊCH TRÙNG (TIME COLLISION CHECK)
      // =========================================================================
      final existingBookings = await FirebaseFirestore.instance
          .collection('bookings')
          .where('itemId', isEqualTo: widget.itemId)
          // 🟢 SỬA Ở ĐÂY: Quét cả Pending, Confirmed lẫn Completed để không lọt đơn nào!
          .where('status', whereIn: ['Pending', 'Confirmed', 'Completed'])
          .get();

      bool isConflict = false;
      String conflictDatesText = "";

      for (var doc in existingBookings.docs) {
        final data = doc.data();
        if (data['checkIn'] != null && data['checkOut'] != null) {
          DateTime bookedCheckIn = DateTime.parse(data['checkIn']);
          DateTime bookedCheckOut = DateTime.parse(data['checkOut']);

          // Kiểm tra logic trùng ngày
          if (_checkInDate.isBefore(bookedCheckOut) &&
              _checkOutDate.isAfter(bookedCheckIn)) {
            isConflict = true;
            conflictDatesText =
                "${bookedCheckIn.day}/${bookedCheckIn.month}/${bookedCheckIn.year} đến ${bookedCheckOut.day}/${bookedCheckOut.month}/${bookedCheckOut.year}";
            break;
          }
        }
      }

      // 🟢 NẾU TRÙNG LỊCH -> HIỆN BẢNG CẢNH BÁO VÀ CHẶN LẠI NGAY LẬP TỨC
      if (isConflict) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 28,
                ),
                SizedBox(width: 8),
                Text(
                  "Phòng đã kín lịch!",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Text(
              "Rất tiếc! Phòng này đã có khách khác đặt từ ngày $conflictDatesText.\n\nVui lòng chọn khoảng thời gian khác.",
              style: const TextStyle(height: 1.4),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0066FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Chọn ngày khác",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return; // ⛔ QUAN TRỌNG NHẤT: CHẶN ĐỨNG CODE TẠI ĐÂY, KHÔNG CHO CHẠY XUỐNG DƯỚI!
      }

      // =========================================================================
      // BƯỚC 2: NẾU KHÔNG TRÙNG LỊCH -> TIẾN HÀNH XỬ LÝ ĐẶT PHÒNG
      // =========================================================================
      final docRef = FirebaseFirestore.instance.collection('bookings').doc();

      // Mặc định nếu trả tiền mặt là Pending
      final bookingData = {
        'id': docRef.id,
        'userId': currentUser!.uid,
        'itemId': widget.itemId,
        'itemType': widget.itemType,
        'checkIn': _checkInDate.toIso8601String(),
        'checkOut': _checkOutDate.toIso8601String(),
        'totalPrice': _totalPrice,
        'status': 'Pending',
        'itemTitle': widget.itemTitle,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // KIỂM TRA PHƯƠNG THỨC THANH TOÁN:
      if (_paymentMethod != 'Thanh toán tại khách sạn') {
        // NẾU LÀ THANH TOÁN ONLINE -> CHUYỂN QUA TRANG QUÉT QR
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentGatewayScreen(
              bookingData: bookingData,
              paymentMethod: _paymentMethod,
            ),
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return; // Chuyển trang xong cũng dừng tại đây, đợi khách quét QR trả tiền mới lưu!
      }

      // NẾU TRẢ TIỀN MẶT TẠI QUẦY -> LƯU THẲNG LÊN FIREBASE (Trạng thái Pending)
      await docRef.set(bookingData);

      if (!mounted) return;
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
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: 70,
              ),
              const SizedBox(height: 16),
              const Text(
                "Đặt phòng thành công!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Đơn đặt phòng #${docRef.id.substring(0, 6).toUpperCase()} đã được ghi nhận.",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
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
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MyBookingScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "XEM ĐƠN ĐẶT PHÒNG",
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
      ).showSnackBar(SnackBar(content: Text("Lỗi đặt phòng: $e")));
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
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: primaryBlue,
        title: const Text(
          "Xác nhận đặt phòng",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Thẻ tóm tắt phòng
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: widget.imgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.hotel,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            widget.itemType,
                            style: const TextStyle(
                              color: primaryBlue,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.itemTitle,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatCurrency(widget.pricePerNight),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              "THỜI GIAN LƯU TRÚ",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),

            // 2. Thẻ chọn ngày
            InkWell(
              onTap: _selectDateRange,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: primaryBlue.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Nhận phòng",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${_checkInDate.day}/${_checkInDate.month}/${_checkInDate.year}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "$_nights đêm",
                        style: const TextStyle(
                          color: primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          "Trả phòng",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${_checkOutDate.day}/${_checkOutDate.month}/${_checkOutDate.year}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              "PHƯƠNG THỨC THANH TOÁN",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),

            // 3. Thẻ phương thức thanh toán
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.payment_rounded,
                    color: primaryBlue,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _paymentMethod,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Icon(Icons.check_circle, color: Colors.green),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              "CHI TIẾT GIÁ",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),

            // 4. Bảng tính tiền
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${_formatCurrency(widget.pricePerNight)} / đêm",
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatCurrency(_totalPrice),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Phí dịch vụ & Thuế",
                        style: TextStyle(color: Colors.grey),
                      ),
                      const Text(
                        "Miễn phí",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "TỔNG THANH TOÁN",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.red,
                        ),
                      ),
                      Text(
                        _formatCurrency(_totalPrice),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),

      // THANH NÚT BẤM ĐẶT PHÒNG Ở ĐÁY MÀN HÌNH
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _isLoading ? null : _confirmBooking,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "XÁC NHẬN ĐẶT PHÒNG",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
