import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mediora/block_0/pages/forget_password/validation_gmail_for_forget_password.dart';
import 'package:mediora/block_4/pages/profile_page.dart';

final List<String> deletionReasons = [
  'I have a duplicate account',
  'I am concerned about my privacy',
  'I am not getting value from the app',
  'I found a better alternative',
  'The app has too many bugs',
  'Other',
];

String currentPassword = "ahmed";

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  final TextEditingController _currentPassword = TextEditingController();
  String? _selectReason;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Delete Account', style: TextStyle(fontSize: 17.sp)),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0.r),
        child: SafeArea(
          child: ListView(
            children: [
              //card of goodbye
              SizedBox(
                //height: 200.h,
                child: Card(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.red.withOpacity(0.15) // 👈 dark version
                      : const Color.fromARGB(255, 255, 238, 237),
                  child: Padding(
                    padding: EdgeInsets.all(10.0.r),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 9.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(Icons.error, color: Colors.red),
                              5.horizontalSpace,
                              Text(
                                "We're sorry to see you go.",
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                        5.verticalSpace,
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'This action is irreversible. All of your data, history, and records will be permanently removed. You will not be able to reactivate this account.',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              40.verticalSpace,
              Padding(
                padding: EdgeInsets.all(8.w),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Current Password",
                    style: TextStyle(fontFamily: 'LineSeedJP', fontSize: 14.sp),
                  ),
                ),
              ),

              CurrentPasswordField(controller: _currentPassword),

              15.verticalSpace,

              Padding(
                padding: EdgeInsets.all(8.w),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Reason For Deletion",
                    style: TextStyle(fontFamily: 'LineSeedJP', fontSize: 14.sp),
                  ),
                ),
              ),

              Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: Color(
                      0xFF2463EB,
                    ), // 👈 changes the highlight color to blue
                  ),
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectReason,
                  focusColor: Color(0xFF2463EB),
                  hint: Text('Select a reason'),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                  ),
                  items: deletionReasons.map((reason) {
                    return DropdownMenuItem<String>(
                      value: reason,
                      child: Text(
                        reason,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontFamily: 'LineSeedJP',
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectReason = value);
                  },
                ),

              ),

              40.verticalSpace,

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPassword.text.isEmpty) {
                      CustomSnackBar.show(
                        context,
                        message: 'Please enter your current password',
                        backgroundColor: Colors.red,
                        icon: Icons.error_outline,
                      );
                      return;
                    }
                    if (_currentPassword.text != currentPassword) {
                      CustomSnackBar.show(
                        context,
                        message: 'Password is incorrect',
                        backgroundColor: Colors.red,
                        icon: Icons.error_outline,
                      );
                      return;
                    }
                    if (_selectReason == null) {
                      CustomSnackBar.show(
                        context,
                        message: 'Please select a reason',
                        backgroundColor: Colors.red,
                        icon: Icons.error_outline,
                      );
                      return;
                    }
                    // all good → show confirm dialog
                    ConfirmDialog.show(
                      context,
                      title: 'Are you sure? This action cannot be undone.',
                      confirmText: 'Delete Account',
                      onConfirm: () {
                        print('Account deleted');
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).brightness == Brightness.dark
                        ? Colors.red.withOpacity(0.15) // 👈 dark version
                        : Colors.red.withOpacity(0.09), // 👈 light version
                    foregroundColor: Colors.red,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 15.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.r),
                      side: BorderSide(
                        color: Colors.red.withOpacity(0.3), // 👈 subtle red border
                        width: 1.5,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete, color: Colors.red, size: 18.r),
                      8.horizontalSpace,
                      Text(
                        'Delete Account',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontFamily: 'LineSeedJP',
                          fontSize: 14.sp,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              10.verticalSpace, 
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context), // 👈 just go back
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: Color(0xFF2463EB).withOpacity(0.4),
                      width: 1.5.w,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 15.h),
                    backgroundColor: Color(0xFF2463EB).withOpacity(0.05),
                  ),
                  child: Text(
                    'Keep My Account',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontFamily: 'LineSeedJP',
                      fontSize: 14.sp,
                      color: Color(0xFF2463EB),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



class CurrentPasswordField extends StatefulWidget {
  final TextEditingController controller;

  const CurrentPasswordField({super.key, required this.controller});

  @override
  State<CurrentPasswordField> createState() => _CurrentPasswordFieldState();
}

class _CurrentPasswordFieldState extends State<CurrentPasswordField> {
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
      // --- ADDED VALIDATOR HERE ---
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your current password';
        }
        return null; // Returning null means the input is valid
      },
      // ----------------------------
      style: TextStyle(fontFamily: 'LineSeedJP', fontSize: 14.sp),
      decoration: InputDecoration(
        hintText: 'Enter your current password',
        hintStyle: TextStyle(color: Colors.grey, fontFamily: 'LineSeedJP'),
        prefixIcon: Icon(
          Icons.lock_outline,
          color: _focusNode.hasFocus ? const Color(0xFF2463EB) : Colors.grey,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: () => setState(() => _obscureText = !_obscureText),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.r)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: BorderSide(color: Color(0xFF2463EB), width: 2.w),
        ),
      ),
    );
  }
}