import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pawffy/features/vets/data/models/vet_model.dart';
import 'package:pawffy/features/pets/data/models/pet_model.dart';
import 'package:pawffy/features/pets/data/services/pet_service.dart';
import '../data/models/booking_model.dart';
import '../providers/booking_controller.dart';
import 'payment_summary_screen.dart';

class BookingDetailsScreen extends ConsumerStatefulWidget {
  final VetModel vet;
  final DateTime selectedDate;
  final String selectedSlot;
  final VetServiceModel selectedService;

  const BookingDetailsScreen({
    super.key,
    required this.vet,
    required this.selectedDate,
    required this.selectedSlot,
    required this.selectedService,
  });

  @override
  ConsumerState<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends ConsumerState<BookingDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _symptomsController = TextEditingController();
  final _notesController = TextEditingController();

  PetModel? _selectedPet;
  List<PetModel> _pets = [];
  bool _isLoadingPets = true;
  String? _petError;
  String? _selectedDuration;

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  Future<void> _loadPets() async {
    try {
      final pets = await PetService().getMyPets();
      setState(() {
        _pets = pets;
        if (pets.isNotEmpty) {
          _selectedPet = pets.first;
        }
        _isLoadingPets = false;
      });
    } catch (e) {
      setState(() {
        _petError = 'Failed to load pets: $e';
        _isLoadingPets = false;
      });
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _symptomsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitBooking() async {
    if (_selectedPet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a pet first')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final dateStr = DateFormat('yyyy-MM-dd').format(widget.selectedDate);

    // Map booking type (e.g., "vet" -> "veterinarian")
    String bookingType = widget.vet.serviceType.toLowerCase().trim();
    if (bookingType == 'vet') {
      bookingType = 'veterinarian';
    }

    // Convert booking time format from "10:00 AM" to 24-hour "10:00" format
    String formattedTime = widget.selectedSlot;
    try {
      final parsedTime = DateFormat('hh:mm a').parse(widget.selectedSlot);
      formattedTime = DateFormat('HH:mm').format(parsedTime);
    } catch (e) {
      debugPrint('Error formatting booking time: $e');
    }

    final bookingData = {
      'vetId': widget.vet.id,
      'serviceId': widget.selectedService.id,
      'petId': _selectedPet!.id,
      'bookingType': bookingType,
      'bookingDate': dateStr,
      'bookingTime': formattedTime,
      'reasonForVisit': _reasonController.text.trim(),
      'symptoms': _symptomsController.text.trim().isNotEmpty ? _symptomsController.text.trim() : null,
      'symptomsDuration': _selectedDuration,
      'notes': _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
    };

    try {
      final notifier = ref.read(bookingControllerProvider.notifier);
      final booking = await notifier.createBooking(bookingData);
      
      if (booking != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentSummaryScreen(booking: booking),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating booking: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFFE85D04);
    final bookingState = ref.watch(bookingControllerProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'BOOKING DETAILS',
          style: GoogleFonts.barlow(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
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
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Pet Selection Title
                          Text(
                            'SELECT PET',
                            style: GoogleFonts.barlow(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Colors.grey,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Pet Selector Widget
                          _buildPetSelector(isDark, primaryColor),
                          const SizedBox(height: 24),

                          // Form Title
                          Text(
                            'VISIT DETAILS',
                            style: GoogleFonts.barlow(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Colors.grey,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Reason Field
                          Text(
                            'Reason for Visit *',
                            style: GoogleFonts.barlow(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _reasonController,
                            decoration: const InputDecoration(
                              hintText: 'e.g., Annual vaccination, checkup...',
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Reason is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Symptoms Field
                          Text(
                            'Symptoms *',
                            style: GoogleFonts.barlow(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _symptomsController,
                            decoration: const InputDecoration(
                              hintText: 'e.g., Lethargy, scratching, coughing...',
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                  return 'Symptoms list is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Symptoms Duration Field
                          Text(
                            'Symptoms Duration *',
                            style: GoogleFonts.barlow(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            value: _selectedDuration,
                            hint: Text(
                              'Select symptoms duration',
                              style: GoogleFonts.barlow(
                                color: Colors.grey,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'Today', child: Text('Today')),
                              DropdownMenuItem(value: '2 Days ago', child: Text('2 Days ago')),
                              DropdownMenuItem(value: 'A week ago', child: Text('A week ago')),
                              DropdownMenuItem(value: 'More than a week', child: Text('More than a week')),
                            ],
                            onChanged: (val) {
                              setState(() {
                                _selectedDuration = val;
                              });
                            },
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Symptoms duration is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Additional Notes
                          Text(
                            'Additional Notes *',
                            style: GoogleFonts.barlow(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _notesController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              hintText: 'e.g., Pet is a bit anxious around new people...',
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Additional notes are required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),

                // Booking Submit CTA
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: ElevatedButton(
                    onPressed: bookingState.isLoading ? null : _submitBooking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(27),
                      ),
                    ),
                    child: Text(
                      'PROCEED TO PAYMENT',
                      style: GoogleFonts.barlow(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Loading spinner overlay
          if (bookingState.isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFFE85D04)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPetSelector(bool isDark, Color primaryColor) {
    if (_isLoadingPets) {
      return SizedBox(
        height: 80,
        child: Center(
          child: CircularProgressIndicator(color: primaryColor),
        ),
      );
    }

    if (_petError != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          _petError!,
          style: GoogleFonts.barlow(color: Colors.red),
        ),
      );
    }

    if (_pets.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            const Icon(Icons.pets_rounded, color: Colors.grey, size: 32),
            const SizedBox(height: 8),
            Text(
              'No pets found',
              style: GoogleFonts.barlow(fontWeight: FontWeight.w700, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              'Please add a pet in your Profile screen first.',
              style: GoogleFonts.barlow(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _pets.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final pet = _pets[index];
          final isSelected = _selectedPet?.id == pet.id;

          return InkWell(
            onTap: () {
              setState(() {
                _selectedPet = pet;
              });
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 140,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryColor
                    : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? primaryColor : Colors.transparent,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: isSelected ? Colors.white24 : primaryColor.withOpacity(0.1),
                    backgroundImage: pet.imageUrl != null ? NetworkImage(pet.imageUrl!) : null,
                    child: pet.imageUrl == null
                        ? Icon(Icons.pets_rounded, color: isSelected ? Colors.white : primaryColor, size: 18)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pet.name,
                          style: GoogleFonts.barlow(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          pet.breed.isNotEmpty ? pet.breed : pet.species,
                          style: GoogleFonts.barlow(
                            fontSize: 11,
                            color: isSelected ? Colors.white70 : Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
