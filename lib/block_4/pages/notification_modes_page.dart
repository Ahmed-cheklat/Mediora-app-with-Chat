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
  bool _messageNotification = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _appointementNotification = prefs.getBool('notif_appointment') ?? false;
      _messageNotification = prefs.getBool('notif_message') ?? false;
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
      appBar: AppBar(title: Text("Notifications")),
      body: Padding(
        padding: EdgeInsets.all(8.0.w),
        child: SafeArea(
          child: Column(
            children: [
              CardCustom(
                value: _messageNotification && _appointementNotification,
                title: 'All',
                onChanged: (value) {
                  setState(() {
                    _messageNotification = value;
                    _appointementNotification = value;
                  });
                },
              ),
              CardCustom(
                description:
                    "Enabling this option allows us to send you a reminder exactly 24 hours prior to your scheduled appointment.",
                value: _appointementNotification,
                title: 'Appointment Notifications',
                onChanged: _setAppointmentNotif,
              ),
              CardCustom(
                description:
                    "Enabling this option allows us to notify you when your doctor sends a new message. For your privacy, the alert will only show the doctor's name and will not display the message content.",
                value: _messageNotification,
                title: 'Message Notifications',
                onChanged: (value) {
                  setState(() {
                    _messageNotification = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CardCustom extends StatefulWidget {
  final String title;
  final String? description;
  final bool value;
  final Function(bool) onChanged;

  const CardCustom({
    super.key,
    required this.value,
    required this.title,
    this.description,
    required this.onChanged,
  });

  @override
  State<CardCustom> createState() => _CardCustomState();
}

class _CardCustomState extends State<CardCustom> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final bool hasDescription =
        widget.description != null && widget.description!.isNotEmpty;

    return Card(
      shadowColor: const Color(0xFF2463EB),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: hasDescription
            ? () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              }
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 13, // استخدم 13.sp
                  fontFamily: 'LineSeedJP',
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: Switch(
                value: widget.value,
                onChanged: widget.onChanged,
                activeColor: const Color(0xFF2463EB),
              ),
            ),

            if (hasDescription)
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: isExpanded
                    ? Padding(
                        padding: EdgeInsets.only(
                          left: 16.w,
                          right: 16.w,
                          bottom: 16.h,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            widget.description!,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontFamily: 'LineSeedJP',
                              color: Colors.grey[600],
                              height: 1.5.h,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
          ],
        ),
      ),
    );
  }
}
