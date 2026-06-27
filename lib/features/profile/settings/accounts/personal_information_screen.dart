import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pawffy/core/utils/image_picker_helper.dart';

import 'package:pawffy/core/utils/location_provider.dart';
import 'package:pawffy/core/utils/location_states.dart';
import 'package:pawffy/features/auth/providers/current_user_provider.dart';
import 'package:pawffy/features/auth/providers/auth_controller.dart';
import 'package:pawffy/features/auth/data/models/user_model.dart';
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
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _pinCodeController;

  String _selectedGender = 'Female';
  String _selectedState = '';
  DateTime? _selectedDate = DateTime(1995, 5, 12);
  
  bool _isInitialized = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _addressController = TextEditingController();
    _cityController = TextEditingController();
    _pinCodeController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _pinCodeController.dispose();
    super.dispose();
  }

  void _initializeFields(UserModel user) {
    if (_isInitialized) return;
    _nameController.text = user.name;
    _addressController.text = user.address ?? '';
    _cityController.text = user.city ?? '';
    _selectedState = user.state ?? '';
    _isInitialized = true;
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

  Future<void> _pickAndUploadAvatar() async {
    final source = await ImagePickerHelper.showSourceBottomSheet(context);
    if (source == null) return;
    if (!mounted) return;

    final pickedFile = await ImagePickerHelper.pickImageWithPermission(
      context: context,
      source: source,
    );

    if (pickedFile != null) {
      setState(() => _isLoading = true);
      final success = await ref
          .read(authControllerProvider.notifier)
          .uploadAvatar(pickedFile.path);

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Avatar updated successfully!' : 'Failed to upload avatar.',
              style: GoogleFonts.barlow(),
            ),
            backgroundColor: success ? Colors.green : Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
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
      'User',
    ];

    return '${_selectedDate!.day} '
        '${months[_selectedDate!.month]} '
        '${_selectedDate!.year}';
  }

  @override
  Widget build(BuildContext context) {
    final countryAsync = ref.watch(countryProvider);
    final userAsync = ref.watch(currentUserProvider);

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

        return countryAsync.when(
          loading: () => Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: const Center(child: CircularProgressIndicator(color: Color(0xFFE85D04))),
          ),
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
        );
      },
    );
  }

  Widget _buildScreen(List<String> states, UserModel user) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

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
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                              image: user.profileImage != null &&
                                      user.profileImage!.isNotEmpty
                                  ? DecorationImage(
                                      image: ImagePickerHelper.getImageProvider(
                                        user.profileImage!,
                                      ),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: user.profileImage == null ||
                                    user.profileImage!.isEmpty
                                ? const Icon(
                                    Icons.person,
                                    size: 70,
                                    color: Colors.grey,
                                  )
                                : null,
                          ),
                          if (_isLoading)
                            Positioned.fill(
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.black26,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFFE85D04),
                                  ),
                                ),
                              ),
                            ),

                          Positioned(
                            right: 10,
                            bottom: 10,
                            child: GestureDetector(
                              onTap: _pickAndUploadAvatar,
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
              color: Theme.of(context).scaffoldBackgroundColor,
              child: SettingsButton(
                text: 'Save Changes',
                onTap: () async {
                  if (_isLoading) return;
                  setState(() => _isLoading = true);
                  final success = await ref
                      .read(authControllerProvider.notifier)
                      .updateProfile(
                        name: _nameController.text.trim(),
                        phone: user.phone ?? '',
                        city: _cityController.text.trim(),
                        userState: _selectedState,
                        address: _addressController.text.trim(),
                      );
                        if (mounted) {
                          setState(() => _isLoading = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? 'Changes saved successfully!'
                                    : 'Failed to save changes.',
                                style: GoogleFonts.barlow(),
                              ),
                              backgroundColor: success ? Colors.green : Colors.redAccent,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          if (success) {
                            Navigator.pop(context);
                          }
                        }
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
          color: Theme.of(context).colorScheme.onSurface,
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
        style: GoogleFonts.barlow(fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
        decoration: InputDecoration(
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.12)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
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
        style: GoogleFonts.barlow(fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
        decoration: InputDecoration(
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          contentPadding: const EdgeInsets.all(16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.12)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
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
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.12)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _formattedDate,
                style: GoogleFonts.barlow(fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
              ),
            ),
            Icon(Icons.calendar_today_outlined, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
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
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.12)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedGender,
          isExpanded: true,
          dropdownColor: Theme.of(context).colorScheme.surface,
          style: GoogleFonts.barlow(fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
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
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.12)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedState,
          isExpanded: true,
          dropdownColor: Theme.of(context).colorScheme.surface,
          style: GoogleFonts.barlow(fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
          items: states
              .map(
                (state) => DropdownMenuItem(value: state, child: Text(state, style: GoogleFonts.barlow(color: Theme.of(context).colorScheme.onSurface))),
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
