import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mediora/block_4/tools/notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationModesPage extends StatefulWidget {
  const NotificationModesPage({super.key});

  @override
  State<NotificationModesPage> createState() => _NotificationModesPageState();
}

class _NotificationModesPageState extends State<NotificationModesPage> {
  bool _appointementNotification = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _appointementNotification = prefs.getBool('notif_appointment') ?? false;
    });
  }

  Future<void> _setAppointmentNotif(bool value) async {
    if (value) {
      await NotiService().initNotifications();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_appointment', value);
    setState(() {
      _appointementNotification = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: Padding(
        padding: EdgeInsets.all(8.0.w),
        child: SafeArea(
      
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: SwitchListTile(
              title: Text(
                'Appointment Notifications',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                "We'll send you a reminder 24 hours before your appointment.",
                style: TextStyle(fontSize: 11.sp, color: Colors.grey),
              ),
              value: _appointementNotification,
              onChanged: _setAppointmentNotif,
              activeColor: const Color(0xFF2463EB),
            ),
          ),
        ),
      ),
    );
  }
}