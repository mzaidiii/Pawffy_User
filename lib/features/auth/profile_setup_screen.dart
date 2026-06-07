import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  int _bioCharCount = 0;

  @override
  void initState() {
    super.initState();
    _bioController.addListener(() {
      setState(() => _bioCharCount = _bioController.text.length);
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
                      controller: _usernameController,
                      hint: 'Username',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 12),

                    // ── Bio Field ─────────────────────────────
                    Stack(
                      children: [
                        TextField(
                          controller: _bioController,
                          maxLines: 5,
                          maxLength: 150,
                          style: GoogleFonts.barlow(color: Colors.white),
                          buildCounter:
                              (
                                context, {
                                required currentLength,
                                required isFocused,
                                maxLength,
                              }) => null,
                          decoration: InputDecoration(
                            hintText: 'Bio',
                            hintStyle: GoogleFonts.barlow(
                              color: Colors.grey,
                              fontWeight: FontWeight.w400,
                            ),
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(bottom: 60),
                              child: Icon(
                                Icons.menu_book_outlined,
                                color: Colors.grey,
                                size: 20,
                              ),
                            ),
                            filled: true,
                            fillColor: const Color(0xFF232323),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFE85D04),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          right: 14,
                          child: Text(
                            '$_bioCharCount/150',
                            style: GoogleFonts.barlow(
                              color: Colors.grey,
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // ── SAVE CHANGES Button ───────────────────
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE85D04),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'SAVE CHANGES',
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
