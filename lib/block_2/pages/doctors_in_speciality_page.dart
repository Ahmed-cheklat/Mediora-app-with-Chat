import 'package:flutter/material.dart';
import 'package:mediora/Network/networkServices.dart';
import 'package:mediora/block_2/pages/doctor_page.dart';
import 'package:mediora/block_2/tools/doctor_card.dart';

class DoctorsInSpeciality extends StatefulWidget {
  final String specialtyName;

  const DoctorsInSpeciality({super.key, required this.specialtyName});

  @override
  State<DoctorsInSpeciality> createState() => _DoctorsInSpecialityState();
}

class _DoctorsInSpecialityState extends State<DoctorsInSpeciality> {
  static const int _pageSize = 10;

  final List<dynamic> _doctors = [];
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;
  bool _isLoadingDoctor = false;
  bool _hasMore = true;
  int _skip = 0;

  @override
  void initState() {
    super.initState();
    _fetchMore();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
          !_isLoading &&
          _hasMore) {
        _fetchMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchMore() async {
    setState(() => _isLoading = true);

    final result = await AppointementService().fetchDoctors(
      specialty: widget.specialtyName,
      skip: _skip,
      limit: _pageSize,
    );

    setState(() {
      _isLoading = false;
      if (result.isEmpty) {
        _hasMore = false;
      } else {
        _doctors.addAll(result);
        _skip += result.length;
        if (result.length < _pageSize) _hasMore = false;
      }
    });
  }

  String _cleanString(dynamic value) {
    if (value == null || value == 'null') return '';
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2463EB)),
        ),
        title: Text(
          widget.specialtyName,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              SearchForDoctorInSpeciality(
                onSearch: (firstName, lastName) {
                  print('firstName: $firstName, lastName: $lastName');
                },
              ),
              Expanded(
                child: _doctors.isEmpty && !_isLoading
                    ? const Center(
                        child: Text('No doctors found for this specialty.'),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: _doctors.length + (_hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _doctors.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          final doctor = _doctors[index];

                          final firstName = _cleanString(doctor['first_name']);
                          final lastName = _cleanString(doctor['last_name']);
                          String fullName = 'Dr. $firstName $lastName'.trim();
                          if (fullName == 'Dr.') fullName = 'Dr.';

                          final specialty = _cleanString(doctor['speciality']);
                          final networkImage = _cleanString(doctor['picture']);
                          final validNetworkImage =
                              networkImage.isNotEmpty ? networkImage : null;

                          return DoctorCard(
                            fullName: fullName,
                            specialty: specialty,
                            networkImage: validNetworkImage,
                            onTap: () async {
                              if (_isLoadingDoctor) return;
                              setState(() => _isLoadingDoctor = true);

                              final fullDoctor = await AppointementService()
                                  .getDoctor(id: doctor['id'].toString());
                              final allServices = await AppointementService()
                                  .getServices(id: doctor['id'].toString());

                              if (mounted) {
                                setState(() => _isLoadingDoctor = false);
                                if (fullDoctor != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DoctorPage(
                                        doctor: fullDoctor,
                                        services: allServices,
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                          );
                        },
                      ),
              ),
            ],
          ),

          // Full page loading overlay
          if (_isLoadingDoctor)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF2463EB),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class SearchForDoctorInSpeciality extends StatefulWidget {
  final Function(String firstName, String? lastName) onSearch;

  const SearchForDoctorInSpeciality({super.key, required this.onSearch});

  @override
  State<SearchForDoctorInSpeciality> createState() =>
      _SearchForDoctorInSpecialityState();
}

class _SearchForDoctorInSpecialityState
    extends State<SearchForDoctorInSpeciality> {
  final TextEditingController _controller = TextEditingController();

  void _onSubmitted(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;

    final parts = trimmed.split(RegExp(r'\s+'));
    final firstName = _capitalize(parts[0]);
    final lastName = parts.length > 1 ? _capitalize(parts[1]) : null;

    widget.onSearch(firstName, lastName);
  }

  String _capitalize(String word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fieldFill =
        isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF3F4F6);
    final textColor = isDark ? Colors.white : Colors.black;

    return TextFormField(
      controller: _controller,
      cursorColor: const Color(0xFF2463EB),
      style: TextStyle(color: textColor),
      textInputAction: TextInputAction.search,
      onFieldSubmitted: _onSubmitted,
      decoration: InputDecoration(
        hintText: "Search for a doctor...",
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: const Icon(Icons.search, color: Color(0xFF2463EB)),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () {
                  _controller.clear();
                  setState(() {});
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
          borderSide: const BorderSide(color: Color(0xFF2463EB), width: 1.5),
        ),
      ),
      onChanged: (_) => setState(() {}),
    );
  }
}