import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

  String _searchQuery = ''; 

  bool _isLoading = false;
  bool _isLoadingDoctor = false;
  bool _hasMore = true;
  int _skip = 0;

  List<dynamic> get _filteredDoctors {
    if (_searchQuery.isEmpty) return _doctors;
    final query = _searchQuery.toLowerCase();
    return _doctors.where((doctor) {
      final first = (doctor['first_name'] ?? '').toString().toLowerCase();
      final last = (doctor['last_name'] ?? '').toString().toLowerCase();
      return first.startsWith(query) || last.startsWith(query);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _fetchMore();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100.w &&
          !_isLoading &&
          _hasMore &&
          _searchQuery.isEmpty) {
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
    final filtered = _filteredDoctors;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2463EB)),
        ),
        title: Text(
          widget.specialtyName,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              SearchForDoctorInSpeciality(
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
                onCleared: () {
                  setState(() => _searchQuery = '');
                },
              ),
              Expanded(
                child: filtered.isEmpty && !_isLoading
                    ? const Center(
                        child: Text('No doctors found for this specialty.'),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: filtered.length +
                            (_hasMore && _searchQuery.isEmpty ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == filtered.length) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 24.h),
                              child: const Center(child: CircularProgressIndicator()),
                            );
                          }

                          final doctor = filtered[index];

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

// ----------------------------------------

class SearchForDoctorInSpeciality extends StatefulWidget {
  final Function(String value) onChanged;
  final VoidCallback onCleared;

  const SearchForDoctorInSpeciality({
    super.key,
    required this.onChanged,
    required this.onCleared,
  });

  @override
  State<SearchForDoctorInSpeciality> createState() =>
      _SearchForDoctorInSpecialityState();
}

class _SearchForDoctorInSpecialityState
    extends State<SearchForDoctorInSpeciality> {
  final TextEditingController _controller = TextEditingController();

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

    return Padding(
      padding: EdgeInsets.all(12.0.r),
      child: TextFormField(
        controller: _controller,
        cursorColor: const Color(0xFF2463EB),
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          hintText: "Search by doctor name...",
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF2463EB)),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () {
                    _controller.clear();
                    setState(() {});
                    widget.onCleared();
                  },
                )
              : null,
          filled: true,
          fillColor: fieldFill,
          contentPadding: EdgeInsets.symmetric(vertical: 18.h),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide:
                BorderSide(color: const Color(0xFF2463EB), width: 1.5.w),
          ),
        ),
        onChanged: (value) {
          setState(() {});
          widget.onChanged(value);
        },
      ),
    );
  }
}
