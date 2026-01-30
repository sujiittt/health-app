import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import './symptom_card_widget.dart';

/// Grid layout widget for displaying symptom cards
/// Implements 2-column responsive grid with proper spacing
class SymptomsGridWidget extends StatelessWidget {
  final List<Map<String, dynamic>> symptoms;
  final Set<String> selectedSymptoms;
  final Function(String) onSymptomTap;

  const SymptomsGridWidget({
    super.key,
    required this.symptoms,
    required this.selectedSymptoms,
    required this.onSymptomTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 3 columns
        crossAxisSpacing: 3.w, // Slightly reduced spacing
        mainAxisSpacing: 2.h,
        childAspectRatio: 0.75, // Taller cards for better visibility
      ),
      itemCount: symptoms.length,
      itemBuilder: (context, index) {
        final symptom = symptoms[index];
        final symptomId = symptom['id'] as String;
        final isSelected = selectedSymptoms.contains(symptomId);

        return SymptomCardWidget(
          symptomName: symptom['name'] as String,
          iconName: symptom['icon'] as String,
          isSelected: isSelected,
          onTap: () => onSymptomTap(symptomId),
        );
      },
    );
  }
}
