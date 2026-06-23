import 'package:flutter/material.dart';
import 'package:bookingapp/screens/auth/register_screen.dart';
import 'package:bookingapp/screens/auth/forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isObscure = true; // Biến ẩn/hiện mật khẩu
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus(); 
      },
      child: Scaffold(
        backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
          Center(
            child: Text( "ĐĂNG NHẬP", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
                      
            const SizedBox(height: 8),

            const SizedBox(height: 40),

            // Nhập Email
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),

            // Nhập Mật khẩu
            TextField(
              controller: _passwordController,
              obscureText: _isObscure,
              decoration: InputDecoration(
                labelText: 'Mật khẩu',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() { _isObscure = !_isObscure; });
                  },
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            // Nút Quên mật khẩu (Căn phải)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()));
                },
                child: const Text("Quên mật khẩu?", style: TextStyle(color: Colors.blueAccent)),
              ),
            ),
            const SizedBox(height: 20),

            // Nút Đăng nhập
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  // TODO: Gọi API đăng nhập ở đây
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đăng nhập thành công!")));
                  Navigator.pop(context); // Đóng trang login, quay về trang chủ
                },
                child: const Text("ĐĂNG NHẬP", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 30),

            // Chuyển sang Đăng ký
           Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Bạn chưa có tài khoản?"),
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                  },
                  child: const Text("Đăng ký ngay", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                )
              ],
            ) 
          ],
        ),
      ),
      ),
    );
  }
}