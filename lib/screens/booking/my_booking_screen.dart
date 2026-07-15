import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bookingapp/models/booking.dart';
import 'package:bookingapp/services/firestore_service.dart';

class MyBookingScreen extends StatefulWidget {
  const MyBookingScreen({super.key});

  @override
  State<MyBookingScreen> createState() => _MyBookingScreenState();
}

class _MyBookingScreenState extends State<MyBookingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final FirestoreService _firestoreService =
      FirestoreService(); // Khởi tạo Service

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF0066FF);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        title: const Text(
          "Lịch sử đặt phòng",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: "Chờ thanh toán"),
            Tab(text: "Đã thanh toán"),
            Tab(text: "Trả phòng"),
            Tab(text: "Đã hủy"),
          ],
        ),
      ),
      body: currentUser == null
          ? _buildNotLoggedInState()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildBookingList(statusFilter: ['Pending']),
                _buildBookingList(statusFilter: ['Confirmed']),
                _buildBookingList(statusFilter: ['Completed']),
                _buildBookingList(statusFilter: ['Cancelled']),
              ],
            ),
    );
  }

  Widget _buildBookingList({required List<String> statusFilter}) {
    return StreamBuilder<QuerySnapshot>(
      // Sử dụng Service thay vì gọi Firebase trực tiếp
      stream: _firestoreService.getUserBookings(
        currentUser?.uid ?? '',
        statusFilter,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Đã xảy ra lỗi: ${snapshot.error}"));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState();
        }

        final docs = snapshot.data!.docs;

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final dataMap = docs[index].data() as Map<String, dynamic>;
            final bookingObj = Booking.fromMap(dataMap, docs[index].id);
            return _buildBookingCard(bookingObj);
          },
        );
      },
    );
  }

  Widget _buildBookingCard(Booking booking) {
    double totalPrice = booking.totalPrice;
    String formattedPrice =
        "${totalPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ";

    String status = booking.status;
    Color statusColor = Colors.orange;
    String statusText = "Chờ thanh toán";

    if (status == 'Confirmed') {
      statusColor = Colors.blue;
      statusText = "Đã thanh toán";
    } else if (status == 'Completed') {
      statusColor = Colors.green;
      statusText = "Đã trả phòng";
    } else if (status == 'Cancelled') {
      statusColor = Colors.red;
      statusText = "Đã hủy";
    }

    String imageUrl = booking.imageUrl ?? '';
    String itemTitle = booking.itemTitle.isNotEmpty
        ? booking.itemTitle
        : 'Phòng chưa có tên';
    String docId = booking.id;

    String checkInStr = booking.checkIn.toString().split(' ')[0];
    String checkOutStr = booking.checkOut.toString().split(' ')[0];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _buildImagePlaceholder(),
                        )
                      : _buildImagePlaceholder(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        itemTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Mã đặt: #${docId.substring(0, 6).toUpperCase()}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Check-in: $checkInStr  ➔  Check-out: $checkOutStr",
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Tổng thanh toán:",
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    Text(
                      formattedPrice,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
                if (status == 'Pending' || status == 'Confirmed')
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => _showCancelDialog(docId),
                    child: const Text(
                      "Hủy phòng",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (status == 'Completed')
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.star, size: 16),
                    label: const Text(
                      "Đánh giá ngay",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      _showReviewDialog(booking.itemId, booking.itemTitle);
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 60,
      height: 60,
      color: Colors.blue.shade50,
      child: const Icon(Icons.hotel, color: Colors.blue),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            "Chưa có đơn đặt phòng nào",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Đơn đặt phòng của bạn sẽ xuất hiện tại đây",
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildNotLoggedInState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline_rounded,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            "Vui lòng đăng nhập để xem đơn đặt phòng",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Xác nhận hủy phòng"),
        content: const Text(
          "Bạn có chắc chắn muốn hủy đơn đặt phòng này không?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Không", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(context);
              // Sử dụng Service thay thế
              await _firestoreService.updateBookingStatus(docId, 'Cancelled');
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Đã hủy đơn đặt phòng!")),
              );
            },
            child: const Text(
              "Hủy ngay",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showReviewDialog(String roomId, String roomTitle) {
    int _rating = 5;
    TextEditingController _commentCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              "Đánh giá $roomTitle",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < _rating
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: Colors.amber,
                        size: 36,
                      ),
                      onPressed: () {
                        setDialogState(() {
                          _rating = index + 1;
                        });
                      },
                    );
                  }),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _commentCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Chia sẻ trải nghiệm của bạn...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0066FF),
                ),
                onPressed: () async {
                  if (_commentCtrl.text.trim().isEmpty) return;

                  Navigator.pop(context);
                  await _firestoreService.addReview(
                    roomId: roomId,
                    userId: currentUser?.uid ?? 'unknown',
                    userName:
                        currentUser?.displayName ??
                        currentUser?.email?.split('@')[0] ??
                        'Khách hàng ẩn danh',
                    rating: _rating,
                    comment: _commentCtrl.text.trim(),
                  );

                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Cảm ơn bạn đã đánh giá!")),
                  );
                },
                child: const Text(
                  "Gửi đánh giá",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
