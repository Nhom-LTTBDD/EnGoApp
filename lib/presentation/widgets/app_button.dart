/*
 * app_button.dart
 *
 * Chức năng:
 * - Nút chuẩn của app với các biến thể: primary (filled gradient), secondary (outline), text, icon button.
 * - Chuẩn hóa radius, padding, disabled state, loading state, và kiểu gradient.
 *
 * Được sử dụng ở đâu:
 * - Mọi nơi cần nút: Auth screens, lesson actions, dialogs, forms.
 *
 * API (props) gợi ý:
 * - final Widget child; // text/icon
 * - final VoidCallback? onPressed;
 * - final ButtonVariant variant; // primary / secondary / ghost / icon
 * - final bool isLoading;
 * - final bool disabled;
 * - final EdgeInsets? padding;
 * - final double? borderRadius;
 *
 * Lưu ý:
 * - Khi isLoading true, disable onPressed và show progress indicator nhỏ trong nút.
 * - Dùng InkWell / Material tap ripple để giữ native feedback.
 * - Hỗ trợ both gradient and solid color (kPrimaryButtonGradient, kPrimaryButtonColor).
 * - Accessibility: ensure contrast and minimum tappable area, add semanticsLabel for icon-only buttons.
 * - Test: disabled vs enabled, loading state, accessibility labels, different text lengths.
 *
 * Ví dụ dùng:
 * AppButton.primary(onPressed: submit, child: Text('Continue'));
 */
