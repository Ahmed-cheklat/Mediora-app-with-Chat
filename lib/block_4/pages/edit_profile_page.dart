import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mediora/Network/networkServices.dart';
import 'dart:io';


class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  File? _pickedImage;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _firstNameEditable = false;
  bool _lastNameEditable = false;
  bool _usernameEditable = false;

  String? _selectedGender;
  DateTime? _selectedDob;
  String? _pictureUrl;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final firstName = await _secureStorage.read(key: 'first_name') ?? '';
    final lastName = await _secureStorage.read(key: 'last_name') ?? '';
    final username = await _secureStorage.read(key: 'username') ?? '';
    final email = await _secureStorage.read(key: 'email') ?? '';
    final gender = await _secureStorage.read(key: 'gender');
    final dobStr = await _secureStorage.read(key: 'date_of_birth');
    final picture = await _secureStorage.read(key: 'picture');

    setState(() {
      _firstNameController.text = firstName;
      _lastNameController.text = lastName;
      _usernameController.text = username;
      _emailController.text = email;
      _selectedGender = (gender != null && gender.isNotEmpty)
          ? gender[0].toUpperCase() + gender.substring(1).toLowerCase()
          : null;
      _selectedDob = (dobStr != null && dobStr.isNotEmpty)
          ? DateTime.tryParse(dobStr)
          : null;
      _pictureUrl =
          (picture != null && picture.startsWith('http') && picture != 'string')
          ? picture
          : null;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (image != null) {
      setState(() => _pickedImage = File(image.path));
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(now.year - 25),
      firstDate: DateTime(1920),
      lastDate: now,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF2463EB),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDob = picked);
  }

  Future<void> _onSave() async {
      if (!_formKey.currentState!.validate()) return;
      setState(() => _isSaving = true);

      try {
        // 1. Update text profile first
        final success = await UserServices().updateProfile(
          firstName: _firstNameEditable ? _firstNameController.text.trim() : null,
          lastName: _lastNameEditable ? _lastNameController.text.trim() : null,
          username: _usernameEditable ? _usernameController.text.trim() : null,
          gender: _selectedGender,
          dateOfBirth: _selectedDob != null
              ? '${_selectedDob!.year}-${_selectedDob!.month.toString().padLeft(2, '0')}-${_selectedDob!.day.toString().padLeft(2, '0')}'
              : null,
        );

        if (!mounted) return;

        if (success) {
          // 2. Save text fields to storage
          if (_firstNameEditable) await _secureStorage.write(key: 'first_name', value: _firstNameController.text.trim());
          if (_lastNameEditable) await _secureStorage.write(key: 'last_name', value: _lastNameController.text.trim());
          if (_usernameEditable) await _secureStorage.write(key: 'username', value: _usernameController.text.trim());
          if (_selectedGender != null) await _secureStorage.write(key: 'gender', value: _selectedGender!);
          if (_selectedDob != null) await _secureStorage.write(key: 'date_of_birth', value: _selectedDob!.toIso8601String());

          // 3. Upload picture separately if picked
          if (_pickedImage != null) {
            final cloudinaryUrl = await UserServices().uploadProfilePicture(_pickedImage!);
            if (cloudinaryUrl != null && mounted) {
              await _secureStorage.write(key: 'picture', value: cloudinaryUrl);
              setState(() {
                _pictureUrl = cloudinaryUrl;
                _pickedImage = null;
              });
            }
          }

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text('Profile updated successfully'),
              ]),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );

          setState(() {
            _firstNameEditable = false;
            _lastNameEditable = false;
            _usernameEditable = false;
          });

          await Future.delayed(const Duration(seconds: 1));
          if (mounted) Navigator.pop(context);
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 10),
                Text('Failed to update profile'),
              ]),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2463EB)),
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          children: [
            // ── Avatar ────────────────────────────────────────────
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 55.r,
                    backgroundColor: const Color(0xFFE8EFFD),
                    backgroundImage: _pickedImage != null
                        ? FileImage(_pickedImage!) as ImageProvider
                        : _pictureUrl != null
                        ? NetworkImage(_pictureUrl!) as ImageProvider
                        : const AssetImage('assets/default_avatar.png'),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 34.r,
                        height: 34.r,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2463EB),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF121212)
                                : Colors.white,
                            width: 2.5,
                          ),
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 16.r,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            28.verticalSpace,

            // ── Email (read-only) ─────────────────────────────────
            _SectionLabel(label: 'Email'),
            8.verticalSpace,
            _ReadOnlyField(
              controller: _emailController,
              icon: Icons.email_outlined,
              isDark: isDark,
            ),
            20.verticalSpace,

            // ── First Name ────────────────────────────────────────
            _SectionLabel(label: 'First Name'),
            8.verticalSpace,
            _EditableField(
              controller: _firstNameController,
              icon: Icons.person_outline,
              isEditable: _firstNameEditable,
              isDark: isDark,
              onToggle: () => setState(() {
                _firstNameEditable = !_firstNameEditable;
              }),
            ),
            20.verticalSpace,

            // ── Last Name ─────────────────────────────────────────
            _SectionLabel(label: 'Last Name'),
            8.verticalSpace,
            _EditableField(
              controller: _lastNameController,
              icon: Icons.person_outline,
              isEditable: _lastNameEditable,
              isDark: isDark,
              onToggle: () => setState(() {
                _lastNameEditable = !_lastNameEditable;
              }),
            ),
            20.verticalSpace,

            // ── Username ──────────────────────────────────────────
            _SectionLabel(label: 'Username'),
            8.verticalSpace,
            _EditableFieldUsername(
              controller: _usernameController,
              isEditable: _usernameEditable,
              isDark: isDark,
              onToggle: () => setState(() {
                _usernameEditable = !_usernameEditable;
              }),
            ),
            20.verticalSpace,

            // ── Gender ────────────────────────────────────────────
            _SectionLabel(label: 'Gender'),
            8.verticalSpace,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E1E1E)
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(14),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedGender,
                  hint: Text(
                    'Select gender',
                    style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                  ),
                  isExpanded: true,
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Color(0xFF2463EB),
                  ),
                  dropdownColor: isDark
                      ? const Color(0xFF1E1E1E)
                      : Colors.white,
                  items: ['Male', 'Female'].map((g) {
                    return DropdownMenuItem(
                      value: g,
                      child: Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 10,
                            color: g == 'Male'
                                ? const Color(0xFF2463EB)
                                : const Color(0xFFFF4D9E),
                          ),
                          8.horizontalSpace,
                          Text(g, style: TextStyle(fontSize: 13.sp)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedGender = val),
                ),
              ),
            ),
            20.verticalSpace,

            // ── Date of Birth ─────────────────────────────────────
            _SectionLabel(label: 'Date of Birth'),
            8.verticalSpace,
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E1E1E)
                      : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.cake_outlined,
                      color: Color(0xFF2463EB),
                      size: 20,
                    ),
                    12.horizontalSpace,
                    Text(
                      _selectedDob != null
                          ? '${_selectedDob!.day}/${_selectedDob!.month}/${_selectedDob!.year}'
                          : 'Select date of birth',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: _selectedDob != null
                            ? (isDark ? Colors.white : Colors.black)
                            : Colors.grey,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFF2463EB),
                    ),
                  ],
                ),
              ),
            ),
            36.verticalSpace,

            // ── Save Button ───────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2463EB),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSaving
                    ?  SizedBox(
                        height: 20.h,
                        width: 20.w,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            24.verticalSpace,
          ],
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: Colors.grey,
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final bool isDark;

  const _ReadOnlyField({
    required this.controller,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.h, vertical: 16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 20.r),
          12.horizontalSpace,
          Expanded(
            child: Text(
              controller.text.isEmpty ? '—' : controller.text,
              style: TextStyle(fontSize: 13.sp, color: Colors.grey),
            ),
          ),
          Icon(Icons.lock_outline, color: Colors.grey, size: 16.r),
        ],
      ),
    );
  }
}

