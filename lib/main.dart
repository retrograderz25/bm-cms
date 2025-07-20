// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'firebase_options.dart';
import 'src/features/authentication/screens/auth_wrapper.dart'; // Sẽ tạo file này ngay sau đây

// Định nghĩa các hằng số để đọc biến môi trường
const apiKey = String.fromEnvironment('FLUTTER_PUBLIC_API_KEY');
const authDomain = String.fromEnvironment('FLUTTER_PUBLIC_AUTH_DOMAIN');
const projectId = String.fromEnvironment('FLUTTER_PUBLIC_PROJECT_ID');
const storageBucket = String.fromEnvironment('FLUTTER_PUBLIC_STORAGE_BUCKET');
const messagingSenderId = String.fromEnvironment('FLUTTER_PUBLIC_MESSAGING_SENDER_ID');
const appId = String.fromEnvironment('FLUTTER_PUBLIC_APP_ID');
// const measurementId = String.fromEnvironment('FLUTTER_PUBLIC_MEASUREMENT_ID');

void main() async {
  // Đảm bảo Flutter được khởi tạo
  WidgetsFlutterBinding.ensureInitialized();
  // Khởi tạo Firebase
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: apiKey,
      authDomain: authDomain,
      projectId: projectId,
      storageBucket: storageBucket,
      messagingSenderId: messagingSenderId,
      appId: appId,
    ),
  );
  // Chạy ứng dụng với ProviderScope
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,

        // input fields theme
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          filled: true,
          fillColor: Colors.white,
        ),

        // button theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent, // Màu nền nút
              foregroundColor: Colors.white, // Màu chữ
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              )
          ),
        ),

        // card theme
        cardTheme: CardThemeData(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),

        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AuthWrapper(), // Điểm bắt đầu là AuthWrapper
    );
  }
}