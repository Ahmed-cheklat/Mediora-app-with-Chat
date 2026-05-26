import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mediora/block_0/pages/signin_with_hellopage/policies.dart';
import 'package:mediora/block_0/pages/signin_with_hellopage/sign_in.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> with TickerProviderStateMixin {
  late AnimationController _launchController;
  late AnimationController _buttonController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _buttonFadeAnimation;
  late Animation<Offset> _buttonSlideAnimation;

  @override
  void initState() {
    super.initState();

    // Launch animation: fade + scale
    _launchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _launchController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1).animate(
      CurvedAnimation(parent: _launchController, curve: Curves.easeOutBack),
    );

    // Button animation: fade + slide up (delayed)
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _buttonFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeIn),
    );

    _buttonSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeOut),
    );

    // Start launch animation, then trigger button animation
    _launchController.forward().then((_) => _buttonController.forward());
  }

  @override
  void dispose() {
    _launchController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  void _navigateToSignIn() {
  Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (_, animation, __) => const SignIn(),
      transitionDuration: const Duration(milliseconds: 600),
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.08), // subtle slide from slightly below
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          ),
        );
      },
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            20.verticalSpace,
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    48.verticalSpace,

                    // Logo: fade + scale
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Image.asset(
                          "assets/icon.png",
                          height: 200.r,
                          width: 200.r,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    10.verticalSpace,

                    // Title: same fade
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        "Mediora",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 30.sp,
                          fontFamily: "LineSeedJP",
                        ),
                      ),
                    ),
                    200.verticalSpace,

                    // Button: delayed fade + slide up
                    FadeTransition(
                      opacity: _buttonFadeAnimation,
                      child: SlideTransition(
                        position: _buttonSlideAnimation,
                        child: SizedBox(
                          width: 216.w,
                          child: ElevatedButton(
                            onPressed: _navigateToSignIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2463EB),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 15.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30).r,
                              ),
                              elevation: 10,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Start',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontFamily: "LINESeedJP",
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                15.horizontalSpace,
                                Icon(Icons.arrow_forward_rounded, size: 30.sp),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 80.h),
            FadeTransition(
              opacity: _buttonFadeAnimation,
              child: PolicyLink(
                text: 'Cookies and Privacy policy',
                widget: Policies(),
              ),
            ),
            20.verticalSpace,
          ],
        ),
      ),
    );
  }
}

class PolicyLink extends StatelessWidget {
  final String text;
  final Widget widget;
  const PolicyLink({super.key, required this.text, required this.widget});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => widget),
      ),
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