class _EditableField extends StatefulWidget {
  final TextEditingController controller;
  final IconData icon;
  final bool isEditable;
  final bool isDark;
  final VoidCallback onToggle;

  const _EditableField({
    required this.controller,
    required this.icon,
    required this.isEditable,
    required this.isDark,
    required this.onToggle,
  });

  @override
  State<_EditableField> createState() => _EditableFieldState();
}

class _EditableFieldState extends State<_EditableField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void didUpdateWidget(_EditableField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isEditable && widget.isEditable) {
      Future.microtask(() => _focusNode.requestFocus());
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      readOnly: !widget.isEditable,
      focusNode: _focusNode,
      cursorColor: const Color(0xFF2463EB),
      style: TextStyle(
        fontSize: 13.sp,
        color: widget.isDark ? Colors.white : Colors.black,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return "Name is required";
        if (value.trim().length < 2)
          return "Name must be at least 2 characters";
        if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(value.trim()))
          return "Name must contain letters only";
        return null;
      },
      decoration: InputDecoration(
        prefixIcon: Icon(
          widget.icon,
          color: const Color(0xFF2463EB),
          size: 20.r,
        ),
        suffixIcon: GestureDetector(
          onTap: widget.onToggle,
          child: Icon(
            widget.isEditable ? Icons.check : Icons.edit,
            color: widget.isEditable ? Colors.green : const Color(0xFF2463EB),
            size: 18.r,
          ),
        ),
        filled: true,
        fillColor: widget.isEditable
            ? (widget.isDark
                  ? const Color(0xFF1E1E1E)
                  : const Color(0xFFF3F4F6))
            : (widget.isDark
                  ? const Color(0xFF2A2A2A)
                  : const Color(0xFFEEEEEE)),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2463EB), width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2463EB), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }
}

