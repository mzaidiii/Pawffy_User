import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pawffy/features/auth/providers/current_user_provider.dart';
import 'package:pawffy/features/auth/providers/auth_controller.dart';
import 'package:pawffy/features/auth/data/models/user_model.dart';
import 'package:pawffy/core/utils/location_provider.dart';
import 'package:pawffy/core/utils/location_states.dart';

import '../widgets/settings_appbar.dart';

class LocationSettingsScreen extends ConsumerStatefulWidget {
  const LocationSettingsScreen({super.key});

  @override
  ConsumerState<LocationSettingsScreen> createState() => _LocationSettingsScreenState();
}

class _LocationSettingsScreenState extends ConsumerState<LocationSettingsScreen> {
  bool _locationAccess = true;
  bool _preciseLocation = true;
  bool _isLoading = false;

  late final TextEditingController _cityController;
  String _selectedState = '';
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _cityController = TextEditingController();
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  void _initializeFields(UserModel user) {
    if (_isInitialized) return;
    _cityController.text = user.city ?? '';
    _selectedState = user.state ?? '';
    _isInitialized = true;
  }

  Future<void> _updateLocation(UserModel user) async {
    final newCity = _cityController.text.trim();
    if (newCity.isEmpty) {
      _showSnackbar('City cannot be empty', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    final success = await ref
        .read(authControllerProvider.notifier)
        .updateProfile(
          name: user.name,
          phone: user.phone ?? '',
          city: newCity,
          userState: _selectedState,
          address: user.address ?? '',
        );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        _showSnackbar('Profile location updated successfully!', isError: false);
      } else {
        _showSnackbar('Failed to update location', isError: true);
      }
    }
  }

  void _showSnackbar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.barlow(),
        ),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final countryAsync = ref.watch(countryProvider);

    return userAsync.when(
      loading: () => Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator(color: Color(0xFFE85D04))),
      ),
      error: (_, __) => Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(child: Text('Error loading profile')),
      ),
      data: (user) {
        if (user == null) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: const Center(child: Text('User not found')),
          );
        }

        _initializeFields(user);

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: const SettingsAppBar(title: 'LOCATION'),
          body: countryAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFE85D04))),
            error: (_, __) {
              var activeCountry = 'United States';
              if (user.state != null && indiaStates.contains(user.state)) {
                activeCountry = 'India';
              }
              final states = getStatesForCountry(activeCountry);
              if (_selectedState.isEmpty || !states.contains(_selectedState)) {
                _selectedState = states.isNotEmpty ? states.first : '';
              }
              return _buildScreen(states, user);
            },
            data: (country) {
              var activeCountry = country;
              if (user.state != null && indiaStates.contains(user.state)) {
                activeCountry = 'India';
              } else if (user.state != null && usStates.contains(user.state)) {
                activeCountry = 'United States';
              }
              final states = getStatesForCountry(activeCountry);
              if (_selectedState.isEmpty || !states.contains(_selectedState)) {
                _selectedState = states.isNotEmpty ? states.first : '';
              }
              return _buildScreen(states, user);
            },
          ),
        );
      },
    );
  }

  Widget _buildScreen(List<String> states, UserModel user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: const Color(0xFFE85D04).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_on_rounded,
                color: Color(0xFFE85D04),
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Location Settings',
              style: GoogleFonts.barlow(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          Center(
            child: Text(
              'Manage your primary location and system access.',
              textAlign: TextAlign.center,
              style: GoogleFonts.barlow(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
          const SizedBox(height: 28),

          // ── Profile Location Section ──
          Text(
            'Profile Location',
            style: GoogleFonts.barlow(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'City',
                  style: GoogleFonts.barlow(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _cityController,
                  style: GoogleFonts.barlow(color: Theme.of(context).colorScheme.onSurface),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Theme.of(context).scaffoldBackgroundColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'State',
                  style: GoogleFonts.barlow(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedState,
                      isExpanded: true,
                      dropdownColor: Theme.of(context).colorScheme.surface,
                      style: GoogleFonts.barlow(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      items: states
                          .map(
                            (state) => DropdownMenuItem(
                              value: state,
                              child: Text(state),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedState = value;
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFE85D04)))
                    : SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () => _updateLocation(user),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE85D04),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Save Profile Location',
                            style: GoogleFonts.barlow(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          Text(
            'Device Permissions',
            style: GoogleFonts.barlow(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          _buildSwitchTile(
            'Location Access',
            'Allow app to access your location',
            _locationAccess,
            (val) => setState(() => _locationAccess = val),
          ),
          _buildSwitchTile(
            'Precise Location',
            'Use precise location for better results',
            _preciseLocation,
            (val) => setState(() => _preciseLocation = val),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E3A2F) : const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock_outline, color: Color(0xFF22C55E)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your location data is encrypted and never shared with third parties.',
                    style: GoogleFonts.barlow(
                      fontSize: 13,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.barlow(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.barlow(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFE85D04),
          ),
        ],
      ),
    );
  }
}
