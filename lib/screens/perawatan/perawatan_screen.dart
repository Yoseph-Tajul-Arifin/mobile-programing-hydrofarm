import 'package:flutter/material.dart';
import 'package:hydrofarm_app/screens/perawatan/perawatan_detail.dart';
import 'package:hydrofarm_app/theme/app_colors.dart';

import '../../models/m_tanaman.dart';
import '../../services/tanaman_services.dart';

class PerawatanScreen extends StatefulWidget {
  const PerawatanScreen({super.key});

  @override
  State<PerawatanScreen> createState() => _PerawatanScreenState();
}

class _PerawatanScreenState extends State<PerawatanScreen> {
  List<Tanaman> daftarTanaman = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadTanaman();
  }

  // Mengambil daftar tanaman dari Google Spreadsheet
  Future<void> loadTanaman() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final hasil = await TanamanService.getTanaman();
      if (!mounted) return;
      setState(() {
        daftarTanaman = hasil;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'lib/assets/logo.png',
              width: 38,
              height: 38,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 10),

            const Text(
              'Perawatan',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: isLoading ? null : loadTanaman,
          ),
        ],
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Gagal mengambil data:\n$errorMessage',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: loadTanaman,
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            )
          : daftarTanaman.isEmpty
          ? const Center(child: Text('Belum ada data tanaman'))
          : RefreshIndicator(
              onRefresh: loadTanaman,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: daftarTanaman.length,
                itemBuilder: (context, index) {
                  final tanaman = daftarTanaman[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF0B6B72)
                            .withValues(alpha: 0.1),
                        child: const Icon(Icons.eco, color: Color(0xFF0B6B72)),
                      ),
                      title: Text(
                        tanaman.namaTanaman,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${tanaman.idTanaman} • '
                        '${tanaman.jenisTanaman}',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // Navigasi ke riwayat perawatan
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PerawatanDetail(tanaman: tanaman),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }
}
