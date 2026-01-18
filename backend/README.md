# Xổ Số Backend API

Backend server cho ứng dụng Xổ Số với Socket.IO real-time updates.

## Cài đặt

```bash
cd backend
npm install
```

## Chạy server

### Development mode (với nodemon)
```bash
npm run dev
```

### Production mode
```bash
npm start
```

Server sẽ chạy tại: `http://localhost:3000`

## API Endpoints

### REST API

- `GET /` - API information
- `GET /api/results/:region` - Lấy kết quả theo vùng (north/central/south)
- `GET /api/results/:region/:date` - Lấy kết quả theo vùng và ngày

### Socket.IO Events

#### Client → Server
- `get_live_results` - Yêu cầu kết quả trực tiếp
  ```javascript
  socket.emit('get_live_results', { region: 'north' });
  ```

#### Server → Client
- `live_results` - Trả về kết quả hiện tại
- `lottery_update` - Cập nhật real-time khi có số mới
- `lottery_complete` - Thông báo khi quay số hoàn tất

## Cấu trúc dữ liệu

```javascript
{
  id: "north_HaNoi_1234567890",
  region: "north",
  date: "2026-01-12T00:00:00.000Z",
  province: "Hà Nội",
  specialPrize: "12345",
  firstPrize: ["67890"],
  secondPrize: ["11111", "22222"],
  thirdPrize: [...],
  fourthPrize: [...],
  fifthPrize: [...],
  sixthPrize: [...],
  seventhPrize: [...],
  eighthPrize: [],
  isLive: true,
  updatedAt: "2026-01-12T00:00:00.000Z"
}
```

## Tính năng

- ✅ Real-time updates với Socket.IO
- ✅ REST API cho dữ liệu lịch sử
- ✅ Tự động tạo dữ liệu mẫu (cho testing)
- ✅ CORS enabled
- ⏳ TODO: Kết nối database
- ⏳ TODO: Web scraping từ nguồn thật
- ⏳ TODO: Authentication
