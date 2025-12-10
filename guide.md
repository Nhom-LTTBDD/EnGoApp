# Hướng dẫn nhanh cho presentation layer (frontend)

Mục đích: cung cấp quy ước và luồng làm việc để mọi người nhanh hiểu structure, trách nhiệm của providers/widgets/screens và viết code theo phong cách clean.

## Tóm tắt ngắn

- Providers: quản lý state + orchestration (gọi repository, xử lý lỗi/cache, debounce, persist).
- Widgets: dumb UI components — nhận props hoặc đọc provider; trả về callbacks.
- Screens/Pages: compose widgets, bind provider, khởi tạo load, điều phối navigation.
- Repositories / Data layer: I/O (HTTP / DB) — providers không gọi HTTP trực tiếp.

## Luồng đơn giản (sequence)

User action → Widget (callback) → Provider.method() → Repository → DataSource (API/DB) → Repository trả về → Provider cập nhật state → notifyListeners() → Widget (Consumer/Selector) rebuild

## Quy ước quan trọng

- Tên constants: lowerCamelCase với tiền tố `k` cho global konstants (ví dụ `kPrimaryColor`).
- Files: một trách nhiệm / file. `widgets/` chỉ UI, `providers/` chỉ state orchestration.
- Provider pattern: inject repository qua constructor (testable), không dùng I/O trực tiếp trong provider.
- Assets: khai báo trong `pubspec.yaml` (thư mục hoặc file). SVG dùng `flutter_svg` hoặc icon font dùng `font_awesome_flutter`.
- Null-safety: handle nullable fields, cung cấp placeholder/fallback cho image/text.
- Linting: bật `flutter_lints` và tuân theo rules (đặt sẵn trong repo).

## Handling trạng thái & lỗi

- State model: {idle, loading, loaded, error} hoặc tương đương; expose `errorMessage`.
- Khi gọi network: set state=loading → call repo → onSuccess set data+loaded → onError set state=error + errorMessage.
- Retry: UI nghiệm thu cơ chế retry/refresh.

## Performance & UX

- Dùng selectors/Consumer để tránh rebuild toàn bộ subtree.
- Cache images (CachedNetworkImage) và responses khi thích hợp.
- Debounce search / rapid taps trong provider.
- Optimize lists: const constructors, keys khi cần.

## Accessibility & Testing

- Thêm semanticLabel cho icon/button, đảm bảo tappable area >= 48x48.
- Unit test providers (mock repository), widget tests cho từng widget, integration test flow chính.
- Tách logic (scoring, SRS, formatting) ra helper/service để đơn vị test.

## Checklist khi thêm feature mới

1. Thiết kế API provider + methods cần thiết.
2. Tạo model/chuyển đổi JSON ở data layer.
3. Viết repository cho network/local.
4. Implement provider (inject repo, xử lý state/error).
5. Tạo reusable widget(s) trong `widgets/` (dumb).
6. Compose trên Screen, bind provider, xử lý navigation.
7. Cập nhật `pubspec.yaml` nếu thêm assets/packages.
8. Viết unit tests cho provider + widget tests cho UI.
9. PR checklist: changelog ngắn, testing steps, screenshots nếu UI thay đổi.

## Ví dụ ngắn — danh sách từ vựng

- Screen init: provider.loadList()
- Provider: set loading -> repo.fetchList() -> set items + loaded -> notify
- Screen: Consumer rebuild list of VocabularyCard (dumb), card callbacks gọi provider.toggleFavorite(id)

---

Ghi chú: giữ file này ngắn, trực quan; nếu muốn tôi có thể thêm diagram ASCII hoặc tạo checklist PR template và một file CONTRIBUTING.md.
