import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'settings/widgets/settings_appbar.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const SettingsAppBar(title: 'PAYMENTS & WALLET'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // ── Wallet Card with Gradient ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE85D04), Color(0xFFF77F00)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE85D04).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pawffy Balance',
                        style: GoogleFonts.barlow(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      const Icon(Icons.pets, color: Colors.white, size: 24),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '₹750.00',
                    style: GoogleFonts.barlow(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Active Wallet / Secure',
                    style: GoogleFonts.barlow(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Quick Actions Row ──
            Row(
              children: [
                Expanded(
                  child: _buildActionBtn(
                    context,
                    icon: Icons.add_card,
                    label: 'Add Money',
                    onTap: () => _showMockupAction(context, 'Add Money'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionBtn(
                    context,
                    icon: Icons.history,
                    label: 'Refunds',
                    onTap: () => _showMockupAction(context, 'Refund History'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionBtn(
                    context,
                    icon: Icons.account_balance,
                    label: 'Send to Bank',
                    onTap: () => _showMockupAction(context, 'Send to Bank'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ── Transaction History Title ──
            Text(
              'Recent Transactions',
              style: GoogleFonts.barlow(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 14),

            // ── Transactions List ──
            _buildTransactionTile(
              context,
              title: 'Refund for Booking #1024',
              date: 'June 20, 2026',
              amount: '+₹250.00',
              isCredit: true,
            ),
            _buildTransactionTile(
              context,
              title: 'Payment for Vet Consultation',
              date: 'June 18, 2026',
              amount: '-₹500.00',
              isCredit: false,
            ),
            _buildTransactionTile(
              context,
              title: 'Money Added to Wallet',
              date: 'June 12, 2026',
              amount: '+₹1,000.00',
              isCredit: true,
            ),
            _buildTransactionTile(
              context,
              title: 'Payment for Grooming Service',
              date: 'June 05, 2026',
              amount: '-₹750.00',
              isCredit: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBtn(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFFE85D04), size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.barlow(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTile(
    BuildContext context, {
    required String title,
    required String date,
    required String amount,
    required bool isCredit,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.08),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isCredit
                  ? const Color(0xFF22C55E).withOpacity(0.12)
                  : const Color(0xFFEF4444).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCredit ? Icons.arrow_downward : Icons.arrow_upward,
              color: isCredit ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.barlow(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: GoogleFonts.barlow(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.barlow(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: isCredit ? const Color(0xFF22C55E) : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  void _showMockupAction(BuildContext context, String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$action feature is currently in mockup sandbox mode.',
          style: GoogleFonts.barlow(),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFFE85D04),
      ),
    );
  }
}
