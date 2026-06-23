import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(25.0), 
          ),
        ),
        centerTitle: false,
        titleSpacing: 10.0, 
        title: Image.asset(
          'assets/images/logofull.png',
          height: 100, 
          fit: BoxFit.contain,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70.0), 
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.0), 
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Bạn muốn tìm phòng ở đâu?',
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.search, color: Colors.blueAccent),
                  border: InputBorder.none, 
                  contentPadding: EdgeInsets.symmetric(vertical: 14.0),
                ),
              ),
            ),
          ),
        ),
      ),
      
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            SizedBox(
              height: 150, 
              child: PageView(
                children: [
                  _buildBannerCard(Colors.blue[400]!, 'Sale Hè Rực Rỡ\nGiảm đến 50% Khách Sạn'),
                  _buildBannerCard(Colors.teal[400]!, 'Homestay Đà Lạt\nChỉ từ 199k/đêm'),
                  _buildBannerCard(Colors.orange[400]!, 'Hoàn tiền 10%\nkhi thanh toán qua Thẻ'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Khám phá loại hình lưu trú',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(), 
                crossAxisCount: 4, 
                mainAxisSpacing: 16, 
                crossAxisSpacing: 16, 
                children: [
                  _buildCategoryIcon(Icons.hotel, 'Khách sạn', Colors.blue),
                  _buildCategoryIcon(Icons.house_siding, 'Homestay', Colors.green),
                  _buildCategoryIcon(Icons.holiday_village, 'Resort', Colors.orange),
                  _buildCategoryIcon(Icons.local_offer, 'Khuyến mãi', Colors.redAccent),
                  _buildCategoryIcon(Icons.map, 'Bản đồ', Colors.indigo),
                  _buildCategoryIcon(Icons.more_horiz, 'Xem thêm', Colors.grey),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Phòng nổi bật giá tốt',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200, 
              child: ListView(
                scrollDirection: Axis.horizontal, 
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  _buildRoomCard('Khách sạn Mường Thanh', 'Đà Nẵng', '850.000đ', Colors.blue[200]!),
                  _buildRoomCard('Chill Homestay', 'Đà Lạt', '350.000đ', Colors.green[200]!),
                  _buildRoomCard('Vinpearl Resort', 'Nha Trang', '2.500.000đ', Colors.orange[200]!),
                ],
              ),
            ),
            const SizedBox(height: 40), 
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () { 
          print("Nút Add được bấm!"); 
        },
        backgroundColor: Colors.blueAccent, // Cùng màu với theme app
        child: const Icon(Icons.add, color: Colors.white),
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: "Favorites"),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: "My Booking"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Account"),
        ],
      ),
    ); 
  }

  Widget _buildBannerCard(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16.0)),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(IconData icon, String title, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: Colors.white, 
            borderRadius: BorderRadius.circular(12.0), 
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))]
          ),
          child: Icon(icon, color: color, size: 28), 
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis, 
        ),
      ],
    );
  }

  Widget _buildRoomCard(String title, String location, String price, Color imgColor) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: imgColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12.0)),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.image, color: Colors.white, size: 40),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 2),
                    Text(location, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(price, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent, fontSize: 14)),
              ],
            ),
          )
        ],
      ),
    );
  }
}