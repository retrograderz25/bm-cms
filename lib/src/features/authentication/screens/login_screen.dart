// lib/src/features/authentication/screens/login_screen.dart

import 'package:bm_cms/src/features/authentication/screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/utils/snackbar_helper.dart';
import '../providers/auth_providers.dart';

// Sử dụng ConsumerStatefulWidget để có thể dùng `ref` trong cả vòng đời của widget
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // Kiểm tra form có hợp lệ không
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Gọi đến repository thông qua provider để đăng nhập
        // Dùng ref.read vì chúng ta chỉ gọi hàm 1 lần, không cần lắng nghe thay đổi
        await ref.read(authRepositoryProvider).signInWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
        // Sau khi login thành công, AuthWrapper sẽ tự động điều hướng
      } catch (e) {
        // Hiển thị lỗi cho người dùng
        String errorMessage = e.toString();
        if (errorMessage.contains('invalid-credential')) {
          errorMessage = 'Sai thông tin đăng nhập, vui lòng kiểm tra lại! Nếu chưa có tài khoản, vui lòng đăng kí!';
        }
        SnackbarHelper.showError(context, message: errorMessage);
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text(e.toString())),
        // );
        // if (mounted) {
        //   SnackbarHelper.showError(context, message: 'Đăng nhập thất bại, vui lòng kiểm tra lại thông tin đăng nhập!');
        // }
      } finally {
        // Dù thành công hay thất bại cũng phải dừng loading
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Sử dụng màu nền nhẹ nhàng hơn
      backgroundColor: Colors.grey[200],
      body: Center(
        // Giới hạn chiều rộng trên màn hình lớn (web)
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Card(
            elevation: 8.0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Giúp card co lại vừa với nội dung
                  children: [
                    // Thêm một tiêu đề
                    Text(
                      'Chào mừng trở lại!',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Đăng nhập để tiếp tục',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 32),

                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      validator: (value) =>
                      value!.isEmpty ? 'Vui lòng nhập email' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Mật khẩu',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        // Thêm icon để ẩn/hiện mật khẩu (nâng cao hơn)
                      ),
                      obscureText: true,
                      validator: (value) =>
                      value!.isEmpty ? 'Vui lòng nhập mật khẩu' : null,
                    ),
                    const SizedBox(height: 24),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                      width: double.infinity, // Làm nút bấm rộng hết cỡ
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            )
                        ),
                        onPressed: _login,
                        child: const Text('Đăng nhập'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const SignUpScreen()),
                        );
                      },
                      child: const Text('Chưa có tài khoản? Đăng ký ngay'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}