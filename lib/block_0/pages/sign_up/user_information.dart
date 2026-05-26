import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mediora/Network/networkServices.dart';
import 'package:mediora/block_0/pages/sign_up/set_a_password_for_sign_up.dart';
import 'package:mediora/tools.dart';

class UserInformation extends StatefulWidget {
  final String email;
  final String token; 
  const UserInformation({super.key, required this.email,required this.token});

  @override
  State<UserInformation> createState() => _UserInformationState();
}

class _UserInformationState extends State<UserInformation> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
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
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    40.verticalSpace,
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Personal Details',
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
                        "Tell us a bit about yourself so we can personalize your experience",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontFamily: "LineSeedJP",
                          color: Colors.grey,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                    40.verticalSpace,
                    Padding(
                      padding: EdgeInsets.only(left: 8.0.w),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Icon(Icons.person, color: Color(0xFF2463EB)),
                            20.verticalSpace,
                            Text(
                              "First Name",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'LineSeedJP',
                                fontSize: 16.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    8.verticalSpace,
                    NameField(
                      nameController: firstNameController,
                      hintText: "Enter your first name",
                    ),
                    20.verticalSpace,
                    Padding(
                      padding: EdgeInsets.only(left: 8.0.w),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Icon(Icons.person, color: Color(0xFF2463EB)),
                            20.verticalSpace,
                            Text(
                              "Last Name",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'LineSeedJP',
                                fontSize: 16.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    8.verticalSpace,
                    NameField(
                      nameController: lastNameController,
                      hintText: "Enter your last name",
                    ),
                    20.verticalSpace,
                    Padding(
                      padding: EdgeInsets.only(left: 8.0.w),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Icon(Icons.person, color: Color(0xFF2463EB)),
                            20.verticalSpace,
                            Text(
                              "Username",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'LineSeedJP',
                                fontSize: 16.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    8.verticalSpace,
                    UsernameField(
                      usernameController: usernameController,
                      hintText: "Enter a username",
                    ),
                    50.verticalSpace,
                    Button(
                      isFromSettings: false,

                      function: () async {
                        if (!_formKey.currentState!.validate()) return;
                        setState(() {
                          _isLoading = true;
                        });
                        final result = await AuthService().checkUsername(
                          username: usernameController.text,
                        );
                        if (!mounted) return;
                        setState(() {
                          _isLoading = false;
                        });
                        if (result.message.isNotEmpty) {
                          CustomSnackBarForSignUp.show(
                            context,
                            message: result.message,
                            icon: Icons.error,
                            backgroundColor: Colors.red,
                          );
                        }
                        if (result.success) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PasswordPage(
                                flow: PasswordFlow.signUp,
                                email: widget.email,
                                firstName: firstNameController.text,
                                lastName: lastNameController.text,
                                username: usernameController.text,
                                token: widget.token,
                              ),
                            ),
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

class NameField extends StatelessWidget {
  final TextEditingController nameController;
  final String hintText;

  const NameField({
    super.key,
    required this.nameController,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: nameController,
      keyboardType: TextInputType.name,
      textCapitalization: TextCapitalization.words,
      maxLength: 20,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Name is required";
        }
        if (value.trim().length < 2) {
          return "Name must be at least 2 characters";
        }
        if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(value.trim())) {
          return "Name must contain letters only";
        }
        return null;
      },
      decoration: InputDecoration(
        counterText: "",
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey,
          fontFamily: "LineSeedJP",
          fontSize: 14.sp,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.r)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: const BorderSide(color: Color(0xFF2463EB), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }
}

class UsernameField extends StatelessWidget {
  final TextEditingController usernameController;
  final String hintText;

  const UsernameField({
    super.key,
    required this.usernameController,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: usernameController,
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.none,
      maxLength: 20,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Username is required";
        }
        if (value.contains(' ')) {
          return "Username cannot contain spaces";
        }
        if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value.trim())) {
          return "Username can only contain letters, numbers, and _";
        }
        return null;
      },
      decoration: InputDecoration(
        counterText: "",
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey,
          fontFamily: "LineSeedJP",
          fontSize: 14.sp,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.r)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: const BorderSide(color: Color(0xFF2463EB), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }
}
