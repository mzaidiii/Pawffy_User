import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/models/medical_record_model.dart';
import '../providers/medical_record_controller.dart';

class AddEditMedicalRecordSheet extends ConsumerStatefulWidget {
  final String petId;
  final MedicalRecordModel? record;
  const AddEditMedicalRecordSheet({
    super.key,
    required this.petId,
    this.record,
  });

  @override
  ConsumerState<AddEditMedicalRecordSheet> createState() =>
      _AddEditMedicalRecordSheetState();
}

class _AddEditMedicalRecordSheetState
    extends ConsumerState<AddEditMedicalRecordSheet> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late final TextEditingController _diagnosisController;
  late final TextEditingController _prescriptionController;
  late final TextEditingController _allergiesController;
  late final TextEditingController _symptomsController;
  late final TextEditingController _reportUrlController;

  bool get _isEditMode => widget.record != null;

  @override
  void initState() {
    super.initState();
    final r = widget.record;
    _diagnosisController = TextEditingController(text: r?.diagnosis ?? '');
    _prescriptionController = TextEditingController(text: r?.prescription ?? '');
    _allergiesController = TextEditingController(text: r?.allergies ?? '');
    _symptomsController = TextEditingController(text: r?.symptoms ?? '');
    _reportUrlController = TextEditingController(text: r?.reportUrl ?? '');
  }

  @override
  void dispose() {
    _diagnosisController.dispose();
    _prescriptionController.dispose();
    _allergiesController.dispose();
    _symptomsController.dispose();
    _reportUrlController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final body = {
      'diagnosis': _diagnosisController.text.trim().isNotEmpty
          ? _diagnosisController.text.trim()
          : null,
      'prescription': _prescriptionController.text.trim().isNotEmpty
          ? _prescriptionController.text.trim()
          : null,
      'allergies': _allergiesController.text.trim().isNotEmpty
          ? _allergiesController.text.trim()
          : null,
      'symptoms': _symptomsController.text.trim().isNotEmpty
          ? _symptomsController.text.trim()
          : null,
      'reportUrl': _reportUrlController.text.trim().isNotEmpty
          ? _reportUrlController.text.trim()
          : null,
    };

    MedicalRecordModel? result;
    if (_isEditMode) {
      result = await ref
          .read(medicalRecordControllerProvider(widget.petId).notifier)
          .updateRecord(widget.record!.id, body);
    } else {
      result = await ref
          .read(medicalRecordControllerProvider(widget.petId).notifier)
          .createRecord(body);
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result != null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditMode ? 'Medical record updated!' : 'Medical record added!',
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
                _isEditMode ? 'EDIT MEDICAL RECORD' : 'ADD MEDICAL RECORD',
                style: GoogleFonts.barlow(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onSurface,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _diagnosisController,
                label: 'Diagnosis',
                hint: 'e.g. Viral Fever',
              ),
              const SizedBox(height: 14),
              _buildTextField(
                controller: _prescriptionController,
                label: 'Prescription (optional)',
                hint: 'e.g. Paracetamol 250mg twice a day',
                maxLines: 2,
              ),
              const SizedBox(height: 14),
              _buildTextField(
                controller: _allergiesController,
                label: 'Allergies (optional)',
                hint: 'e.g. Penicillin',
              ),
              const SizedBox(height: 14),
              _buildTextField(
                controller: _symptomsController,
                label: 'Symptoms (optional)',
                hint: 'e.g. High fever, lethargy, loss of appetite',
                maxLines: 2,
              ),
              const SizedBox(height: 14),
              _buildTextField(
                controller: _reportUrlController,
                label: 'Report URL (PDF/Link, optional)',
                hint: 'e.g. https://link-to-report-pdf.com/report.pdf',
                keyboardType: TextInputType.url,
                validator: (v) {
                  if (v != null && v.isNotEmpty) {
                    final uri = Uri.tryParse(v);
                    if (uri == null || !uri.hasAbsolutePath) {
                      return 'Enter a valid URL (e.g. https://...)';
                    }
                  }
                  return null;
                },
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
                          _isEditMode ? 'SAVE CHANGES' : 'ADD RECORD',
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
            fillColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
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
}
