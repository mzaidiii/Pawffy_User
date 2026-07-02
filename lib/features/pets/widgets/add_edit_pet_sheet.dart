import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pawffy/core/utils/image_picker_helper.dart';
import '../providers/pet_controller.dart';
import '../data/models/pet_model.dart';

class AddEditPetSheet extends ConsumerStatefulWidget {
  final PetModel? pet;
  const AddEditPetSheet({super.key, this.pet});

  @override
  ConsumerState<AddEditPetSheet> createState() => _AddEditPetSheetState();
}

class _AddEditPetSheetState extends ConsumerState<AddEditPetSheet> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers
  late final TextEditingController _nameController;
  late final TextEditingController _breedController;
  late final TextEditingController _ageController;
  late final TextEditingController _weightController;
  late final TextEditingController _colorController;
  late final TextEditingController _medicalNotesController;

  String _species = 'Dog';
  String _gender = 'Male';
  String _vaccinationStatus = 'Up to date';

  final List<String> _speciesList = ['Dog', 'Cat', 'Bird', 'Rabbit', 'Other'];
  final List<String> _genderList = ['Male', 'Female'];
  final List<String> _vaccinationList = [
    'Up to date',
    'Partially vaccinated',
    'Not vaccinated',
    'Unknown',
  ];

  String? _localImagePath;

  bool get _isEditMode => widget.pet != null;

  @override
  void initState() {
    super.initState();
    final p = widget.pet;
    _nameController = TextEditingController(text: p?.name ?? '');
    _breedController = TextEditingController(text: p?.breed ?? '');
    _ageController = TextEditingController(text: p != null ? '${p.age}' : '');
    _weightController = TextEditingController(text: p?.weight ?? '');
    _colorController = TextEditingController(text: p?.color ?? '');
    _medicalNotesController = TextEditingController(
      text: p?.medicalNotes ?? '',
    );

    if (p != null) {
      final capSpecies = p.species.isNotEmpty
          ? '${p.species[0].toUpperCase()}${p.species.substring(1).toLowerCase()}'
          : 'Dog';
      _species = _speciesList.contains(capSpecies) ? capSpecies : 'Other';

      final capGender = p.gender.isNotEmpty
          ? '${p.gender[0].toUpperCase()}${p.gender.substring(1).toLowerCase()}'
          : 'Male';
      _gender = _genderList.contains(capGender) ? capGender : 'Male';

      _vaccinationStatus = p.vaccinationStatus;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _colorController.dispose();
    _medicalNotesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final source = await ImagePickerHelper.showSourceBottomSheet(context);
    if (source == null) return;
    if (!mounted) return;

    final pickedFile = await ImagePickerHelper.pickImageWithPermission(
      context: context,
      source: source,
    );

    if (pickedFile != null) {
      setState(() {
        _localImagePath = pickedFile.path;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final body = {
      'name': _nameController.text.trim(),
      'species': _species.toLowerCase(),
      'breed': _breedController.text.trim(),
      'gender': _gender.toLowerCase(),
      'age': int.tryParse(_ageController.text.trim()) ?? 0,
      'weight': double.tryParse(_weightController.text.trim()) ?? 0.0,
      'color': _colorController.text.trim(),
      'vaccinationStatus': _vaccinationStatus,
      if (_medicalNotesController.text.trim().isNotEmpty)
        'medicalNotes': _medicalNotesController.text.trim(),
    };

    bool success = false;

    if (_isEditMode) {
      final updated = await ref
          .read(petControllerProvider.notifier)
          .updatePet(widget.pet!.id, body);

      if (updated != null) {
        if (_localImagePath != null) {
          final updatedWithImage = await ref
              .read(petControllerProvider.notifier)
              .uploadPetImage(widget.pet!.id, _localImagePath!);
          success = updatedWithImage != null;
        } else {
          success = true;
        }
      }
    } else {
      final created = await ref
          .read(petControllerProvider.notifier)
          .createPet(body);

      if (created != null) {
        if (_localImagePath != null) {
          final updatedWithImage = await ref
              .read(petControllerProvider.notifier)
              .uploadPetImage(created.id, _localImagePath!);
          success = updatedWithImage != null;
        } else {
          success = true;
        }
      }
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditMode ? 'Pet updated!' : 'Pet added!',
            style: GoogleFonts.barlow(),
          ),
          backgroundColor: const Color(0xFFE85D04),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Something went wrong. Try again.',
            style: GoogleFonts.barlow(),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _isEditMode ? 'EDIT PET' : 'ADD NEW PET',
                style: GoogleFonts.barlow(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onSurface,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 20),

              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE85D04).withOpacity(0.1),
                        shape: BoxShape.circle,
                        image: _localImagePath != null
                            ? DecorationImage(
                                image: FileImage(File(_localImagePath!)),
                                fit: BoxFit.cover,
                              )
                            : (widget.pet?.imageUrl != null &&
                                      widget.pet!.imageUrl!.isNotEmpty
                                  ? DecorationImage(
                                      image: ImagePickerHelper.getImageProvider(
                                        widget.pet!.imageUrl!,
                                      ),
                                      fit: BoxFit.cover,
                                    )
                                  : null),
                      ),
                      child:
                          _localImagePath == null &&
                              (widget.pet?.imageUrl == null ||
                                  widget.pet!.imageUrl!.isEmpty)
                          ? const Icon(
                              Icons.pets_rounded,
                              size: 50,
                              color: Color(0xFFE85D04),
                            )
                          : null,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE85D04),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt_outlined,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              _buildTextField(
                controller: _nameController,
                label: 'Pet Name',
                hint: 'e.g. Buddy',
                validator: (v) =>
                    v == null || v.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 14),

              _buildDropdown(
                label: 'Species',
                value: _species,
                items: _speciesList,
                onChanged: (v) => setState(() => _species = v!),
              ),
              const SizedBox(height: 14),

              _buildTextField(
                controller: _breedController,
                label: 'Breed',
                hint: 'e.g. Labrador',
                validator: (v) =>
                    v == null || v.isEmpty ? 'Breed is required' : null,
              ),
              const SizedBox(height: 14),

              _buildDropdown(
                label: 'Gender',
                value: _gender,
                items: _genderList,
                onChanged: (v) => setState(() => _gender = v!),
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _ageController,
                      label: 'Age (years)',
                      hint: 'e.g. 3',
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _weightController,
                      label: 'Weight (kg)',
                      hint: 'e.g. 25.5',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              _buildTextField(
                controller: _colorController,
                label: 'Color',
                hint: 'e.g. Golden',
                validator: (v) =>
                    v == null || v.isEmpty ? 'Color is required' : null,
              ),
              const SizedBox(height: 14),

              _buildDropdown(
                label: 'Vaccination Status',
                value: _vaccinationStatus,
                items: _vaccinationList,
                onChanged: (v) => setState(() => _vaccinationStatus = v!),
              ),
              const SizedBox(height: 14),

              _buildTextField(
                controller: _medicalNotesController,
                label: 'Medical Notes (optional)',
                hint: 'e.g. Allergic to certain foods',
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE85D04),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _isEditMode ? 'SAVE CHANGES' : 'ADD PET',
                          style: GoogleFonts.barlow(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.barlow(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: GoogleFonts.barlow(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.barlow(
              fontSize: 14,
              color: Colors.grey.withOpacity(0.6),
            ),
            filled: true,
            fillColor: Theme.of(
              context,
            ).colorScheme.onSurface.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.barlow(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              style: GoogleFonts.barlow(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              dropdownColor: Theme.of(context).scaffoldBackgroundColor,
              items: items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
