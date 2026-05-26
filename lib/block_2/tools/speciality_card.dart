import 'package:flutter/material.dart';
import 'package:health_icons/health_icons.dart';

final List<Map<String, dynamic>> specialties = [
  {"specialty": "generaliste", "icon": HealthIcons.stethoscopeFilled},
  {"specialty": "gynecology", "icon": HealthIcons.pregnantFilled},
  {"specialty": "cardiology", "icon": HealthIcons.heartCardiogramFilled},
  {"specialty": "general Surgery", "icon": HealthIcons.generalSurgeryFilled},
  {"specialty": "dentistry", "icon": HealthIcons.toothFilled},
  {"specialty": "urology", "icon": HealthIcons.urologyFilled},
  {"specialty": "neurology", "icon": HealthIcons.neurologyFilled},
  {"specialty": "nephrology", "icon": HealthIcons.urologyFilled},
  {"specialty": "oRL", "icon": HealthIcons.earFilled},
  {"specialty": "ophthalmology", "icon": HealthIcons.eyeFilled},
  {"specialty": "endocrinology", "icon": HealthIcons.stomachFilled},
  {"specialty": "dermatology", "icon": HealthIcons.allergiesFilled},
  {"specialty": "pediatric", "icon": HealthIcons.childCareFilled},
  {"specialty": "traumatology", "icon": HealthIcons.orthopaedicsFilled},
  {"specialty": "gastroenterology", "icon": HealthIcons.stomachFilled},
];
class SpecialityCard extends StatelessWidget {
  final Map<String, dynamic> specialities;
  final VoidCallback function; 

  const SpecialityCard({super.key, required this.specialities,required this.function});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: function,
      child: Card(
        child: ListTile(
          leading: Icon(specialities["icon"], color: Color(0xFF2463EB)),
          title: Text(
            specialities['specialty'],
            style: TextStyle(fontSize: 18),
          ),
          trailing: Icon(Icons.arrow_forward_ios, color: Color(0xFF2463EB)),
        ),
      ),
    );
  }
}
