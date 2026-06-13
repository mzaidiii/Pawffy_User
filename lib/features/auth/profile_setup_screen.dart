import 'package:pawffy/features/auth/providers/auth_controller.dart';
import 'package:pawffy/features/home/home_screen.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  final String name;
  final String email;
  final String password;

  const ProfileSetupScreen({
    super.key,
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // ── Background Image ──────────────────────────────────
          RepaintBoundary(
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: Image.asset(
                'android/assets/ProfileSetUp.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // ── Interactive Widgets ───────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

                    // ── Back Button ───────────────────────────
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),

                    // ── Space to clear bg text ────────────────
                    SizedBox(height: size.height * 0.30),

                    // ── Avatar Upload ─────────────────────────
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF2A2A2A),
                              border: Border.all(
                                color: const Color(0xFF333333),
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.person_outline,
                              color: Colors.grey,
                              size: 44,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {},
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFE85D04),
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
                    const SizedBox(height: 28),

                    // ── Username Field ────────────────────────
                    _buildTextField(
                      controller: _phoneController,
                      hint: 'Phone Number',
                      icon: Icons.phone_outlined,
                    ),
                    const SizedBox(height: 12),

                    _buildTextField(
                      controller: _cityController,
                      hint: 'City',
                      icon: Icons.location_city_outlined,
                    ),
                    const SizedBox(height: 12),

                    _buildTextField(
                      controller: _stateController,
                      hint: 'State',
                      icon: Icons.map_outlined,
                    ),
                    const SizedBox(height: 28),
                    // ── SAVE CHANGES Button ───────────────────
                    ElevatedButton(
                      onPressed: () async {
                        final phone = _phoneController.text.trim();
                        final city = _cityController.text.trim();
                        final userState = _stateController.text.trim();

                        if (phone.isEmpty ||
                            city.isEmpty ||
                            userState.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please fill all fields'),
                            ),
                          );
                          return;
                        }

                        if (phone.length < 10) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Enter a valid phone number'),
                            ),
                          );
                          return;
                        }

                        try {
                          // STEP 1: Register User
                          final registerSuccess = await ref
                              .read(authControllerProvider.notifier)
                              .register(
                                name: widget.name,
                                email: widget.email,
                                password: widget.password,
                              );

                          if (!registerSuccess) {
                            final error = ref.read(authControllerProvider);

                            if (!mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  error.hasError
                                      ? error.error.toString().replaceFirst(
                                          'Exception: ',
                                          '',
                                        )
                                      : 'Registration failed',
                                ),
                              ),
                            );

                            return;
                          }

                          // STEP 2: Update Profile
                          final profileSuccess = await ref
                              .read(authControllerProvider.notifier)
                              .updateProfile(
                                name: widget.name,
                                phone: phone,
                                city: city,
                                userState: userState,
                              );

                          if (!mounted) return;

                          if (!profileSuccess) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to update profile'),
                              ),
                            );
                            return;
                          }

                          // STEP 3: Go Home
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HomeScreen(),
                            ),
                            (route) => false,
                          );
                        } catch (e) {
                          if (!mounted) return;

                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(e.toString())));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE85D04),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: authState.isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Complete Profile',
                                  style: GoogleFonts.barlow(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_outward, size: 18),
                              ],
                            ),
                    ),

                    // ── keyboard padding ──────────────────────
                    SizedBox(
                      height: MediaQuery.of(context).viewInsets.bottom + 30,
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

  // ── Reusable Text Field ─────────────────────────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      style: GoogleFonts.barlow(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.barlow(
          color: Colors.grey,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: Icon(icon, color: Colors.grey, size: 20),
        filled: true,
        fillColor: const Color(0xFF232323),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE85D04), width: 1.5),
        ),
      ),
    );
  }
}
