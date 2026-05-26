import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mediora/Network/networkServices.dart';
import 'package:mediora/block_0/pages/forget_password/gmail_enter_for_forget_password.dart';
import 'package:mediora/block_0/pages/signin_with_hellopage/sign_in.dart';
import 'package:mediora/block_1/pages%20/homePage.dart';
// import 'package:mediora/block_0/pages/forget_password/rest_passwrod.dart';
// import 'package:mediora/block_0/pages/sign_up/password.dart';
import 'package:mediora/block_4/pages/delete_account_page.dart';
import 'package:mediora/tools.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  bool _isLoading = false;
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  // final TextEditingController _confirmPasswordController =
  //     TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password', style: TextStyle(fontSize: 20)),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0.w),
        child: SafeArea(
          child: Form(
            key: _formkey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  20.verticalSpace,
                  // Text of chnaging password
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "To keep your account secure, please enter your current password before setting a new one.",
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 16.sp,
                        fontFamily: "LineSeedJP",
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  40.verticalSpace,
                  //Title of current password
                  Padding(
                    padding: EdgeInsets.all(8.w),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Current Password",
                        style: TextStyle(
                          fontFamily: 'LineSeedJP',
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                  //Field of current password
                  CurrentPasswordField(controller: _currentPasswordController),
                  Align(
                    alignment: AlignmentGeometry.bottomLeft,
                    child: LinkToForgetPassword(
                      text: 'Forget Passowrd?',
                      widget: ForgetpasswordGmail(isFromSettings: true),
                    ),
                  ),
                  5.verticalSpace,
                  //Title of New password
                  Padding(
                    padding: EdgeInsets.all(8.w),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "New Password",
                        style: TextStyle(
                          fontFamily: 'LineSeedJP',
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                  CreatePassword(controller: _newPasswordController),
                  5.verticalSpace,
                  //Title of confirm password

                  //ConfirmPasswordField(controller: _confirmPasswordController),
                  70.verticalSpace,
                  ContinueButtonCustom(
                    function: () async {
                      if (!_formkey.currentState!.validate()) return;
                      setState(() {
                        _isLoading = true;
                      });
                      final result = await AuthService().changePassword(
                        _currentPasswordController.text,
                        _newPasswordController.text,
                      );
                      if (!mounted) return;
                      setState(() {
                        _isLoading = false;
                      });
                      CustomSnackBarForSignIn.show(
                        // ignore: use_build_context_synchronously
                        context,
                        message: result.message,
                        icon: result.success ? Icons.check_circle : Icons.error,
                        backgroundColor: result.success
                            ? const Color(0xFF2463EB)
                            : Colors.red,
                      );
                      if (result.success) {
                        // ignore: use_build_context_synchronously
                        Navigator.pushAndRemoveUntil(
                          // ignore: use_build_context_synchronously
                          context,
                          MaterialPageRoute(builder: (context) => Homepage()),
                          (route) => false,
                        );
                      }
                    },
                    widget: _isLoading ? 
                    SizedBox(
                              height: 20.r,
                              width: 20.r,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                    ):
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Continue",
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontFamily: "LineSeedJP",
                            fontSize: 16.sp,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ContinueButtonCustom extends StatelessWidget {
  final VoidCallback function;
  final Widget widget;
  const ContinueButtonCustom({
    super.key,
    required this.function,
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
          elevation: 10.h,
        ),
        child: widget,
      ),
    );
  }
}

class LinkToForgetPassword extends StatelessWidget {
  final String text;
  final Widget widget;
  const LinkToForgetPassword({
    super.key,
    required this.text,
    required this.widget,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => widget),
        );
      },
      child: Text(
        text,
        style: TextStyle(
          fontFamily: "LineSeedJP",
          fontWeight: FontWeight.w400,
          color: Colors.grey,
          decoration: TextDecoration.underline,
          decorationColor: Colors.grey,
          decorationThickness: 1.5,
        ),
      ),
    );
  }
}
