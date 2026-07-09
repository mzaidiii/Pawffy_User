import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pawffy/features/message/chat_screen.dart';
import '../providers/lost_found_provider.dart';
import '../data/models/lost_found_model.dart';

class ReportDetailsScreen extends ConsumerWidget {
  final String reportId;
  final String type; // "lost" | "found"

  const ReportDetailsScreen({
    super.key,
    required this.reportId,
    required this.type,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = type.toLowerCase() == 'lost'
        ? ref.watch(lostReportDetailsProvider(reportId))
        : ref.watch(foundReportDetailsProvider(reportId));

    final isDark = Theme.of(context).brightness == Brightness.dark;
    const primaryColor = Color(0xFFE85D04);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'REPORT DETAILS',
          style: GoogleFonts.barlow(
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: detailAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: primaryColor),
        ),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning_amber_rounded, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text(
                'Failed to load details: $err',
                style: GoogleFonts.barlow(color: Colors.grey),
              ),
            ],
          ),
        ),
        data: (report) {
          final isLost = report.reportType == 'lost';

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Header
                Stack(
                  children: [
                    Container(
                      height: 250,
                      width: double.infinity,
                      color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFEEEEEE),
                      child: report.images.isNotEmpty
                          ? Image.network(
                              report.images.first,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _fallbackIcon(),
                            )
                          : _fallbackIcon(),
                    ),
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isLost ? const Color(0xFFD90429) : const Color(0xFF2B9348),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isLost ? 'LOST' : 'FOUND',
                          style: GoogleFonts.barlow(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title / Name
                      Text(
                        isLost ? (report.name ?? 'Bruno') : 'Found ${report.breed}',
                        style: GoogleFonts.barlow(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Reported on ${DateFormat('MMM d, yyyy').format(report.createdAt)}',
                        style: GoogleFonts.barlow(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Attributes Grid
                      _buildAttributes(report, isDark),
                      const SizedBox(height: 24),

                      // Location / Address Section
                      Text(
                        isLost ? 'LAST SEEN LOCATION' : 'FOUND LOCATION',
                        style: GoogleFonts.barlow(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on_rounded, color: primaryColor, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              report.location.address,
                              style: GoogleFonts.barlow(
                                fontSize: 15,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Description
                      Text(
                        'DESCRIPTION',
                        style: GoogleFonts.barlow(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        report.description,
                        style: GoogleFonts.barlow(
                          fontSize: 15,
                          height: 1.5,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Contact Reporter Action Card
                      _buildReporterCard(context, report, isDark, primaryColor),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _fallbackIcon() {
    return const Center(
      child: Icon(
        Icons.pets_rounded,
        size: 72,
        color: Color(0xFFCCCCCC),
      ),
    );
  }

  Widget _buildAttributes(LostFoundReportModel report, bool isDark) {
    final items = [
      {'label': 'Breed', 'value': report.breed, 'icon': Icons.category_rounded},
      {'label': 'Gender', 'value': report.gender, 'icon': Icons.wc_rounded},
      {'label': 'Color', 'value': report.color, 'icon': Icons.palette_rounded},
      if (report.age != null)
        {'label': 'Age', 'value': '${report.age} yrs', 'icon': Icons.cake_rounded},
      if (report.height != null && report.height!.isNotEmpty)
        {'label': 'Height', 'value': report.height!, 'icon': Icons.height_rounded},
      if (report.weight != null && report.weight!.isNotEmpty)
        {'label': 'Weight', 'value': report.weight!, 'icon': Icons.monitor_weight_rounded},
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items.map((item) {
        return Container(
          width: 100,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF262626) : const Color(0xFFF9F9F9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                item['icon'] as IconData,
                color: const Color(0xFFE85D04),
                size: 18,
              ),
              const SizedBox(height: 6),
              Text(
                item['label'] as String,
                style: GoogleFonts.barlow(
                  fontSize: 10,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item['value'] as String,
                style: GoogleFonts.barlow(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReporterCard(
      BuildContext context, LostFoundReportModel report, bool isDark, Color primaryColor) {
    final String repName = report.reporterName ?? 'Helpful User';
    final String repEmail = report.reporterEmail ?? 'reporter@pawffy.com';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF222222) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'REPORTER CONTACT',
            style: GoogleFonts.barlow(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Colors.grey,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: primaryColor.withOpacity(0.2),
                child: Text(
                  repName.substring(0, 1).toUpperCase(),
                  style: GoogleFonts.barlow(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      repName,
                      style: GoogleFonts.barlow(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      repEmail,
                      style: GoogleFonts.barlow(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Actions Row
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Start in-app chat with reporter
                    // We generate receiverId: standard reporterEmail or ID
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          receiverId: report.reporterId ?? report.id,
                          receiverName: repName,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                  label: const Text('MESSAGE'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: GoogleFonts.barlow(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
