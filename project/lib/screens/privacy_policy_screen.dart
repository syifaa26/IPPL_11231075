import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Kebijakan Privasi'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kebijakan Privasi Nutrix',
              style: AppTextStyles.h2.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Terakhir diperbarui: 18 Oktober 2025',
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: AppSpacing.xl),
            
            _buildSection(
              '1. Informasi yang Kami Kumpulkan',
              'Kami mengumpulkan informasi yang Anda berikan saat membuat akun, termasuk:\n\n'
              '• Nama dan alamat email\n'
              '• Data kesehatan (berat badan, tinggi, umur, jenis kelamin)\n'
              '• Informasi nutrisi dan makanan yang Anda catat\n'
              '• Riwayat berat badan dan progress kesehatan\n'
              '• Preferensi dan pengaturan aplikasi',
            ),
            
            _buildSection(
              '2. Bagaimana Kami Menggunakan Informasi Anda',
              'Informasi yang dikumpulkan digunakan untuk:\n\n'
              '• Menyediakan layanan pelacakan kalori dan nutrisi\n'
              '• Menghitung kebutuhan kalori harian Anda\n'
              '• Menampilkan progress dan statistik kesehatan\n'
              '• Memberikan rekomendasi yang dipersonalisasi\n'
              '• Meningkatkan layanan kami',
            ),
            
            _buildSection(
              '3. Keamanan Data',
              'Kami berkomitmen melindungi data Anda dengan:\n\n'
              '• Enkripsi data saat transmisi\n'
              '• Penyimpanan data yang aman\n'
              '• Akses terbatas hanya untuk keperluan layanan\n'
              '• Tidak membagikan data Anda kepada pihak ketiga tanpa izin',
            ),
            
            _buildSection(
              '4. Hak Anda',
              'Anda memiliki hak untuk:\n\n'
              '• Mengakses data pribadi Anda\n'
              '• Mengubah atau memperbarui informasi\n'
              '• Menghapus akun dan semua data terkait\n'
              '• Mengekspor data Anda\n'
              '• Menolak penggunaan data tertentu',
            ),
            
            _buildSection(
              '5. Penyimpanan Data',
              'Data Anda disimpan selama akun Anda aktif. Jika Anda menghapus akun, '
              'semua data pribadi akan dihapus secara permanen dalam waktu 30 hari.',
            ),
            
            _buildSection(
              '6. Perubahan Kebijakan',
              'Kami dapat memperbarui kebijakan privasi ini dari waktu ke waktu. '
              'Perubahan signifikan akan diberitahukan melalui aplikasi atau email.',
            ),
            
            _buildSection(
              '7. Hubungi Kami',
              'Jika Anda memiliki pertanyaan tentang kebijakan privasi ini, '
              'silakan hubungi kami di:\n\n'
              'Email: privacy@nutrix.app\n'
              'Website: www.nutrix.app/privacy',
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.shield_outlined,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Privasi Anda adalah prioritas kami. Data kesehatan Anda akan selalu dilindungi.',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.h4.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            content,
            style: AppTextStyles.body2.copyWith(
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
