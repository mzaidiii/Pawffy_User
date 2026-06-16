import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'data/models/pet_model.dart';
import 'providers/pet_controller.dart';
import 'widgets/add_edit_pet_sheet.dart';

class PetDetailScreen extends ConsumerStatefulWidget {
  final PetModel pet;
  const PetDetailScreen({super.key, required this.pet});

  @override
  ConsumerState<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends ConsumerState<PetDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final pet = widget.pet; // we'll refresh if needed later

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
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFFE85D04).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _iconForSpecies(pet.species),
                  size: 60,
                  color: const Color(0xFFE85D04),
                ),
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

            // Future sections (placeholders for medical/vaccination tabs)
            Text(
              'MEDICAL RECORDS & VACCINATIONS',
              style: GoogleFonts.barlow(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.grey,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                'Coming soon...',
                style: TextStyle(color: Colors.grey),
              ),
            ),
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
