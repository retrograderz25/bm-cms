#!/bin/bash

# Thoát ngay lập tức nếu có lệnh nào thất bại
set -e

# Sử dụng một phiên bản Flutter ổn định và cụ thể
# Phiên bản này PHẢI khớp với phiên bản trên máy của bạn
FLUTTER_VERSION="3.32.5" # <-- ĐÃ CẬP NHẬT THEO THÔNG TIN CỦA BẠN

# 1. Cài đặt Flutter SDK
echo ">>>> Cloning Flutter repository for version $FLUTTER_VERSION..."
git clone https://github.com/flutter/flutter.git --branch $FLUTTER_VERSION
export PATH="$PATH:`pwd`/flutter/bin"

# 2. Kiểm tra phiên bản Flutter (để xác nhận trong log)
echo ">>>> Verifying Flutter version..."
flutter --version

# 3. Kích hoạt Flutter web
echo ">>>> Enabling Flutter web..."
flutter config --enable-web

# 4. Tải các package của dự án
echo ">>>> Getting pub dependencies..."
flutter pub get

# 5. Build dự án Flutter Web
echo ">>>> Building Flutter web..."
flutter build web --release --no-tree-shake-icons

echo ">>>> Build successful!"