/*
 * app_modal.dart
 *
 * Chức năng:
 * - Định nghĩa modal sheet / dialog tiêu chuẩn của app (header, body, actions).
 * - Chuẩn hóa style, paddings, radius và animation cho mọi modal.
 *
 * Được sử dụng ở đâu:
 * - Confirm dialog, select options, preview image, settings modal, authentication prompts.
 *
 * API (props) gợi ý:
 * - final Widget title;
 * - final Widget? content;
 * - final List<Widget>? actions;
 * - final bool dismissible;
 * - final ShapeBorder? shape;
 * - final Color? backgroundColor;
 *
 * Lưu ý:
 * - Dùng showModalBottomSheet hoặc showDialog tuỳ loại modal; cung cấp wrapper helper showAppModal().
 * - Accessibility: đảm bảo focus trap trong dialog, cung cấp semanticDismiss action.
 * - Hạn chế đặt logic nặng trong modal; truyền callback để xử lý.
 * - Nếu modal chứa form, dùng Form với GlobalKey để validate trước khi đóng.
 * - Test: mở/đóng modal, callback actions được gọi, keyboard/escape dismiss hoạt động.
 *
 * Ví dụ dùng:
 * showAppModal(
 *   context: context,
 *   title: Text('Confirm'),
 *   content: Text('Are you sure?'),
 *   actions: [TextButton(onPressed: cancel, child: Text('Cancel'))],
 * );
 */
