import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

final List<Map<String, String>> faqs = [
  {
    "question": "How do I book an appointment on Mediora?",
    "answer": "Find your preferred doctor, open their profile to view their information and available services, and simply select an available date and time slot to book your appointment."
  },
  {
    "question": "Can I see what services a doctor offers and how much they cost?",
    "answer": "Yes! Every doctor's profile displays a clear list of the services they provide along with their prices so you are fully informed beforehand. You don't need to select a service when booking, as the actual services are managed directly by the doctor."
  },
  {
    "question": "How can I search for a particular doctor or specialty?",
    "answer": "Use the search bar on the home screen to instantly filter and find doctors by their name or medical specialty."
  },
  {
    "question": "Can I chat with a doctor directly through the app?",
    "answer": "Yes! Mediora features a built-in messaging system. Simply visit any doctor's profile page and tap the chat icon to start a direct conversation."
  },
  {
    "question": "How do I leave feedback or a review for a doctor?",
    "answer": "Once your appointment is completed, Mediora will provide an option to rate your experience and write a review directly on the doctor's profile."
  },
  {
    "question": "Can I see ratings and reviews from other patients before choosing a doctor?",
    "answer": "Yes, transparency is important to us. You can read honest feedback, patient experiences, and overall ratings near the bottom of any doctor's profile page."
  },
  {
    "question": "Where can I see my active chats and message history with doctors?",
    "answer": "All your ongoing and past conversations are securely saved and can be accessed at any time via the 'Chats' tab in the app's main navigation bar."
  },
  {
    "question": "Where can I view the details of my upcoming appointments?",
    "answer": "Navigate to the 'Appointments' section to view your upcoming schedule, including the date, time, and doctor information."
  }
];

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor         = isDark ? const Color(0xFF121212) : const Color(0xFFF2F2F7);
    final cardColor       = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final accentColor     = const Color(0xFF2463EB);
    final textPrimary     = isDark ? Colors.white : const Color(0xFF0D1B2A);
    final textSecondary   = isDark ? const Color(0xFF9E9E9E) : const Color(0xFF6B7280);
    final dividerColor    = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE5E7EB);

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
                            offset: Offset(0.w, 2.h),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16.sp,
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
                      'HELP CENTER',
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
                    'Frequently Asked\nQuestions',
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
                    'Everything you need to know about using Mediora.',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── FAQ List ─────────────────────────────────
          SliverPadding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 40.h),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final faq = faqs[index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: _FaqCard(
                      index: index + 1,
                      question: faq['question'] ?? '',
                      answer: faq['answer'] ?? '',
                      cardColor: cardColor,
                      accentColor: accentColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      dividerColor: dividerColor,
                      isDark: isDark,
                    ),
                  );
                },
                childCount: faqs.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqCard extends StatefulWidget {
  final int index;
  final String question;
  final String answer;
  final Color cardColor;
  final Color accentColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color dividerColor;
  final bool isDark;

  const _FaqCard({
    required this.index,
    required this.question,
    required this.answer,
    required this.cardColor,
    required this.accentColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.dividerColor,
    required this.isDark,
  });

  @override
  State<_FaqCard> createState() => _FaqCardState();
}

class _FaqCardState extends State<_FaqCard> with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
    _rotateAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: _expanded
            ? widget.accentColor.withOpacity(widget.isDark ? 0.12 : 0.05)
            : widget.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: _expanded
              ? widget.accentColor.withOpacity(0.3)
              : widget.dividerColor,
          width: 1.5.w,
        ),
        boxShadow: _expanded
            ? [
                BoxShadow(
                  color: widget.accentColor.withOpacity(0.08),
                  blurRadius: 16.r,
                  offset: Offset(0.w, 4.h),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(widget.isDark ? 0.2 : 0.04),
                  blurRadius: 8.r,
                  offset: Offset(0.w, 2.h),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _toggle,
          borderRadius: BorderRadius.circular(16.r),
          splashColor: widget.accentColor.withOpacity(0.08),
          highlightColor: Colors.transparent,
          child: Padding(
            padding: EdgeInsets.all(18.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Question row ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28.w,
                      height: 28.h,
                      decoration: BoxDecoration(
                        color: _expanded
                            ? widget.accentColor
                            : widget.accentColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${widget.index}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: _expanded ? Colors.white : widget.accentColor,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),

                    Expanded(
                      child: Text(
                        widget.question,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: widget.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),

                    RotationTransition(
                      turns: _rotateAnimation,
                      child: Container(
                        width: 28.w,
                        height: 28.h,
                        decoration: BoxDecoration(
                          color: _expanded
                              ? widget.accentColor
                              : widget.accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 18.sp,
                          color: _expanded ? Colors.white : widget.accentColor,
                        ),
                      ),
                    ),
                  ],
                ),

                // ── Answer (animated) ──
                SizeTransition(
                  sizeFactor: _expandAnimation,
                  child: FadeTransition(
                    opacity: _expandAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 14.h),
                        Container(
                          height: 1.h,
                          color: widget.accentColor.withOpacity(0.15),
                        ),
                        SizedBox(height: 14.h),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 3.w,
                              height: 60.h,
                              decoration: BoxDecoration(
                                color: widget.accentColor,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                widget.answer,
                                style: TextStyle(
                                  fontSize: 13.5.sp,
                                  color: widget.textSecondary,
                                  height: 1.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