class _EditableFieldUsername extends StatefulWidget {
  final TextEditingController controller;
  final bool isEditable;
  final bool isDark;
  final VoidCallback onToggle;

  const _EditableFieldUsername({
    required this.controller,
    required this.isEditable,
    required this.isDark,
    required this.onToggle,
  });

  @override
  State<_EditableFieldUsername> createState() => _EditableFieldUsernameState();
}

class _EditableFieldUsernameState extends State<_EditableFieldUsername> {
  final FocusNode _focusNode = FocusNode();

  @override
  void didUpdateWidget(_EditableFieldUsername oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isEditable && widget.isEditable) {
      Future.microtask(() => _focusNode.requestFocus());
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      readOnly: !widget.isEditable,
      focusNode: _focusNode,
      cursorColor: const Color(0xFF2463EB),
      style: TextStyle(
        fontSize: 13.sp,
        color: widget.isDark ? Colors.white : Colors.black,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty)
          return "Username is required";
        if (value.contains(' ')) return "Username cannot contain spaces";
        if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value.trim()))
          return "Username can only contain letters, numbers, and _";
        return null;
      },
      decoration: InputDecoration(
        prefixIcon: const Icon(
          Icons.alternate_email,
          color: Color(0xFF2463EB),
          size: 20,
        ),
        suffixIcon: GestureDetector(
          onTap: widget.onToggle,
          child: Icon(
            widget.isEditable ? Icons.check : Icons.edit,
            color: widget.isEditable ? Colors.green : const Color(0xFF2463EB),
            size: 18,
          ),
        ),
        filled: true,
        fillColor: widget.isEditable
            ? (widget.isDark
                  ? const Color(0xFF1E1E1E)
                  : const Color(0xFFF3F4F6))
            : (widget.isDark
                  ? const Color(0xFF2A2A2A)
                  : const Color(0xFFEEEEEE)),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2463EB), width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2463EB), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }
}
