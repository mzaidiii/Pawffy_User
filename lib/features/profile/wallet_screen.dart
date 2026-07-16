import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'settings/widgets/settings_appbar.dart';
import 'wallet_controller.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  final _amountController = TextEditingController();
  bool _isActionLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String _formatTxDate(String rawDate) {
    try {
      final parsed = DateTime.parse(rawDate).toLocal();
      return DateFormat('MMM dd, yyyy - hh:mm a').format(parsed);
    } catch (_) {
      return rawDate;
    }
  }

  void _showTopUpDialog(BuildContext context) {
    _amountController.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Top Up Wallet',
          style: GoogleFonts.barlow(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter the amount you wish to add to your Pawffy Wallet via card payment:',
              style: GoogleFonts.barlow(fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: GoogleFonts.barlow(),
              decoration: InputDecoration(
                prefixText: '\$ ',
                hintText: '0.00',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'CANCEL',
              style: GoogleFonts.barlow(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () async {
              final val = double.tryParse(_amountController.text.trim());
              if (val == null || val <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid amount')),
                );
                return;
              }
              Navigator.pop(ctx);
              _processTopUp(val);
            },
            child: Text(
              'PROCEED',
              style: GoogleFonts.barlow(color: const Color(0xFFE85D04), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showWithdrawDialog(BuildContext context, double currentBalance) {
    _amountController.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Withdraw Funds',
          style: GoogleFonts.barlow(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter the amount you wish to send to your linked bank account:',
              style: GoogleFonts.barlow(fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: GoogleFonts.barlow(),
              decoration: InputDecoration(
                prefixText: '\$ ',
                hintText: '0.00',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'CANCEL',
              style: GoogleFonts.barlow(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () async {
              final val = double.tryParse(_amountController.text.trim());
              if (val == null || val <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid amount')),
                );
                return;
              }
              if (val > currentBalance) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Insufficient balance')),
                );
                return;
              }
              Navigator.pop(ctx);
              _processWithdraw(val);
            },
            child: Text(
              'WITHDRAW',
              style: GoogleFonts.barlow(color: const Color(0xFFE85D04), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processTopUp(double amount) async {
    setState(() => _isActionLoading = true);
    final success = await ref
        .read(walletControllerProvider.notifier)
        .topUpWallet(amount: amount);
    setState(() => _isActionLoading = false);

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wallet topped up successfully!'), backgroundColor: Colors.green),
      );
    } else {
      final errorState = ref.read(walletControllerProvider);
      final errorMsg = errorState.hasError
          ? errorState.error.toString().replaceFirst('Exception: ', '')
          : 'Payment failed or cancelled';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: Colors.redAccent),
      );
    }
  }

  Future<void> _processWithdraw(double amount) async {
    setState(() => _isActionLoading = true);
    final success = await ref
        .read(walletControllerProvider.notifier)
        .withdrawWallet(amount: amount);
    setState(() => _isActionLoading = false);

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Withdrawal request processed successfully!'), backgroundColor: Colors.green),
      );
    } else {
      final errorState = ref.read(walletControllerProvider);
      final errorMsg = errorState.hasError
          ? errorState.error.toString().replaceFirst('Exception: ', '')
          : 'Withdrawal failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletAsync = ref.watch(walletControllerProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const SettingsAppBar(title: 'PAYMENTS & WALLET'),
      body: _isActionLoading
          ? const Center(child: CircularProgressIndicator())
          : walletAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'Failed to load wallet data: $err',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.barlow(color: Colors.red, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              data: (wallet) {
                return SingleChildScrollView(
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
                              '\$${wallet.balance.toStringAsFixed(2)}',
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
                              onTap: () => _showTopUpDialog(context),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildActionBtn(
                              context,
                              icon: Icons.history,
                              label: 'Refunds',
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Refund history is loaded inside the transactions below.')),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildActionBtn(
                              context,
                              icon: Icons.account_balance,
                              label: 'Send to Bank',
                              onTap: () => _showWithdrawDialog(context, wallet.balance),
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
                      wallet.transactions.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 40.0),
                                child: Text(
                                  'No transactions yet.',
                                  style: GoogleFonts.barlow(color: Colors.grey),
                                ),
                              ),
                            )
                          : Column(
                              children: wallet.transactions.map((tx) {
                                final isCredit = tx.type == 'credit';
                                return _buildTransactionTile(
                                  context,
                                  title: tx.description,
                                  date: _formatTxDate(tx.date),
                                  amount: '${isCredit ? '+' : '-'}\$${tx.amount.toStringAsFixed(2)}',
                                  isCredit: isCredit,
                                );
                              }).toList(),
                            ),
                    ],
                  ),
                );
              },
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
}
