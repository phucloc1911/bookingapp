import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      // Tắt tự động căn giữa để logo nằm về bên trái
      centerTitle: false, 
      // Ép sát logo vào lề trái
      titleSpacing: 5.0, 
      
      // Đặt logo vào title thay vì leading
      title: Image.asset(
        'assets/images/logofull.png',
        height: 100, // Bạn có thể tăng giảm số này để logo to nhỏ tùy ý
        fit: BoxFit.contain, // Đảm bảo logo không bị méo
      ),
    ), 
  );
}
}

