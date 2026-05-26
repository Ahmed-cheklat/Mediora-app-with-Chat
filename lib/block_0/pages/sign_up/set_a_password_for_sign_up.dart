import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mediora/Network/networkServices.dart';
import 'package:mediora/block_0/pages/sign_up/number_adding.dart';

enum PasswordFlow { signUp, forgetPasswordAuth, forgetPasswordSettings }

//Function and classes used in this file and it contain this file
//  class Custom Button, function (string) validatePassword, class Createpasswordforsignup,
// class customsnackbarforsignup , class confirmpassword

class ConfirmPasswordForSignUp extends StatefulWidget {
  final TextEditingController controller;
  const ConfirmPasswordForSignUp({super.key, required this.controller});

  @override
  State<ConfirmPasswordForSignUp> createState() =>
      _ConfirmPasswordForSignUpState();
}

class _ConfirmPasswordForSignUpState extends State<ConfirmPasswordForSignUp> {
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

class CustomButton extends StatelessWidget {
  final VoidCallback function;
  final Widget mywidget;
  const CustomButton({
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

String? validatePasswords(
  TextEditingController createPasswordController,
  TextEditingController confirmPasswordController,
) {
  if (createPasswordController.text.isEmpty ||
      confirmPasswordController.text.isEmpty) {
    return 'Please Fill in all fields';
  }
  if (createPasswordController.text != confirmPasswordController.text) {
    return 'Passwords do not match';
  }
  return null;
}

class CreatePasswordForSignUp extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;

  const CreatePasswordForSignUp({
    super.key,
    required this.controller,
    this.hintText = 'Enter your password',
  });

  @override
  State<CreatePasswordForSignUp> createState() =>
      _CreatePasswordForSignUpState();
}

class _CreatePasswordForSignUpState extends State<CreatePasswordForSignUp> {
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

//Custom snack bar instead in order to avoid the problem of duplicated
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

//---------------------------------------------------------

//---------------------------------------------------------
class PasswordPage extends StatefulWidget {
  final PasswordFlow flow;
  final String email;
  final String firstName;
  final String lastName;
  final String username;
  final String token;
  const PasswordPage({
    super.key,
    required this.flow,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.token,
  });

  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  final TextEditingController passwordcontroller = TextEditingController();
  final TextEditingController confirmcontroller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  @override
  void dispose() {
    passwordcontroller.dispose();
    confirmcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  120.verticalSpace,
                  if (widget.flow == PasswordFlow.signUp) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Secure your account by choosing a strong password",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontFamily: "LineSeedJP",
                          color: Colors.grey,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                    10.verticalSpace,
                  ],
                  Padding(
                    padding: EdgeInsets.all(8.w),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "New Password",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'LineSeedJP',
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                  ),

                  CreatePasswordForSignUp(controller: passwordcontroller),

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
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                  ),

                  ConfirmPasswordForSignUp(controller: confirmcontroller),
                  15.verticalSpace,

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 9.w),
                    child: Divider(color: Colors.grey, thickness: 1.h),
                  ),

                  15.verticalSpace,

                  CustomButton(
                    function: () async {
                      if (_isLoading) return; 
                      // 1. Validate form
                      if (!_formKey.currentState!.validate()) return;
                      final error = validatePasswords(
                        passwordcontroller,
                        confirmcontroller,
                      );
                      if (error != null) {
                        CustomSnackBarForSignUp.show(
                          context,
                          message: error,
                          backgroundColor: Colors.red,
                          icon: Icons.error_outline,
                        );
                        return;
                      }

                      // 2. Start loading
                      setState(() => _isLoading = true);

                      // 3. Create auth service instance (reuse)
                      final authService = AuthService();

                      // 4. Perform sign up
                      final result = await authService.SignUp(
                        firstName: widget.firstName,
                        lastName: widget.lastName,
                        username: widget.username,
                        email: widget.email,
                        password: passwordcontroller.text,
                        creationToken: widget.token,
                      );

                      if (!mounted) return;

                      // 5. Handle sign up failure
                      if (!result.success) {
                        setState(() => _isLoading = false);
                        CustomSnackBarForSignUp.show(
                          context,
                          message: result.message,
                          icon: Icons.error,
                          backgroundColor: Colors.red,
                        );
                        return;
                      }

                      // 6. Sign up succeeded → get refresh token

                      setState(() => _isLoading = false);
                      Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => NumberAdding()),
                      (route) => false,
                    );
                    },
                    //Design of the button
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
