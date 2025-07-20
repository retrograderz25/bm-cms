// lib/src/features/authentication/screens/signup_screen.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/utils/snackbar_helper.dart';
import '../../../data/models/user_model.dart';
import '../providers/auth_providers.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();
  UserRole _selectedRole = UserRole.student; // Sử dụng Enum
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() { _isLoading = true; });

      try {
        await ref.read(authRepositoryProvider).signUpWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          displayName: _displayNameController.text.trim(),
          role: _selectedRole, // Truyền Enum
        );

        if (mounted) {
          // SnackbarHelper.showSuccess(context, message: 'Đăng ký thành công!');
          Navigator.of(context).pop();
        }

      } on FirebaseAuthException catch (e) {
        if (mounted) {
          String errorMessage = 'Đăng ký thất bại. Vui lòng thử lại.';
          if (e.code == 'email-already-in-use') {
            errorMessage = 'Email này đã được sử dụng.';
          } else if (e.code == 'weak-password') {
            errorMessage = 'Mật khẩu quá yếu.';
          }
          SnackbarHelper.showError(context, message: errorMessage);
        }
      } catch (e) {
        if (mounted) {
          SnackbarHelper.showError(context, message: 'Đã có lỗi xảy ra.');
        }
      } finally {
        if (mounted) {
          setState(() { _isLoading = false; });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng ký tài khoản')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Card(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Tạo tài khoản',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _displayNameController,
                      decoration: const InputDecoration(
                        labelText: 'Tên hiển thị',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) => value!.isEmpty ? 'Vui lòng nhập tên của bạn' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) => value!.isEmpty || !value.contains('@') ? 'Vui lòng nhập email hợp lệ' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Mật khẩu',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      obscureText: true,
                      validator: (value) => value!.length < 6 ? 'Mật khẩu phải có ít nhất 6 ký tự' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<UserRole>(
                      value: _selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'Bạn là',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                      items: const [
                        DropdownMenuItem(value: UserRole.student, child: Text('Học sinh')),
                        DropdownMenuItem(value: UserRole.ta, child: Text('Trợ giảng')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedRole = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _signUp,
                        child: const Text('Đăng ký'),
                      ),
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