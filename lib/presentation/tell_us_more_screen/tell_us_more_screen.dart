import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../services/gemini_service.dart';
import '../../widgets/translated_text.dart';
import '../../services/localization_service.dart';
import '../../widgets/ai_response_viewer.dart';

class TellUsMoreScreen extends StatefulWidget {
  const TellUsMoreScreen({super.key});

  @override
  State<TellUsMoreScreen> createState() => _TellUsMoreScreenState();
}

class _TellUsMoreScreenState extends State<TellUsMoreScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String _selectedGender = 'Male';
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  final List<String> _chipOptions = [
    'Pain', 'Dizziness', 'Weakness', 'Vomiting', 'Injury', 'Breathing Issue', 'Other'
  ];
  final Set<String> _selectedChips = {};

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    LocalizationService().currentLanguage.addListener(_onLanguageChange);
  }

  @override
  void dispose() {
    LocalizationService().currentLanguage.removeListener(_onLanguageChange);
    _ageController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onLanguageChange() {
    setState(() {});
  }

  void _submitData() async {
    if (!_formKey.currentState!.validate()) return;
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LocalizationService().translateSync('Please describe your problem'))),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final currentLang = LocalizationService().langCode;
      
      // Call backend via GeminiService
      final guidance = await GeminiService().generateGeneralGuidance(
        gender: _selectedGender,
        age: _ageController.text,
        description: _descriptionController.text,
        selectedChips: _selectedChips.toList(),
        language: currentLang,
      );

      if (!mounted) return;
      
      _showGuidanceSheet(guidance);

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LocalizationService().translateSync('Failed to get guidance. Please try again.')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showGuidanceSheet(Map<String, dynamic> guidance) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: Column(
             children: [
               SizedBox(height: 1.h),
               // Drag Handle
               Center(
                child: Container(
                  width: 10.w,
                  height: 5,
                  margin: EdgeInsets.symmetric(vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: controller,
                  child: Column(
                    children: [
                      Text(
                        LocalizationService().translateSync('Guidance'),
                         style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 3.h),
                      
                      // Use shared AI Response Viewer
                      AiResponseViewer(
                        data: guidance,
                      ),

                      SizedBox(height: 3.h),
                      SizedBox(
                        width: double.infinity,
                        height: 6.h,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: TrText('Close'),
                        ),
                      ),
                      SizedBox(height: 4.h),
                    ],
                  ),
                ),
              ),
             ],
           ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, {Color? color}) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        children: [
          Icon(icon, color: color ?? theme.colorScheme.primary, size: 20),
          SizedBox(width: 2.w),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color ?? theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Tell Us More',
        showBackButton: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(4.w),
            children: [
              // Reassurance Message
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.security, color: theme.colorScheme.primary),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: TrText(
                        'This is for preliminary guidance only. We do not provide medical diagnosis. In emergencies, call 108 immediately.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          height: 1.4
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 3.h),

              // Gender Selection
              TrText('Gender', style: theme.textTheme.titleMedium),
              Row(
                children: ['Male', 'Female', 'Other'].map((gender) {
                  return Expanded(
                    child: RadioListTile<String>(
                      title: TrText(gender, style: theme.textTheme.bodyMedium),
                      value: gender,
                      groupValue: _selectedGender,
                      onChanged: (val) => setState(() => _selectedGender = val!),
                      contentPadding: EdgeInsets.zero,
                      activeColor: theme.colorScheme.primary,
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 2.h),

              // Age Input
              TrText('Age', style: theme.textTheme.titleMedium),
              SizedBox(height: 1.h),
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                maxLength: 3,
                decoration: InputDecoration(
                  hintText: LocalizationService().translateSync('Enter age'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return LocalizationService().translateSync('Required');
                  if (int.tryParse(val) == null) return LocalizationService().translateSync('Invalid age');
                  return null;
                },
              ),
              SizedBox(height: 2.h),

              // Symptom Chips
              TrText('Common Symptoms (Optional)', style: theme.textTheme.titleMedium),
              SizedBox(height: 1.h),
              Wrap(
                spacing: 2.w,
                children: _chipOptions.map((chip) {
                  final isSelected = _selectedChips.contains(chip);
                  return FilterChip(
                    label: TrText(chip), // TrText for chips
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) _selectedChips.add(chip);
                        else _selectedChips.remove(chip);
                      });
                    },
                    selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                    checkmarkColor: theme.colorScheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? theme.colorScheme.primary : theme.textTheme.bodyMedium?.color,
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 3.h),

              // Description Input
              TrText('Describe your problem', style: theme.textTheme.titleMedium),
              SizedBox(height: 1.h),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: LocalizationService().translateSync('Type here regarding what you are feeling...'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignLabelWithHint: true,
                ),
              ),
              SizedBox(height: 4.h),

              // Action Button
              SizedBox(
                width: double.infinity,
                height: 6.h,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading 
                    ? const SizedBox(
                        height: 24, 
                        width: 24, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      )
                    : TrText('Get Guidance', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }
}
