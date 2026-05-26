import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mediora/Network/networkServices.dart';
import 'package:mediora/block_0/pages/signin_with_hellopage/policies.dart';
import 'package:mediora/block_0/pages/signin_with_hellopage/sign_in.dart';
import 'package:mediora/block_4/pages/FAQ_page.dart';
import 'package:mediora/block_4/pages/change_password_page.dart';
import 'package:mediora/block_4/pages/delete_account_page.dart';
import 'package:mediora/block_4/pages/edit_profile_page.dart';
import 'package:mediora/block_4/pages/notification_modes_page.dart';
import 'package:mediora/block_4/tools/themeProvider.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _profilePicture = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUserData();
}

  Future<void> _loadUserData() async {
    final firstName = await _secureStorage.read(key: 'first_name') ?? '';
    final lastName = await _secureStorage.read(key: 'last_name') ?? '';
    final email = await _secureStorage.read(key: 'email') ?? '';
    final picture = await _secureStorage.read(key: 'picture') ?? '';
    if (mounted) {
      setState(() {
        _firstName = firstName;
        _lastName = lastName;
        _email = email;
        _profilePicture = picture;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Padding(
      padding: EdgeInsets.all(8.0.r),
      child: ListView(
        children: [
          30.verticalSpace,
          SizedBox(
            height: 200.h,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ProfilePictureCustom(picture: _profilePicture),
                10.verticalSpace,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _firstName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp,
                      ),
                    ),
                    5.horizontalSpace,
                    Text(
                      _lastName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp,
                      ),
                    ),
                  ],
                ),
                Text(
                  _email,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                  ),
                ),
                5.verticalSpace,
              ],
            ),
          ),
          Divider(
            thickness: 1,
            color: Colors.grey.withOpacity(0.3),
            indent: 16.w,
            endIndent: 16.w,
          ),
          Padding(
            padding: EdgeInsets.all(8.0.r),
            child: Text(
              'PREFERENCES',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 12.sp,
              ),
            ),
          ),
          Column(
            children: [
              Card(
                shadowColor: const Color(0xFF2463EB),
                child: ListTile(
                  leading: const Icon(Icons.dark_mode, color: Color(0xFF2463EB)),
                  title: Text(
                    'Dark Mode',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontFamily: 'LineSeedJP',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: Switch(
                    value: themeProvider.isDark,
                    onChanged: (_) => themeProvider.toggleTheme(),
                    activeColor: const Color(0xFF2463EB),
                  ),
                ),
              ),
              ...List.generate(
                preferencesActions.length,
                (index) => ActionsCardCustom(
                  title: preferencesActions[index]["title"],
                  icon: preferencesActions[index]["icon"],
                  function: () {
                    switch (index) {
                      case 0:
                        NavigateTo.pushTo(context, const ChangePasswordPage());
                        break;
                      case 1:
                        NavigateTo.pushTo(context, const NotificationModesPage());
                        break;
                      case 2:
                        NavigateTo.pushTo(context, const FaqPage());
                        break;
                      case 3:
                        NavigateTo.pushTo(context, const Policies());
                        break;
                    }
                  },
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(8.0.r),
            child: Text(
              'ACCOUNT',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 12.sp,
              ),
            ),
          ),
          Column(
            children: [
              ...List.generate(
                accountActions.length,
                (index) => ActionsCardForAccountCustom(
                  title: accountActions[index]["title"],
                  icon: accountActions[index]["icon"],
                  function: () {
                    switch (index) {
                      case 0:
                        ConfirmDialog.show(
                          context,
                          title: 'Are you sure to Log out?',
                          confirmText: 'Log Out',
                          onConfirm: () async {
                            final result = await AuthService().signOut();
                            if (result.success) {
                              print('Logged out');
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => SignIn()),
                                (route) => false,
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
                        );
                        break;
                      case 1:
                        NavigateTo.pushTo(context, const DeleteAccountPage());
                        break;
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ProfilePictureCustom extends StatefulWidget {
  final String picture;

  const ProfilePictureCustom({super.key, required this.picture});

  @override
  State<ProfilePictureCustom> createState() => _ProfilePictureCustomState();
}

class _ProfilePictureCustomState extends State<ProfilePictureCustom> {
  late String _picture;

  @override
  void didUpdateWidget(ProfilePictureCustom oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.picture != widget.picture) {
      setState(() => _picture = widget.picture);
  }
}

  @override
  void initState() {
    super.initState();
    _picture = widget.picture;
  }

  Future<void> _reloadPicture() async {
    const storage = FlutterSecureStorage();
    final picture = await storage.read(key: 'picture') ?? '';
    if (mounted) setState(() => _picture = picture);
  }

  bool get _hasValidPicture =>
      _picture.isNotEmpty &&
      _picture != 'string' &&
      _picture.startsWith('http');

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 45.r,
          backgroundImage: _hasValidPicture
              ? NetworkImage(_picture) as ImageProvider
              : const AssetImage('assets/default_avatar.png'),
        ),
        Positioned(
          bottom: 0.h,
          right: 0.w,
          child: Container(
            width: 28.r,
            height: 28.r,
            decoration: BoxDecoration(
              color: const Color(0xFF2463EB),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.w),
            ),
            child: GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfilePage()),
                );
                _reloadPicture();
                 if (context.mounted) {
                    final state = context.findAncestorStateOfType<_ProfilePageState>();
                    state?._loadUserData();
                  }
              },
              child: Icon(Icons.edit, color: Colors.white, size: 14.r),
            ),
          ),
        ),
      ],
    );
  }
}

class ActionsCardCustom extends StatelessWidget {
  final Function function;
  final IconData icon;
  final String title;

  const ActionsCardCustom({
    super.key,
    required this.icon,
    required this.title,
    required this.function,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => function(),
      child: Card(
        shadowColor: const Color(0xFF2463EB),
        child: ListTile(
          leading: Icon(icon, color: const Color(0xFF2463EB)),
          title: Text(title, style: TextStyle(fontSize: 13.sp)),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}

final List<Map<String, dynamic>> preferencesActions = [
  {"title": "Change Password", "icon": Icons.lock},
  {"title": "Notifications", "icon": Icons.notifications},
  {"title": "FAQ", "icon": Icons.help},
  {"title": "Privacy Policy", "icon": Icons.shield},
];

final List<Map<String, dynamic>> accountActions = [
  {"title": "Log Out", "icon": Icons.logout},
  {"title": "Delete Account", "icon": Icons.delete},
];

class ActionsCardForAccountCustom extends StatelessWidget {
  final Function function;
  final IconData icon;
  final String title;

  const ActionsCardForAccountCustom({
    super.key,
    required this.icon,
    required this.title,
    required this.function,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => function(),
      child: SizedBox(
        height: 60.h,
        child: Card(
          shadowColor: Colors.red,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.red),
              5.horizontalSpace,
              Text(
                title,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NavigateTo {
  static void pushTo(BuildContext context, Widget destination) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => destination));
  }
}

class ConfirmDialog {
  static void show(
    BuildContext context, {
    required String title,
    required String confirmText,
    required Function() onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title, style: const TextStyle(fontSize: 15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: Text(confirmText, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}