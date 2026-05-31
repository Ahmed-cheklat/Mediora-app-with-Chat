import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_icons/health_icons.dart';
import 'package:mediora/Network/networkServices.dart';
import 'package:mediora/block_2/pages/book_and_pay_page.dart';

class DoctorPage extends StatefulWidget {
  final Map<String, dynamic> doctor;
  final List<dynamic>? services;
  const DoctorPage({super.key, required this.doctor, required this.services});

  @override
  State<DoctorPage> createState() => _DoctorPageState();
}

class _DoctorPageState extends State<DoctorPage> {
  List<dynamic> _feedbacks = [];
  bool _isLoadingFeedback = true;
  final TextEditingController _feedbackController = TextEditingController();
  bool _submitting = false;
  bool _hasSubmittedFeedback = false;
  String? _myFeedbackId;
  String _currentUserId = '';

  @override
  void initState() {
    super.initState();
    _loadFeedback();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _loadFeedback({bool checkOwn = true}) async {
    final doctorId = widget.doctor['id']?.toString() ?? '';
    if (doctorId.isEmpty) return;
    final data = await FeedBackServices().getFeedback(doctorId: doctorId);
    if (mounted) {
      setState(() {
        _feedbacks = data;
        _isLoadingFeedback = false;
      });
      if (checkOwn) _checkMyFeedback();
    }
  }

  Future<void> _checkMyFeedback() async {
    final user = await UserServices().getUser();
    final myId = user['id']?.toString() ?? '';
    if (myId.isEmpty) return;
    _currentUserId = myId;
    for (final fb in _feedbacks) {
      final fbMap = fb as Map<String, dynamic>;
      final patient = fbMap['patient'] as Map<String, dynamic>? ?? {};
      final userId = patient['id']?.toString() ?? '';
      if (userId == myId) {
        if (mounted) {
          setState(() {
            _hasSubmittedFeedback = true;
            _myFeedbackId = fbMap['id']?.toString();
            _feedbackController.text = fbMap['body']?.toString() ?? fbMap['comment']?.toString() ?? '';
          });
        }
        break;
      }
    }
  }

  Future<void> _submitFeedback() async {
    final text = _feedbackController.text.trim();
    if (text.isEmpty) return;
    setState(() => _submitting = true);

    final doctorId = widget.doctor['id']?.toString() ?? '';
    final result = await FeedBackServices().postFeedback(
      doctorId: doctorId,
      body: text,
    );

    if (mounted) {
      setState(() => _submitting = false);
      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Feedback submitted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _feedbackController.clear();
        _loadFeedback();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateFeedback() async {
    final text = _feedbackController.text.trim();
    if (text.isEmpty || _myFeedbackId == null) return;
    setState(() => _submitting = true);

    final result = await FeedBackServices().updateFeedback(
      feedbackId: _myFeedbackId!,
      body: text,
    );

    if (mounted) {
      setState(() => _submitting = false);
      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Feedback updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _feedbackController.clear();
        setState(() {
          _hasSubmittedFeedback = false;
          _myFeedbackId = null;
        });
        _loadFeedback(checkOwn: false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final firstName = widget.doctor['first_name'] ?? '';
    final lastName = widget.doctor['last_name'] ?? '';
    final fullName = 'Dr. $firstName $lastName'.trim();
    final specialty = widget.doctor['specialty'] ?? '';
    final username = widget.doctor['username'] ?? '';
    final email = widget.doctor['email'] ?? '';
    final picture = widget.doctor['picture'];
    final gender = widget.doctor['gender'];
    final description = (widget.doctor['description'] as String?)?.trim() ?? '';
    final clinicPos = (widget.doctor['clinic_pos'] as String?)?.trim() ?? '';
    final imageForWorkplace = widget.doctor['image_for_workplace'];

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

    final Map<String, dynamic>? consultation = widget.services?.firstWhere(
      (s) => s['name'].toString().toLowerCase() == 'consultation',
      orElse: () => null,
    );

    final List<dynamic> otherServices =
        widget.services
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
                          if (widget.doctor["gender"].isNotEmpty) ...[
                            8.horizontalSpace,
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.h,
                                vertical: 6.w,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    widget.doctor["gender"].toLowerCase() == 'female'
                                    ? const Color(0xFFFF4D9E).withOpacity(0.12)
                                    : const Color(0xFF2463EB).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                widget.doctor["gender"],
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color:
                                      widget.doctor['gender'].toLowerCase() == 'female'
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
                                                  HealthIcons.stethoscopeOutline,
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
                   // ── Feedback ──────────────────────────────
                   const _SectionTitle(title: 'Feedback'),
                   12.verticalSpace,
                   _isLoadingFeedback
                       ? const Center(child: CircularProgressIndicator(color: Color(0xFF2463EB)))
                       : Column(
                           children: [
                if (_feedbacks.isNotEmpty)
                                ...List.generate(_feedbacks.length, (index) {
                                  final fb = _feedbacks[index] as Map<String, dynamic>;
                                  final patient = fb['patient'] as Map<String, dynamic>? ?? {};
                                  final username = patient['username']?.toString() ?? 'Anonymous';
                                  return Card(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  CircleAvatar(
                                                    radius: 14.r,
                                                    backgroundColor: const Color(0xFF2463EB).withOpacity(0.1),
                                                    child: Text(
                                                      username.isNotEmpty ? username[0].toUpperCase() : '?',
                                                      style: TextStyle(
                                                        fontSize: 12.sp,
                                                        color: const Color(0xFF2463EB),
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  8.horizontalSpace,
                                                  Text(
                                                    username,
                                                    style: TextStyle(
                                                      fontSize: 13.sp,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    _formatDate(fb['created_at']?.toString() ?? ''),
                                                    style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                                                  ),
                                                  if (patient['id']?.toString() == _currentUserId)
                                                    PopupMenuButton<String>(
                                                      icon: Icon(Icons.more_horiz, size: 18.sp, color: Colors.grey),
                                                      onSelected: (value) {
                                                        final fbId = fb['id']?.toString() ?? '';
                                                        final fbBody = fb['body']?.toString() ?? '';
                                                        if (value == 'edit') {
                                                          setState(() {
                                                            _feedbackController.text = fbBody;
                                                            _myFeedbackId = fbId;
                                                            _hasSubmittedFeedback = true;
                                                          });
                                                        } else if (value == 'delete') {
                                                          _confirmDeleteFeedback(fbId);
                                                        }
                                                      },
                                                      itemBuilder: (_) => [
                                                        const PopupMenuItem(value: 'edit', child: Text('Modify')),
                                                        const PopupMenuItem(value: 'delete', child: Text('Delete')),
                                                      ],
                                                    ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 8.h),
                                          Text(
                                            fb['body']?.toString() ?? '',
                                            style: TextStyle(fontSize: 13.sp, height: 1.5),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                             if (!_hasSubmittedFeedback) ...[
                               12.verticalSpace,
                               TextField(
                                 controller: _feedbackController,
                                 maxLines: 3,
                                 decoration: InputDecoration(
                                   hintText: 'Share your experience with this doctor...',
                                   hintStyle: const TextStyle(color: Colors.grey),
                                   border: OutlineInputBorder(
                                     borderRadius: BorderRadius.circular(12),
                                   ),
                                   contentPadding: const EdgeInsets.all(12),
                                 ),
                               ),
                               12.verticalSpace,
                               SizedBox(
                                 width: double.infinity,
                                 child: ElevatedButton(
                                   onPressed: _submitting ? null : _submitFeedback,
                                   style: ElevatedButton.styleFrom(
                                     backgroundColor: const Color(0xFF2463EB),
                                     foregroundColor: Colors.white,
                                     padding: const EdgeInsets.symmetric(vertical: 12),
                                     shape: RoundedRectangleBorder(
                                       borderRadius: BorderRadius.circular(12),
                                     ),
                                   ),
                                   child: _submitting
                                       ? const SizedBox(
                                           width: 20,
                                           height: 20,
                                           child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                         )
                                       : const Text('Submit Feedback', style: TextStyle(fontWeight: FontWeight.w600)),
                                 ),
                               ),
                             ] else ...[
                               12.verticalSpace,
                               TextField(
                                 controller: _feedbackController,
                                 maxLines: 3,
                                 decoration: InputDecoration(
                                   hintText: 'Update your feedback...',
                                   hintStyle: const TextStyle(color: Colors.grey),
                                   border: OutlineInputBorder(
                                     borderRadius: BorderRadius.circular(12),
                                   ),
                                   contentPadding: const EdgeInsets.all(12),
                                 ),
                               ),
                               12.verticalSpace,
                               Row(
                                 children: [
                                   Expanded(
                                     child: ElevatedButton(
                                       onPressed: _submitting ? null : _updateFeedback,
                                       style: ElevatedButton.styleFrom(
                                         backgroundColor: const Color(0xFF2463EB),
                                         foregroundColor: Colors.white,
                                         padding: const EdgeInsets.symmetric(vertical: 12),
                                         shape: RoundedRectangleBorder(
                                           borderRadius: BorderRadius.circular(12),
                                         ),
                                       ),
                                       child: _submitting
                                           ? const SizedBox(
                                               width: 20,
                                               height: 20,
                                               child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                             )
                                           : const Text('Update Feedback', style: TextStyle(fontWeight: FontWeight.w600)),
                                     ),
                                   ),
                                   const SizedBox(width: 12),
                                   Expanded(
                                     child: OutlinedButton(
                                        onPressed: () async {
                                          if (_myFeedbackId == null) return;
                                          final confirmed = await showDialog<bool>(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: const Text('Delete Feedback'),
                                              content: const Text('Are you sure you want to delete this feedback?'),
                                              actions: [
                                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                                TextButton(
                                                  onPressed: () => Navigator.pop(ctx, true),
                                                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                                                  child: const Text('Delete'),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirmed != true || !mounted) return;
                                          final result = await FeedBackServices().deleteFeedback(
                                            feedbackId: _myFeedbackId!,
                                          );
                                          if (mounted) {
                                            if (result.success) {
                                              _feedbackController.clear();
                                              setState(() {
                                                _hasSubmittedFeedback = false;
                                                _myFeedbackId = null;
                                              });
                                              _loadFeedback(checkOwn: false);
                                            }
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(result.success ? 'Feedback deleted' : result.message),
                                                backgroundColor: result.success ? Colors.green : Colors.red,
                                              ),
                                            );
                                          }
                                        },
                                       style: OutlinedButton.styleFrom(
                                         foregroundColor: Colors.red,
                                         side: const BorderSide(color: Colors.red),
                                         padding: const EdgeInsets.symmetric(vertical: 12),
                                         shape: RoundedRectangleBorder(
                                           borderRadius: BorderRadius.circular(12),
                                         ),
                                       ),
                                       child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w600)),
                                     ),
                                   ),
                                 ],
                               ),
                             ],
                           ],
                         ),
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
                               doctor: widget.doctor,
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

  Future<void> _confirmDeleteFeedback(String feedbackId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Feedback'),
        content: const Text('Are you sure you want to delete this feedback?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final result = await FeedBackServices().deleteFeedback(feedbackId: feedbackId);
      if (mounted) {
        if (result.success) {
          _feedbackController.clear();
          setState(() {
            _hasSubmittedFeedback = false;
            _myFeedbackId = null;
          });
          _loadFeedback(checkOwn: false);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.success ? 'Feedback deleted' : result.message),
            backgroundColor: result.success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final min = dt.minute.toString().padLeft(2, '0');
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year} $hour:$min $ampm';
    } catch (_) {
      return iso;
    }
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
