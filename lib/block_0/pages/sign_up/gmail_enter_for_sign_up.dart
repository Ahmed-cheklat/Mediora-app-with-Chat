// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mediora/Network/networkServices.dart';
import 'package:mediora/block_0/pages/sign_up/gmail_validation_for_sign_up.dart';
//import 'package:mediora/block_0/pages/forget_password/rest_passwrod.dart';
import 'package:mediora/block_0/pages/signin_with_hellopage/sign_in.dart';
import 'package:mediora/tools.dart';
//import 'dart:convert';
//import 'package:http/http.dart' as http;

class GmailEnter extends StatefulWidget {
  const GmailEnter({super.key});

  @override
  State<GmailEnter> createState() => _GmailEnterState();
}

class _GmailEnterState extends State<GmailEnter> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController gmailcontroller = TextEditingController();
  bool _isLoading = false;
  @override
  void dispose() {
    gmailcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(14.w),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    40.verticalSpace,

                    //Text of Join Mediora
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Join Mediora',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontFamily: "LineSeedJP",
                          fontSize: 32.sp,
                        ),
                      ),
                    ),
                    10.verticalSpace,
                    //text for the description
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Let's get started with your email address to create your secure account",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontFamily: "LineSeedJP",
                          color: Colors.grey,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                    40.verticalSpace,
                    //gmail field starting
                    Padding(
                      padding: EdgeInsets.only(left: 8.0.w),
                      child: Align(
                        alignment: Alignment.centerLeft,
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
                    8.verticalSpace,
                    GmailField(
                      gmailcontroller: gmailcontroller,
                      hinttext: "name@example.com",
                    ),
                    15.verticalSpace,
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "We'll send you a confirmation link to this address.",
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontFamily: "LineSeedJP",
                            color: Colors.grey,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ),
                    200.verticalSpace,
                    Button(
                      isFromSettings: false,
                      function: () async {
                        if (!_formKey.currentState!.validate()) return;
                        setState(() {
                          _isLoading = true;
                        });
                        final result = await AuthService().checkEmail(
                          email: gmailcontroller.text,
                        );
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
                              builder: (context) => GmailValidation(
                                email: gmailcontroller.text,
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

class GmailFieldForSignIn extends StatelessWidget {
  final TextEditingController gmailInputController;
  final String hinttext;
  const GmailFieldForSignIn({
    super.key,
    required this.gmailInputController,
    required this.hinttext,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: gmailInputController,
      keyboardType: TextInputType.emailAddress,
      autofillHints: const [AutofillHints.email],
      validator: (value) {
        if (value == null || value.isEmpty)
          return "Email or username is required";

        final trimmed = value.trim();

        if (trimmed.contains('@')) {
          // ── EMAIL VALIDATION ──────────────────────────────────

          if (trimmed.contains(' ')) return "Invalid email address";
          if (trimmed.split('@').length != 2) return "Invalid email address";

          final parts = trimmed.split('@');
          final localPart = parts[0];
          final domainPart = parts[1];

          if (localPart.isEmpty || domainPart.isEmpty)
            return "Invalid email address";
          if (localPart.startsWith('.') || localPart.endsWith('.'))
            return "Invalid email address";
          if (localPart.contains('..')) return "Invalid email address";

          if (!domainPart.endsWith('.com')) return "Invalid email address";
          if (domainPart.startsWith('.') || domainPart.endsWith('.'))
            return "Invalid email address";
          if (domainPart.contains('..')) return "Invalid email address";

          if (!RegExp(r'^[\w\-\.]+@([\w\-]+\.)+com$').hasMatch(trimmed))
            return "Invalid email address";

          final blockedDomains = [
            'test.com',
            'example.com',
            'fake.com',
            'dummy.com',
          ];
          if (blockedDomains.contains(domainPart.toLowerCase()))
            return "Invalid email address";
        } else {
          // ── USERNAME VALIDATION ───────────────────────────────

          if (trimmed.length < 3) return "Invalid username";
          if (trimmed.length > 30) return "Invalid username";

          // Only lowercase letters, digits, underscores, and dots
          if (!RegExp(r'^[a-z0-9._]+$').hasMatch(trimmed))
            return "Invalid username";

          if (trimmed.startsWith('.') || trimmed.startsWith('_'))
            return "Invalid username";
          if (trimmed.endsWith('.') || trimmed.endsWith('_'))
            return "Invalid username";

          if (trimmed.contains('..') ||
              trimmed.contains('__') ||
              trimmed.contains('._') ||
              trimmed.contains('_.')) {
            return "Invalid username";
          }

          // Must contain at least one letter
          if (!RegExp(r'[a-z]').hasMatch(trimmed)) return "Invalid username";
        }

        return null;
      },
      decoration: InputDecoration(
        hintText: hinttext,
        hintStyle: TextStyle(
          color: Colors.grey,
          fontFamily: "LineSeedJP",
          fontSize: 14.sp,
        ),
        prefixIcon: Icon(
          Icons.email_outlined,
          color: Color(0xFF2463EB),
          size: 24.sp,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.r)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: BorderSide(color: Color(0xFF2463EB), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }
}

class CustomSnackBarForSignUp {
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
