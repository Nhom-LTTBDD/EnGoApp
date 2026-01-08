// lib/presentation/pages/profile/edit_profile_page.dart
// Trang chỉnh sửa thông tin profile
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:en_go_app/core/constants/app_colors.dart';
import '../../providers/profile/profile_provider.dart';
import '../../providers/profile/profile_state.dart';
import '../../widgets/app_button.dart';
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
    // Load dữ liệu hiện tại
    final profileProvider = context.read<ProfileProvider>();
    final user = profileProvider.currentUser;
    if (user != null) {
      _nameController.text = user.name;
      if (user.birthDate != null && user.birthDate!.isNotEmpty) {
        try {
          _selectedDate = DateFormat('dd/MM/yyyy').parse(user.birthDate!);
        } catch (e) {
          // Nếu parse lỗi, để null
        }
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

  void _handleSave(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      final profileProvider = context.read<ProfileProvider>();
      final birthDateStr = _selectedDate != null
          ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
          : null;

      profileProvider.updateProfile(
        name: _nameController.text.trim(),
        birthDate: birthDateStr,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Chỉnh sửa hồ sơ'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, _) {
          // Listen to state changes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final state = profileProvider.state;

            if (state is ProfileUpdated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cập nhật thông tin thành công'),
                  backgroundColor: Colors.green,
                ),
              );
              // Navigate back sau khi cập nhật
              Future.delayed(const Duration(milliseconds: 500), () {
                if (context.mounted) {
                  Navigator.pop(context);
                }
              });
            } else if (state is ProfileError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: kDanger,
                ),
              );
            }
          });

          final isLoading = profileProvider.state is ProfileUpdating;

          return Container(
            decoration: const BoxDecoration(gradient: kBackgroundGradient),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),

                    // Name Field
                    TextFormField(
                      controller: _nameController,
                      focusNode: _nameFocusNode,
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'Họ và tên',
                        prefixIcon: Icon(Icons.person_outlined),
                        floatingLabelStyle: TextStyle(color: kPrimaryColor),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: kPrimaryColor,
                            width: 2,
                          ),
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
                    ),
                    const SizedBox(height: 20),

                    // Birth Date Picker
                    InkWell(
                      onTap: isLoading ? null : () => _selectDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.cake_outlined, color: Colors.grey),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _selectedDate != null
                                    ? DateFormat(
                                        'dd/MM/yyyy',
                                      ).format(_selectedDate!)
                                    : 'Chọn ngày sinh',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _selectedDate != null
                                      ? Colors.black87
                                      : Colors.grey[600],
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.calendar_today,
                              color: kPrimaryColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Save Button
                    SizedBox(
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

                    if (isLoading) ...[
                      const SizedBox(height: 20),
                      const Center(
                        child: CircularProgressIndicator(color: kPrimaryColor),
                      ),
                    ],

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
}
