import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pawffy/core/utils/location_provider.dart';
import '../providers/lost_found_provider.dart';
import '../data/models/lost_found_model.dart';

class ReportPetScreen extends ConsumerStatefulWidget {
  final LostFoundReportModel? existingReport;
  const ReportPetScreen({super.key, this.existingReport});

  @override
  ConsumerState<ReportPetScreen> createState() => _ReportPetScreenState();
}

class _ReportPetScreenState extends ConsumerState<ReportPetScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLost = true; // true = Lost, false = Found

  // Form controllers
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _colorController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _imageController = TextEditingController(); // Simulates image URLs/base64

  String _gender = 'Male';
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingReport != null) {
      final rep = widget.existingReport!;
      _isLost = rep.reportType == 'lost';
      _nameController.text = rep.name ?? '';
      _breedController.text = rep.breed;
      _ageController.text = rep.age?.toString() ?? '';
      _colorController.text = rep.color;
      _heightController.text = rep.height ?? '';
      _weightController.text = rep.weight ?? '';
      _descriptionController.text = rep.description;
      _addressController.text = rep.location.address;
      _imageController.text = rep.images.isNotEmpty ? rep.images.first : '';
      _gender = rep.gender;
    } else {
      _prefillLocation();
    }
  }

  Future<void> _prefillLocation() async {
    final position = ref.read(positionProvider).value;
    final address = ref.read(locationTextProvider).value;
    if (address != null && address != 'Location unavailable') {
      _addressController.text = address;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _colorController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    final position = ref.read(positionProvider).value;
    final lat = position?.latitude ?? 19.076;
    final lng = position?.longitude ?? 72.877;

    // Use default generic images if none provided
    final String imgUrl = _imageController.text.trim().isNotEmpty
        ? _imageController.text.trim()
        : 'https://images.unsplash.com/photo-1543466835-00a7907e9de1?w=500';

    final payload = {
      'images': [imgUrl],
      'breed': _breedController.text.trim(),
      'color': _colorController.text.trim(),
      'gender': _gender,
      'description': _descriptionController.text.trim(),
      'location': {
        'latitude': lat,
        'longitude': lng,
        'address': _addressController.text.trim(),
      }
    };

    if (_isLost) {
      payload['name'] = _nameController.text.trim();
      final ageInt = int.tryParse(_ageController.text.trim());
      if (ageInt != null) payload['age'] = ageInt;
      if (_heightController.text.isNotEmpty) {
        payload['height'] = _heightController.text.trim();
      }
      if (_weightController.text.isNotEmpty) {
        payload['weight'] = _weightController.text.trim();
      }
    }

    try {
      final notifier = ref.read(lostFoundFeedProvider.notifier);
      if (widget.existingReport != null) {
        if (_isLost) {
          await notifier.updateLostPet(widget.existingReport!.id, payload);
        } else {
          await notifier.updateFoundPet(widget.existingReport!.id, payload);
        }
      } else {
        if (_isLost) {
          await notifier.reportLostPet(payload);
        } else {
          await notifier.reportFoundPet(payload);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingReport != null
                  ? (_isLost
                      ? 'Lost pet report updated successfully!'
                      : 'Found pet report updated successfully!')
                  : (_isLost
                      ? 'Lost pet reported successfully!'
                      : 'Found pet reported successfully!'),
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submission failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const primaryColor = Color(0xFFE85D04);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.existingReport != null ? 'EDIT REPORT' : 'REPORT A PET',
          style: GoogleFonts.barlow(
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Report Type Selector
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: widget.existingReport != null
                                ? null
                                : () => setState(() => _isLost = true),
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: _isLost
                                    ? const Color(0xFFD90429)
                                    : (isDark ? const Color(0xFF222222) : const Color(0xFFEEEEEE)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  'LOST PET',
                                  style: GoogleFonts.barlow(
                                    color: _isLost ? Colors.white : Colors.grey,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: widget.existingReport != null
                                ? null
                                : () => setState(() => _isLost = false),
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: !_isLost
                                    ? const Color(0xFF2B9348)
                                    : (isDark ? const Color(0xFF222222) : const Color(0xFFEEEEEE)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  'FOUND PET',
                                  style: GoogleFonts.barlow(
                                    color: !_isLost ? Colors.white : Colors.grey,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Common Details
                    Text(
                      'PET DETAILS',
                      style: GoogleFonts.barlow(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (_isLost) ...[
                      // Name
                      Text('Pet Name *', style: GoogleFonts.barlow(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(hintText: 'e.g., Bruno'),
                        validator: (val) =>
                            (val == null || val.isEmpty) ? 'Pet name is required' : null,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Breed
                    Text('Breed *', style: GoogleFonts.barlow(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _breedController,
                      decoration: const InputDecoration(hintText: 'e.g., Labrador, Indie, Persian Cat'),
                      validator: (val) =>
                          (val == null || val.isEmpty) ? 'Breed is required' : null,
                    ),
                    const SizedBox(height: 16),

                    if (_isLost) ...[
                      // Age
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Age (years) *', style: GoogleFonts.barlow(fontWeight: FontWeight.w600)),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _ageController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(hintText: 'e.g., 3'),
                                  validator: (val) =>
                                      (val == null || val.isEmpty) ? 'Age is required' : null,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Gender *', style: GoogleFonts.barlow(fontWeight: FontWeight.w600)),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  value: _gender,
                                  decoration: const InputDecoration(
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  ),
                                  items: const [
                                    DropdownMenuItem(value: 'Male', child: Text('Male')),
                                    DropdownMenuItem(value: 'Female', child: Text('Female')),
                                    DropdownMenuItem(value: 'Unknown', child: Text('Unknown')),
                                  ],
                                  onChanged: (val) => setState(() => _gender = val ?? 'Male'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Height & Weight
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Height (approx)', style: GoogleFonts.barlow(fontWeight: FontWeight.w600)),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _heightController,
                                  decoration: const InputDecoration(hintText: 'e.g., 45 cm'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Weight (approx)', style: GoogleFonts.barlow(fontWeight: FontWeight.w600)),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _weightController,
                                  decoration: const InputDecoration(hintText: 'e.g., 12 kg'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ] else ...[
                      // Gender only (for found pet)
                      Text('Gender *', style: GoogleFonts.barlow(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _gender,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Male', child: Text('Male')),
                          DropdownMenuItem(value: 'Female', child: Text('Female')),
                          DropdownMenuItem(value: 'Unknown', child: Text('Unknown')),
                        ],
                        onChanged: (val) => setState(() => _gender = val ?? 'Male'),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Color
                    Text('Color *', style: GoogleFonts.barlow(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _colorController,
                      decoration: const InputDecoration(hintText: 'e.g., Brown, White with spots'),
                      validator: (val) =>
                          (val == null || val.isEmpty) ? 'Color is required' : null,
                    ),
                    const SizedBox(height: 16),

                    // Last Seen Location Address
                    Text(
                      _isLost ? 'Last Seen Location *' : 'Found Location *',
                      style: GoogleFonts.barlow(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        hintText: 'e.g., Bandra Station, Mumbai',
                        suffixIcon: Icon(Icons.location_on_rounded, color: primaryColor),
                      ),
                      validator: (val) =>
                          (val == null || val.isEmpty) ? 'Location address is required' : null,
                    ),
                    const SizedBox(height: 16),

                    // Image URL
                    Text('Pet Image URL (optional)', style: GoogleFonts.barlow(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _imageController,
                      decoration: const InputDecoration(
                        hintText: 'e.g., https://example.com/pet.jpg',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description / Notes
                    Text(
                      _isLost ? 'Distinguishing Marks / Notes *' : 'Pet Condition / Details *',
                      style: GoogleFonts.barlow(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: _isLost
                            ? 'e.g., Friendly labrador wearing a red collar. Last seen near playground.'
                            : 'e.g., Scared but friendly. Currently kept safe in local veterinary clinic.',
                      ),
                      validator: (val) =>
                          (val == null || val.isEmpty) ? 'Description is required' : null,
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitting ? null : _submitReport,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isLost ? const Color(0xFFD90429) : const Color(0xFF2B9348),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: _submitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Text(
                                widget.existingReport != null ? 'SAVE CHANGES' : 'SUBMIT REPORT',
                                style: GoogleFonts.barlow(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.1,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
