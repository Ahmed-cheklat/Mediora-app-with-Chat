import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mediora/advices.dart';
import 'package:mediora/block_1/tools/appointement_card.dart';
import 'package:mediora/block_3/pages/chat_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mediora/Network/networkServices.dart';
import 'package:mediora/block_2/pages/specialites_page.dart';
import 'package:mediora/block_3/pages/conversations_page.dart';
import 'package:mediora/block_4/pages/edit_profile_page.dart';
import 'package:mediora/block_4/pages/profile_page.dart';
import 'package:mediora/block_4/tools/notifications.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  String _userName = '...';
  String? _pictureUrl;

  final List<Widget> _pages = [
    const HomepageBody(),
    const AppointmentPage(),
    const ConversationsPage(),
    const ProfilePage(),
  ];

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _initUser();
  }

  Future<void> _initUser() async {
    try {
      final data = await UserServices().getUser();
      await _saveUser(data);
      await _readUser();
    } catch (e) {
      await _readUser();
    }
  }

  Future<void> _saveUser(Map<String, dynamic> data) async {
    await _secureStorage.write(
      key: 'first_name',
      value: data['first_name']?.toString() ?? '',
    );
    await _secureStorage.write(
      key: 'last_name',
      value: data['last_name']?.toString() ?? '',
    );
    await _secureStorage.write(
      key: 'picture',
      value: data['picture']?.toString() ?? '',
    );
    await _secureStorage.write(
      key: 'username',
      value: data['username']?.toString() ?? '',
    );
    await _secureStorage.write(
      key: 'email',
      value: data['email']?.toString() ?? '',
    );
    await _secureStorage.write(
      key: 'gender',
      value: data['gender']?.toString() ?? '',
    );
    await _secureStorage.write(
      key: 'phone_number',
      value: data['phone_number']?.toString() ?? '',
    );
  }

  Future<void> _readUser() async {
    final firstName = await _secureStorage.read(key: 'first_name') ?? '';
    final lastName = await _secureStorage.read(key: 'last_name') ?? '';
    final picture = await _secureStorage.read(key: 'picture');

    if (mounted) {
      setState(() {
        _userName = '$firstName $lastName'.trim();
        _pictureUrl =
            (picture != null &&
                picture.startsWith('http') &&
                picture != 'string')
            ? picture
            : null;
      });
    }
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Good Morning,';
    if (hour >= 12 && hour < 17) return 'Good Afternoon,';
    if (hour >= 17 && hour < 21) return 'Good Evening,';
    return 'Good Night,';
  }

  @override
  Widget build(BuildContext context) {
    final greeting = getGreeting();

    return PopScope(
      canPop: false,
      child: Scaffold(
        extendBody: true,
        appBar: _currentIndex == 0
            ? AppBar(
                toolbarHeight: 60.h,
                elevation: 0,
                flexibleSpace: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 36, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        greeting,
                        style: TextStyle(
                          color: const Color.fromARGB(255, 115, 111, 111),
                          fontSize: 15.sp,
                        ),
                      ),
                      Text(
                        _userName,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                actions: [
                  Padding(
                    padding: EdgeInsets.only(right: 16.w),
                    child: GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => EditProfilePage()),
                        );
                        _initUser();
                      },
                      child: CircleAvatar(
                        radius: 22.r,
                        backgroundImage: _pictureUrl != null
                            ? NetworkImage(_pictureUrl!) as ImageProvider
                            : const AssetImage('assets/default_avatar.png'),
                      ),
                    ),
                  ),
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(1),
                  child: Container(color: Colors.grey[300], height: 1),
                ),
              )
            : null,
        body: _pages[_currentIndex],
        bottomNavigationBar: BottomNavigatorBarNewCustom(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index == 0) _initUser();
            setState(() => _currentIndex = index);
          },
        ),
      ),
    );
  }
}

// ── HomepageBody ──────────────────────────────────────────────────────────────

class HomepageBody extends StatefulWidget {
  const HomepageBody({super.key});

  @override
  State<HomepageBody> createState() => _HomepageBodyState();
}

class _HomepageBodyState extends State<HomepageBody> {
  List<dynamic> _appointments = [];
  bool _isLoading = true;
  String _dailyAdvice = '';

  @override
  void initState() {
    super.initState();
    _loadDailyAdvice();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([_loadAppointments()]);
  }

  Future<void> _loadDailyAdvice() async {
    final prefs = await SharedPreferences.getInstance();
    final currentSession = DateTime.now().millisecondsSinceEpoch.toString();
    final random = Random();
    final advice = medicalAdvices[random.nextInt(medicalAdvices.length)];
    await prefs.setString('daily_advice', advice);
    await prefs.setString('advice_session_id', currentSession);
    if (mounted) setState(() => _dailyAdvice = advice);
  }

