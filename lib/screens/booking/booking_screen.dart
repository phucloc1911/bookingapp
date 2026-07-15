import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bookingapp/screens/booking/my_booking_screen.dart';
import 'package:bookingapp/screens/payment/payment_screen.dart';
import 'package:bookingapp/models/booking.dart';
import 'package:bookingapp/models/room.dart';

class BookingScreen extends StatefulWidget {
  final Room room;

  const BookingScreen({super.key, required this.room});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime _checkInDate = DateTime.now().add(const Duration(days: 1));
  DateTime _checkOutDate = DateTime.now().add(const Duration(days: 2));

  String _selectedPaymentMethod = 'Thanh toán tại khách sạn';
  int _selectedBeds = 1;
  bool _isLoading = false;

  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadDefaultPayment();
  }

  Future<void> _loadDefaultPayment() async {
    if (currentUser != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      if (doc.exists && doc.data()?['defaultPaymentMethod'] != null) {
        String methodId = doc.data()!['defaultPaymentMethod'];
        setState(() {
          if (methodId == 'vnpay') {
            _selectedPaymentMethod = 'VNPAY QR / Thẻ ATM';
          } else {
            _selectedPaymentMethod = 'Thanh toán tại khách sạn';
          }
        });
      }
    }
  }

  Widget _buildBedSelector() {
    List<int> availableBeds = [1];

    if (widget.room.price2Beds > widget.room.price) {
      availableBeds.add(2);
    }
    if (widget.room.price3Beds > widget.room.price) {
      availableBeds.add(3);
    }

    if (availableBeds.length == 1) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "SỐ LƯỢNG GIƯỜNG",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: availableBeds.map((bedCount) {
            bool isSelected = _selectedBeds == bedCount;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedBeds = bedCount;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF0066FF) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF0066FF)
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "$bedCount giường",
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (_selectedBeds == 2 && widget.room.price2Beds > widget.room.price)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              "+ ${_formatCurrency(widget.room.price2Beds - widget.room.price)} phụ thu giường thứ 2 / đêm",
              style: const TextStyle(
                color: Colors.orange,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        if (_selectedBeds == 3 && widget.room.price3Beds > widget.room.price)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              "+ ${_formatCurrency(widget.room.price3Beds - widget.room.price)} phụ thu cho 3 giường / đêm",
              style: const TextStyle(
                color: Colors.orange,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPaymentOption(String title, IconData icon, Color iconColor) {
    bool isSelected = _selectedPaymentMethod == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = title;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF0066FF) : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.green, size: 24)
            else
              Icon(
                Icons.circle_outlined,
                color: Colors.grey.shade300,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    return "${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ";
  }

  int get _nights {
    final difference = _checkOutDate.difference(_checkInDate).inDays;
    return difference > 0 ? difference : 1;
  }

  double get _totalPrice {
    double basePrice = widget.room.price;

    if (_selectedBeds == 2) {
      basePrice = widget.room.price2Beds;
    } else if (_selectedBeds == 3) {
      basePrice = widget.room.price3Beds;
    }

    return basePrice * _nights;
  }

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
      // 1. KIỂM TRA TRÙNG LỊCH
      final existingBookings = await FirebaseFirestore.instance
          .collection('bookings')
          .where('itemId', isEqualTo: widget.room.id)
          .where('status', whereIn: ['Pending', 'Confirmed', 'Completed'])
          .get();

      bool isConflict = false;
      String conflictDatesText = "";

      for (var doc in existingBookings.docs) {
        final data = doc.data();
        if (data['checkIn'] != null && data['checkOut'] != null) {
          DateTime bookedCheckIn = DateTime.parse(data['checkIn']);
          DateTime bookedCheckOut = DateTime.parse(data['checkOut']);

          if (_checkInDate.isBefore(bookedCheckOut) &&
              _checkOutDate.isAfter(bookedCheckIn)) {
            isConflict = true;
            conflictDatesText =
                "${bookedCheckIn.day}/${bookedCheckIn.month}/${bookedCheckIn.year} đến ${bookedCheckOut.day}/${bookedCheckOut.month}/${bookedCheckOut.year}";
            break;
          }
        }
      }

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
        return;
      }

      // 2. TẠO ĐƠN HÀNG
      final docRef = FirebaseFirestore.instance.collection('bookings').doc();

      final newBooking = Booking(
        id: docRef.id,
        userId: currentUser!.uid,
        itemId: widget.room.id,
        itemTitle: widget.room.title,
        itemType: widget.room.type,
        checkIn: _checkInDate,
        checkOut: _checkOutDate,
        totalPrice: _totalPrice,
        status: 'Pending',
        imageUrl: widget.room.imageUrl,
      );

      final bookingData = newBooking.toMap();
      bookingData['bedCount'] = _selectedBeds;
      bookingData['paymentMethod'] = _selectedPaymentMethod;

      if (_selectedPaymentMethod != 'Thanh toán tại khách sạn') {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentGatewayScreen(
              bookingData: bookingData,
              paymentMethod: _selectedPaymentMethod,
            ),
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // LƯU ĐƠN BẰNG TIỀN MẶT LÊN FIREBASE
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
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Lỗi đặt phòng: $e")));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: (widget.room.imageUrl.isNotEmpty)
                        ? Image.network(
                            widget.room.imageUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.blueAccent,
                                  child: const Icon(
                                    Icons.hotel,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                          )
                        : Container(
                            width: 80,
                            height: 80,
                            color: Colors.blueAccent,
                            child: const Icon(
                              Icons.hotel,
                              color: Colors.white,
                              size: 40,
                            ),
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
                            widget.room.type,
                            style: const TextStyle(
                              color: primaryBlue,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.room.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatCurrency(widget.room.price),
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
            const SizedBox(height: 24),
            _buildBedSelector(),
            const SizedBox(height: 20),
            const Text(
              "PHƯƠNG THỨC THANH TOÁN",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            _buildPaymentOption(
              'VNPAY QR / Thẻ ATM',
              Icons.qr_code_scanner,
              Colors.blue,
            ),
            _buildPaymentOption(
              'Thanh toán tại khách sạn',
              Icons.storefront,
              Colors.orange,
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
                        "${_formatCurrency(_totalPrice / _nights)} / đêm",
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
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Phí dịch vụ & Thuế",
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
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
