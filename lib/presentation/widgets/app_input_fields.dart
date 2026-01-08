/*
 * app_input_fields.dart
 *
 * Chức năng:
 * - Tập hợp các trường nhập liệu chuẩn của app: TextField, PasswordField, SearchField, OTPField, TextArea.
 * - Chuẩn hóa kích thước, border, error handling, prefix/suffix icons, và validation hooks.
 *
 * Được sử dụng ở đâu:
 * - Form đăng nhập/đăng ký, tìm kiếm, profile edit, bài tập nhập liệu, modal forms.
 *
 * API (props) gợi ý:
 * - final TextEditingController controller;
 * - final String? labelText;
 * - final String? hintText;
 * - final String? Function(String?)? validator;
 * - final bool obscureText; // password
 * - final Widget? prefixIcon;
 * - final Widget? suffixIcon;
 * - final TextInputType? keyboardType;
 *
 * Lưu ý:
 * - Dùng InputDecorationTheme hoặc reuse constants từ theme để giữ consistent style.
 * - Hiện error text chỉ khi field touched/dirty — validation logic nên quản lý bởi form/state quản lý.
 * - Accessibility: labelText + semantics; ensure contrast ratio cho text/error color.
 * - Test: kiểm tra visual states (focused, error, disabled), và validator behaviors.
 * - Security: không log giá trị password; nếu copy/paste disabled cho sensitive fields thì ghi chú.
 *
 * Ví dụ dùng:
 * AppPasswordField(
 *   controller: _passwordCtrl,
 *   labelText: 'Mật khẩu',
 *   validator: (v) => v != null && v.length < 8 ? 'Ít nhất 8 ký tự' : null,
 * )
 */
