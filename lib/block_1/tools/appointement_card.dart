import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppointmentCard extends StatelessWidget {
  final Map<String, dynamic> appointment;
  final void Function(String appointmentId) onCancel;
  final void Function(BuildContext context, Map<String, dynamic> appointment) onMessage;

  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.onCancel,
    required this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    final doctor = appointment['doctor'] as Map<String, dynamic>? ?? {};
    final String doctorName = doctor['first_name']?.toString() ?? 'Unknown Doctor';
    final String specialty = doctor['specialty']?.toString() ?? '';
    final String? pictureUrl = doctor['picture']?.toString();
    final String date = appointment['date']?.toString() ?? '';
    final String status = appointment['status']?.toString() ?? '';
    final String appointmentId = appointment['id']?.toString() ?? '';

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          children: [
            // ── Doctor info row ──
            Row(
              children: [
                CircleAvatar(
                  radius: 28.r,
                  backgroundImage: (pictureUrl != null && pictureUrl.startsWith('http'))
                      ? NetworkImage(pictureUrl)
                      : const AssetImage('assets/default_avatar.png') as ImageProvider,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dr. $doctorName',
                        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        specialty,
                        style: TextStyle(fontSize: 13.sp, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2463EB).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: const Color(0xFF2463EB),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Divider(height: 1, color: Colors.grey[200]),
            SizedBox(height: 12.h),
            // ── Date + buttons row ──
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 16.r, color: Colors.grey[500]),
                SizedBox(width: 6.w),
                Text(
                  date,
                  style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
                ),
                const Spacer(),
                SizedBox(
                  height: 34.h,
                  child: OutlinedButton(
                    onPressed: () => onMessage(context,appointment),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2463EB),
                      side: const BorderSide(color: Color(0xFF2463EB)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                    ),
                    child: Text(
                      'Message',
                      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                SizedBox(
                  height: 34.h,
                  child: OutlinedButton(
                    onPressed: () => onCancel(appointmentId),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}