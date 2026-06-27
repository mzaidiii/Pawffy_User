import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../data/models/vaccination_model.dart';
import '../providers/vaccination_controller.dart';
import '../../vets/providers/vet_controller.dart';

class AddEditVaccinationSheet extends ConsumerStatefulWidget {
  final String petId;
  final VaccinationModel? vaccination;
  const AddEditVaccinationSheet({
    super.key,
    required this.petId,
    this.vaccination,
  });

  @override
  ConsumerState<AddEditVaccinationSheet> createState() =>
      _AddEditVaccinationSheetState();
}

class _AddEditVaccinationSheetState
    extends ConsumerState<AddEditVaccinationSheet> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late final TextEditingController _vaccineNameController;
  late final TextEditingController _notesController;
  late final TextEditingController _dateController;
  late final TextEditingController _nextDueDateController;

  DateTime _vaccinationDate = DateTime.now();
  DateTime? _nextDueDate;
  String? _selectedVetId;

  bool get _isEditMode => widget.vaccination != null;

  @override
  void initState() {
    super.initState();
    final v = widget.vaccination;
    _vaccineNameController = TextEditingController(text: v?.vaccineName ?? '');
    _notesController = TextEditingController(text: v?.notes ?? '');
    
    if (v != null) {
      _vaccinationDate = v.vaccinationDate;
      _nextDueDate = v.nextDueDate;
      _selectedVetId = v.vetId ?? v.vet?.id;
    }

    _dateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(_vaccinationDate),
    );
    _nextDueDateController = TextEditingController(
      text: _nextDueDate != null
          ? DateFormat('yyyy-MM-dd').format(_nextDueDate!)
          : '',
    );
  }

  @override
  void dispose() {
    _vaccineNameController.dispose();
    _notesController.dispose();
    _dateController.dispose();
    _nextDueDateController.dispose();
    super.dispose();
  }

  Future<void> _selectVaccinationDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _vaccinationDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: const Color(0xFFE85D04),
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _vaccinationDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectNextDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextDueDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: const Color(0xFFE85D04),
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _nextDueDate = picked;
        _nextDueDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final body = {
      'vaccineName': _vaccineNameController.text.trim(),
      'vaccinationDate': _vaccinationDate.toIso8601String().substring(0, 10),
      'nextDueDate': _nextDueDate?.toIso8601String().substring(0, 10),
      'vetId': _selectedVetId,
      'notes': _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
    };

    VaccinationModel? result;
    if (_isEditMode) {
      result = await ref
          .read(vaccinationControllerProvider(widget.petId).notifier)
          .updateVaccination(widget.vaccination!.id, body);
    } else {
      result = await ref
          .read(vaccinationControllerProvider(widget.petId).notifier)
          .addVaccination(body);
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result != null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditMode ? 'Vaccination record updated!' : 'Vaccination record added!',
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
    final vetsAsync = ref.watch(vetControllerProvider);

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
                _isEditMode ? 'EDIT VACCINATION RECORD' : 'ADD VACCINATION RECORD',
                style: GoogleFonts.barlow(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onSurface,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 20),
              
              // Vaccine Name
              _buildTextField(
                controller: _vaccineNameController,
                label: 'Vaccine Name',
                hint: 'e.g. Rabies, DHPP',
                validator: (v) =>
                    v == null || v.isEmpty ? 'Vaccine name is required' : null,
              ),
              const SizedBox(height: 14),

              // Date picker fields side by side
              Row(
                children: [
                  Expanded(
                    child: _buildClickableField(
                      controller: _dateController,
                      label: 'Date Given',
                      hint: 'Select Date',
                      onTap: _selectVaccinationDate,
                      icon: Icons.calendar_today_outlined,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildClickableField(
                      controller: _nextDueDateController,
                      label: 'Next Due Date (optional)',
                      hint: 'Select Date',
                      onTap: _selectNextDueDate,
                      icon: Icons.event_repeat_outlined,
                      onClear: _nextDueDateController.text.isNotEmpty
                          ? () {
                              setState(() {
                                _nextDueDate = null;
                                _nextDueDateController.clear();
                              });
                            }
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Vet Dropdown
              Text(
                'Assigned Veterinarian (optional)',
                style: GoogleFonts.barlow(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 6),
              vetsAsync.when(
                data: (vets) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedVetId,
                        isExpanded: true,
                        hint: Text(
                          'Select a Vet',
                          style: GoogleFonts.barlow(
                            fontSize: 14,
                            color: Colors.grey.withOpacity(0.6),
                          ),
                        ),
                        style: GoogleFonts.barlow(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                        items: [
                          DropdownMenuItem<String>(
                            value: null,
                            child: Text(
                              'None / Custom Vet',
                              style: GoogleFonts.barlow(color: Colors.grey),
                            ),
                          ),
                          ...vets.map((vet) {
                            return DropdownMenuItem<String>(
                              value: vet.id,
                              child: Text('${vet.name} (${vet.clinicName})'),
                            );
                          }),
                        ],
                        onChanged: (val) {
                          setState(() {
                            _selectedVetId = val;
                          });
                        },
                      ),
                    ),
                  );
                },
                loading: () => Container(
                  height: 48,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                error: (_, __) => Container(
                  height: 48,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Failed to load vets',
                    style: GoogleFonts.barlow(color: Colors.redAccent),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Notes
              _buildTextField(
                controller: _notesController,
                label: 'Notes (optional)',
                hint: 'e.g. Remained calm, slight redness at injection site',
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Submit button
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

  Widget _buildClickableField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required VoidCallback onTap,
    required IconData icon,
    VoidCallback? onClear,
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
          readOnly: true,
          onTap: onTap,
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
            suffixIcon: onClear != null
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                    onPressed: onClear,
                  )
                : Icon(icon, size: 18, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
