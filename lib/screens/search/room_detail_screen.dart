import 'package:flutter/material.dart';
import 'package:bookingapp/models/room.dart';
import 'package:bookingapp/models/review.dart';
import 'package:bookingapp/screens/booking/booking_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bookingapp/services/firestore_service.dart';

class RoomDetailScreen extends StatefulWidget {
  final Room room;
  const RoomDetailScreen({super.key, required this.room});

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  int _currentImageIndex = 0;
  bool _isFavorite = false;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    // Sử dụng Service thay cho Firebase trực tiếp
    final doc = await _firestoreService.checkFavorite(widget.room.id);

    if (doc.exists) {
      setState(() {
        _isFavorite = true;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    try {
      if (_isFavorite) {
        await _firestoreService.addFavorite(
          widget.room.id,
          widget.room.toJson(),
        );
      } else {
        await _firestoreService.removeFavorite(widget.room.id);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isFavorite
                  ? "Đã thêm vào danh sách yêu thích!"
                  : "Đã xóa khỏi danh sách yêu thích!",
            ),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isFavorite = !_isFavorite;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF0066FF);

    final List<String> allImages = [
      if (widget.room.imageUrl.isNotEmpty) widget.room.imageUrl,
      ...widget.room.gallery,
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: primaryBlue,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.redAccent : Colors.white,
                  size: 28,
                ),
                onPressed: _toggleFavorite,
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: allImages.isNotEmpty
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        PageView.builder(
                          onPageChanged: (index) {
                            setState(() {
                              _currentImageIndex = index;
                            });
                          },
                          itemCount: allImages.length,
                          itemBuilder: (context, index) {
                            return Image.network(
                              allImages[index],
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.blue.shade200,
                                child: const Icon(
                                  Icons.broken_image,
                                  size: 50,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                        ),
                        if (allImages.length > 1)
                          Positioned(
                            bottom: 16,
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "${_currentImageIndex + 1} / ${allImages.length}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                      ],
                    )
                  : Container(
                      color: Colors.blue.shade200,
                      child: const Icon(
                        Icons.hotel,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: StreamBuilder<QuerySnapshot>(
              // Sử dụng Service thay cho Firebase trực tiếp
              stream: _firestoreService.getRoomReviews(widget.room.id),
              builder: (context, snapshot) {
                double avgRating = widget.room.rating;
                int totalReviews = 0;
                List<Review> reviews = [];

                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  reviews = snapshot.data!.docs.map((doc) {
                    return Review.fromMap(
                      doc.data() as Map<String, dynamic>,
                      doc.id,
                    );
                  }).toList();

                  totalReviews = reviews.length;
                  double totalStars = 0;
                  for (var rev in reviews) {
                    totalStars += rev.rating;
                  }
                  avgRating = totalStars / totalReviews;
                }

                int displayCount = reviews.length > 3 ? 3 : reviews.length;

                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              widget.room.title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: primaryBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.room.type,
                              style: const TextStyle(
                                color: primaryBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 22,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${avgRating.toStringAsFixed(1)} ($totalReviews Đánh giá)",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Divider(height: 1),
                      ),
                      const Text(
                        "Tiện nghi nổi bật",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: widget.room.amenities.map((amenity) {
                          IconData icon;
                          if (amenity == "Wifi Miễn phí") {
                            icon = Icons.wifi;
                          } else if (amenity == "Đỗ xe") {
                            icon = Icons.directions_car;
                          } else if (amenity == "Hồ bơi") {
                            icon = Icons.pool;
                          } else if (amenity == "Máy lạnh") {
                            icon = Icons.ac_unit;
                          } else if (amenity == "Nhà hàng") {
                            icon = Icons.restaurant;
                          } else if (amenity == "Lễ tân 24/7") {
                            icon = Icons.support_agent;
                          } else {
                            icon = Icons.star;
                          }
                          return _buildAmenityIcon(icon, amenity);
                        }).toList(),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Divider(height: 1),
                      ),
                      const Text(
                        "Mô tả",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.room.description.isNotEmpty
                            ? widget.room.description
                            : "Đang cập nhật mô tả...",
                        style: const TextStyle(
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Divider(height: 1),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Đánh giá từ khách",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (totalReviews > 3)
                            InkWell(
                              onTap: () => _showAllReviewsBottomSheet(reviews),
                              child: const Text(
                                "Xem tất cả",
                                style: TextStyle(
                                  color: primaryBlue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (totalReviews == 0)
                        const Text(
                          "Chưa có đánh giá nào. Hãy là người đầu tiên trải nghiệm nhé!",
                          style: TextStyle(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: displayCount,
                          itemBuilder: (context, index) {
                            final revObj = reviews[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: _buildReviewCard(
                                revObj.userName,
                                revObj.comment,
                                revObj.rating.toInt(),
                              ),
                            );
                          },
                        ),
                      if (totalReviews > 3)
                        Center(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: primaryBlue,
                              side: const BorderSide(color: primaryBlue),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () =>
                                _showAllReviewsBottomSheet(reviews),
                            child: Text("Xem tất cả $totalReviews đánh giá"),
                          ),
                        ),
                      const SizedBox(height: 100),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Giá mỗi đêm từ",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  Text(
                    "${widget.room.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookingScreen(room: widget.room),
                    ),
                  );
                },
                child: const Text(
                  "Chọn phòng",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAllReviewsBottomSheet(List<Review> allReviews) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Tất cả ${allReviews.length} đánh giá",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      controller: controller,
                      itemCount: allReviews.length,
                      itemBuilder: (context, index) {
                        final revObj = allReviews[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: _buildReviewCard(
                            revObj.userName,
                            revObj.comment,
                            revObj.rating.toInt(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAmenityIcon(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF0066FF)),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

Widget _buildReviewCard(String name, String comment, int rating) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue.shade200,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < rating
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: Colors.amber,
                        size: 16,
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          comment,
          style: TextStyle(color: Colors.grey.shade800, height: 1.4),
        ),
      ],
    ),
  );
}
