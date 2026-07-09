import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../data/models/lost_found_model.dart';
import '../providers/lost_found_provider.dart';
import 'report_pet_screen.dart';
import 'report_details_screen.dart';

class LostFoundFeedScreen extends ConsumerStatefulWidget {
  const LostFoundFeedScreen({super.key});

  @override
  ConsumerState<LostFoundFeedScreen> createState() => _LostFoundFeedScreenState();
}

class _LostFoundFeedScreenState extends ConsumerState<LostFoundFeedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(lostFoundFeedProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const primaryColor = Color(0xFFE85D04);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'LOST & FOUND PETS',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.read(lostFoundFeedProvider.notifier).refreshFeed(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: primaryColor,
          labelStyle: GoogleFonts.barlow(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
          tabs: const [
            Tab(text: 'ALL'),
            Tab(text: 'LOST'),
            Tab(text: 'FOUND'),
          ],
        ),
      ),
      body: reportsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: primaryColor),
        ),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text(
                'Could not load feed',
                style: GoogleFonts.barlow(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.read(lostFoundFeedProvider.notifier).refreshFeed(),
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (reports) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildFeedList(reports, isDark, primaryColor),
              _buildFeedList(
                  reports.where((r) => r.reportType == 'lost').toList(),
                  isDark,
                  primaryColor),
              _buildFeedList(
                  reports.where((r) => r.reportType == 'found').toList(),
                  isDark,
                  primaryColor),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ReportPetScreen(),
            ),
          );
        },
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'REPORT A PET',
          style: GoogleFonts.barlow(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildFeedList(
      List<LostFoundReportModel> reports, bool isDark, Color primaryColor) {
    if (reports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No pet reports found',
              style: GoogleFonts.barlow(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.76,
      ),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final report = reports[index];
        final isLost = report.reportType == 'lost';

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ReportDetailsScreen(
                  reportId: report.id,
                  type: report.reportType,
                ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        child: report.images.isNotEmpty
                            ? Image.network(
                                report.images.first,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _fallbackImage(),
                              )
                            : _fallbackImage(),
                      ),
                      // Lost/Found Tag
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isLost
                                ? const Color(0xFFD90429)
                                : const Color(0xFF2B9348),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isLost ? 'LOST' : 'FOUND',
                            style: GoogleFonts.barlow(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Title and description
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isLost ? (report.name ?? 'Unknown') : 'Found ${report.breed}',
                        style: GoogleFonts.barlow(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${report.gender.toUpperCase()} • ${report.breed}',
                        style: GoogleFonts.barlow(
                          fontSize: 11,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 13,
                            color: primaryColor,
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              report.location.address,
                              style: GoogleFonts.barlow(
                                fontSize: 11,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMM d, yyyy').format(report.createdAt),
                        style: GoogleFonts.barlow(
                          fontSize: 9,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _fallbackImage() {
    return Container(
      color: const Color(0xFFE5E5E5),
      child: const Center(
        child: Icon(
          Icons.pets_rounded,
          size: 40,
          color: Color(0xFFCCCCCC),
        ),
      ),
    );
  }
}
