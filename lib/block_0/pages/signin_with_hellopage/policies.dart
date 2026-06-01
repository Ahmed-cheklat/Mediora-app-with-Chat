import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

final List<Map<String, String>> privacyPolicyData = [
  {
    "title": "Introduction",
    "content":
        "Your privacy and the security of your data are our highest priorities. This Privacy Policy explains how Mediora collects, uses, and safeguards your information when you use our medical reservation platform. Last updated: June 2026."
  },
  {
    "title": "1. Information We Collect",
    "content":
        "We collect personal identification details (full name, email, phone number), appointment histories, secure in-app chat conversations with doctors, and any feedback or reviews you post on doctor profiles."
  },
  {
    "title": "2. How We Use Your Information",
    "content":
        "We use your data strictly to process your appointment reservations, facilitate real-time chatting with medical providers, publish your submitted reviews on doctor profiles, and enhance your doctor search results."
  },
  {
    "title": "3. Data Sharing and Disclosure",
    "content":
        "We maintain a strict confidentiality rule. We never sell, rent, or trade your data with third-party advertisers. Your profile and chat details are shared exclusively with the specific doctors you book or converse with. Patient feedback and reviews are visible publicly on the respective doctor's profile."
  },
  {
    "title": "4. Data Security & Storage",
    "content":
        "We implement industry-standard security protocols. All data transmitted between the Mediora mobile application and our cloud servers—including your chat history and reservation details—is fully encrypted and stored in secure databases."
  },
  {
    "title": "5. Your Rights",
    "content":
        "You maintain control over your personal profile data. You have the right to access, review, and update your information at any time through the application settings. Please note that direct account deletion is not supported within the app to ensure the integrity and continuity of active reservation records and medical communication logs."
  },
  {
    "title": "6. Changes to This Policy",
    "content":
        "We reserve the right to update this Privacy Policy as Mediora introduces new features or complies with changing healthcare platform regulations. We encourage users to review this section periodically."
  },
];

class Policies extends StatelessWidget {
  const Policies({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor       = isDark ? const Color(0xFF121212) : const Color(0xFFF2F2F7);
    final cardColor     = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final accentColor   = const Color(0xFF2463EB);
    final textPrimary   = isDark ? Colors.white : const Color(0xFF0D1B2A);
    final textSecondary = isDark ? const Color(0xFF9E9E9E) : const Color(0xFF6B7280);
    final dividerColor  = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE5E7EB);

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Header ──────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.fromLTRB(24.w, 60.h, 24.w, 32.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40.w,
                      height: 40.h,
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                            blurRadius: 8.r,
                            offset: Offset(0, 2.h),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16.r,
                        color: textPrimary,
                      ),
                    ),
                  ),
                  SizedBox(height: 28.h),

                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      'LEGAL',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                        color: accentColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),

                  Text(
                    'Privacy Policy &\nData Protection',
                    style: TextStyle(
                      fontSize: 30.sp,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                      color: textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'How we collect, use, and protect your information.',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: textSecondary,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 24.h),

                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: dividerColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.access_time_rounded, size: 13.r, color: textSecondary),
                        SizedBox(width: 6.w),
                        Text(
                          'Last updated: May 2026',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Policy Sections ──────────────────────────
          SliverPadding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 60.h),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final section = privacyPolicyData[index];
                  final isLast  = index == privacyPolicyData.length - 1;

                  return _PolicySection(
                    index: index,
                    title: section['title'] ?? '',
                    content: section['content'] ?? '',
                    isLast: isLast,
                    cardColor: cardColor,
                    accentColor: accentColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    dividerColor: dividerColor,
                    isDark: isDark,
                  );
                },
                childCount: privacyPolicyData.length,
              ),
            ),
          ),

          // ── Footer ──────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 48.h),
              child: Container(
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: accentColor.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40.w,
                      height: 40.h,
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.shield_rounded,
                        color: Colors.white,
                        size: 20.r,
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your data is protected',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            'End-to-end encrypted & never sold.',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Individual section widget ────────────────────
class _PolicySection extends StatelessWidget {
  final int index;
  final String title;
  final String content;
  final bool isLast;
  final Color cardColor;
  final Color accentColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color dividerColor;
  final bool isDark;

  const _PolicySection({
    required this.index,
    required this.title,
    required this.content,
    required this.isLast,
    required this.cardColor,
    required this.accentColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.dividerColor,
    required this.isDark,
  });

  IconData get _icon {
    switch (index) {
      case 0: return Icons.info_outline_rounded;
      case 1: return Icons.person_outline_rounded;
      case 2: return Icons.tune_rounded;
      case 3: return Icons.handshake_outlined;
      case 4: return Icons.lock_outline_rounded;
      case 5: return Icons.verified_user_outlined;
      case 6: return Icons.edit_note_rounded;
      default: return Icons.article_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Timeline column ──
          Column(
            children: [
              Container(
                width: 36.w,
                height: 36.h,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(10.r),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.3),
                      blurRadius: 8.r,
                      offset: Offset(0, 3.h),
                    ),
                  ],
                ),
                child: Icon(_icon, color: Colors.white, size: 17.r),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2.w,
                    margin: EdgeInsets.symmetric(vertical: 4.h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          accentColor.withOpacity(0.4),
                          accentColor.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(width: 14.w),

          // ── Content card ──
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16.h),
              child: Container(
                padding: EdgeInsets.all(18.r),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: dividerColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                      blurRadius: 8.r,
                      offset: Offset(0, 2.h),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      content,
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        color: textSecondary,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
