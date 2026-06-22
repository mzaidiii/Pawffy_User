import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pawffy/core/utils/image_picker_helper.dart';
import 'data/models/pet_model.dart';
import 'providers/pet_controller.dart';
import 'providers/medical_record_controller.dart';
import 'providers/vaccination_controller.dart';
import 'widgets/add_edit_pet_sheet.dart';
import 'widgets/add_edit_medical_record_sheet.dart';
import 'widgets/add_edit_vaccination_sheet.dart';
import '../vets/providers/vet_controller.dart';


class PetDetailScreen extends ConsumerStatefulWidget {
  final PetModel pet;
  const PetDetailScreen({super.key, required this.pet});

  @override
  ConsumerState<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends ConsumerState<PetDetailScreen> {
  int _selectedTab = 0; // 0 for Medical Records, 1 for Vaccinations

  @override
  Widget build(BuildContext context) {
    final petsAsync = ref.watch(petControllerProvider);
    final pet = petsAsync.asData?.value.firstWhere(
          (p) => p.id == widget.pet.id,
          orElse: () => widget.pet,
        ) ??
        widget.pet;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Theme.of(context).colorScheme.onSurface,
            size: 20,
          ),
        ),
        title: Text(
          pet.name.toUpperCase(),
          style: GoogleFonts.barlow(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onSurface,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => AddEditPetSheet(pet: pet),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () => _showDeleteDialog(pet.id),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image / icon
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE85D04).withOpacity(0.1),
                      shape: BoxShape.circle,
                      image: pet.imageUrl != null && pet.imageUrl!.isNotEmpty
                          ? DecorationImage(
                              image: ImagePickerHelper.getImageProvider(pet.imageUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: pet.imageUrl == null || pet.imageUrl!.isEmpty
                        ? Icon(
                            _iconForSpecies(pet.species),
                            size: 60,
                            color: const Color(0xFFE85D04),
                          )
                        : null,
                  ),

                ],
              ),
            ),
            const SizedBox(height: 24),

            // Basic info cards
            _InfoCard(
              title: 'Basic Information',
              children: [
                _InfoRow('Species', pet.species),
                _InfoRow('Breed', pet.breed),
                _InfoRow('Gender', pet.gender),
                _InfoRow('Age', '${pet.age} years'),
                _InfoRow('Weight', '${pet.weight} kg'),
                _InfoRow('Color', pet.color),
                _InfoRow('Vaccination Status', pet.vaccinationStatus),
              ],
            ),
            const SizedBox(height: 16),

            if (pet.medicalNotes != null && pet.medicalNotes!.isNotEmpty)
              _InfoCard(
                title: 'Medical Notes',
                children: [
                  Text(
                    pet.medicalNotes!,
                    style: GoogleFonts.barlow(
                      fontSize: 14,
                      height: 1.5,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 24),

            // Quick stats
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.calendar_today,
                    label: 'Bookings',
                    value: pet.bookingCount.toString(),
                    color: const Color(0xFF2196F3),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.medical_services,
                    label: 'Records',
                    value: pet.medicalRecordCount.toString(),
                    color: const Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Tabs Segment Switcher
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedTab == 0
                              ? const Color(0xFFE85D04)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Medical Records',
                          style: GoogleFonts.barlow(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _selectedTab == 0
                                ? Colors.white
                                : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedTab == 1
                              ? const Color(0xFFE85D04)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Vaccinations',
                          style: GoogleFonts.barlow(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _selectedTab == 1
                                ? Colors.white
                                : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Header Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedTab == 0 ? 'PET MEDICAL HISTORY' : 'VACCINATION LOGS',
                  style: GoogleFonts.barlow(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey,
                    letterSpacing: 0.5,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (_selectedTab == 0) {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => AddEditMedicalRecordSheet(petId: pet.id),
                      );
                    } else {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => AddEditVaccinationSheet(petId: pet.id),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE85D04).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.add_rounded,
                          size: 14,
                          color: Color(0xFFE85D04),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _selectedTab == 0 ? 'Add Record' : 'Log Vaccine',
                          style: GoogleFonts.barlow(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFE85D04),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Content List
            _selectedTab == 0
                ? _buildMedicalRecordsSection(context, ref, pet)
                : _buildVaccinationsSection(context, ref, pet),
          ],
        ),
      ),
    );
  }

  IconData _iconForSpecies(String species) {
    switch (species.toLowerCase()) {
      case 'dog':
        return Icons.pets_rounded;
      case 'cat':
        return Icons.catching_pokemon_rounded;
      case 'bird':
        return Icons.flutter_dash_rounded;
      default:
        return Icons.pets_rounded;
    }
  }

  void _showDeleteDialog(String petId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Pet?'),
        content: const Text(
          'This action cannot be undone. All associated data will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext); // Close dialog first

              final success = await ref
                  .read(petControllerProvider.notifier)
                  .deletePet(petId);

              if (!mounted) return;

              // Show snackbar from the remaining screen (detail or pets list)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? 'Pet deleted successfully'
                        : 'Failed to delete pet',
                  ),
                  backgroundColor: success ? Colors.green : Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                ),
              );

              if (success) {
                // Go back to pets list
                if (mounted) {
                  Navigator.pop(context);
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalRecordsSection(BuildContext context, WidgetRef ref, PetModel pet) {
    final recordsAsync = ref.watch(medicalRecordControllerProvider(pet.id));

    return recordsAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CircularProgressIndicator(color: Color(0xFFE85D04)),
        ),
      ),
      error: (err, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'Error: ${err.toString()}',
            style: GoogleFonts.barlow(color: Colors.redAccent),
          ),
        ),
      ),
      data: (records) {
        if (records.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(
                    Icons.folder_open_outlined,
                    size: 48,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No Medical Records yet.',
                    style: GoogleFonts.barlow(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: records.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final record = records[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          record.diagnosis ?? 'General Checkup',
                          style: GoogleFonts.barlow(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            DateFormat('MMM dd, yyyy').format(record.createdAt),
                            style: GoogleFonts.barlow(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, size: 18, color: Colors.grey),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onSelected: (val) {
                              if (val == 'edit') {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (_) => AddEditMedicalRecordSheet(
                                    petId: pet.id,
                                    record: record,
                                  ),
                                );
                              } else if (val == 'delete') {
                                _confirmDeleteMedicalRecord(context, ref, pet.id, record.id);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Text('Edit'),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete', style: TextStyle(color: Colors.redAccent)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (record.symptoms != null && record.symptoms!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.barlow(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        children: [
                          const TextSpan(
                            text: 'Symptoms: ',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                          ),
                          TextSpan(text: record.symptoms),
                        ],
                      ),
                    ),
                  ],
                  if (record.prescription != null && record.prescription!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.barlow(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        children: [
                          const TextSpan(
                            text: 'Prescription: ',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                          ),
                          TextSpan(text: record.prescription),
                        ],
                      ),
                    ),
                  ],
                  if (record.allergies != null && record.allergies!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.barlow(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        children: [
                          const TextSpan(
                            text: 'Allergies: ',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                          ),
                          TextSpan(text: record.allergies),
                        ],
                      ),
                    ),
                  ],
                  if (record.createdByVet != null && record.createdByVet!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.verified_user_outlined, size: 14, color: Color(0xFFE85D04)),
                        const SizedBox(width: 4),
                        Text(
                          'Created by Veterinarian',
                          style: GoogleFonts.barlow(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFE85D04),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (record.reportUrl != null && record.reportUrl!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: record.reportUrl!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Report link copied to clipboard!',
                              style: GoogleFonts.barlow(),
                            ),
                            backgroundColor: const Color(0xFFE85D04),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE85D04).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE85D04).withOpacity(0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.picture_as_pdf_outlined, size: 16, color: Color(0xFFE85D04)),
                            const SizedBox(width: 6),
                            Text(
                              'Copy Lab Report URL',
                              style: GoogleFonts.barlow(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFE85D04),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildVaccinationsSection(BuildContext context, WidgetRef ref, PetModel pet) {
    final vaccinationsAsync = ref.watch(vaccinationControllerProvider(pet.id));
    final vetsAsync = ref.watch(vetControllerProvider);

    return vaccinationsAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CircularProgressIndicator(color: Color(0xFFE85D04)),
        ),
      ),
      error: (err, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'Error: ${err.toString()}',
            style: GoogleFonts.barlow(color: Colors.redAccent),
          ),
        ),
      ),
      data: (vaccinations) {
        if (vaccinations.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(
                    Icons.vaccines_outlined,
                    size: 48,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No Vaccination records yet.',
                    style: GoogleFonts.barlow(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: vaccinations.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final vaccination = vaccinations[index];
            
            Color statusColor = Colors.grey;
            String statusText = '';
            
            if (vaccination.nextDueDate != null) {
              final difference = vaccination.nextDueDate!.difference(DateTime.now()).inDays;
              if (difference < 0) {
                statusColor = Colors.redAccent;
                statusText = 'Overdue';
              } else if (difference <= 30) {
                statusColor = const Color(0xFFE85D04);
                statusText = 'Due Soon';
              } else {
                statusColor = Colors.green;
                statusText = 'Upcoming';
              }
            }

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          vaccination.vaccineName,
                          style: GoogleFonts.barlow(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            DateFormat('MMM dd, yyyy').format(vaccination.vaccinationDate),
                            style: GoogleFonts.barlow(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, size: 18, color: Colors.grey),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onSelected: (val) {
                              if (val == 'edit') {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (_) => AddEditVaccinationSheet(
                                    petId: pet.id,
                                    vaccination: vaccination,
                                  ),
                                );
                              } else if (val == 'delete') {
                                _confirmDeleteVaccination(context, ref, pet.id, vaccination.id);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Text('Edit'),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete', style: TextStyle(color: Colors.redAccent)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (vaccination.nextDueDate != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          'Next Due Date: ${DateFormat('MMM dd, yyyy').format(vaccination.nextDueDate!)}',
                          style: GoogleFonts.barlow(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            statusText,
                            style: GoogleFonts.barlow(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (vaccination.vet != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.person_outline, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          'Administered by: Dr. ${vaccination.vet!.name} (${vaccination.vet!.clinicName ?? 'Clinic'})',
                          style: GoogleFonts.barlow(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ] else if (vaccination.vetId != null && vaccination.vetId!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.person_outline, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Builder(
                          builder: (context) {
                            final vets = vetsAsync.asData?.value ?? [];
                            final matchingVets = vets.where((v) => v.id == vaccination.vetId);
                            final String vetText = matchingVets.isNotEmpty
                                ? 'Dr. ${matchingVets.first.name} (${matchingVets.first.clinicName})'
                                : 'Registered Veterinarian';
                            return Text(
                              'Administered by: $vetText',
                              style: GoogleFonts.barlow(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                  if (vaccination.notes != null && vaccination.notes!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.02),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05)),
                      ),
                      child: Text(
                        vaccination.notes!,
                        style: GoogleFonts.barlow(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDeleteMedicalRecord(BuildContext context, WidgetRef ref, String petId, String recordId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Medical Record?'),
        content: const Text('Are you sure you want to delete this record? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final success = await ref
                  .read(medicalRecordControllerProvider(petId).notifier)
                  .deleteRecord(recordId);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Medical record deleted'
                          : 'Failed to delete medical record',
                    ),
                    backgroundColor: success ? Colors.green : Colors.redAccent,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteVaccination(BuildContext context, WidgetRef ref, String petId, String vaccinationId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Vaccination Log?'),
        content: const Text('Are you sure you want to delete this vaccination record? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final success = await ref
                  .read(vaccinationControllerProvider(petId).notifier)
                  .deleteVaccination(vaccinationId);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Vaccination record deleted'
                          : 'Failed to delete vaccination record',
                    ),
                    backgroundColor: success ? Colors.green : Colors.redAccent,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _InfoCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.barlow(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.barlow(fontSize: 14, color: Colors.grey),
          ),
          Text(
            value,
            style: GoogleFonts.barlow(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.barlow(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.barlow(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
