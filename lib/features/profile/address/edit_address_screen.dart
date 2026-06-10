import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/location_provider.dart';
import '../../../core/utils/location_states.dart';
import 'address_provider.dart';

class EditAddressScreen extends ConsumerStatefulWidget {
  final AddressModel address;
  const EditAddressScreen({super.key, required this.address});

  @override
  ConsumerState<EditAddressScreen> createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends ConsumerState<EditAddressScreen> {
  late final TextEditingController _fullNameController;
  late final TextEditingController _mobileController;
  late final TextEditingController _line1Controller;
  late final TextEditingController _line2Controller;
  late final TextEditingController _landmarkController;
  late final TextEditingController _cityController;
  late final TextEditingController _pincodeController;

  late String _selectedLabel;
  late String _selectedState;
  late bool _saveAsDefault;
  String? _pinCodeError;

  final List<String> _labels = ['Home', 'Work', 'Parents House', 'Other'];

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.address.fullName);
    _mobileController = TextEditingController(text: widget.address.mobile);
    _line1Controller = TextEditingController(text: widget.address.addressLine1);
    _line2Controller = TextEditingController(text: widget.address.addressLine2);
    _landmarkController = TextEditingController(text: widget.address.landmark);
    _cityController = TextEditingController(text: widget.address.city);
    _pincodeController = TextEditingController(text: widget.address.pinCode);
    _selectedLabel = widget.address.label;
    _selectedState = widget.address.state;
    _saveAsDefault = widget.address.isDefault;
  }

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

  void _updateAddress(String country, List<String> states) {
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

    // ensure selected state is valid for country
    final validState = states.contains(_selectedState)
        ? _selectedState
        : states.first;

    final updated = widget.address.copyWith(
      label: _selectedLabel,
      fullName: _fullNameController.text,
      mobile: _mobileController.text,
      addressLine1: _line1Controller.text,
      addressLine2: _line2Controller.text,
      landmark: _landmarkController.text,
      city: _cityController.text,
      state: validState,
      pinCode: _pincodeController.text,
      isDefault: _saveAsDefault,
    );

    ref.read(addressProvider.notifier).updateAddress(updated);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final countryAsync = ref.watch(countryProvider);

    return countryAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => _buildForm(context, 'United States', usStates),
      data: (country) {
        final states = getStatesForCountry(country);
        if (!states.contains(_selectedState)) {
          _selectedState = states.first;
        }
        return _buildForm(context, country, states);
      },
    );
  }

  Widget _buildForm(BuildContext context, String country, List<String> states) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back,
            color: Color.fromARGB(221, 235, 100, 3),
          ),
        ),
        title: Text(
          'EDIT ADDRESS',
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
                      _buildTextField(controller: _fullNameController),
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
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 14),

            _buildLabel('Address Line 1'),
            const SizedBox(height: 6),
            _buildTextField(controller: _line1Controller),
            const SizedBox(height: 14),

            _buildLabel('Address Line 2 (Optional)'),
            const SizedBox(height: 6),
            _buildTextField(controller: _line2Controller),
            const SizedBox(height: 14),

            _buildLabel('Landmark (Optional)'),
            const SizedBox(height: 6),
            _buildTextField(controller: _landmarkController),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('City'),
                      const SizedBox(height: 6),
                      _buildTextField(controller: _cityController),
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
                        value: _selectedState,
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

            _buildLabel(getPinCodeLabel(country)),
            const SizedBox(height: 6),
            _buildTextField(
              controller: _pincodeController,
              keyboardType: TextInputType.number,
              maxLength: getPinCodeLength(country),
              errorText: _pinCodeError,
            ),
            const SizedBox(height: 16),

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

            ElevatedButton(
              onPressed: () => _updateAddress(country, states),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE85D04),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'UPDATE ADDRESS',
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
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
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
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color.fromARGB(235, 240, 97, 3),
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
