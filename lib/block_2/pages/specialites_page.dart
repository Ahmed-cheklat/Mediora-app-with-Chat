import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mediora/block_1/pages%20/homePage.dart';
import 'package:mediora/block_2/pages/doctors_in_speciality_page.dart';
import 'package:mediora/block_2/tools/speciality_card.dart';

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({super.key});

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  List<Map<String, dynamic>> _displayedSpecialties = specialties;

  void _onSearchSelected(Map<String, dynamic> selected) {
    setState(() {
      _displayedSpecialties = [selected];
    });
  }

  void _onSearchCleared() {
    setState(() {
      _displayedSpecialties = specialties;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => Homepage()),
              (route) => false,
            );
          },
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2463EB)),
        ),
        title: Text(
          'Find a Specialist',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: SearchForDoctorField(
              specialties: specialties,
              onSelected: _onSearchSelected,
              onCleared: _onSearchCleared,
            ),
          ),
          10.verticalSpace,
          ..._displayedSpecialties.map(
            (specialty) => SpecialityCard(
              specialities: specialty,
              function: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DoctorsInSpeciality(
                      specialtyName: specialty['specialty'],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

//----------------------------------------

class SearchForDoctorField extends StatefulWidget {
  final List<Map<String, dynamic>> specialties;
  final Function(Map<String, dynamic>) onSelected;
  final VoidCallback onCleared;

  const SearchForDoctorField({
    super.key,
    required this.specialties,
    required this.onSelected,
    required this.onCleared,
  });

  @override
  State<SearchForDoctorField> createState() => _SearchForDoctorFieldState();
}

class _SearchForDoctorFieldState extends State<SearchForDoctorField> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _filtered = [];
  bool _showDropdown = false;

  void _onChanged(String value) {
    setState(() {
      if (value.isEmpty) {
        _filtered = [];
        _showDropdown = false;
      } else {
        _filtered = widget.specialties
            .where(
              (s) => (s['specialty'] as String).toLowerCase().startsWith(
                value.toLowerCase(),
              ),
            )
            .toList();
        _showDropdown = _filtered.isNotEmpty;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fieldFill = isDark
        ? const Color(0xFF1E1E1E)
        : const Color(0xFFF3F4F6);
    final dropdownBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final dividerColor = isDark
        ? const Color(0xFF2A2A2A)
        : const Color(0xFFEEEEEE);

    return Column(
      children: [
        TextFormField(
          controller: _controller,
          cursorColor: const Color(0xFF2463EB),
          style: TextStyle(color: textColor),
          onChanged: _onChanged,
          decoration: InputDecoration(
            hintText: "Search for a speciality...",
            hintStyle: const TextStyle(color: Colors.grey),
            prefixIcon: const Icon(Icons.search, color: Color(0xFF2463EB)),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () {
                      _controller.clear();
                      _onChanged('');
                      widget.onCleared();
                    },
                  )
                : null,
            filled: true,
            fillColor: fieldFill,
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF2463EB),
                width: 1.5,
              ),
            ),
          ),
        ),
        if (_showDropdown)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: dropdownBg,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Column(
                children: _filtered.asMap().entries.map((entry) {
                  final index = entry.key;
                  final specialty = entry.value;
                  return Column(
                    children: [
                      InkWell(
                        onTap: () {
                          _controller.text = specialty['specialty'];
                          setState(() => _showDropdown = false);
                          widget.onSelected(specialty);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                specialty['icon'],
                                color: const Color(0xFF2463EB),
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                specialty['specialty'],
                                style: TextStyle(
                                  fontSize: 15,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (index < _filtered.length - 1)
                        Divider(height: 1, color: dividerColor),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }
}
