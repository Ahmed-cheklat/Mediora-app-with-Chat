import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mediora/Network/networkServices.dart';
import 'package:mediora/block_1/pages%20/homePage.dart';

class InvoicePage extends StatelessWidget {
  final Map<String, dynamic> doctor;
  final Map<String, dynamic> patient;

  const InvoicePage({super.key, required this.doctor, required this.patient, required DateTime selectedDate});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    UserServices().getUser();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          'Invoice',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.r),
        children: [
          // ── Confirmed header ──────────────────────────────────
          Column(
            children: [
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
                  size: 56.r,
                ),
              ),
              12.verticalSpace,
              Text(
                'Appointment Confirmed',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          24.verticalSpace,

          // ── Patient Details ───────────────────────────────────
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Patient Details',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  12.verticalSpace,
                  _InvoiceRow(
                    icon: Icons.person_outline,
                    label: 'Full Name',
                    value: patient['first_name'] ?? '',
                  ),
                  const _InvoiceDivider(),
                  _InvoiceRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: patient['email'] ?? '',
                  ),
                ],
              ),
            ),
          ),
          16.verticalSpace,

          // ── QR Code ───────────────────────────────────────────
          Card(
            child: Padding(
              padding: EdgeInsets.all(24.r),
              child: Column(
                children: [
                  Text(
                    'Appointment QR Code',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  16.verticalSpace,
                  Container(
                    width: 180.w,
                    height: 180.h,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF2463EB).withOpacity(0.3),
                        width: 2.w,
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                      color: isDark
                          ? const Color(0xFF2A2A2A)
                          : const Color(0xFFF3F4F6),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.qr_code_2_rounded,
                          size: 80.r,
                          color: isDark ? Colors.white24 : Colors.black12,
                        ),
                        8.verticalSpace,
                        Text(
                          'QR Code Here',
                          style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          16.verticalSpace,

          // ── Consultation Fee + Date ───────────────────────────
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                children: [
                  _InvoiceRow(
                    icon: Icons.medical_services_outlined,
                    label: 'Consultation Fee',
                    value: '2,500 DZD',
                    valueColor: const Color(0xFF2463EB),
                    valueBold: true,
                  ),
                  const _InvoiceDivider(),
                  _InvoiceRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Date',
                    value: 'April 24, 2026',
                  ),
                  const _InvoiceDivider(),
                  _InvoiceRow(
                    icon: Icons.medical_services_outlined,
                    label: 'Doctor',
                    value: 'Dr. ${doctor['first_name']} ${doctor['last_name']}',
                  ),
                  const _InvoiceDivider(),
                  _InvoiceRow(
                    icon: Icons.local_hospital_outlined,
                    label: 'Specialty',
                    value: doctor['specialty'] ?? '',
                  ),
                ],
              ),
            ),
          ),
          32.verticalSpace,

          // ── Download button ───────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download_rounded, color: Colors.white),
              label: Text(
                'Download Ticket',
                style: TextStyle(
                  fontSize: 15.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2463EB),
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
            ),
          ),
          10.verticalSpace,
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => Homepage()),
                  (route) => false,
                );
              },
              label: Text(
                'Done',
                style: TextStyle(
                  fontSize: 15.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2463EB),
                padding: EdgeInsets.symmetric(vertical: 16.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
            ),
          ),
          24.verticalSpace,
        ],
      ),
    );
  }
}

class _InvoiceRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool valueBold;

  const _InvoiceRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.valueBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2463EB), size: 20.r),
          12.horizontalSpace,
          Text(
            label,
            style: TextStyle(fontSize: 13.sp, color: Colors.grey),
          ),
          16.horizontalSpace,
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: valueBold ? FontWeight.bold : FontWeight.w500,
                color: valueColor,
              ),
              textAlign: TextAlign.end,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _InvoiceDivider extends StatelessWidget {
  const _InvoiceDivider();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Divider(
      height: 1.h,
      color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFEEEEEE),
    );
  }
}
