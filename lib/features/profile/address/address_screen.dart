import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'address_provider.dart';
import 'add_address_screen.dart';
import 'edit_address_screen.dart';

class AddressScreen extends ConsumerWidget {
  const AddressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addresses = ref.watch(addressProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back,
            color: Color.fromARGB(221, 221, 102, 4),
          ),
        ),
        title: Text(
          'ADDRESS',
          style: GoogleFonts.barlow(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onSurface,
            letterSpacing: 1,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // ── Address List ───────────────────────────
            Expanded(
              child: addresses.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(
                  child: Text(
                    'Error loading addresses: $err',
                    style: GoogleFonts.barlow(color: Colors.red),
                  ),
                ),
                data: (list) {
                  if (list.isEmpty) {
                    return _buildEmptyState(context);
                  }
                  return ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildAddressCard(
                        context,
                        ref,
                        list[index],
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // ── Add New Address Button ─────────────────
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddAddressScreen()),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFDDDDDD),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.add_rounded,
                      color: Color(0xFFE85D04),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Add New Address',
                      style: GoogleFonts.barlow(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFE85D04),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ── Address Card ──────────────────────────────────────
  Widget _buildAddressCard(
    BuildContext context,
    WidgetRef ref,
    AddressModel address,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: address.isDefault
              ? const Color(0xFFE85D04)
              : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Content ──────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      address.label,
                      style: GoogleFonts.barlow(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    if (address.isDefault) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF22C55E),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'Default',
                          style: GoogleFonts.barlow(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF22C55E),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  address.addressLine1,
                  style: GoogleFonts.barlow(
                    fontSize: 12,
                    color: const Color(0xFF888888),
                  ),
                ),
                if (address.addressLine2.isNotEmpty)
                  Text(
                    address.addressLine2,
                    style: GoogleFonts.barlow(
                      fontSize: 12,
                      color: const Color(0xFF888888),
                    ),
                  ),
                Text(
                  '${address.city}, ${address.state}',
                  style: GoogleFonts.barlow(
                    fontSize: 12,
                    color: const Color(0xFF888888),
                  ),
                ),
              ],
            ),
          ),

          // ── 3-dot Menu ────────────────────────────
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert_rounded,
              color: isDark ? Colors.white60 : Colors.black54,
              size: 20,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              if (value == 'default') {
                ref.read(addressProvider.notifier).setDefault(address.id);
              } else if (value == 'edit') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditAddressScreen(address: address),
                  ),
                );
              } else if (value == 'delete') {
                _showDeleteDialog(context, ref, address.id);
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'default',
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      size: 16,
                      color: Color(0xFF22C55E),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Set as Default',
                      style: GoogleFonts.barlow(fontSize: 13),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      size: 16,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                    const SizedBox(width: 8),
                    Text('Edit', style: GoogleFonts.barlow(fontSize: 13)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(
                      Icons.delete_outline,
                      size: 16,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Delete',
                      style: GoogleFonts.barlow(
                        fontSize: 13,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Delete Dialog ─────────────────────────────────────
  void _showDeleteDialog(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Address',
          style: GoogleFonts.barlow(fontWeight: FontWeight.w800),
        ),
        content: Text(
          'Are you sure you want to delete this address?',
          style: GoogleFonts.barlow(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.barlow(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(addressProvider.notifier).deleteAddress(id);
              Navigator.pop(context);
            },
            child: Text('Delete', style: GoogleFonts.barlow(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ── Empty State ───────────────────────────────────────
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off_outlined,
            size: 60,
            color: Colors.grey.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No addresses saved',
            style: GoogleFonts.barlow(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Add your first address below',
            style: GoogleFonts.barlow(
              fontSize: 13,
              color: const Color(0xFF888888),
            ),
          ),
        ],
      ),
    );
  }
}
