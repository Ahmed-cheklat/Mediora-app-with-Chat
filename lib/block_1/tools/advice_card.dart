import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HealthTips extends StatefulWidget {
  const HealthTips({super.key});

  @override
  State<HealthTips> createState() => _HealthTipsState();
}

class _HealthTipsState extends State<HealthTips> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 240, 253, 244),
      child: Padding(
        padding:  EdgeInsets.all(12.0.r),
        child: ListTile(
          leading: Icon(
            Icons.water_drop,
            color: const Color.fromARGB(255, 0, 91, 25),
          ),
          title: Text(
            'Remember to drink 8 glasses of water today to stay hydrated.',
            style: TextStyle(color: const Color.fromARGB(255, 0, 91, 25),fontSize: 14.sp),
          ),
        ),
      ),
    );
  }
}
