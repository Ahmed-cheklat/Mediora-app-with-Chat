import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mediora/Network/networkServices.dart';
import 'package:mediora/block_0/pages/forget_password/rest_passwrod.dart';
import 'package:mediora/block_0/pages/sign_up/set_a_password_for_sign_up.dart';

class ValidationGmail extends StatefulWidget {
  final String gmail;
  final bool isFromSettings;
  const ValidationGmail({
    super.key,
    required this.gmail,
    required this.isFromSettings,
  });

  @override
  State<ValidationGmail> createState() => _ValidationGmailState();
}

class _ValidationGmailState extends State<ValidationGmail> {
  final TextEditingController _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(8.w),
          child: SingleChildScrollView(
            child: Column(
              children: [
                40.verticalSpace,
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Enter verification code',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontFamily: "LineSeedJP",
                      fontSize: 32.sp,
                    ),
                  ),
                ),
                10.verticalSpace,
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "We sent a code to ${widget.gmail}. Enter it below to verify your account",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14.sp,
                      fontFamily: "LineSeedJP",
                      color: Colors.grey,
                    ),
                  ),
                ),
                50.verticalSpace,
                GmailVerifyCode(controller: _otpController),
                15.verticalSpace,
                ResendCodeTimer(),
                25.verticalSpace,
                VerfiyAndConituneButton(
                  isFromSettings: widget.isFromSettings,
                  otpController: _otpController,
                  function: () async {
                    final code = _otpController.text;
                    if (code.length < 10) {
                      CustomSnackBar.show(
                        context,
                        message: 'Please enter the complete code',
                        backgroundColor: Colors.red,
                        icon: Icons.error_outline,
                      );
                      return;
                    }

                    final result = await AuthService().resetPassword(
                      code: _otpController.text,
                    );
                    if (!result.success) {
                      CustomSnackBar.show(
                        context,
                        message: result.message,
                        icon: Icons.error,
                        backgroundColor: Colors.red,
                      );
                    }
                    if (result.success){
                      Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RestPasswrod(
                          isFromSettings: widget.isFromSettings,
                          flow: PasswordFlow.forgetPasswordAuth,
                          token: result.token!,
                        ),
                      ),
                      (route) => false, 
                    );
                    }
                    
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GmailVerifyCode extends StatelessWidget {
  final TextEditingController controller;
  const GmailVerifyCode({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [
          LengthLimitingTextInputFormatter(10),
          FilteringTextInputFormatter.digitsOnly,
        ],
        style: TextStyle(
          fontFamily: "LineSeedJP",
          fontSize: 22.sp,
          fontWeight: FontWeight.bold,
          letterSpacing: 6.w,
        ),
        textAlign: TextAlign.center,
        cursorColor: const Color(0xFF2463EB),
        decoration: InputDecoration(
          hintText: '• • • • • • • • • •',
          hintStyle: TextStyle(
            color: Colors.grey.shade300,
            fontSize: 22.sp,
            letterSpacing: 6.w,
          ),
          border: InputBorder.none,
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade300, width: 2.h),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: const Color(0xFF2463EB), width: 2.h),
          ),
        ),
      ),
    );
  }
}

class VerfiyAndConituneButton extends StatefulWidget {
  final bool isFromSettings;
  final TextEditingController otpController;
  final Future<void> Function() function;
  const VerfiyAndConituneButton({
    super.key,
    required this.isFromSettings,
    required this.otpController,
    required this.function,
  });

  @override
  State<VerfiyAndConituneButton> createState() =>
      _VerfiyAndConituneButtonState();
}

class _VerfiyAndConituneButtonState extends State<VerfiyAndConituneButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading
            ? null
            : () async {
                setState(() => _isLoading = true);
                await widget.function();
                if (mounted) setState(() => _isLoading = false);
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2463EB),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 15.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r),
          ),
          elevation: 10.h,
        ),
        child: _isLoading
            ? SizedBox(
                height: 20.h,
                width: 20.h,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Verify & Continue",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontFamily: "LineSeedJP",
                      fontSize: 16.sp,
                      color: Colors.white,
                    ),
                  ),
                  10.horizontalSpace,
                  Icon(Icons.check_circle_outline_outlined, size: 30.r),
                ],
              ),
      ),
    );
  }
}

class ResendCodeTimer extends StatefulWidget {
  const ResendCodeTimer({super.key});

  @override
  State<ResendCodeTimer> createState() => _ResendCodeTimerState();
}

class _ResendCodeTimerState extends State<ResendCodeTimer> {
  Timer? _timer;
  int _start = 60;

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        timer.cancel();
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Resend code in ",
              style: TextStyle(
                color: Colors.grey,
                fontFamily: "LineSeedJP",
                fontWeight: FontWeight.w400,
                fontSize: 14.sp,
              ),
            ),
            Text(
              "${_start}s",
              style: TextStyle(
                color: const Color(0xFF2463EB),
                fontWeight: FontWeight.bold,
                fontFamily: "LineSeedJP",
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
        if (_start == 0)
          TextButton(
            onPressed: () {
              setState(() {
                _start = 60;
                startTimer();
              });
            },
            child: Text(
              "Resend Now",
              style: TextStyle(color: const Color(0xFF2463EB), fontSize: 14.sp),
            ),
          ),
      ],
    );
  }
}

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
