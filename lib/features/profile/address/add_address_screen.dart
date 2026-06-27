import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/location_provider.dart';
import '../../../core/utils/location_states.dart';
import 'address_provider.dart';
import 'package:geocoding/geocoding.dart';

class AddAddressScreen extends ConsumerStatefulWidget {
  const AddAddressScreen({super.key});

  @override
  ConsumerState<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends ConsumerState<AddAddressScreen> {
  final _fullNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _line1Controller = TextEditingController();
  final _line2Controller = TextEditingController();
  final _landmarkController = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();

  String _selectedLabel = 'Home';
  String? _selectedState;
  bool _saveAsDefault = false;
  String? _pinCodeError;

  bool _prefilled = false;

  final List<String> _labels = ['Home', 'Work', 'Parents House', 'Other'];

  @override
  void dispose() {
    _fullNameController.dispose();
    _mobileController.dispose();
    _line1Controller.dispose();
    _line2Controller.dispose();
    _landmarkController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  // auto-fill city and state from location
  void _prefillFromLocation(Placemark placemark, List<String> states) {
    if (_prefilled) return;
    _prefilled = true;
    final city = placemark.locality ?? '';
    final state = placemark.administrativeArea ?? '';

    _cityController.text = city;

    // find matching state in list
    final matched = states.firstWhere(
      (s) => s.toLowerCase() == state.toLowerCase(),
      orElse: () => states.first,
    );
    setState(() => _selectedState = matched);
  }

  void _saveAddress(String country, List<String> states) {
    final pinError = validatePinCode(_pincodeController.text, country);
    setState(() => _pinCodeError = pinError);

    if (_fullNameController.text.isEmpty ||
        _mobileController.text.isEmpty ||
        _line1Controller.text.isEmpty ||
        _cityController.text.isEmpty ||
        pinError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please fill all required fields',
            style: GoogleFonts.barlow(),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    final address = AddressModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      label: _selectedLabel,
      fullName: _fullNameController.text,
      mobile: _mobileController.text,
      addressLine1: _line1Controller.text,
      addressLine2: _line2Controller.text,
      landmark: _landmarkController.text,
      city: _cityController.text,
      state: _selectedState ?? states.first,
      pinCode: _pincodeController.text,
      isDefault: _saveAsDefault,
    );

    ref.read(addressProvider.notifier).addAddress(address);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final countryAsync = ref.watch(countryProvider);
    final placemarkAsync = ref.watch(placemarkProvider);

    return countryAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => _buildForm(context, 'United States', usStates),
      data: (country) {
        final states = getStatesForCountry(country);
        _selectedState ??= states.first;

        // auto-fill from placemark
        placemarkAsync.whenData((placemark) {
          if (placemark != null) {
            _prefillFromLocation(placemark, states);
          }
        });

        return _buildForm(context, country, states);
      },
    );
  }

  Widget _buildForm(BuildContext context, String country, List<String> states) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back,
            color: Color.fromARGB(245, 247, 113, 3),
          ),
        ),
        title: Text(
          'ADD NEW ADDRESS',
          style: GoogleFonts.barlow(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onSurface,
            letterSpacing: 1,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // ── Label + Full Name ─────────────────────
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Label'),
                      const SizedBox(height: 6),
                      _buildDropdown(
                        value: _selectedLabel,
                        items: _labels,
                        onChanged: (val) =>
                            setState(() => _selectedLabel = val!),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Full Name'),
                      const SizedBox(height: 6),
                      _buildTextField(
                        controller: _fullNameController,
                        hint: 'Amit Patel',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            _buildLabel('Mobile Number'),
            const SizedBox(height: 6),
            _buildTextField(
              controller: _mobileController,
              hint: country == 'India' ? '+91 98765 43210' : '+1 234 567 8900',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 14),

            _buildLabel('Address Line 1'),
            const SizedBox(height: 6),
            _buildTextField(
              controller: _line1Controller,
              hint: '123, Street Name',
            ),
            const SizedBox(height: 14),

            _buildLabel('Address Line 2 (Optional)'),
            const SizedBox(height: 6),
            _buildTextField(
              controller: _line2Controller,
              hint: 'Apartment, suite, etc.',
            ),
            const SizedBox(height: 14),

            _buildLabel('Landmark (Optional)'),
            const SizedBox(height: 6),
            _buildTextField(
              controller: _landmarkController,
              hint: country == 'India'
                  ? 'Near Metro Station'
                  : 'Near Central Park',
            ),
            const SizedBox(height: 14),

            // ── City + State ──────────────────────────
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('City'),
                      const SizedBox(height: 6),
                      _buildTextField(
                        controller: _cityController,
                        hint: country == 'India' ? 'Ghaziabad' : 'New York',
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('State'),
                      const SizedBox(height: 6),
                      _buildDropdown(
                        value: _selectedState ?? states.first,
                        items: states,
                        onChanged: (val) =>
                            setState(() => _selectedState = val!),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Pin/Zip Code ──────────────────────────
            _buildLabel(getPinCodeLabel(country)),
            const SizedBox(height: 6),
            _buildTextField(
              controller: _pincodeController,
              hint: getPinCodeHint(country),
              keyboardType: TextInputType.number,
              maxLength: getPinCodeLength(country),
              errorText: _pinCodeError,
            ),
            const SizedBox(height: 16),

            // ── Save as Default ───────────────────────
            Row(
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: Checkbox(
                    value: _saveAsDefault,
                    onChanged: (val) => setState(() => _saveAsDefault = val!),
                    activeColor: const Color(0xFFE85D04),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    side: const BorderSide(
                      color: Color(0xFFE85D04),
                      width: 1.5,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Save as default Address',
                  style: GoogleFonts.barlow(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Save Button ───────────────────────────
            ElevatedButton(
              onPressed: () => _saveAddress(country, states),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE85D04),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'SAVE ADDRESS',
                style: GoogleFonts.barlow(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(
    text,
    style: GoogleFonts.barlow(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: Theme.of(context).colorScheme.onSurface,
    ),
  );

  Widget _buildTextField({
    required TextEditingController controller,
    String hint = '',
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    String? errorText,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      style: GoogleFonts.barlow(
        fontSize: 13,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        hintText: hint,
        errorText: errorText,
        counterText: '',
        hintStyle: GoogleFonts.barlow(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          fontSize: 13,
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE85D04), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            dropdownColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest,
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            style: GoogleFonts.barlow(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            items: items
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      e,
                      style: GoogleFonts.barlow(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}
