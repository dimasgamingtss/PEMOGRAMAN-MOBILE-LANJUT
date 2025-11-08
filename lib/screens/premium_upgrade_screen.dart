import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/subscription_service.dart';
import '../services/sync_service.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import 'dashboard_screen.dart';

/// Screen untuk upgrade ke Premium dengan payment gateway Duitku
class PremiumUpgradeScreen extends StatefulWidget {
  const PremiumUpgradeScreen({super.key});

  @override
  State<PremiumUpgradeScreen> createState() => _PremiumUpgradeScreenState();
}

class _PremiumUpgradeScreenState extends State<PremiumUpgradeScreen> {
  User? _currentUser;
  bool _isLoading = false;
  bool _isProcessing = false;
  String? _selectedPaymentMethod;
  final List<String> _paymentMethods = [
    'Bank Transfer',
    'E-Wallet (OVO/GoPay/Dana)',
    'Credit Card',
    'QRIS',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await AuthService.getCurrentUser();
    setState(() {
      _currentUser = user;
    });
  }

  Future<void> _upgradeToPremium() async {
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih metode pembayaran terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Proses payment via Duitku (simulasi)
      final paymentResult = await SubscriptionService.processDuitkuPayment(
        username: _currentUser!.username,
        amount: SubscriptionService.premiumPrice,
        paymentMethod: _selectedPaymentMethod!,
      );

      if (paymentResult['status'] == 'success') {
        // Upgrade user ke premium
        final upgradeResult = await SubscriptionService.upgradeToPremium(
          _currentUser!.username,
          _selectedPaymentMethod!,
        );

        if (upgradeResult['success']) {
          // Migrasi data lokal ke cloud
          final migrateResult = await SyncService.migrateToCloud(
            _currentUser!.username,
          );

          // Update user di AuthService
          final updatedUser = _currentUser!.copyWith(
            isPremium: true,
            premiumPaymentId: upgradeResult['paymentId'],
          );
          await AuthService.updateUser(updatedUser);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Upgrade ke Premium berhasil!'),
                backgroundColor: Colors.green,
              ),
            );

            // Kembali ke dashboard
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(upgradeResult['message'] ?? 'Upgrade gagal'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(paymentResult['message'] ?? 'Payment gagal'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = _currentUser?.isPremiumActive ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upgrade ke Premium'),
        backgroundColor: Colors.amber[700],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isPremium) ...[
                    Card(
                      color: Colors.green,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            const Icon(Icons.verified, color: Colors.white),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Text(
                                'Anda sudah memiliki akun Premium!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber[700], size: 32),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Text(
                                  'Fitur Premium',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _buildFeatureItem(
                            Icons.cloud_sync,
                            'Sinkronisasi Online',
                            'Data tersimpan di cloud, aman dan dapat diakses dari mana saja',
                          ),
                          const SizedBox(height: 16),
                          _buildFeatureItem(
                            Icons.devices,
                            'Multi-Device (3 Perangkat)',
                            'Login hingga 3 perangkat berbeda secara bersamaan',
                          ),
                          const SizedBox(height: 16),
                          _buildFeatureItem(
                            Icons.block,
                            'Tanpa Iklan',
                            'Pengalaman tanpa gangguan iklan',
                          ),
                          const SizedBox(height: 16),
                          _buildFeatureItem(
                            Icons.backup,
                            'Backup & Restore Otomatis',
                            'Data otomatis di-backup ke cloud',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Harga Premium',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Durasi:',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                '${SubscriptionService.premiumDurationDays} hari',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Harga:',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                'Rp ${NumberFormat('#,###').format(SubscriptionService.premiumPrice)}',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Metode Pembayaran',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ..._paymentMethods.map((method) => RadioListTile<String>(
                                title: Text(method),
                                value: method,
                                groupValue: _selectedPaymentMethod,
                                onChanged: isPremium
                                    ? null
                                    : (value) {
                                        setState(() {
                                          _selectedPaymentMethod = value;
                                        });
                                      },
                              )),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (!isPremium)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isProcessing ? null : _upgradeToPremium,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber[700],
                          foregroundColor: Colors.white,
                        ),
                        child: _isProcessing
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Upgrade Sekarang',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  const Text(
                    'Pembayaran diproses melalui Duitku Payment Gateway yang aman dan terpercaya.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.blue, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

