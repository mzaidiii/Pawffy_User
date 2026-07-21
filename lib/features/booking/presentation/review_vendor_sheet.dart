import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pawffy/core/storage/storage_service.dart';
import '../../vendors/providers/vendor_provider.dart';
import '../../vendors/providers/vendor_controller.dart';

class ReviewVendorSheet extends ConsumerStatefulWidget {
  final String bookingId;
  final String vendorId;
  final String vendorName;

  const ReviewVendorSheet({super.key, required this.bookingId, required this.vendorId, required this.vendorName});

  @override
  ConsumerState<ReviewVendorSheet> createState() => _ReviewVendorSheetState();
}

class _ReviewVendorSheetState extends ConsumerState<ReviewVendorSheet> with SingleTickerProviderStateMixin {
  final _comment = TextEditingController();
  late final AnimationController _pulse;
  int _rating = 0;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
  }

  @override
  void dispose() { _comment.dispose(); _pulse.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (_rating == 0 || _saving) return;
    setState(() => _saving = true);
    try {
      await ref.read(vendorServiceProvider).createReview(
        vendorId: widget.vendorId, bookingId: widget.bookingId, rating: _rating, comment: _comment.text.trim(),
      );
      await StorageService.markBookingReviewed(widget.bookingId);
      ref.invalidate(vendorReviewsProvider(widget.vendorId));
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
    } finally { if (mounted) setState(() => _saving = false); }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final inputBgColor = isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade100;
    final inputTextColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark ? Colors.grey.shade500 : Colors.grey.shade500;
    final handleColor = isDark ? Colors.grey.shade700 : Colors.grey.shade300;
    final unselectedStarColor = isDark ? Colors.grey.shade700 : Colors.grey.shade400;

    return Container(
      decoration: BoxDecoration(
        color: sheetBgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 18, 24, bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: handleColor,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 20),
            ScaleTransition(
              scale: Tween(begin: .82, end: 1.0).animate(
                CurvedAnimation(parent: _pulse, curve: Curves.easeOutBack),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Color(0xFFE85D04),
                size: 42,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'How was ${widget.vendorName}?',
              style: GoogleFonts.barlow(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Your review helps other pet parents.',
              style: GoogleFonts.barlow(color: subtextColor),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final selected = index < _rating;
                return GestureDetector(
                  onTap: () {
                    setState(() => _rating = index + 1);
                    _pulse.forward(from: 0);
                  },
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 180),
                    scale: selected ? 1.16 : 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        selected
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 42,
                        color: selected
                            ? const Color(0xFFFFB703)
                            : unselectedStarColor,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _comment,
              minLines: 3,
              maxLines: 4,
              style: GoogleFonts.barlow(color: inputTextColor, fontSize: 14),
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Tell us about your experience (optional)',
                hintStyle: GoogleFonts.barlow(color: hintColor, fontSize: 14),
                filled: true,
                fillColor: inputBgColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _rating == 0 || _saving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE85D04),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'SUBMIT REVIEW',
                        style: GoogleFonts.barlow(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
