import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mediora/Network/networkServices.dart';
import 'package:mediora/block_0/pages/sign_up/set_a_password_for_sign_up.dart';
import 'package:mediora/block_0/pages/sign_up/user_information.dart';

class GmailValidation extends StatefulWidget {
  final String email;
  const GmailValidation({super.key, required this.email});

  @override
  State<GmailValidation> createState() => _GmailValidationState();
}

class _GmailValidationState extends State<GmailValidation> {
  String otpCode = "";
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(8.0.w),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                        "A code has been sent to your email, Please enter it below",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontFamily: "LineSeedJP",
                          color: Colors.grey,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                    40.verticalSpace,
                    GmailVerifyCodeForSignUp(
                      onCodeChanged: (code) {
                        setState(() {
                          otpCode = code;
                        });
                        //print("Current Code saved in Parent: $otpCode");
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 9.w),
                      child: Divider(color: Colors.grey, thickness: 1.h),
                    ),
                    15.verticalSpace,
                    ResendCodeTimerForSignUp(email: widget.email, otp: otpCode),
                    25.verticalSpace,
                    ButtonOfGmailValidation(
                      function: () async {
                         if (otpCode.length < 7) {
                        CustomSnackBarForSignUp.show(
                          context,
                          message: 'Please enter the complete 6-digit code',
                          icon: Icons.error,
                          backgroundColor: Colors.red,
                        );
                        return;
    }
                        if (!_formKey.currentState!.validate()) return;
                        setState(() {
                          _isLoading = true;
                        });
                        final result = await AuthService().verifyEmail(
                          email: widget.email,
                          otp: otpCode,
                        );
                        print('Token from verifyEmail: ${result.token}');
                        if (!mounted) return;
                        setState(() {
                          _isLoading = false;
                        });
                        CustomSnackBarForSignUp.show(
                          context,
                          message: result.message,
                          icon: result.success
                              ? Icons.check_circle
                              : Icons.error,
                          backgroundColor: result.success
                              ? const Color(0xFF2463EB)
                              : Colors.red,
                        );
                        if (result.success) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserInformation(
                                email: widget.email,
                                token: result.token!,
                              ),
                            ),
                            (route) => false,
                          );
                        }
                      },
                      mywidget: _isLoading
                          ? SizedBox(
                              height: 20.r,
                              width: 20.r,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Next',
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
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

//---------------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------------

class GmailVerifyCodeForSignUp extends StatefulWidget {
  final Function(String) onCodeChanged;
  const GmailVerifyCodeForSignUp({super.key, required this.onCodeChanged});

  @override
  State<GmailVerifyCodeForSignUp> createState() =>
      _GmailVerifyCodeForSignUpState();
}

class _GmailVerifyCodeForSignUpState extends State<GmailVerifyCodeForSignUp> {
  final List<TextEditingController> _controllers = List.generate(
    7,
    (index) => TextEditingController(),
  );

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateCode() {
    String fullCode = _controllers.map((c) => c.text).join();
    widget.onCodeChanged(fullCode);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (index) {
            return SizedBox(
              height: 60.h,
              width: 42.w,
              child: TextFormField(
                controller: _controllers[index],
                onChanged: (value) {
                  if (value.length == 1 && index < 6) {
                    FocusScope.of(context).nextFocus();
                  }
                  if (value.isEmpty && index > 0) {
                    FocusScope.of(context).previousFocus();
                  }
                  _updateCode();
                },
                style: TextStyle(
                  fontFamily: "LineSeedJP",
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(1),
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(
                      color: Color(0xFF2463EB),
                      width: 2,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class ResendCodeTimerForSignUp extends StatefulWidget {
  final email;
  final otp;
  const ResendCodeTimerForSignUp({
    super.key,
    required this.email,
    required this.otp,
  });

  @override
  State<ResendCodeTimerForSignUp> createState() =>
      _ResendCodeTimerForSignUpState();
}

class _ResendCodeTimerForSignUpState extends State<ResendCodeTimerForSignUp> {
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
            onPressed: () async {
              setState(() {
                _start = 60;
                startTimer();
              });
              final result = await AuthService().checkEmail(
                email: widget.email,
              );
              if (!result.success) {
                CustomSnackBarForSignUp.show(
                  context,
                  message: result.message,
                  icon: Icons.error,
                  backgroundColor: Colors.red,
                );
              }
              ;
              if (result.success) {
                CustomSnackBarForSignUp.show(
                  context,
                  message: 'A new code has been sent to your email',
                );
              }
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

class ButtonOfGmailValidation extends StatelessWidget {
  final VoidCallback function;
  final Widget mywidget;
  const ButtonOfGmailValidation({
    super.key,
    required this.function,
    required this.mywidget,
  });

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
