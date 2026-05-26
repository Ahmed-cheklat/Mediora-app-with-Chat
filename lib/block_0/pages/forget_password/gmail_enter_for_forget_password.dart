import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mediora/Network/networkServices.dart';
import 'package:mediora/block_0/pages/forget_password/validation_gmail_for_forget_password.dart';
import 'package:mediora/block_0/pages/signin_with_hellopage/sign_in.dart';

class ForgetpasswordGmail extends StatefulWidget {
  final bool isFromSettings;
  const ForgetpasswordGmail({super.key, required this.isFromSettings});

  @override
  State<ForgetpasswordGmail> createState() => _ForgetpasswordGmailState();
}

class _ForgetpasswordGmailState extends State<ForgetpasswordGmail> {
  TextEditingController emailcontroller = TextEditingController();
  bool _isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,

          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                50.verticalSpace,
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "No worries! Enter your email and we'll help you reset your password",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 16.sp,
                      fontFamily: "LineSeedJP",
                      color: Colors.grey,
                    ),
                  ),
                ),
                50.verticalSpace,

                // Emaflil Label
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.all(8.w),
                    child: Text(
                      "Email",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'LineSeedJP',
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                ),
                GmailField(
                  gmailcontroller: emailcontroller,
                  hinttext: "Enter your gmail",
                ),
                15.verticalSpace,

                Divider(color: Colors.grey, thickness: 1),
                15.verticalSpace,

                ValidateButton(
                  function: () async {
                    if (!_formKey.currentState!.validate()) return;
                    setState(() {
                      _isLoading = true;
                    });
                    final result = await AuthService().forgotPassword(
                      email: emailcontroller.text,
                    );
                    if (!mounted) return;
                    setState(() {
                      _isLoading = false;
                    });
                    CustomSnackBarForSignIn.show(
                      context,
                      message: result.message,
                      icon: result.success ? Icons.check_circle : Icons.error,
                      backgroundColor: result.success
                          ? const Color(0xFF2463EB)
                          : Colors.red,
                    );
                    if (result.success) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ValidationGmail(
                            gmail: emailcontroller.text,
                            isFromSettings: widget.isFromSettings,
                          ),
                        ),
                        (route) => false,
                      );
                    }
                  },
                  widget:_isLoading
                          ? SizedBox(
                              height: 20.r,
                              width: 20.r,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            ) :    
                   Text(
                    "Next",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontFamily: "LineSeedJP",
                      fontSize: 16.sp,
                      color: Colors.white,
                    ),
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

// Validate Button
class ValidateButton extends StatelessWidget {
  final VoidCallback function;
  final bool isFromSettings;
  final Widget widget;
  const ValidateButton({
    super.key,
    required this.function,
    required this.isFromSettings,
    required this.widget,
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
          elevation: 10,
        ),
        child: widget,
      ),
    );
  }
}