  Future<void> _loadAppointments() async {
    final data = await AppointementService().getUserAppointment(
      page: 1,
      limit: 20,
    );
    if (mounted) {
      setState(() {
        _appointments = data;
        _isLoading = false;
      });

      final prefs = await SharedPreferences.getInstance();
      final appointmentNotifEnabled =
          prefs.getBool('notif_appointment') ?? false;
      if (!appointmentNotifEnabled) return;

      final noti = NotiService();
      await noti.initNotifications();
      final now = DateTime.now();

      for (int i = 0; i < data.length; i++) {
        final ap = data[i] as Map<String, dynamic>;
        final dateStr = ap['date']?.toString() ?? '';
        final doctor = ap['doctor'] as Map<String, dynamic>? ?? {};
        final doctorName = doctor['first_name']?.toString() ?? 'your doctor';
        final appointmentDate = DateTime.tryParse(dateStr);
        if (appointmentDate == null) continue;

        final morningNotif = DateTime(
          appointmentDate.year,
          appointmentDate.month,
          appointmentDate.day,
          6,
          0,
        );
        final reminderNotif = DateTime(
          appointmentDate.year,
          appointmentDate.month,
          appointmentDate.day - 1,
          20,
          0,
        );

        if (appointmentNotifEnabled && morningNotif.isAfter(now)) {
          await noti.scheduleNotificationAtDate(
            id: i * 10,
            title: 'Appointment Today',
            body: 'You have an appointment with Dr. $doctorName today.',
            dateTime: morningNotif,
          );
        }
        if (appointmentNotifEnabled && reminderNotif.isAfter(now)) {
          await noti.scheduleNotificationAtDate(
            id: i * 10 + 1,
            title: 'Appointment Tomorrow',
            body:
                'Reminder: You have an appointment with Dr. $doctorName tomorrow.',
            dateTime: reminderNotif,
          );
        }
      }
    }
  }

  Future<void> _cancelAppointment(String appointmentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: const Text(
          'Are you sure you want to cancel this appointment?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final result = await AppointementService().cancelAppointement(
        id: appointmentId,
      );
      if (!context.mounted) return;
      if (result.success) {
        final index = _appointments.indexWhere((a) => a['id'] == appointmentId);
        if (index != -1) {
          final noti = NotiService();
          await noti.cancelNotification(id: index * 10);
          await noti.cancelNotification(id: index * 10 + 1);
        }
        setState(
          () => _appointments.removeWhere((a) => a['id'] == appointmentId),
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Appointment cancelled')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _onMessage(BuildContext context, Map<String, dynamic> appointment) {
    final doctor = appointment['doctor'] as Map<String, dynamic>? ?? {};
    final String doctorId = doctor['id']?.toString() ?? '';
    final String doctorName =
        '${doctor['first_name'] ?? ''} ${doctor['last_name'] ?? ''}'.trim();
    final String? avatarUrl = doctor['picture']?.toString();

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ConversationsPage()),
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatPage(
          conversationId:null ,
          doctorId: doctorId,
          doctorName: doctorName,
          avatarUrl: avatarUrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF2463EB)),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF2463EB),
      onRefresh: _loadData,
      child: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
        children: [
          // ── Appointments ──────────────────────────────────────
          if (_appointments.isNotEmpty) ...[
            Text(
              'Upcoming Appointments',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 12.h),
            ..._appointments.map(
              (appointment) => AppointmentCard(
                appointment: appointment as Map<String, dynamic>,
                onCancel: _cancelAppointment,
                onMessage: _onMessage,
              ),
            ),
          ] else ...[
            Center(
              child: Column(
                children: [
                  SizedBox(height: 40.h),
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 64.r,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'No upcoming appointments',
                    style: TextStyle(fontSize: 15.sp, color: Colors.grey[500]),
                  ),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ],

          // ── Daily Advice ──────────────────────────────────────
          if (_dailyAdvice.isNotEmpty) ...[
            SizedBox(height: 24.h),
            Text(
              'Health Tip of the Day',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 12.h),
            Card(
              color: const Color.fromARGB(255, 240, 253, 244),
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.tips_and_updates_outlined,
                      color: Color.fromARGB(255, 0, 91, 25),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        _dailyAdvice,
                        style: TextStyle(
                          color: const Color.fromARGB(255, 0, 91, 25),
                          fontSize: 14.sp,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── BottomNavigationBar ───────────────────────────────────────────────────────

class BottomNavigatorBarNewCustom extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavigatorBarNewCustom({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<BottomNavigatorBarNewCustom> createState() =>
      _BottomNavigatorBarNewCustomState();
}

class _BottomNavigatorBarNewCustomState
    extends State<BottomNavigatorBarNewCustom> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 68,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black45 : Colors.black26,
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(padding: EdgeInsets.zero),
          child: SizedBox(
            height: 68,
            child: OverflowBox(
              maxHeight: 68,
              child: BottomNavigationBar(
                backgroundColor: isDark
                    ? const Color(0xFF1E1E1E)
                    : Colors.white,
                selectedFontSize: 10,
                unselectedFontSize: 10,
                currentIndex: widget.currentIndex,
                selectedItemColor: const Color(0xFF2463EB),
                unselectedItemColor: Colors.grey,
                enableFeedback: false,
                onTap: widget.onTap,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_rounded, size: 20),
                    label: "Home",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.calendar_month, size: 20),
                    label: "Appointment",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.chat, size: 20),
                    label: "Chat",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person, size: 20),
                    label: "Profile",
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
