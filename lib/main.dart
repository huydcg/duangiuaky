import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';
import 'index.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref("users");

  // Hàm kiểm tra đăng nhập
  void _login() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    // Đọc dữ liệu từ Firebase Realtime Database
    final snapshot = await _databaseRef.child(username).get();
    if (snapshot.exists) {
      Map<dynamic, dynamic> userData = snapshot.value as Map<dynamic, dynamic>;
      if (userData['password'] == password) {
        if (userData['role'] == "admin") {
          // Chuyển đến trang dành cho Admin
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const RealTimeCRUDEdatabase()),
          );
        } else {
          // Chuyển đến trang người dùng nếu không phải Admin
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const UserHomePage()),
          );
        }
      } else {
        _showMessageDialog('Đăng nhập thất bại', 'Mật khẩu không đúng.');
      }
    } else {
      _showMessageDialog('Đăng nhập thất bại', 'Người dùng không tồn tại.');
    }
  }

  // Xử lý thêm người dùng mới
  void _addUser() async {
    String username = _usernameController.text;
    String password = _passwordController.text;
    String role = "user"; // Mặc định thêm người dùng mới là 'user'

    // Kiểm tra xem người dùng đã tồn tại hay chưa
    final snapshot = await _databaseRef.child(username).get();
    if (snapshot.exists) {
      _showMessageDialog('Thêm thất bại', 'Người dùng đã tồn tại.');
    } else {
      // Thêm người dùng mới vào cơ sở dữ liệu
      await _databaseRef.child(username).set({
        'username': username,
        'password': password,
        'role': role,
      });
      _showMessageDialog('Thêm thành công', 'Người dùng mới đã được thêm.');
    }
  }

  // Hàm hiển thị thông báo
  void _showMessageDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng nhập'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Tên đăng nhập',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mật khẩu',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _login,
                  child: const Text('Đăng nhập'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _addUser,
                  child: const Text('Thêm người dùng'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Trang dành cho người dùng thông thường
class UserHomePage extends StatelessWidget {
  const UserHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang người dùng'),
      ),
      body: const Center(
        child: Text('Bạn đang đăng nhập với tư cách user!'),
      ),
    );
  }
}
