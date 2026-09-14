# DLSLowRes — Dopamine / ElleKit / Rootless

**Dành cho Dopamine thường**, không phải RootHide.

Dopamine dùng ElleKit để inject tweak. Không có mục `App List` như RootHide.
Tweak được lọc tự động bằng `DLSLowRes.plist`:

`com.firsttouch.dls7`

## Cài đặt
1. Nếu đã cài bản `DLSLowRes` build cho RootHide trước đó, gỡ nó trong Sileo/Zebra trước.
2. Build file `.deb` từ project này bằng GitHub Actions.
3. Cài `.deb` bằng Sileo/Zebra.
4. Respring một lần.
5. Vào Data container của DLS -> `Documents`.
6. Tạo `dlslowres.txt`, nội dung ví dụ `55`.
7. Force close DLS và mở lại.

## Kiểm tra inject
Nếu hook thực sự chạy, tweak tự tạo:

`Documents/dlslowres_status.txt`

Nội dung sẽ có:
- scale
- input drawable size
- output drawable size

Không có file status => tweak chưa inject hoặc DLS không đi qua `CAMetalLayer setDrawableSize:` theo đường hook này.

## Preset
- 75 = đẹp hơn, nhẹ vừa
- 65 = cân bằng
- 55 = nhẹ mạnh
- 40 = cực thấp để test
