import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdBanner extends StatelessWidget {
  const AdBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCCCCCC), width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.campaign_outlined,
            color: Color(0xFF888888),
            size: 24,
          ),
          const SizedBox(width: 10),
          Text(
            'Advertisement Space',
            style: GoogleFonts.barlow(
              color: const Color(0xFF888888),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
