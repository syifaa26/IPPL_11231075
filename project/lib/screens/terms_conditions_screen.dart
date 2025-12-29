import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Syarat & Ketentuan'),
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
              'Syarat & Ketentuan Penggunaan Nutrix',
              style: AppTextStyles.h2.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Terakhir diperbarui: 18 Oktober 2025',
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: AppSpacing.xl),
            
            _buildSection(
              '1. Penerimaan Syarat',
              'Dengan menggunakan aplikasi Nutrix, Anda menyetujui syarat dan ketentuan ini. '
              'Jika Anda tidak setuju, harap jangan gunakan aplikasi ini.',
            ),
            
            _buildSection(
              '2. Penggunaan Aplikasi',
              'Anda setuju untuk:\n\n'
              '• Memberikan informasi yang akurat dan lengkap\n'
              '• Menjaga keamanan akun Anda\n'
              '• Tidak menyalahgunakan layanan\n'
              '• Tidak menggunakan aplikasi untuk tujuan ilegal\n'
              '• Mematuhi semua hukum yang berlaku',
            ),
            
            _buildSection(
              '3. Akun Pengguna',
              'Anda bertanggung jawab untuk:\n\n'
              '• Kerahasiaan password Anda\n'
              '• Semua aktivitas yang terjadi di akun Anda\n'
              '• Memberitahu kami jika ada akses tidak sah\n'
              '• Memastikan informasi akun tetap terkini',
            ),
            
            _buildSection(
              '4. Batasan Layanan',
              'Nutrix adalah alat bantu pelacakan nutrisi. Aplikasi ini:\n\n'
              '• BUKAN pengganti konsultasi medis profesional\n'
              '• Tidak memberikan diagnosis atau perawatan medis\n'
              '• Rekomendasi kalori bersifat umum dan perkiraan\n'
              '• Selalu konsultasikan dengan ahli kesehatan untuk keputusan diet',
            ),
            
            _buildSection(
              '5. Konten dan Kepemilikan',
              '• Semua konten aplikasi adalah milik Nutrix\n'
              '• Data yang Anda input tetap menjadi milik Anda\n'
              '• Anda memberikan kami lisensi untuk menggunakan data Anda untuk menyediakan layanan\n'
              '• Kami tidak mengklaim kepemilikan atas data pribadi Anda',
            ),
            
            _buildSection(
              '6. Pembatasan Tanggung Jawab',
              'Nutrix tidak bertanggung jawab atas:\n\n'
              '• Kerugian atau kerusakan dari penggunaan aplikasi\n'
              '• Keputusan kesehatan yang Anda buat berdasarkan aplikasi\n'
              '• Ketidakakuratan data atau kalkulasi\n'
              '• Gangguan layanan atau kehilangan data',
            ),
            
            _buildSection(
              '7. Penghentian Layanan',
              'Kami berhak untuk:\n\n'
              '• Menangguhkan atau menghentikan akun Anda\n'
              '• Menolak layanan kepada siapa pun\n'
              '• Mengubah atau menghentikan fitur aplikasi\n'
              '• Semua hal di atas tanpa pemberitahuan sebelumnya',
            ),
            
            _buildSection(
              '8. Perubahan Syarat',
              'Kami dapat mengubah syarat dan ketentuan ini kapan saja. '
              'Perubahan akan efektif setelah dipublikasikan dalam aplikasi. '
              'Penggunaan berkelanjutan Anda menunjukkan penerimaan terhadap perubahan.',
            ),
            
            _buildSection(
              '9. Hukum yang Berlaku',
              'Syarat dan ketentuan ini diatur oleh hukum Republik Indonesia. '
              'Setiap sengketa akan diselesaikan di pengadilan yang berwenang di Indonesia.',
            ),
            
            _buildSection(
              '10. Hubungi Kami',
              'Untuk pertanyaan tentang syarat dan ketentuan:\n\n'
              'Email: legal@nutrix.app\n'
              'Website: www.nutrix.app/terms\n'
              'Alamat: Jl. Contoh No. 123, Jakarta, Indonesia',
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
                    Icons.description_outlined,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Dengan menggunakan Nutrix, Anda menyetujui syarat dan ketentuan ini.',
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
