import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/pet_controller.dart';
import 'data/models/pet_model.dart';
import 'widgets/add_edit_pet_sheet.dart';
import 'pet_detail_screen.dart';

class PetsScreen extends ConsumerWidget {
  const PetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petsAsync = ref.watch(petControllerProvider);

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
          'MY PETS',
          style: GoogleFonts.barlow(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onSurface,
            letterSpacing: 0.5,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFE85D04),
        shape: const CircleBorder(),
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const AddEditPetSheet(),
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: petsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.grey, size: 48),
              const SizedBox(height: 12),
              Text(
                'Could not load pets',
                style: GoogleFonts.barlow(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => ref.read(petControllerProvider.notifier).refresh(),
                child: Text(
                  'Try again',
                  style: GoogleFonts.barlow(
                    color: const Color(0xFFE85D04),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        data: (pets) {
          if (pets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.pets_rounded,
                    size: 64,
                    color: const Color(0xFFE85D04).withOpacity(0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No pets yet!',
                    style: GoogleFonts.barlow(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tap the + button to add your first pet.',
                    style: GoogleFonts.barlow(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: const Color(0xFFE85D04),
            onRefresh: () => ref.read(petControllerProvider.notifier).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: pets.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final pet = pets[index];
                return _PetCard(pet: pet);
              },
            ),
          );
        },
      ),
    );
  }
}

class _PetCard extends ConsumerWidget {
  final PetModel pet;
  const _PetCard({required this.pet});

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PetDetailScreen(pet: pet)),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Species icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFE85D04).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _iconForSpecies(pet.species),
                color: const Color(0xFFE85D04),
                size: 28,
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.name,
                    style: GoogleFonts.barlow(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${pet.breed} • ${pet.species}',
                    style: GoogleFonts.barlow(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _Badge(label: '${pet.age}y', icon: Icons.cake_outlined),
                      const SizedBox(width: 6),
                      _Badge(
                        label: '${pet.weight}kg',
                        icon: Icons.monitor_weight_outlined,
                      ),
                      const SizedBox(width: 6),
                      _Badge(
                        label: pet.gender,
                        icon: pet.gender.toLowerCase() == 'male'
                            ? Icons.male_rounded
                            : Icons.female_rounded,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Counts + arrow
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.grey,
                ),
                const SizedBox(height: 8),
                if (pet.bookingCount > 0)
                  _CountBadge(
                    count: pet.bookingCount,
                    label: 'bookings',
                    color: const Color(0xFF2196F3),
                  ),
                if (pet.medicalRecordCount > 0) ...[
                  const SizedBox(height: 4),
                  _CountBadge(
                    count: pet.medicalRecordCount,
                    label: 'records',
                    color: const Color(0xFF4CAF50),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final IconData icon;
  const _Badge({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: Colors.grey),
          const SizedBox(width: 3),
          Text(
            label,
            style: GoogleFonts.barlow(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  const _CountBadge({
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$count $label',
        style: GoogleFonts.barlow(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
