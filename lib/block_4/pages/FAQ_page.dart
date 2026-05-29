import 'package:flutter/material.dart';

final List<Map<String, String>> faqs = [
  {
    "question": "How do I book an appointment with a specialist?",
    "answer": "Go to the 'Find a Specialist' screen, choose a medical specialty, tap on your preferred doctor to view their profile, and click the 'Book Appointment' button."
  },
  {
    "question": "How much does an appointment consultation cost?",
    "answer": "The price of the visit varies depending on the doctor and their specialty. You can view the exact price clearly displayed on each doctor's profile page before booking."
  },
  {
    "question": "Can I see the physical location of the doctor's clinic?",
    "answer": "Yes! Every doctor's profile page contains photos of their local clinic and a direct link to open their exact location on Google Maps."
  },
  {
    "question": "Where can I view my scheduled appointments?",
    "answer": "All your active and upcoming appointments are displayed directly on your Home screen. If you don't have any, the app will display helpful daily health tips instead."
  },
  {
    "question": "How can I contact a doctor directly?",
    "answer": "On the doctor's profile page, you will find dedicated quick-action buttons to send an email or make a direct phone call to their clinic."
  },
  {
    "question": "What should I do if I am experiencing a severe medical emergency?",
    "answer": "This application is for scheduled consultations. In case of a life-threatening emergency, please use the 'Emergency Medicine' specialty tag to contact urgent care, or call your local emergency number immediately."
  },
  {
    "question": "Is my personal medical data safe on this application?",
    "answer": "Absolutely. Your data privacy is our highest priority. All medical records, profile information, and appointment history are fully encrypted and securely stored."
  },
  {
    "question": "Can I use this application in Dark Mode?",
    "answer": "Yes! The entire application utilizes dynamic semantic themes and will automatically match your phone's system preferences for both Light Mode and Dark Mode."
  },
  {
    "question": "How do I search for a specific medical condition or department?",
    "answer": "Use the search bar at the top of the 'Find a Specialist' screen. Simply type the name of the specialty (like Cardiology or Pediatrics) to instantly filter the list."
  },
  {
    "question": "What happens if I need to cancel an appointment?",
    "answer": "You can select the active appointment from your Home page and tap 'Cancel'. We recommend canceling at least 24 hours in advance out of respect for the doctor's schedule."
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
                      'HELP CENTER',
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
                    'Frequently Asked\nQuestions',
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
                    'Everything you need to know about using Mediora.',
                    style: TextStyle(
                      fontSize: 14,
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
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final faq = faqs[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _expanded
              ? widget.accentColor.withOpacity(0.3)
              : widget.dividerColor,
          width: 1.5,
        ),
        boxShadow: _expanded
            ? [
                BoxShadow(
                  color: widget.accentColor.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(widget.isDark ? 0.2 : 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _toggle,
          borderRadius: BorderRadius.circular(16),
          splashColor: widget.accentColor.withOpacity(0.08),
          highlightColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Question row ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // index number badge
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: _expanded
                            ? widget.accentColor
                            : widget.accentColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${widget.index}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _expanded ? Colors.white : widget.accentColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // question text
                    Expanded(
                      child: Text(
                        widget.question,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: widget.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // animated chevron
                    RotationTransition(
                      turns: _rotateAnimation,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: _expanded
                              ? widget.accentColor
                              : widget.accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 18,
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
                        const SizedBox(height: 14),
                        Container(
                          height: 1,
                          color: widget.accentColor.withOpacity(0.15),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 3,
                              height: 60,
                              decoration: BoxDecoration(
                                color: widget.accentColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.answer,
                                style: TextStyle(
                                  fontSize: 13.5,
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