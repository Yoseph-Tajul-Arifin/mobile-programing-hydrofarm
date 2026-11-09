import 'package:flutter/material.dart';

import '../../models/m_tanaman.dart';
import '../../models/m_perawatan.dart';
import '../../services/perawatan_services.dart';

class PerawatanInsert extends StatefulWidget {
  final Tanaman tanaman;

  const PerawatanInsert({super.key, required this.tanaman});

  @override
  State<PerawatanInsert> createState() => _PerawatanInsertState();
}

class _PerawatanInsertState extends State<PerawatanInsert> {
  final _formKey = GlobalKey<FormState>();

  final tanggalController = TextEditingController();
  final catatanController = TextEditingController();

  String? jenisPerawatan;
  String status = 'Terjadwal';

  bool isSaving = false;

  final List<String> daftarJenis = [
    'Nutrisi',
    'Pembersihan',
    'Pengecekan Air',
    'Pengecekan Tanaman',
  ];

  final List<String> daftarStatus = ['Terjadwal', 'Selesai'];

  @override
  void initState() {
    super.initState();

    // Tanggal awal: hari ini
    final sekarang = DateTime.now();
    tanggalController.text = formatTanggal(sekarang);
  }

  String formatTanggal(DateTime tanggal) {
    final hari = tanggal.day.toString().padLeft(2, '0');
    final bulan = tanggal.month.toString().padLeft(2, '0');
    final tahun = tanggal.year;

    return '$hari/$bulan/$tahun';
  }

  Future<void> pilihTanggal() async {
    final tanggal = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2026),
      lastDate: DateTime(2050),
    );

    if (tanggal != null) {
      setState(() {
        tanggalController.text = formatTanggal(tanggal);
      });
    }
  }

  Future<void> simpanPerawatan() async {
    if (!_formKey.currentState!.validate()) return;
    if (isSaving) return;

    setState(() {
      isSaving = true;
    });

    try {
      final perawatan = Perawatan(
        idJadwal: '',
        idTanaman: widget.tanaman.idTanaman,
        tanggalPerawatan: tanggalController.text,
        jenisPerawatan: jenisPerawatan!,
        catatan: catatanController.text.trim(),
        status: status,
      );
      final berhasil = await PerawatanService.insertPerawatan(perawatan);
      if (!mounted) return;
      if (berhasil) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Jadwal perawatan berhasil ditambahkan'),
          ),
        );
        // Kembali ke riwayat perawatan
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    tanggalController.dispose();
    catatanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Perawatan')),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Informasi tanaman
              Container(
                width: double.infinity,
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('ID: ${widget.tanaman.idTanaman}'),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Tanggal perawatan
              TextFormField(
                controller: tanggalController,
                readOnly: true,
                onTap: pilihTanggal,
                decoration: const InputDecoration(
                  labelText: 'Tanggal Perawatan',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tanggal wajib diisi';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Jenis perawatan
              DropdownButtonFormField<String>(
                initialValue: jenisPerawatan,
                decoration: const InputDecoration(
                  labelText: 'Jenis Perawatan',
                  border: OutlineInputBorder(),
                ),
                items: daftarJenis.map((jenis) {
                  return DropdownMenuItem(value: jenis, child: Text(jenis));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    jenisPerawatan = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Pilih jenis perawatan';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Catatan
              TextFormField(
                controller: catatanController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Catatan',
                  hintText: 'Masukkan catatan perawatan',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              // Status
              DropdownButtonFormField<String>(
                initialValue: status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: daftarStatus.map((item) {
                  return DropdownMenuItem(value: item, child: Text(item));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      status = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 24),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isSaving ? null : simpanPerawatan,
                  icon: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(isSaving ? 'Menyimpan...' : 'Simpan Perawatan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
