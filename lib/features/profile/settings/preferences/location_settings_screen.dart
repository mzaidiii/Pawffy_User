import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/settings_appbar.dart';

class LocationSettingsScreen extends StatefulWidget {
  const LocationSettingsScreen({super.key});

  @override
  State<LocationSettingsScreen> createState() => _LocationSettingsScreenState();
}

class _LocationSettingsScreenState extends State<LocationSettingsScreen> {
  bool _locationAccess = true;
  bool _preciseLocation = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const SettingsAppBar(title: 'LOCATION'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            Center(
              child: Container(
                width: 84,
                height: 84,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF1E8),
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
                ),
              ),
            ),
            Center(
              child: Text(
                'Manage how your location is used to\nimprove your experience.',
                textAlign: TextAlign.center,
                style: GoogleFonts.barlow(fontSize: 13, color: Colors.black54),
              ),
            ),

            const SizedBox(height: 32),

            Text(
              'Location Access',
              style: GoogleFonts.barlow(
                fontSize: 15,
                fontWeight: FontWeight.w700,
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

            const SizedBox(height: 32),

            Text(
              'Location Usage',
              style: GoogleFonts.barlow(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),

            _buildUsageRow('Find nearby services', true),
            _buildUsageRow('Real-time tracking', true),
            _buildUsageRow('Location-based offers', true),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
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
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.barlow(fontWeight: FontWeight.w600),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.barlow(
                    fontSize: 13,
                    color: Colors.black54,
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

  Widget _buildUsageRow(String title, bool enabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(title, style: GoogleFonts.barlow(fontSize: 14))),
          Icon(
            enabled ? Icons.check_circle : Icons.cancel,
            color: enabled ? const Color(0xFF22C55E) : Colors.grey,
            size: 20,
          ),
        ],
      ),
    );
  }
}
