import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CreatePassword extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;

  const CreatePassword({
    super.key,
    required this.controller,
    this.hintText = 'Enter your password',
  });

  @override
  State<CreatePassword> createState() => _CreatePasswordState();
}

class _CreatePasswordState extends State<CreatePassword> {
  bool _obscureText = true;
  bool _hasMinLength = false;
  bool _hasUpperCase = false;
  bool _hasSymbol = false;
  bool _isTouched = false;

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _validatePassword(String value) {
    setState(() {
      _isTouched = true;
      _hasMinLength = value.length >= 8;
      _hasUpperCase = RegExp(r'[A-Z]').hasMatch(value);
      _hasSymbol = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Password field
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          obscureText: _obscureText,
          onChanged: _validatePassword,
          style: TextStyle(fontFamily: 'LineSeedJP', fontSize: 14.sp),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: const TextStyle(
              color: Colors.grey,
              fontFamily: "LineSeedJP",
            ),
            prefixIcon: Icon(
              Icons.lock_outline,
              color: _focusNode.hasFocus
                  ? const Color(0xFF2463EB)
                  : Colors.grey,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: () => setState(() => _obscureText = !_obscureText),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.r),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.r),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.r),
              borderSide: BorderSide(color: Color(0xFF2463EB), width: 2.w),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.r),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            errorStyle: TextStyle(
              fontFamily: 'LineSeedJP',
              color: Colors.red,
              fontSize: 13.sp,
            ),
          ),

          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Password is required';
            }
            if (value.length < 8) {
              return 'At least 8 characters';
            }
            if (!RegExp(r'[A-Z]').hasMatch(value)) {
              return 'Need 1 uppercase letter';
            }
            if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
              return 'Need 1 special character';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // Simple requirements check
        if (_isTouched) ...[
          _buildRequirement('✓ 8+ characters', _hasMinLength),
          const SizedBox(height: 4),
          _buildRequirement('✓ 1 uppercase', _hasUpperCase),
          const SizedBox(height: 4),
          _buildRequirement('✓ 1 special character', _hasSymbol),
        ],
      ],
    );
  }

  Widget _buildRequirement(String text, bool isMet) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'LineSeedJP',
        fontSize: 13,
        color: isMet ? Colors.green : Colors.red,
      ),
    );
  }
}


// button and you add what inside
class Button extends StatelessWidget {
  final VoidCallback function;
  final bool isFromSettings; 
  final Widget mywidget;
  const Button({super.key, required this.function, required this.mywidget,required this.isFromSettings});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: function,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2463EB),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 15.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r),
          ),
          elevation: 10.h,
        ),
        child: mywidget,
      ),
    );
  }
}

//button navigat and remove until
class ButtonRemoveUntil extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final IconData icon;
  const ButtonRemoveUntil({
    super.key,
    required this.text,
    required this.onPressed,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2463EB),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 15.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r),
          ),
          elevation: 10.h,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontFamily: "LineSeedJP",
                fontSize: 16.sp,
                color: Colors.white,
              ),
            ),
            10.horizontalSpace,
            Icon(icon, size: 30.r),
          ],
        ),
      ),
    );
  }
}






