import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';
import 'dart:math';

import '../../core/utils/emergency_helper.dart'; // Import Helper
import '../../services/localization_service.dart';
import '../../widgets/custom_app_bar.dart';
import './widgets/hospital_card_widget.dart';

/// Model class for hospital data
class Hospital {
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  double? distance;

  Hospital({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.distance,
  });
}

class NearbyGovernmentHospitalsScreen extends StatefulWidget {
  const NearbyGovernmentHospitalsScreen({super.key});

  @override
  State<NearbyGovernmentHospitalsScreen> createState() =>
      _NearbyGovernmentHospitalsScreenState();
}

class _NearbyGovernmentHospitalsScreenState
    extends State<NearbyGovernmentHospitalsScreen> {
  bool _isLoading = true;
  List<Hospital> _hospitals = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHospitals();
    LocalizationService().currentLanguage.addListener(_onLanguageChange);
  }

  @override
  void dispose() {
    LocalizationService().currentLanguage.removeListener(_onLanguageChange);
    super.dispose();
  }

  void _onLanguageChange() {
    if (mounted) {
      setState(() {
        // UI rebuild triggers translations
      });
    }
  }

  String _t(String text) => LocalizationService().translateSync(text);

  Future<void> _loadHospitals() async {
    try {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // 1. Request Location Permission
      final permission = await Permission.location.request();
      if (!permission.isGranted) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Location permission is required to find nearby hospitals.';
        });
        return;
      }

      // 2. Get User Location
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorMessage = 'Location services are disabled. Please enable them.';
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // 3. Load CSV Data
      final csvString = await rootBundle.loadString('assets/hospital_directory.csv');
      
      // 4. Parse CSV in Background Isolate
      final allHospitals = await compute(_parseHospitalsInIsolate, csvString);

      // 5. Calculate Distances & Filter
      final nearbyHospitals = <Hospital>[];
      for (var hospital in allHospitals) {
        final dist = _calculateDistance(
          position.latitude,
          position.longitude,
          hospital.latitude,
          hospital.longitude,
        );
        hospital.distance = dist;

        // Strict 10km filter
        if (dist <= 10.0) {
          nearbyHospitals.add(hospital);
        }
      }

      // 6. Sort by nearest
      nearbyHospitals.sort((a, b) => a.distance!.compareTo(b.distance!));

      if (!mounted) return;
      setState(() {
        _hospitals = nearbyHospitals;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading hospitals: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load hospital data. Please try again.';
      });
    }
  }

  /// Haversine formula for distance calculation (returns km)
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // Math.PI / 180
    final c = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(c)); // 2 * R; R = 6371 km
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: _t('Nearby Government Hospitals'),
        showBackButton: true,
        centerTitle: true,
        actions: [
            // Static Emergency Call Button (108)
            IconButton(
              onPressed: () => EmergencyHelper.showEmergencyDialog(context),
              icon: const Icon(Icons.phone_in_talk),
              color: const Color(0xFFD32F2F), // Emergency Red
              iconSize: 28,
              tooltip: _t('Emergency Helpline'),
              padding: const EdgeInsets.all(12),
            ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? _buildLoadingState(theme)
            : _errorMessage != null
                ? _buildErrorState(theme)
                : _buildHospitalList(theme),
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Color(0xFFD32F2F),
            strokeWidth: 3,
          ),
          SizedBox(height: 3.h),
          Text(
            _t('Finding hospitals near you...'),
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(5.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 20.w, color: const Color(0xFFD32F2F)),
            SizedBox(height: 3.h),
            Text(
              _t(_errorMessage ?? 'Failed to load hospital data. Please try again.'),
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            SizedBox(
              width: 60.w,
              height: 6.h,
              child: ElevatedButton(
                onPressed: _loadHospitals,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD32F2F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(_t('Try Again')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHospitalList(ThemeData theme) {
    if (_hospitals.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(5.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_off,
                size: 20.w,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              SizedBox(height: 3.h),
              Text(
                _t('No government hospitals found within 10km.'),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Container(
          width: 90.w,
          margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: const Color(0xFFD32F2F).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFD32F2F), width: 1),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: const Color(0xFFD32F2F), size: 6.w),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  '${_t('Found')} ${_hospitals.length} ${_t('hospitals within 10km')}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFFD32F2F),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
             
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
            itemCount: _hospitals.length,
            itemBuilder: (context, index) {
              return HospitalCardWidget(hospital: _hospitals[index]);
            },
          ),
        ),
      ],
    );
  }
}

/// Top-level function for Isolate
/// Parses RAW CSV string into List<Hospital>
List<Hospital> _parseHospitalsInIsolate(String csvString) {
  final List<Hospital> hospitals = [];
  
  // Handling universal newlines
  final lines = csvString.split(RegExp(r'\r\n|\r|\n'));
  
  if (lines.isEmpty) return hospitals;

  // Header detection
  final headerLine = lines.first;
  final headers = headerLine.split(',');
  
  // Find column indices
  int nameIndex = -1;
  int coordIndex = -1;
  int addressIndex = -1;
  int stateIndex = -1;
  int districtIndex = -1;
  int pincodeIndex = -1;

  for (int i = 0; i < headers.length; i++) {
    final h = headers[i].trim().toLowerCase();
    if (h.contains('hospital_name')) nameIndex = i;
    else if (h.contains('location_coordinates')) coordIndex = i;
    else if (h.contains('address_original_first_line')) addressIndex = i;
    else if (h == 'state') stateIndex = i;
    else if (h == 'district') districtIndex = i;
    else if (h == 'pincode') pincodeIndex = i;
  }

  // Fallback: Name=1, Coords=Last? We'll rely on finding them.
  if (nameIndex == -1 || coordIndex == -1) {
    return hospitals; 
  }

  for (int i = 1; i < lines.length; i++) {
    final line = lines[i].trim();
    if (line.isEmpty) continue;

    final parts = _splitCsvLine(line);
    
    if (parts.length <= max(nameIndex, coordIndex)) continue;

    try {
      final name = parts[nameIndex].trim();
      final coordString = parts[coordIndex].trim().replaceAll('"', '');
      
      final coords = coordString.split(',');
      if (coords.length < 2) continue;
      
      final lat = double.tryParse(coords[0].trim());
      final long = double.tryParse(coords[1].trim());
      
      if (lat == null || long == null) continue;
      if (lat == 0 && long == 0) continue;

      // Construct Address
      String address = '';
      if (addressIndex != -1 && parts.length > addressIndex) address += parts[addressIndex];
      if (districtIndex != -1 && parts.length > districtIndex) address += ', ${parts[districtIndex]}';
      if (stateIndex != -1 && parts.length > stateIndex) address += ', ${parts[stateIndex]}';
      if (pincodeIndex != -1 && parts.length > pincodeIndex) address += ' - ${parts[pincodeIndex]}';
      
      address = address.replaceAll(RegExp(r'^, | , |,$'), '').trim();
      if (address.isEmpty) address = 'Unknown Address';

      hospitals.add(Hospital(
        name: name,
        address: address,
        latitude: lat,
        longitude: long,
      ));
    } catch (e) {
      continue;
    }
  }

  return hospitals;
}

/// Helper to split CSV line respecting quotes
List<String> _splitCsvLine(String line) {
  final List<String> values = [];
  bool inQuote = false;
  StringBuffer currentValue = StringBuffer();

  for (int i = 0; i < line.length; i++) {
    final char = line[i];
    
    if (char == '"') {
      inQuote = !inQuote;
    } else if (char == ',' && !inQuote) {
      values.add(currentValue.toString());
      currentValue.clear();
    } else {
      currentValue.write(char);
    }
  }
  values.add(currentValue.toString());
  return values;
}
