# bm_cms

A new Flutter project.

# Project Structure
```
flutter_student_manager/
├── lib/
│   ├── main.dart                   <-- Điểm khởi đầu của ứng dụng
│
│   └── src/                        <-- Chứa toàn bộ mã nguồn của ứng dụng
│       ├── common/                 <-- Các widget, hằng số, tiện ích dùng chung
│       │   ├── constants/
│       │   │   └── app_colors.dart
│       │   │   └── firestore_constants.dart
│       │   ├── routing/
│       │   │   └── app_router.dart
│       │   ├── utils/
│       │   │   └── validators.dart
│       │   └── widgets/
│       │       └── custom_button.dart
│       │       └── loading_indicator.dart
│
│       ├── data/                   <-- Lớp dữ liệu (Models, Repositories)
│       │   ├── models/
│       │   │   └── user_model.dart
│       │   │   └── class_model.dart
│       │   │   └── assignment_model.dart
│       │   │   └── submission_model.dart
│       │   ├── repositories/
│       │   │   └── auth_repository.dart
│       │   │   └── class_repository.dart
│       │   └── services/
│       │       └── firebase_auth_service.dart
│       │       └── firestore_service.dart
│
│       └── features/               <-- Các tính năng chính của ứng dụng
│           ├── authentication/
│           │   ├── providers/        <-- Quản lý state cho tính năng này
│           │   ├── screens/          <-- Các màn hình (UI)
│           │   └── widgets/          <-- Các widget con chỉ dùng trong tính năng này
│           │
│           ├── ta_dashboard/
│           │   ├── providers/
│           │   ├── screens/
│           │   └── widgets/
│           │
│           └── student_dashboard/
│               ├── providers/
│               ├── screens/
│               └── widgets/
│
└── pubspec.yaml
```
