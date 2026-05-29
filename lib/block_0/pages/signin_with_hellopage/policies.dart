import 'package:flutter/material.dart';

final List<Map<String, String>> privacyPolicyData = [
  {
    "title": "Introduction",
    "content":
        "Your privacy and the security of your health data are our highest priorities. This Privacy Policy explains how our Telemedicine Application collects, uses, and safeguards your information when you use our services. Last updated: May 2026."
  },
  {
    "title": "1. Information We Collect",
    "content":
        "We collect personal identification (full name, email, phone number), medical & appointment history data, and basic device usage information to optimize your user experience."
  },
  {
    "title": "2. How We Use Your Information",
    "content":
        "We use your data strictly to manage your medical appointments on your home screen, enable direct communication with clinics via email/phone links, and automatically apply system themes like Light or Dark mode."
  },
  {
    "title": "3. Data Sharing and Disclosure",
    "content":
        "We maintain a strict confidentiality rule. We never sell, rent, or trade your personal or medical data with third-party advertisers. Data is only shared with the specific medical providers you choose to book appointments with."
  },
  {
    "title": "4. Data Security & Storage",
    "content":
        "We implement industry-standard security measures. All data transmitted between this mobile application and our backend cloud servers is fully encrypted, and profile data is stored in secure databases."
  },
  {
    "title": "5. Your Rights",
    "content":
        "You maintain complete control over your information. At any point through the application settings, you have the right to access your stored personal data or request the permanent deletion of your account and appointment history."
  },
  {
    "title": "6. Changes to This Policy",
    "content":
        "We reserve the right to update this Privacy Policy as our app introduces new features or complies with changing healthcare regulations. We encourage users to review this section periodically."
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
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // back button
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // pill label
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'LEGAL',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                        color: accentColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    'Privacy Policy &\nData Protection',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                      color: textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'How we collect, use, and protect your information.',
                    style: TextStyle(
                      fontSize: 14,
                      color: textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // last updated chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: dividerColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.access_time_rounded, size: 13, color: textSecondary),
                        const SizedBox(width: 6),
                        Text(
                          'Last updated: May 2026',
                          style: TextStyle(
                            fontSize: 12,
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
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 60),
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
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 48),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: accentColor.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.shield_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your data is protected',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'End-to-end encrypted & never sold.',
                            style: TextStyle(
                              fontSize: 12,
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

  // icon per section
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
              // dot
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(_icon, color: Colors.white, size: 17),
              ),
              // line
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          accentColor.withOpacity(0.4),
                          accentColor.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),

          // ── Content card ──
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: dividerColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      content,
                      style: TextStyle(
                        fontSize: 13.5,
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