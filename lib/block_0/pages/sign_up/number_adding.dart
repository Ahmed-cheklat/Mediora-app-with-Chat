import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mediora/Network/networkServices.dart';
import 'package:mediora/block_0/pages/sign_up/set_a_password_for_sign_up.dart';
import 'package:mediora/block_1/pages%20/homePage.dart';
import 'package:mediora/tools.dart';

class NumberAdding extends StatefulWidget {
  const NumberAdding({super.key});

  @override
  State<NumberAdding> createState() => _NumberAddingState();
}

class _NumberAddingState extends State<NumberAdding> {
  // ✅ Moved outside build() so they survive rebuilds
  late TextEditingController numberController;
  late GlobalKey<FormState> _formKey;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    numberController = TextEditingController();
    _formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    numberController.dispose(); // ✅ Prevent memory leak
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(14.0.w),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    40.verticalSpace,
                    // Contact information title
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Contact Information ',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontFamily: "LineSeedJP",
                          fontSize: 32.sp,
                        ),
                      ),
                    ),
                    10.verticalSpace,
                    // Description
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Adding your phone number will help us to contact use easily",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontFamily: "LineSeedJP",
                          color: Colors.grey,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                    40.verticalSpace,

                    // Phone number label
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Icon(Icons.phone, color: const Color(0xFF2463EB)),
                          10.horizontalSpace,
                          Text(
                            "Phone Number",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'LineSeedJP',
                              fontSize: 16.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    8.verticalSpace,
                    NumberField(numberController: numberController),
                    150.verticalSpace,
                    Button(
                      isFromSettings: false,
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
                      function: () async {
                        if (!_formKey.currentState!.validate()) return;

                        setState(() => _isLoading = true);

                        final phoneAdded = await UserServices().addPhoneNumber(
                          '0${numberController.text}',
                        );

                        if (!context.mounted) return;

                        setState(() => _isLoading = false);

                        if (phoneAdded) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => Homepage()),
                            (route) => false,
                          );
                        } else {
                          CustomSnackBarForSignUp.show(
                            context,
                            message: "Something went wrong",
                            backgroundColor: Colors.red,
                            icon: Icons.error_outline,
                          );
                        }
                      },
                    ),
                    20.verticalSpace,
                    SkipLink(text: "Skip for now", widget: Homepage()),
                    30.verticalSpace,
                    // SMS disclaimer
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        "By continuing, you agree to receive SMS from us ",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontFamily: "LineSeedJP",
                          color: Colors.grey,
                          fontSize: 14.sp,
                        ),
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

// Number field widget
class NumberField extends StatelessWidget {
  final TextEditingController numberController;

  const NumberField({super.key, required this.numberController});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: numberController,
      keyboardType: TextInputType.number,
      maxLength: 9,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Phone number is required";
        }
        if (value.length != 9) {
          return "Please Enter a valid number";
        }
        if (!value.startsWith('5') &&
            !value.startsWith('6') &&
            !value.startsWith('7')) {
          return "Please Enter a valid number";
        }
        return null;
      },
      decoration: InputDecoration(
        counterText: "",
        hintText: "567 463 424",
        hintStyle: TextStyle(
          color: Colors.grey,
          fontFamily: "LineSeedJP",
          fontSize: 14.sp,
        ),
        prefixIcon: Container(
          margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          decoration: BoxDecoration(
            color: const Color(0xFF2463EB).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            "+213",
            style: TextStyle(
              color: const Color(0xFF2463EB),
              fontFamily: "LineSeedJP",
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
          ),
        ),
        prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
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

// Skip link widget
class SkipLink extends StatelessWidget {
  final String text;
  final Widget widget;
  const SkipLink({super.key, required this.text, required this.widget});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => widget),
        (route) => false,
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