import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mediora/block_2/pages/book_and_pay_page.dart';

class DoctorPage extends StatelessWidget {
  final Map<String, dynamic> doctor;
  final List<dynamic>? services;
  const DoctorPage({super.key, required this.doctor, required this.services});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final firstName = doctor['first_name'] ?? '';
    final lastName = doctor['last_name'] ?? '';
    final fullName = 'Dr. $firstName $lastName'.trim();
    final specialty = doctor['specialty'] ?? '';
    final username = doctor['username'] ?? '';
    final email = doctor['email'] ?? '';
    final picture = doctor['picture'];
    final gender = doctor['gender'];
    final description = (doctor['description'] as String?)?.trim() ?? '';
    final clinicPos = (doctor['clinic_pos'] as String?)?.trim() ?? '';
    final imageForWorkplace = doctor['image_for_workplace'];

    // Parse clinic images — could be List or single string
    List<String> clinicImages = [];
    if (imageForWorkplace is List) {
      clinicImages = imageForWorkplace
          .map((e) => e.toString())
          .where((e) => e.isNotEmpty && e != 'string')
          .toList();
    } else if (imageForWorkplace is String &&
        imageForWorkplace.isNotEmpty &&
        imageForWorkplace != 'string') {
      clinicImages = [imageForWorkplace];
    }

    final bool hasValidPicture =
        picture != null &&
        picture.toString().startsWith('http') &&
        picture.toString() != 'string';

    final Map<String, dynamic>? consultation = services?.firstWhere(
      (s) => s['name'].toString().toLowerCase() == 'consultation',
      orElse: () => null,
    );

