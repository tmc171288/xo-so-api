# Xổ Số Trực Tiếp - Lottery App

Ứng dụng xổ số trực tiếp với Flutter và Node.js backend, hỗ trợ cập nhật real-time qua Socket.IO.

## 📱 Tính năng

- ✅ **Kết quả trực tiếp** - Cập nhật real-time cho 3 vùng (Bắc, Trung, Nam)
- ✅ **Socket.IO Integration** - Nhận dữ liệu real-time
- ✅ **GetX State Management** - Quản lý state hiệu quả
- ✅ **Clean Architecture** - Cấu trúc code rõ ràng, dễ maintain
- ⏳ **Thống kê** - Tần suất, lô gan, đầu/đuôi (Coming soon)
- ⏳ **AI Dự đoán** - Phân tích và dự đoán (Coming soon)
- ⏳ **Cộng đồng** - Chia sẻ dự đoán (Coming soon)

## 🏗️ Cấu trúc Project

```
xoso_app/
├── lib/
│   ├── app/
│   │   ├── routes/          # App routing
│   │   ├── themes/          # Theme configuration
│   │   └── config/          # App config
│   ├── core/
│   │   ├── constants/       # Constants (colors, strings)
│   │   ├── utils/           # Utility functions
│   │   └── services/        # Core services (Socket, API)
│   ├── data/
│   │   ├── models/          # Data models
│   │   ├── repositories/    # Data repositories
│   │   └── providers/       # Data providers
│   ├── features/
│   │   ├── home/            # Home screen
│   │   ├── results/         # Results screen
│   │   ├── statistics/      # Statistics screen
│   │   ├── predictions/     # Predictions screen
│   │   └── community/       # Community screen
│   └── shared/
│       ├── widgets/         # Reusable widgets
│       └── components/      # UI components
├── backend/
│   ├── server.js            # Node.js server
│   └── package.json         # Backend dependencies
└── assets/
    ├── images/
    ├── icons/
    └── animations/
```

## 🚀 Cài đặt và Chạy

### 1. Backend (Node.js)

```bash
# Di chuyển vào thư mục backend
cd backend

# Cài đặt dependencies
npm install

# Chạy server
npm run dev
```

Server sẽ chạy tại: `http://localhost:3000`

### 2. Flutter App

```bash
# Cài đặt Flutter dependencies
flutter pub get

# Chạy app (Android/iOS)
flutter run

# Hoặc chạy trên Chrome
flutter run -d chrome
```

## 📦 Dependencies

### Flutter
- `get` - State management
- `socket_io_client` - Real-time communication
- `http` - HTTP requests
- `hive` - Local database
- `cached_network_image` - Image caching
- `shimmer` - Loading animations

### Backend
- `express` - Web framework
- `socket.io` - Real-time engine
- `cors` - CORS middleware
- `axios` - HTTP client
- `cheerio` - Web scraping (for future use)

## 🎨 Theme & Colors

### Region Colors
- 🔴 **Miền Bắc** - Red (#E53935)
- 🔵 **Miền Trung** - Blue (#1E88E5)
- 🟡 **Miền Nam** - Yellow (#FDD835)

## 🔌 API Endpoints

### REST API
- `GET /api/results/:region` - Lấy kết quả theo vùng
- `GET /api/results/:region/:date` - Lấy kết quả theo ngày

### Socket.IO Events
- **Client → Server**
  - `get_live_results` - Yêu cầu kết quả trực tiếp
  
- **Server → Client**
  - `lottery_update` - Cập nhật real-time
  - `lottery_complete` - Thông báo hoàn tất

## 📝 Hướng dẫn Phát triển

### Thêm màn hình mới

1. Tạo folder trong `lib/features/`
2. Tạo controller với GetX:
```dart
class MyController extends GetxController {
  // Your logic here
}
```
3. Tạo screen:
```dart
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MyController());
    // Your UI here
  }
}
```

### Thêm model mới

1. Tạo file trong `lib/data/models/`
2. Thêm Hive annotations nếu cần lưu local:
```dart
@HiveType(typeId: 1)
class MyModel {
  @HiveField(0)
  final String id;
  // ...
}
```
3. Chạy code generation:
```bash
flutter pub run build_runner build
```

## 🔮 Roadmap

### Phase 1: MVP (✅ Hoàn thành)
- [x] Project setup
- [x] Backend API với Socket.IO
- [x] Flutter app cơ bản
- [x] Home screen với region tabs
- [x] Real-time connection

### Phase 2: Core Features (🚧 Đang phát triển)
- [ ] Hiển thị kết quả chi tiết
- [ ] Lưu trữ lịch sử với Hive
- [ ] Thống kê cơ bản
- [ ] UI/UX improvements

### Phase 3: Advanced Features
- [ ] AI dự đoán
- [ ] Cộng đồng & social feed
- [ ] Push notifications
- [ ] Firebase integration
- [ ] AdMob monetization

## 🤝 Đóng góp

Đây là project học tập. Mọi đóng góp đều được hoan nghênh!

## 📄 License

MIT License

---

**Lưu ý**: Đây là ứng dụng demo cho mục đích học tập. Dữ liệu hiện tại được tạo ngẫu nhiên. Để sử dụng thực tế, cần tích hợp với nguồn dữ liệu xổ số chính thức.
