import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/utils/location_provider.dart';
import '../../../core/utils/location_states.dart';
import '../widgets/settings_appbar.dart';
import '../widgets/settings_button.dart';

class PersonalInformationScreen extends ConsumerStatefulWidget {
  const PersonalInformationScreen({super.key});

  @override
  ConsumerState<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState
    extends ConsumerState<PersonalInformationScreen> {
  final _nameController = TextEditingController(text: 'Ankita Sharma');

  final _addressController = TextEditingController(
    text: '123, 4th Cross, Koramangala,\nBangalore, Karnataka',
  );

  final _cityController = TextEditingController(text: 'Bangalore');

  final _pinCodeController = TextEditingController(text: '560014');

  String _selectedGender = 'Female';
  String _selectedState = 'Karnataka';

  DateTime? _selectedDate = DateTime(1995, 5, 12);

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _pinCodeController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String get _formattedDate {
    if (_selectedDate == null) return 'Select Date';

    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${_selectedDate!.day} '
        '${months[_selectedDate!.month]} '
        '${_selectedDate!.year}';
  }

  @override
  Widget build(BuildContext context) {
    final countryAsync = ref.watch(countryProvider);

    return countryAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => _buildScreen(usStates),
      data: (country) {
        final states = getStatesForCountry(country);

        if (!states.contains(_selectedState)) {
          _selectedState = states.first;
        }

        return _buildScreen(states);
      },
    );
  }

  Widget _buildScreen(List<String> states) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: const SettingsAppBar(title: 'Personal Information'),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Column(
                  children: [
                    const SizedBox(height: 18),

                    // Avatar
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 140,
                            height: 140,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 70,
                              color: Colors.grey,
                            ),
                          ),

                          Positioned(
                            right: 10,
                            bottom: 10,
                            child: GestureDetector(
                              onTap: () {},
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE85D04),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt_outlined,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    _label('Full Name'),
                    _textField(_nameController),

                    const SizedBox(height: 20),

                    _label('Date of Birth'),
                    _dateField(),

                    const SizedBox(height: 20),

                    _label('Gender'),
                    _genderDropdown(),

                    const SizedBox(height: 20),

                    _label('Address'),
                    _addressField(),

                    const SizedBox(height: 20),

                    _label('City'),
                    _textField(_cityController),

                    const SizedBox(height: 20),

                    _label('State'),
                    _stateDropdown(states),

                    const SizedBox(height: 20),

                    _label('Pin Code'),
                    _textField(
                      _pinCodeController,
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 22),
              color: const Color(0xFFF5F5F5),
              child: SettingsButton(
                text: 'Save Changes',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Changes saved',
                        style: GoogleFonts.barlow(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: GoogleFonts.barlow(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _textField(
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      height: 64,
      margin: const EdgeInsets.only(top: 8),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.barlow(fontSize: 16),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
        ),
      ),
    );
  }

  Widget _addressField() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: TextField(
        controller: _addressController,
        maxLines: 3,
        style: GoogleFonts.barlow(fontSize: 16),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
        ),
      ),
    );
  }

  Widget _dateField() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        height: 64,
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _formattedDate,
                style: GoogleFonts.barlow(fontSize: 16),
              ),
            ),
            const Icon(Icons.calendar_today_outlined),
          ],
        ),
      ),
    );
  }

  Widget _genderDropdown() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedGender,
          isExpanded: true,
          items: const [
            DropdownMenuItem(value: 'Male', child: Text('Male')),
            DropdownMenuItem(value: 'Female', child: Text('Female')),
            DropdownMenuItem(value: 'Other', child: Text('Other')),
          ],
          onChanged: (value) {
            setState(() {
              _selectedGender = value!;
            });
          },
        ),
      ),
    );
  }

  Widget _stateDropdown(List<String> states) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedState,
          isExpanded: true,
          items: states
              .map(
                (state) => DropdownMenuItem(value: state, child: Text(state)),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedState = value!;
            });
          },
        ),
      ),
    );
  }
}
