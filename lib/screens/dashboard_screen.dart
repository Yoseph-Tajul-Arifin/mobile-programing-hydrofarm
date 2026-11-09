import 'package:flutter/material.dart';
import 'package:hydrofarm_app/screens/login_screen.dart';
import 'package:hydrofarm_app/screens/perawatan/perawatan_screen.dart';
import 'package:hydrofarm_app/screens/tanaman/tanaman_screen.dart';
import 'package:hydrofarm_app/theme/app_colors.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'lib/assets/icon.png',
              width: 28,
              height: 28,
              fit: BoxFit.contain,
            ),

            const SizedBox(width: 10),

            const Text(
              'Dashboard',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),

        backgroundColor: Colors.white,
        elevation: 0,

        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout, color: Color(0xFF0B6B72), size: 26),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),

          const SizedBox(width: 8),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              'Selamat Datang di HydroFarm',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Kelola tanaman hidroponik dengan lebih mudah.',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),

            const SizedBox(height: 30),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,

                children: [
                  _dashboardCard(
                    context,
                    title: 'Tanaman',
                    icon: Icons.eco_outlined,
                    color: const Color(0xFF47B567),
                    onTap: () {
                      // Nanti dihubungkan ke TanamanScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TanamanScreen(),
                        ),
                      );
                    },
                  ),

                  _dashboardCard(
                    context,
                    title: 'Perawatan',
                    icon: Icons.calendar_month_outlined,
                    color: const Color(0xFF0B6B72),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PerawatanScreen(),
                        ),
                      );
                    },
                  ),

                  _dashboardCard(
                    context,
                    title: 'Monitoring',
                    icon: Icons.monitor_heart_outlined,
                    color: const Color(0xFF4BA3C7),
                    onTap: () {
                      // Nanti
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dashboardCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),

      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Padding(
          padding: const EdgeInsets.all(18),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              Container(
                width: 64,
                height: 64,

                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),

                child: Icon(icon, size: 34, color: color),
              ),

              const SizedBox(height: 16),

              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
