import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:medisync_doctor/core/router/app_router.dart';
import 'package:medisync_doctor/core/theme/app_colors.dart';
import 'package:medisync_doctor/core/utils/validators.dart';
import 'package:medisync_doctor/core/widgets/app_button.dart';
import 'package:medisync_doctor/core/widgets/app_text_field.dart';
import 'package:medisync_doctor/core/widgets/loading_overlay.dart';
import 'package:medisync_doctor/features/auth_onboarding/presentation/providers/auth_provider.dart';
import 'package:medisync_doctor/features/auth_onboarding/presentation/providers/clinic_provider.dart';
import 'package:medisync_doctor/features/auth_onboarding/presentation/widgets/auth_form_card.dart';

class ClinicCreationScreen extends ConsumerStatefulWidget {
  const ClinicCreationScreen({super.key});

  @override
  ConsumerState<ClinicCreationScreen> createState() =>
      _ClinicCreationScreenState();
}

class _ClinicCreationScreenState
    extends ConsumerState<ClinicCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();
  
  bool _isLocating = false;
  bool _isVerifyingAddress = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    super.dispose();
  }

  /// NEW: Resolves Coordinates from a manually typed address (Forward Geocoding)
  Future<void> _verifyAddress() async {
    final address = _addressCtrl.text.trim();
    if (address.isEmpty || address.length < 10) return;

    setState(() => _isVerifyingAddress = true);
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        _latCtrl.text = loc.latitude.toString();
        _lngCtrl.text = loc.longitude.toString();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Address verified and mapped! ✅'),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Geocoding error: $e');
      // If forward geocoding fails, we don't block the user, 
      // but they might need to enter coords manually or use GPS.
    } finally {
      if (mounted) setState(() => _isVerifyingAddress = false);
    }
  }

  Future<void> _fetchCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw 'Location services are disabled.';

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw 'Location permissions are denied';
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _latCtrl.text = position.latitude.toString();
      _lngCtrl.text = position.longitude.toString();

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        _addressCtrl.text = [
          if (p.name != null && p.name != p.street) p.name,
          p.street, p.subLocality, p.locality, p.administrativeArea, p.postalCode, p.country,
        ].where((e) => e != null && e.isNotEmpty).join(', ');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  Future<void> _createClinic() async {
    // Before creating, if coords are empty but address exists, try one last verify
    if (_latCtrl.text.isEmpty && _addressCtrl.text.isNotEmpty) {
      await _verifyAddress();
    }

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    await ref.read(clinicNotifierProvider.notifier).createClinic(
          doctorId: user.uid,
          clinicName: _nameCtrl.text.trim(),
          address: _addressCtrl.text.trim(),
          latitude: double.tryParse(_latCtrl.text.trim()) ?? 0.0,
          longitude: double.tryParse(_lngCtrl.text.trim()) ?? 0.0,
        );

    if (!mounted) return;
    final state = ref.read(clinicNotifierProvider);
    
    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.error.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppColors.error,
        ),
      );
    } else {
      context.go(AppRoutes.documentUpload);
    }
  }

  @override
  Widget build(BuildContext context) {
    final clinicState = ref.watch(clinicNotifierProvider);
    final isLoading = clinicState.isLoading || _isLocating || _isVerifyingAddress;

    return LoadingOverlay(
      isLoading: isLoading,
      message: _isVerifyingAddress ? 'Verifying address...' : 'Processing...',
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 12),
                  const GradientHeading('Set Up\nYour Clinic 🏥'),
                  const SizedBox(height: 32),
                  AuthFormCard(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppTextField(
                            controller: _nameCtrl,
                            label: 'Clinic Name',
                            hint: 'MediSync City Clinic',
                            prefixIcon: const Icon(Icons.local_hospital_outlined, size: 18),
                            validator: Validators.clinicName,
                          ),
                          const SizedBox(height: 14),
                          Focus(
                            onFocusChange: (hasFocus) {
                              if (!hasFocus) _verifyAddress(); // Auto-verify when field loses focus
                            },
                            child: AppTextField(
                              controller: _addressCtrl,
                              label: 'Address',
                              hint: '42 Main Street, Mumbai, Maharashtra',
                              prefixIcon: const Icon(Icons.location_on_outlined, size: 18),
                              validator: Validators.address,
                              maxLines: 2,
                              keyboardType: TextInputType.multiline,
                              textInputAction: TextInputAction.done,
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _isLocating ? null : _fetchCurrentLocation,
                            icon: const Icon(Icons.my_location_rounded, size: 18),
                            label: const Text('Use Current Location'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 44),
                              foregroundColor: AppColors.brandCyan,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: AppTextField(
                                  controller: _latCtrl,
                                  label: 'Latitude',
                                  hint: 'Lat',
                                  enabled: false, // Protected, filled by geocoding
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AppTextField(
                                  controller: _lngCtrl,
                                  label: 'Longitude',
                                  hint: 'Lng',
                                  enabled: false, // Protected, filled by geocoding
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          AppButton(
                            label: 'Create Clinic',
                            onPressed: _createClinic,
                            isLoading: isLoading,
                            icon: const Icon(Icons.add_business_rounded, size: 18),
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
      ),
    );
  }
}
