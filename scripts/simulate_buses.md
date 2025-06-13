# Tài liệu: simulate_buses.dart

## Mục đích
Script này dùng để mô phỏng hoạt động của các xe buýt trên các tuyến đường, cập nhật vị trí, hướng di chuyển, tốc độ, trạng thái chỗ ngồi và gửi dữ liệu lên Supabase.

## Cấu trúc chính

### 1. Cấu hình
- Kết nối Supabase bằng `baseUrl` và `serviceRoleKey` từ file cấu hình.
- Sử dụng logger để log thông tin và lỗi.
- Sử dụng thư viện geodesy để tính toán địa lý.

### 2. Model
- **Stop**: Đại diện cho một điểm dừng (lat, lng).
- **Bus**: Đại diện cho một xe buýt, gồm các thuộc tính:
  - `vehicleId`, `routeId`, `stops`, `fromIndex`, `toIndex`, `direction`, `progress`, `speed`, `pauseAtStop`, `bearing`, `occupancyStatus`.
  - Phương thức `moveStep()` để cập nhật vị trí, hướng, tốc độ, trạng thái xe buýt mỗi bước mô phỏng.

### 3. Data Access
- **getRouteStops**: Lấy danh sách điểm dừng của một tuyến từ Supabase.
- **updateBusLocation**: Gửi vị trí, tốc độ, hướng, trạng thái xe buýt lên Supabase.

### 4. Main Logic
- Định nghĩa các tuyến và số lượng xe buýt cho mỗi tuyến.
- Khởi tạo danh sách xe buýt.
- Vòng lặp chính: mỗi giây cập nhật vị trí, trạng thái từng xe buýt và gửi lên Supabase.
- Log thông tin di chuyển và lỗi nếu có.

## Cách sử dụng
1. Đảm bảo đã cấu hình đúng Supabase trong `lib/configs/env.dart`.
2. Chạy script bằng lệnh:
   ```
   dart run scripts/simulate_buses.dart
   ```
3. Theo dõi log để kiểm tra hoạt động mô phỏng.

## Lưu ý
- Không import các package Flutter vào file này.
- Đảm bảo các file import cũng không phụ thuộc Flutter.
- Có thể mở rộng số tuyến, số xe buýt, logic mô phỏng theo nhu cầu.

---
Tác giả: Duy Phan
Ngày tạo: 2025-06-13

