import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mediora/block_0/pages/forget_password/gmail_enter_for_forget_password.dart';
import 'package:mediora/block_0/pages/sign_up/gmail_enter_for_sign_up.dart';
import 'package:mediora/block_1/pages%20/homePage.dart';
import 'package:mediora/Network/networkServices.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController gmailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();

  @override
  void dispose() {
    gmailcontroller.dispose();
    passwordcontroller.dispose();
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
            padding: EdgeInsets.all(14.w),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  40.verticalSpace,
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
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Welcome back! Sign in to continue to your account.",
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontFamily: "LineSeedJP",
                        color: Colors.grey,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                  40.verticalSpace,
                  // Email
                  Align(
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
                  8.verticalSpace,
                  GmailFieldForSignIn(
                    gmailInputController: gmailcontroller,
                    hinttext: "Enter your email",
                  ),
                  20.verticalSpace,

                  // Password
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Password",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'LineSeedJP',
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                  8.verticalSpace,
                  PasswordField(controller: passwordcontroller),

                  8.verticalSpace,
                  Align(
                    alignment: Alignment.centerRight,
                    child: ForgetPassword(),
                  ),
                  20.verticalSpace,
                  SignInButton(
                    function: () async {
                      if (!_formKey.currentState!.validate()) return;

                      final result = await AuthService().signIn(
                        email: gmailcontroller.text.trim(),
                        password: passwordcontroller.text,
                      );

                      // ignore: use_build_context_synchronously
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
                        Navigator.pushAndRemoveUntil(
                          // ignore: use_build_context_synchronously
                          context,
                          MaterialPageRoute(builder: (context) => Homepage()),
                          (route) => false,
                        );
                      }
                    },
                  ),
                  20.verticalSpace,

                  // Separate line (or)
                  Row(
                    children: [
                      Expanded(
                        child: Divider(color: Colors.grey, thickness: 1),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: Text(
                          "or",
                          style: TextStyle(
                            color: Colors.grey,
                            fontFamily: "LineSeedJP",
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(color: Colors.grey, thickness: 1),
                      ),
                    ],
                  ),
                  20.verticalSpace,
                  SignInWithGoogleButton(
                    function: () async {
                      final result = await AuthService().googleSignIn();
                      if (result.success) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const   Homepage(),
                          ),
                        );
                      } else {
                        CustomSnackBarForSignIn.show(
                          context,
                          message: result.message,
                          icon: Icons.error,
                          backgroundColor: Colors.red,
                        );
                      }
                    },
                  ),
                  30.verticalSpace,

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey,
                          fontFamily: "LineSeedJP",
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      PolicyLink(text: 'Sign Up', widget: GmailEnter()),
                    ],
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

// Gmail Field
class GmailField extends StatelessWidget {
  final TextEditingController gmailcontroller;
  final String hinttext;
  const GmailField({
    super.key,
    required this.gmailcontroller,
    required this.hinttext,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: gmailcontroller,
      keyboardType: TextInputType.emailAddress,
      autofillHints: const [AutofillHints.email],
      validator: (value) {
        if (value == null || value.isEmpty) return "Email is required";

        final trimmed = value.trim();

        if (trimmed.contains(' ')) return "Invalid email address";
        if (trimmed.split('@').length != 2) return "Invalid email address";

        final parts = trimmed.split('@');
        final localPart = parts[0];
        final domainPart = parts[1];

        if (localPart.isEmpty) return "Invalid email address";
        if (localPart.startsWith('.') || localPart.endsWith('.')) {
          return "Invalid email address";
        }
        if (localPart.contains('..')) return "Invalid email address";

        if (!domainPart.endsWith('.com')) return "Invalid email address";
        if (domainPart.startsWith('.') || domainPart.endsWith('.')) {
          return "Invalid email address";
        }
        if (domainPart.contains('..')) return "Invalid email address";

        if (!RegExp(r'^[\w\-\.]+@([\w\-]+\.)+com$').hasMatch(trimmed)) {
          return "Invalid email address";
        }

        final blockedDomains = [
          'test.com',
          'example.com',
          'fake.com',
          'dummy.com',
        ];
        if (blockedDomains.contains(domainPart.toLowerCase()))
          return "Invalid email address";

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

// Password Field
class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  const PasswordField({super.key, required this.controller});

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      autofillHints: const [AutofillHints.password],
      validator: (value) {
        if (value == null || value.isEmpty) return "Password is required";
        if (value.length < 8) return "Password must be at least 8 characters";
        return null;
      },
      decoration: InputDecoration(
        hintText: "Enter your password",
        hintStyle: TextStyle(
          color: Colors.grey,
          fontFamily: "LineSeedJP",
          fontSize: 14.sp,
        ),
        prefixIcon: Icon(
          Icons.lock_outline,
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
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
            size: 24.sp,
          ),
          onPressed: () => setState(() => _obscureText = !_obscureText),
        ),
      ),
    );
  }
}

