import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mediora/block_0/pages/sign_up/set_a_password_for_sign_up.dart';
import 'package:mediora/block_2/pages/invoice_page.dart';
import 'package:mediora/Network/networkServices.dart';
import 'package:url_launcher/url_launcher.dart';

class BookAndPayPage extends StatefulWidget {
  final Map<String, dynamic> doctor;
  final Map<String, dynamic> consultation;
  const BookAndPayPage({
    super.key,
    required this.doctor,
    required this.consultation,
  });

  @override
  State<BookAndPayPage> createState() => _BookAndPayPageState();
}

class _BookAndPayPageState extends State<BookAndPayPage> {
  int _selectedDayIndex = 0;
  bool _isConfirming = false;
  bool _isLoadingSchedule = true;

  // key: day_of_week (0=Sun,1=Mon,...), value: schedule entry
  Map<int, Map<String, dynamic>> _scheduleMap = {};

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    final doctorId = widget.doctor['id']?.toString() ?? '';
    final schedule = await AppointementService().daysAndTimeOfWork(id: doctorId);
    final map = <int, Map<String, dynamic>>{};
    for (final entry in schedule) {
      final dow = entry['day_of_week'] as int?;
      if (dow != null) map[dow] = entry as Map<String, dynamic>;
    }
    if (mounted) setState(() { _scheduleMap = map; _isLoadingSchedule = false; });
  }

  // Flutter weekday: Mon=1 ... Sun=7  →  API: Sun=0, Mon=1 ... Sat=6
  int _toApiDow(DateTime date) => date.weekday - 1;
  List<DateTime> get _next7Days {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return List.generate(7, (i) => tomorrow.add(Duration(days: i)));
  }

  bool _isDayOff(DateTime date) => !_scheduleMap.containsKey(_toApiDow(date));

  String _weekdayShort(DateTime date) {
    const short = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return short[date.weekday - 1];
  }

  // Parses "06:07:37.186Z" or full ISO → "06:07"
  String _formatTime(String? raw) {
    if (raw == null || raw.isEmpty) return '--:--';
    try {
      // Try full ISO first
      final dt = DateTime.tryParse(raw);
      if (dt != null) {
        return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      }
      // Fallback: just take HH:mm from the string
      return raw.substring(0, 5);
    } catch (_) {
      return raw.length >= 5 ? raw.substring(0, 5) : raw;
    }
  }

  String _getStartTime(DateTime date) {
    final entry = _scheduleMap[_toApiDow(date)];
    return _formatTime(entry?['starting_time']?.toString());
  }

  String _getFinishTime(DateTime date) {
    final entry = _scheduleMap[_toApiDow(date)];
    return _formatTime(entry?['finish_time']?.toString());
  }

  Future<void> _onConfirm() async {
  final days = _next7Days;
  final selectedDate = days[_selectedDayIndex];

  print('Selected date: $selectedDate');
  print('Selected weekday (Flutter): ${selectedDate.weekday}');
  print('Converted API dow: ${_toApiDow(selectedDate)}');
  print('Schedule map keys: ${_scheduleMap.keys.toList()}');
  print('Date sent to API: ${selectedDate.toIso8601String().split('T').first}');

  print('serviceId: ${widget.consultation['id']}');
  print('doctorId: ${widget.doctor['id']}');
  print('date: ${selectedDate.toIso8601String().split('T').first}');

  setState(() => _isConfirming = true);
  try {
    // 1. Check doctor is free
   final doctorIsFree = await AppointementService().doctorIsFree(
    serviceId: widget.consultation['id'],
    date: selectedDate.toIso8601String().split('T').first, // → "2026-04-29"
);

    if (!mounted) return;

    if (!doctorIsFree.success) {
      CustomSnackBarForSignUp.show(
        context,
        message: 'Doctor is not available on this day',
        icon: Icons.event_busy_outlined,
        backgroundColor: Colors.red,
      );
      return;
    }

    // 2. Make the appointment → get payment URL
    final appointment = await AppointementService().makeAppointement(
      serviceId: widget.consultation['id'],
      date: selectedDate.toIso8601String().split('T').first,
      id: widget.doctor['id']?.toString() ?? '',
    );

    if (!mounted) return;

    if (!appointment.success || appointment.message.isEmpty) {
      CustomSnackBarForSignUp.show(
        context,
        message: appointment.message, 
        icon: Icons.error_outline,
        backgroundColor: Colors.red,
      );
      return;
    }

    // 3. Open payment URL in browser
    final uri = Uri.parse(appointment.message);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      CustomSnackBarForSignUp.show(
        context,
        message: 'Could not open payment page',
        icon: Icons.open_in_browser_outlined,
        backgroundColor: Colors.red,
      );
      return;
    }

    if (!mounted) return;

    // 4. Navigate to invoice
    final user = await UserServices().getUser();
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InvoicePage(
          doctor: widget.doctor,
          patient: user,
          selectedDate: selectedDate,
        ),
      ),
    );
  } catch (e) {
    if (!mounted) return;
    CustomSnackBarForSignUp.show(
      context,
      message: 'Something went wrong, try again',
      icon: Icons.error_outline,
      backgroundColor: Colors.red,
    );
  } finally {
    if (mounted) setState(() => _isConfirming = false);
  }
}

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final doctor = widget.doctor;
    final picture = doctor['picture'];
    final hasValidPicture =
        picture != null &&
        picture.toString().startsWith('http') &&
        picture.toString() != 'string';
    final days = _next7Days;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2463EB)),
        ),
        title: Text(
          'Book Appointment',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
      ),

      // ── Confirm button always at bottom ──────────────────────
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (_isConfirming || _isDayOff(days[_selectedDayIndex]))
                ? null
                : _onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2463EB),
              disabledBackgroundColor: Colors.grey.shade400,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _isConfirming
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Confirm and Pay',
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),

      body: _isLoadingSchedule
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2463EB)))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── Doctor Card ─────────────────────────────────
                Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      radius: 28,
                      backgroundColor: const Color(0xFFE8EFFD),
                      backgroundImage: hasValidPicture
                          ? NetworkImage(picture.toString())
                          : const AssetImage('assets/doctor_male_avatar.png')
                                as ImageProvider,
                    ),
                    title: Text(
                      'Dr. ${doctor['first_name']} ${doctor['last_name']}',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      doctor['specialty'] ?? '',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF2463EB),
                      ),
                    ),
                  ),
                ),
                24.verticalSpace,

                // ── Select Date ─────────────────────────────────
                Text(
                  'Select Date',
                  style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold),
                ),
                12.verticalSpace,
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: days.length,
                    itemBuilder: (context, index) {
                      final day = days[index];
                      final isSelected = _selectedDayIndex == index;
                      final isDayOff = _isDayOff(day);

                      return GestureDetector(
                        onTap: isDayOff
                            ? null
                            : () => setState(() => _selectedDayIndex = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 10),
                          width: 68,
                          decoration: BoxDecoration(
                            color: isDayOff
                                ? (isDark
                                      ? const Color(0xFF2A2A2A)
                                      : const Color(0xFFF0F0F0))
                                : isSelected
                                ? const Color(0xFF2463EB)
                                : (isDark
                                      ? const Color(0xFF1E1E1E)
                                      : Colors.white),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF2463EB)
                                  : Colors.transparent,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF2463EB,
                                      ).withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _weekdayShort(day),
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w500,
                                  color: isDayOff
                                      ? Colors.grey
                                      : isSelected
                                      ? Colors.white
                                      : Colors.grey,
                                ),
                              ),
                              4.verticalSpace,
                              Text(
                                '${day.day}',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: isDayOff
                                      ? Colors.grey
                                      : isSelected
                                      ? Colors.white
                                      : (isDark ? Colors.white : Colors.black),
                                ),
                              ),
                              4.verticalSpace,
                              // ── Time range or Off ────────────
                              if (isDayOff)
                                Text(
                                  'Off',
                                  style: TextStyle(
                                    fontSize: 9.sp,
                                    color: Colors.grey,
                                  ),
                                )
                              else
                                Column(
                                  children: [
                                    Text(
                                      _getStartTime(day),
                                      style: TextStyle(
                                        fontSize: 9.sp,
                                        color: isSelected
                                            ? Colors.white70
                                            : const Color(0xFF2463EB),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      _getFinishTime(day),
                                      style: TextStyle(
                                        fontSize: 9.sp,
                                        color: isSelected
                                            ? Colors.white70
                                            : const Color(0xFF2463EB),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                24.verticalSpace,
              ],
            ),
    );
  }
}