import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:medisync_doctor/core/theme/app_colors.dart';
import 'package:medisync_doctor/core/utils/validators.dart';
import 'package:medisync_doctor/core/widgets/app_button.dart';
import 'package:medisync_doctor/core/widgets/app_text_field.dart';
import 'package:medisync_doctor/core/widgets/loading_overlay.dart';
import 'package:medisync_doctor/features/auth_onboarding/presentation/providers/auth_provider.dart';
import 'package:medisync_doctor/features/auth_onboarding/presentation/providers/clinic_provider.dart';
import 'package:medisync_doctor/features/auth_onboarding/presentation/widgets/auth_form_card.dart';

/// Doctor-only screen to create their first (or additional) clinic.
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

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied, we cannot request permissions.';
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _latCtrl.text = position.latitude.toString();
      _lngCtrl.text = position.longitude.toString();

      // Reverse geocode to get address
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final address = [
          if (p.name != null && p.name != p.street) p.name,
          p.street,
          p.subLocality,
          p.locality,
          p.administrativeArea,
          p.postalCode,
          p.country,
        ].where((e) => e != null && e.isNotEmpty).join(', ');
        
        _addressCtrl.text = address;
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
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    await ref.read(clinicNotifierProvider.notifier).createClinic(
          doctorId: user.uid,
          clinicName: _nameCtrl.text.trim(),
          address: _addressCtrl.text.trim(),
          latitude: double.parse(_latCtrl.text.trim()),
          longitude: double.parse(_lngCtrl.text.trim()),
        );

    if (!mounted) return;
    final state = ref.read(clinicNotifierProvider);
    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              state.error.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final clinicState = ref.watch(clinicNotifierProvider);
    final isLoading = clinicState.isLoading || _isLocating;

    return LoadingOverlay(
      isLoading: isLoading,
      message: _isLocating ? 'Fetching precise location...' : 'Creating clinic...',
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Container(
          decoration:
              const BoxDecoration(gradient: AppColors.backgroundGradient),
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
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 12),

                  Text(
                    'Step 2 of 3',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.brandCyan,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                  ).animate().fadeIn(),
                  const SizedBox(height: 8),

                  const GradientHeading('Set Up\nYour Clinic 🏥')
                      .animate(delay: 50.ms)
                      .fadeIn()
                      .slideY(begin: -0.2),
                  const SizedBox(height: 6),
                  Text(
                    'Clinic location is used by patients to find you on the map.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ).animate(delay: 100.ms).fadeIn(),

                  const SizedBox(height: 32),

                  // Clinic form
                  AuthFormCard(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Clinic name
                          AppTextField(
                            controller: _nameCtrl,
                            label: 'Clinic Name',
                            hint: 'MediSync City Clinic',
                            prefixIcon: const Icon(
                                Icons.local_hospital_outlined,
                                size: 18),
                            validator: Validators.clinicName,
                          ),
                          const SizedBox(height: 14),

                          // Address
                          AppTextField(
                            controller: _addressCtrl,
                            label: 'Address',
                            hint: '42 Main Street, Mumbai, Maharashtra',
                            prefixIcon: const Icon(Icons.location_on_outlined,
                                size: 18),
                            validator: Validators.address,
                            maxLines: 2,
                            textInputAction: TextInputAction.newline,
                          ),
                          const SizedBox(height: 12),

                          // NEW: Get location button
                          OutlinedButton.icon(
                            onPressed: _isLocating ? null : _fetchCurrentLocation,
                            icon: const Icon(Icons.my_location_rounded, size: 18),
                            label: const Text('Use Current Location'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 44),
                              side: BorderSide(color: AppColors.brandCyan.withOpacity(0.5)),
                              foregroundColor: AppColors.brandCyan,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Location section header
                          Row(
                            children: [
                              const Icon(
                                Icons.gps_fixed_rounded,
                                size: 16,
                                color: AppColors.brandCyan,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'GPS Coordinates',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      color: AppColors.brandCyan,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Fetched automatically or entered manually.',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textHint,
                                    ),
                          ),
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: AppTextField(
                                  controller: _latCtrl,
                                  label: 'Latitude',
                                  hint: '28.7041',
                                  keyboardType: const TextInputType
                                      .numberWithOptions(decimal: true),
                                  prefixIcon: const Icon(Icons.north, size: 16),
                                  validator: Validators.latitude,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AppTextField(
                                  controller: _lngCtrl,
                                  label: 'Longitude',
                                  hint: '77.1025',
                                  keyboardType: const TextInputType
                                      .numberWithOptions(decimal: true),
                                  prefixIcon: const Icon(Icons.east, size: 16),
                                  validator: Validators.longitude,
                                  textInputAction: TextInputAction.done,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),
                          AppButton(
                            label: 'Create Clinic',
                            onPressed: _createClinic,
                            isLoading: isLoading,
                            icon: const Icon(Icons.add_business_rounded,
                                size: 18),
                          ),
                          const SizedBox(height: 12),
                          AppButton(
                            label: 'Do this later',
                            variant: AppButtonVariant.ghost,
                            onPressed: () => context.go('/home'),
                          ),
                        ],
                      ),
                    ),
                  ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