// Forget Password
class ForgetPassword extends StatelessWidget {
  const ForgetPassword({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ForgetpasswordGmail(isFromSettings: false),
        ),
      ),
      child: Text(
        "Forget Password?",
        style: TextStyle(
          color: Color(0xFF6E6B6B),
          fontFamily: "LineSeedJP",
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          decoration: TextDecoration.underline,
          decorationColor: Color(0xFF6E6B6B),
          decorationThickness: 1.5,
        ),
      ),
    );
  }
}

// SignIn Button
class SignInButton extends StatefulWidget {
  final Future<void> Function() function;
  const SignInButton({super.key, required this.function});

  @override
  State<SignInButton> createState() => _SignInButtonState();
}

class _SignInButtonState extends State<SignInButton> {
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
                try {
                  await widget.function();
                } finally {
                  if (mounted) setState(() => _isLoading = false);
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF2463EB),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 15.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r),
          ),
          elevation: 10,
        ),
        child: _isLoading
            ? SizedBox(
                height: 20.r,
                width: 20.r,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                "Sign in",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontFamily: "LineSeedJP",
                  fontSize: 16.sp,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}

// SignIn with Google Button
class SignInWithGoogleButton extends StatelessWidget {
  final Future<void> Function() function;
  const SignInWithGoogleButton({super.key, required this.function});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: function,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFDBDADA),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 15.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r),
          ),
          elevation: 10,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/google_icon.png", height: 24.r, width: 24.r),
            8.horizontalSpace,
            Text(
              'Sign in with Google',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.black,
                fontFamily: "LineSeedJP",
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Policy Link
class PolicyLink extends StatelessWidget {
  final String text;
  final Widget widget;
  const PolicyLink({super.key, required this.text, required this.widget});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => widget),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: "LineSeedJP",
          fontWeight: FontWeight.bold,
          fontSize: 14.sp,
          color: Color(0xFF2463EB),
          decoration: TextDecoration.underline,
          decorationColor: Color(0xFF2463EB),
          decorationThickness: 1.5,
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
        if (value == null || value.isEmpty) {
          return "Email or username is required";
        }

        final trimmed = value.trim();

        if (trimmed.contains('@')) {
          // ── EMAIL VALIDATION ──────────────────────────────────

          if (trimmed.contains(' ')) return "Invalid email address";
          if (trimmed.split('@').length != 2) return "Invalid email address";

          final parts = trimmed.split('@');
          final localPart = parts[0];
          final domainPart = parts[1];

          if (localPart.isEmpty || domainPart.isEmpty) {
            return "Invalid email address";
          }
          if (localPart.startsWith('.') || localPart.endsWith('.')) {
            return "Invalid email address";
          }
          if (localPart.contains('..')) return "Invalid email address";

          if (!domainPart.endsWith('.com')) return "Invalid email address";
          if (domainPart.startsWith('.') || domainPart.endsWith('.')) {
            return "Invalid email address";
          }
          if (domainPart.contains('..')) return "Invalid email address";

          if (!RegExp(r'^[\w\-\.]+@([\w\-]+\.)+com$').hasMatch(trimmed)) {
            return "Invalid email address";
          }

          final blockedDomains = [
            'test.com',
            'example.com',
            'fake.com',
            'dummy.com',
          ];
          if (blockedDomains.contains(domainPart.toLowerCase())) {
            return "Invalid email address";
          }
        } else {
          // ── USERNAME VALIDATION ───────────────────────────────

          if (trimmed.length < 3) return "Invalid username";
          if (trimmed.length > 30) return "Invalid username";

          // Only lowercase letters, digits, underscores, and dots
          if (!RegExp(r'^[a-z0-9._]+$').hasMatch(trimmed)) {
            return "Invalid username";
          }

          if (trimmed.startsWith('.') || trimmed.startsWith('_')) {
            return "Invalid username";
          }
          if (trimmed.endsWith('.') || trimmed.endsWith('_')) {
            return "Invalid username";
          }

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

class CustomSnackBarForSignIn {
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
