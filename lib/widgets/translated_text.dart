import 'package:flutter/material.dart';
import '../services/localization_service.dart';

/// A widget that displays text which automatically translates based on the selected language.
/// It uses LocalizationService to fetch translations (cached or via Gemini).
class TrText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final String? context; // Helps AI understand the context (e.g. "Button", "Title")

  const TrText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.context,
  });

  @override
  State<TrText> createState() => _TrTextState();
}

class _TrTextState extends State<TrText> {
  String? _translatedText;
  final LocalizationService _localizationService = LocalizationService();

  @override
  void initState() {
    super.initState();
    _updateTranslation();
    _localizationService.currentLanguage.addListener(_onLanguageChanged);
  }

  @override
  void didUpdateWidget(TrText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _updateTranslation();
    }
  }

  @override
  void dispose() {
    _localizationService.currentLanguage.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    _updateTranslation();
  }

  Future<void> _updateTranslation() async {
    if (!mounted) return;
    
    // Optimistic UI: If English, show immediately
    if (_localizationService.langCode == 'en') {
      if (_translatedText != widget.text) {
         setState(() => _translatedText = widget.text);
      }
      return;
    }

    // Fetch translation
    final translated = await _localizationService.translate(
      widget.text, 
      context: widget.context
    );
    
    if (mounted && _translatedText != translated) {
      setState(() => _translatedText = translated);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show translated text if available, otherwise original (or shimmer if strictly desired, but original is better UX for fallback)
    return Text(
      _translatedText ?? widget.text,
      style: widget.style,
      textAlign: widget.textAlign,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
    );
  }
}
