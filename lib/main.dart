import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mediora/block_0/pages/signin_with_hellopage/start_page.dart';
import 'package:mediora/block_4/tools/notifications.dart';
import 'package:mediora/block_4/tools/themeProvider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotiService().initNotifications();
  await GoogleSignIn.instance.initialize(
    clientId: '583663368113-vmset5bjhiu86qigf3aur6qaf68sg2u5.apps.googleusercontent.com',
  );
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(prefs),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) => MaterialApp(
          themeMode: themeProvider.themeMode,
          theme: ThemeData(
            brightness: Brightness.light,
            fontFamily: 'LineSeedJP',
            scaffoldBackgroundColor: const Color(0xFFF2F2F7),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFFF2F2F7),
              foregroundColor: Colors.black,
              elevation: 0,
              scrolledUnderElevation: 0,
            ),
            cardTheme: CardThemeData(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            iconTheme: const IconThemeData(color: Color(0xFF2463EB)),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2463EB),
              surface: Color(0xFFF2F2F7),
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            fontFamily: 'LineSeedJP',
            scaffoldBackgroundColor: const Color(0xFF121212),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF121212),
              foregroundColor: Colors.white,
              elevation: 0,
              scrolledUnderElevation: 0,
            ),
            cardTheme: CardThemeData(
              color: const Color(0xFF1E1E1E),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            iconTheme: const IconThemeData(color: Color(0xFF2463EB)),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF2463EB),
              surface: const Color(0xFF1E1E1E),
            ),
          ),
          debugShowCheckedModeBanner: false,
          home: const StartPage(),
        ),
      ),
    );
  }
}
