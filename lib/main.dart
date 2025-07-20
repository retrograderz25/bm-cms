// lib/main.dart

import 'package:flutter/foundation.dart'; // Import để dùng kIsWeb
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/features/authentication/screens/auth_wrapper.dart';

// Import file options cho local development
import 'firebase_options.dart';

// Đọc biến môi trường cho Vercel deployment
const apiKey = String.fromEnvironment('FLUTTER_PUBLIC_API_KEY');
const authDomain = String.fromEnvironment('FLUTTER_PUBLIC_AUTH_DOMAIN');
const projectId = String.fromEnvironment('FLUTTER_PUBLIC_PROJECT_ID');
const storageBucket = String.fromEnvironment('FLUTTER_PUBLIC_STORAGE_BUCKET');
const messagingSenderId = String.fromEnvironment('FLUTTER_PUBLIC_MESSAGING_SENDER_ID');
const appId = String.fromEnvironment('FLUTTER_PUBLIC_APP_ID');
const measurementId = String.fromEnvironment('FLUTTER_PUBLIC_MEASUREMENT_ID');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Xác định xem nên dùng cấu hình từ file hay từ biến môi trường
  FirebaseOptions firebaseOptions;

  if (kIsWeb && apiKey.isNotEmpty) {
    // ---- CHẠY TRÊN MÔI TRƯỜNG PRODUCTION (VERCEL) ----
    // Nếu là web và apiKey từ biến môi trường có giá trị
    print("Initializing Firebase with environment variables for production.");
    firebaseOptions = const FirebaseOptions(
      apiKey: apiKey,
      authDomain: authDomain,
      projectId: projectId,
      storageBucket: storageBucket,
      messagingSenderId: messagingSenderId,
      appId: appId,
      measurementId: measurementId,
    );
  } else {
    // ---- CHẠY TRÊN MÔI TRƯỜNG LOCAL DEVELOPMENT ----
    // Sử dụng file firebase_options.dart mặc định
    print("Initializing Firebase with default options for local development.");
    firebaseOptions = DefaultFirebaseOptions.currentPlatform;
  }

  // Khởi tạo Firebase với cấu hình đã chọn
  await Firebase.initializeApp(
    options: firebaseOptions,
  );

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
        // ... các theme khác của bạn
      ),
      home: const AuthWrapper(),
    );
  }
}