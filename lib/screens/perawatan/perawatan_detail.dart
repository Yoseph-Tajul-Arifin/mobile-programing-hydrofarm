import 'package:flutter/material.dart';
import 'package:hydrofarm_app/screens/perawatan/perawatan_insert.dart';
import 'package:hydrofarm_app/theme/app_colors.dart';

import '../../models/m_tanaman.dart';
import '../../models/m_perawatan.dart';
import '../../services/perawatan_services.dart';

class PerawatanDetail extends StatefulWidget {
  final Tanaman tanaman;

  const PerawatanDetail({super.key, required this.tanaman});

  @override
  State<PerawatanDetail> createState() => _PerawatanDetailState();
}

class _PerawatanDetailState extends State<PerawatanDetail> {
  List<Perawatan> daftarPerawatan = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadPerawatan();
  }

  Future<void> loadPerawatan() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final hasil = await PerawatanService.getPerawatan();

      // Filter berdasarkan tanaman yang dipilih
      final filtered = hasil.where((item) {
        return item.idTanaman == widget.tanaman.idTanaman;
      }).toList();
      if (!mounted) return;
      setState(() {
        daftarPerawatan = filtered;
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

  Future<void> konfirmasiUpdateStatus(Perawatan perawatan) async {
    // Status Selesai tidak boleh diubah
    if (perawatan.status == 'Selesai') return;
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Status'),
          content: Text(
            'Ubah status perawatan '
            '${perawatan.jenisPerawatan} '
            'menjadi Selesai?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Ya, Selesai'),
            ),
          ],
        );
      },
    );

    if (konfirmasi != true || !mounted) return;
    try {
      final berhasil = await PerawatanService.updateStatusPerawatan(
        perawatan.idJadwal,
      );
      if (!mounted) return;
      if (berhasil) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status perawatan berhasil diperbarui')),
        );
        // Refresh riwayat perawatan
        await loadPerawatan();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal update status: $e')));
    }
  }

  Future<void> konfirmasiDeletePerawatan(Perawatan perawatan) async {
    // Status Selesai tidak boleh dihapus
    if (perawatan.status.trim() != 'Terjadwal') return;
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Perawatan'),
          content: Text(
            'Yakin ingin menghapus jadwal '
            '${perawatan.jenisPerawatan}?\n\n'
            'Data yang dihapus tidak dapat dikembalikan.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Ya, Hapus'),
            ),
          ],
        );
      },
    );
    if (konfirmasi != true || !mounted) return;
    try {
      final berhasil = await PerawatanService.deletePerawatan(
        perawatan.idJadwal,
      );
      if (!mounted) return;
      if (berhasil) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Jadwal perawatan berhasil dihapus')),
        );
        // Refresh daftar setelah Delete
        await loadPerawatan();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menghapus perawatan: $e')));
    }
  }

  Future<void> tampilkanMenuPerawatan(Perawatan perawatan) async {
    // Hanya perawatan Terjadwal yang boleh dikelola
    if (perawatan.status.trim() != 'Terjadwal') return;
    final pilihan = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Kelola Perawatan'),
          content: Text(
            'Pilih tindakan untuk '
            '${perawatan.jenisPerawatan}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton.icon(
              onPressed: () => Navigator.pop(context, 'delete'),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Hapus'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context, 'update'),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Ubah Status'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;
    if (pilihan == 'update') {
      await konfirmasiUpdateStatus(perawatan);
    } else if (pilihan == 'delete') {
      await konfirmasiDeletePerawatan(perawatan);
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
            onPressed: isLoading ? null : loadPerawatan,
          ),
        ],
      ),

      body: Column(
        children: [
          // Informasi tanaman
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0B6B72).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.tanaman.namaTanaman,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text('ID Tanaman: ${widget.tanaman.idTanaman}'),
              ],
            ),
          ),

          // Daftar riwayat perawatan
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Gagal mengambil data:\n'
                            '$errorMessage',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: loadPerawatan,
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  )
                : daftarPerawatan.isEmpty
                ? const Center(child: Text('Belum ada riwayat perawatan'))
                : RefreshIndicator(
                    onRefresh: loadPerawatan,
                    child:
                        // Old sebelum update status
                        // ListView.builder(
                        //   padding: const EdgeInsets.symmetric(horizontal: 16),
                        //   itemCount: daftarPerawatan.length,
                        //   itemBuilder: (context, index) {
                        //     final perawatan = daftarPerawatan[index];
                        //     return Card(
                        //       margin: const EdgeInsets.only(bottom: 12),
                        //       child: ListTile(
                        //         title: Text(
                        //           perawatan.jenisPerawatan,
                        //           style: const TextStyle(
                        //             fontWeight: FontWeight.bold,
                        //           ),
                        //         ),
                        //         subtitle: Column(
                        //           crossAxisAlignment: CrossAxisAlignment.start,
                        //           children: [
                        //             const SizedBox(height: 6),
                        //             Text(perawatan.tanggalPerawatan),
                        //             Text(perawatan.catatan),
                        //             const SizedBox(height: 6),
                        //             Text(
                        //               'Status: '
                        //               '${perawatan.status}',
                        //             ),
                        //           ],
                        //         ),
                        //         trailing: const Icon(Icons.chevron_right),
                        //       ),
                        //     );
                        //   },
                        // ),
                        // New Setelah Update Status
                        ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: daftarPerawatan.length,
                          itemBuilder: (context, index) {
                            final perawatan = daftarPerawatan[index];

                            // Cek apakah perawatan sudah selesai
                            final bool sudahSelesai =
                                perawatan.status.trim() == 'Selesai';

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                // Hanya status Terjadwal yang bisa diketuk
                                // Sebelumnya hanya untuk link Update saja
                                // onTap: sudahSelesai
                                //     ? null
                                //     : () => konfirmasiUpdateStatus(perawatan),

                                // Setelah combine Fungsi update dan delete
                                onTap: sudahSelesai
                                    ? null
                                    : () => tampilkanMenuPerawatan(perawatan),

                                title: Text(
                                  perawatan.jenisPerawatan,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 6),
                                    Text(perawatan.tanggalPerawatan),
                                    Text(perawatan.catatan),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Status: ${perawatan.status}',
                                      style: TextStyle(
                                        color: sudahSelesai
                                            ? Colors.green
                                            : Colors.orange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),

                                // Ikon berubah sesuai status
                                trailing: Icon(
                                  sudahSelesai
                                      ? Icons.lock_outline
                                      : Icons.chevron_right,
                                  color: sudahSelesai ? Colors.grey : null,
                                ),
                              ),
                            );
                          },
                        ),
                  ),
          ),
        ],
      ),

      // Tombol tambah disiapkan untuk tahap berikutnya
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
        onPressed: () async {
          final hasil = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => PerawatanInsert(tanaman: widget.tanaman),
            ),
          );

          // Refresh daftar setelah berhasil insert
          if (hasil == true && mounted) {
            loadPerawatan();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