    final List<dynamic> otherServices =
        services
            ?.where((s) => s['name'].toString().toLowerCase() != 'consultation')
            .toList() ??
        [];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2463EB)),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDark
                        ? [const Color(0xFF1A2F6F), const Color(0xFF121212)]
                        : [const Color(0xFFDDE8FF), const Color(0xFFF2F2F7)],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    60.verticalSpace,
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF2463EB),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2463EB).withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: const Color(0xFFE8EFFD),
                        backgroundImage: hasValidPicture
                            ? NetworkImage(picture.toString())
                            : (gender == "male"
                                      ? const AssetImage(
                                          'assets/doctor_male_avatar.png',
                                        )
                                      : const AssetImage(
                                          'assets/doctor_female_avatar.png',
                                        ))
                                  as ImageProvider,
                      ),
                    ),
                    16.verticalSpace,
                    Text(
                      fullName,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    6.verticalSpace,
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        //color: const Color(0xFF2463EB).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.h,
                              vertical: 6.w,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2463EB).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              specialty,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: const Color(0xFF2463EB),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (doctor["gender"].isNotEmpty) ...[
                            8.horizontalSpace,
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.h,
                                vertical: 6.w,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    doctor["gender"].toLowerCase() == 'female'
                                    ? const Color(0xFFFF4D9E).withOpacity(0.12)
                                    : const Color(0xFF2463EB).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                doctor["gender"],
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color:
                                      doctor['gender'].toLowerCase() == 'female'
                                      ? const Color(0xFFFF4D9E)
                                      : const Color(0xFF2463EB),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── About ────────────────────────────────────
                  const _SectionTitle(title: 'About'),
                  12.verticalSpace,
                  _InfoCard(
                    children: [
                      _InfoRow(
                        icon: Icons.person_outline,
                        label: 'Username',
                        value: '@$username',
                      ),
                      const _Divider(),
                      _InfoRow(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: email,
                      ),
                      const _Divider(),
                      _InfoRow(
                        icon: Icons.medical_services_outlined,
                        label: 'Specialty',
                        value: specialty,
                      ),
                    ],
                  ),

                  // ── About Doctor (description) ────────────────
                  if (description.isNotEmpty) ...[
                    24.verticalSpace,
                    const _SectionTitle(title: 'About Doctor'),
                    12.verticalSpace,
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          description,
                          style: TextStyle(
                            fontSize: 13.sp,
                            height: 1.6,
                            color: isDark
                                ? Colors.white70
                                : const Color(0xFF444444),
                          ),
                        ),
                      ),
                    ),
                  ],

                  // ── Clinic Location ───────────────────────────
                  if (clinicPos.isNotEmpty) ...[
                    24.verticalSpace,
                    const _SectionTitle(title: 'Clinic Location'),
                    12.verticalSpace,
                    Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: const Icon(
                          Icons.location_on,
                          color: Color(0xFF2463EB),
                          size: 36,
                        ),
                        title: Text(
                          clinicPos,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: const Color(0xFF2463EB),
                          ),
                        ),
                        trailing: const Icon(
                          Icons.open_in_new,
                          color: Color(0xFF2463EB),
                          size: 18,
                        ),
                      ),
                    ),
                  ],

                  // ── Clinic Pictures ───────────────────────────
                  if (clinicImages.isNotEmpty) ...[
                    24.verticalSpace,
                    const _SectionTitle(title: 'Clinic Pictures'),
                    12.verticalSpace,
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: SizedBox(
                          height: 140,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: clinicImages.length,
                            separatorBuilder: (_, __) => 10.horizontalSpace,
                            itemBuilder: (context, index) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  clinicImages[index],
                                  width: 180,
                                  height: 140,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 180,
                                    height: 140,
                                    color: isDark
                                        ? const Color(0xFF2A2A2A)
                                        : const Color(0xFFEEEEEE),
                                    child: const Icon(
                                      Icons.broken_image_outlined,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],

                  24.verticalSpace,

                  // ── Consultation Fee ─────────────────────────────────────
                  if (consultation != null) ...[
                    const _SectionTitle(title: 'Consultation Fee'),
                    12.verticalSpace,
                    Card(
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.h,
                          vertical: 8.w,
                        ),
                        leading: Icon(
                          Icons.payments_outlined,
                          color: Color(0xFF2463EB),
                          size: 36.r,
                        ),
                        title: Text(
                          'Consultation',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        trailing: Text(
                          '${consultation['price']} DZD',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: const Color(0xFF2463EB),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                  // ── Services ─────────────────────────────────────────────
                  if (otherServices.isNotEmpty) ...[
                    24.verticalSpace,
                    const _SectionTitle(title: 'Available Services'),
                    12.verticalSpace,
                    Card(
                      child: Column(
                        children: [
                          // Header row
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.h,
                              vertical: 10.w,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2463EB).withOpacity(0.1),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12.r),
                                topRight: Radius.circular(12.r),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Service',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF2463EB),
                                    ),
                                  ),
                                ),
                                Text(
                                  'Price',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF2463EB),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Service rows
                          ...List.generate(otherServices.length, (index) {
                            final service =
                                otherServices[index] as Map<String, dynamic>;
                            return Column(
                              children: [
                                const _Divider(),
                                InkWell(
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(20),
                                        ),
                                      ),
                                      builder: (_) => Padding(
                                        padding: const EdgeInsets.all(24),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons
                                                      .medical_services_outlined,
                                                  color: Color(0xFF2463EB),
                                                ),
                                                12.horizontalSpace,
                                                Text(
                                                  service['name'] ?? '',
                                                  style: TextStyle(
                                                    fontSize: 16.sp,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            16.verticalSpace,
                                            Text(
                                              service['description'] ??
                                                  'No description available.',
                                              style: TextStyle(
                                                fontSize: 13.sp,
                                                height: 1.6,
                                                color: isDark
                                                    ? Colors.white70
                                                    : const Color(0xFF444444),
                                              ),
                                            ),
                                            16.verticalSpace,
                                            Text(
                                              'Price: ${service['price']} DZD',
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF2463EB),
                                              ),
                                            ),
                                            24.verticalSpace,
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            service['name'] ?? '',
                                            style: TextStyle(fontSize: 13.sp),
                                          ),
                                        ),
                                        Text(
                                          '${service['price']} DZD',
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                            color: const Color(0xFF2463EB),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        8.horizontalSpace,
                                        const Icon(
                                          Icons.info_outline,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                  24.verticalSpace,
                  // ── Book button ───────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (consultation == null) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Service Unavailable"),
                              content: const Text(
                                "You cannot take an appointment with a doctor who doesn't have a consultation service.",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text(
                                    "OK",
                                    style: TextStyle(color: Color(0xFF2463EB)),
                                  ),
                                ),
                              ],
                            ),
                          );
                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookAndPayPage(
                              doctor: doctor,
                              consultation: consultation,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.calendar_month_outlined,
                        color: Colors.white,
                      ),
                      label: Text(
                        'Book Appointment',
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2463EB),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(children: children),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2463EB), size: 20),
          12.horizontalSpace,
          Text(
            label,
            style: TextStyle(fontSize: 13.sp, color: Colors.grey),
          ),
          16.horizontalSpace,
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
              textAlign: TextAlign.end,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Divider(
      height: 1,
      color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFEEEEEE),
    );
  }
}
