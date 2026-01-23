// lib/presentation/pages/profile/edit_profile_page.dart
// Trang chỉnh sửa thông tin profile
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:en_go_app/core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/profile/profile_provider.dart';
import '../../providers/profile/profile_state.dart';
import '../../widgets/common/app_button.dart';
import 'package:intl/intl.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nameFocusNode = FocusNode();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _nameFocusNode.addListener(() => setState(() {}));

    // Load dữ liệu hiện tại của user vào form
    _loadUserData();
  }

  /// Load dữ liệu user hiện tại vào các field
  void _loadUserData() {
    final user = context.read<ProfileProvider>().currentUser;
    if (user == null) return;

    _nameController.text = user.name;

    // Parse ngày sinh nếu có
    if (user.birthDate != null && user.birthDate!.isNotEmpty) {
      try {
        _selectedDate = DateFormat('dd/MM/yyyy').parse(user.birthDate!);
      } catch (e) {
        // Nếu parse lỗi, giữ _selectedDate là null
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: kPrimaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// Xử lý lưu thông tin profile
  Future<void> _handleSave(BuildContext context) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final profileProvider = context.read<ProfileProvider>();
    final birthDateStr = _selectedDate != null
        ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
        : null;

    await profileProvider.updateProfile(
      name: _nameController.text.trim(),
      birthDate: birthDateStr,
    );

    if (!context.mounted) return;

    final state = profileProvider.state;
    if (state is ProfileUpdated) {
      // Quay lại và hiển thị thông báo thành công
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật thông tin thành công'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } else if (state is ProfileError) {
      // Hiển thị thông báo lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: kDanger,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Chỉnh sửa hồ sơ'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, _) {
          final isLoading = profileProvider.state is ProfileUpdating;

          return Container(
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors:
                    themeExt?.backgroundGradientColors ??
                    [Colors.white, const Color(0xFFB2E0FF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),

                    _buildNameField(context, themeExt, isLoading),
                    const SizedBox(height: 20),

                    _buildDatePickerField(context, themeExt, isLoading),
                    const SizedBox(height: 40),

                    // Save Button
                    Opacity(
                      opacity: isLoading ? 0.5 : 1.0,
                      child: SizedBox(
                        height: 50,
                        child: AppButton(
                          text: isLoading ? 'Đang lưu...' : 'Lưu thay đổi',
                          variant: AppButtonVariant.accent,
                          size: AppButtonSize.large,
                          onPressed: isLoading
                              ? null
                              : () => _handleSave(context),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Cancel Button
                    SizedBox(
                      height: 50,
                      child: AppButton(
                        text: 'Hủy',
                        variant: AppButtonVariant.danger,
                        size: AppButtonSize.large,
                        onPressed: isLoading
                            ? null
                            : () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Widget name input field
  Widget _buildNameField(
    BuildContext context,
    AppThemeExtension? themeExt,
    bool isLoading,
  ) {
    return TextFormField(
      controller: _nameController,
      focusNode: _nameFocusNode,
      autofocus: true,
      style: TextStyle(
        color: Theme.of(context).textTheme.bodyLarge?.color,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: 'Họ và tên',
        prefixIcon: Icon(
          Icons.person_outlined,
          color: _nameFocusNode.hasFocus ? kPrimaryColor : Colors.grey.shade600,
        ),
        labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 16),
        floatingLabelStyle: const TextStyle(color: kPrimaryColor, fontSize: 14),
        filled: true,
        fillColor: (themeExt?.cardBackground ?? Colors.white).withOpacity(
          themeExt?.surfaceOpacity ?? 0.9,
        ),
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: kPrimaryColor, width: 2.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: kDanger, width: 1.5),
        ),
      ),
      textInputAction: TextInputAction.done,
      enabled: !isLoading,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng nhập họ tên';
        }
        if (value.length < 2) {
          return 'Họ tên phải có ít nhất 2 ký tự';
        }
        return null;
      },
    );
  }

  /// Widget date picker field
  Widget _buildDatePickerField(
    BuildContext context,
    AppThemeExtension? themeExt,
    bool isLoading,
  ) {
    return InkWell(
      onTap: isLoading ? null : () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: (themeExt?.cardBackground ?? Colors.white).withOpacity(
            themeExt?.surfaceOpacity ?? 0.9,
          ),
          border: Border.all(color: Colors.grey.shade400, width: 1.5),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Icon(Icons.cake_outlined, color: Colors.grey.shade600),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedDate != null
                    ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                    : 'Chọn ngày sinh',
                style: TextStyle(
                  fontSize: 16,
                  color: _selectedDate != null
                      ? Theme.of(context).textTheme.bodyLarge?.color
                      : Colors.grey[600],
                ),
              ),
            ),
            const Icon(Icons.calendar_today, color: kPrimaryColor),
          ],
        ),
      ),
    );
  }
}
