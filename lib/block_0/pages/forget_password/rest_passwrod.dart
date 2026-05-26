import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mediora/Network/networkServices.dart';
import 'package:mediora/block_0/pages/sign_up/set_a_password_for_sign_up.dart';
import 'package:mediora/block_0/pages/signin_with_hellopage/sign_in.dart';
import 'package:mediora/block_1/pages%20/homePage.dart';

import 'package:mediora/tools.dart';

class RestPasswrod extends StatefulWidget {
  final PasswordFlow flow;
  final bool isFromSettings;
  final String? token;
  const RestPasswrod({
    super.key,
    required this.isFromSettings,
    required this.flow,
    required this.token,
  });

  @override
  State<RestPasswrod> createState() => _RestPasswrodState();
}

class _RestPasswrodState extends State<RestPasswrod> {
  final TextEditingController passwordcontroller = TextEditingController();
  final TextEditingController confirmcontroller = TextEditingController();

  @override
  void dispose() {
    passwordcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                70.verticalSpace,
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Choose a strong password to keep your account safe",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontFamily: "LineSeedJP",
                      color: Colors.grey,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                40.verticalSpace, // بدل SizedBox(height: ...)

                Padding(
                  padding: EdgeInsets.all(8.w),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "New Password",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'LineSeedJP',
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),

                CreatePassword(controller: passwordcontroller),

                20.verticalSpace,

                Padding(
                  padding: EdgeInsets.all(8.w),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Confirm Password",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'LineSeedJP',
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),

                ConfirmPasswordField(controller: confirmcontroller),

                15.verticalSpace,

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 9.w),
                  child: Divider(color: Colors.grey, thickness: 1.h),
                ),

                15.verticalSpace,

                Button(
                  function: () async {
                    final error = validatePasswords(
                      passwordcontroller,
                      confirmcontroller,
                    );
                    if (error != null) {
                      CustomSnackBar.show(
                        context,
                        message: error,
                        backgroundColor: Colors.red,
                        icon: Icons.error_outline,
                      );
                      return;
                    }
                    final result = await AuthService().updatePasswordWithToken(
                      password: passwordcontroller.text,
                      resetToken: widget.token!,
                    );
                    if (!result.success){
                      CustomSnackBar.show(context, 
                      message: result.message,
                      icon: Icons.error,
                      backgroundColor: Colors.red); 
                    }
                    if (result.success){
                    
                      if (PasswordFlow.forgetPasswordAuth == widget.flow) {
                        CustomSnackBar.show(
                          context,
                          message: 'Password Updated',
                          backgroundColor: Color(0xFF2463EB),
                          icon: Icons.error_outline,
                        );
                        if (widget.isFromSettings) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => Homepage()),
                            (route) => false,
                          );
                        } else {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => SignIn()),
                            (route) => false,
                          );
                        }
                      }
                    }
                  },
                  //Button design
                  mywidget: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Next",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontFamily: "LineSeedJP",
                          fontSize: 16.sp,
                          color: Colors.white,
                        ),
                      ),
                      10.horizontalSpace,
                      Icon(Icons.arrow_forward, size: 30.r),
                    ],
                  ),
                  isFromSettings: widget.isFromSettings,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Message that password updated
class CustomSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    int seconds = 2,
    Color backgroundColor = const Color(0xFF2463EB),
    IconData? icon,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: seconds),
        behavior: SnackBarBehavior.floating,
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.w),
        ),
        margin: EdgeInsets.symmetric(horizontal: 20.h, vertical: 20.w),
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white),
              SizedBox(width: 10.w),
            ],
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: "LineSeedJP",
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ConfirmPasswordField extends StatefulWidget {
  final TextEditingController controller;
  const ConfirmPasswordField({super.key, required this.controller});

  @override
  State<ConfirmPasswordField> createState() => _ConfirmPasswordFieldState();
}

class _ConfirmPasswordFieldState extends State<ConfirmPasswordField> {
  bool _obscureText = true;
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

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      obscureText: _obscureText,
      style: TextStyle(fontFamily: 'LineSeedJP', fontSize: 14.sp),
      keyboardType: TextInputType.visiblePassword,
      decoration: InputDecoration(
        hintText: 'Confirm your password',
        hintStyle: TextStyle(
          fontFamily: 'LineSeedJP',
          color: Colors.grey.shade400,
          fontSize: 14.sp,
        ),
        prefixIcon: Icon(
          Icons.lock_outline,
          color: _focusNode.hasFocus ? const Color(0xFF2463EB) : Colors.grey,
        ),
        suffixIcon: IconButton(
          icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _obscureText = !_obscureText),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.r)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: BorderSide(color: Color(0xFF2463EB), width: 2.w),
        ),
      ),
    );
  }
}
