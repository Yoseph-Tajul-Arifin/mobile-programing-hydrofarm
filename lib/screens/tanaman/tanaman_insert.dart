import 'package:flutter/material.dart';
import 'package:hydrofarm_app/models/m_tanaman.dart';
import 'package:hydrofarm_app/services/tanaman_services.dart';
import 'package:hydrofarm_app/theme/app_colors.dart';

class TanamanInsert extends StatefulWidget {
  final Tanaman? tanaman;
  const TanamanInsert({super.key, this.tanaman});

  @override
  State<TanamanInsert> createState() => _TanamanInsertState();
}

class _TanamanInsertState extends State<TanamanInsert> {
  bool isSaving = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController jenisController = TextEditingController();
  final TextEditingController tanggalController = TextEditingController();
  final TextEditingController umurPanenController = TextEditingController();
  String status = 'Aktif';

  // Simpan old
  // Future<void> simpanTanaman() async {
  //   if (!_formKey.currentState!.validate()) return;
  //   if (isSaving) return;
  //   setState(() {
  //     isSaving = true;
  //   });
  //   try {
  //     final tanamanBaru = Tanaman(
  //       idTanaman: '',
  //       namaTanaman: namaController.text.trim(),
  //       jenisTanaman: jenisController.text.trim(),
  //       tanggalTanam: tanggalController.text,
  //       umurPanen: int.parse(umurPanenController.text),
  //       status: status,
  //     );
  //     await TanamanService.insertTanaman(tanamanBaru);
  //     if (!mounted) return;
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Tanaman berhasil disimpan')),
  //     );
  //     Navigator.pop(context, true);
  //   } catch (e) {
  //     if (!mounted) return;
  //     ScaffoldMessenger.of(context)
  //         .showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
  //   } finally {
  //     if (mounted) {
  //       setState(() {
  //         isSaving = false;
  //       });
  //     }
  //   }
  // }

  // Simpan dan Edit/Update
  Future<void> simpanTanaman() async {
    if (!_formKey.currentState!.validate()) return;
    if (isSaving) return;

    setState(() {
      isSaving = true;
    });

    try {
      final tanamanData = Tanaman(
        idTanaman: widget.tanaman?.idTanaman ?? '',
        namaTanaman: namaController.text.trim(),
        jenisTanaman: jenisController.text.trim(),
        tanggalTanam: tanggalController.text,
        umurPanen: int.parse(umurPanenController.text),
        status: status,
      );

      if (widget.tanaman == null) {
        // Mode Tambah
        await TanamanService.insertTanaman(tanamanData);
      } else {
        // Mode Edit
        await TanamanService.updateTanaman(tanamanData);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.tanaman != null) {
      namaController.text = widget.tanaman!.namaTanaman;
      jenisController.text = widget.tanaman!.jenisTanaman;
      tanggalController.text = widget.tanaman!.tanggalTanam;
      umurPanenController.text = widget.tanaman!.umurPanen.toString();
      status = widget.tanaman!.status;
    }
  }

  @override
  void dispose() {
    namaController.dispose();
    jenisController.dispose();
    tanggalController.dispose();
    umurPanenController.dispose();
    super.dispose();
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

            Text(
              widget.tanaman == null ? 'Tambah Tanaman' : 'Edit Tanaman',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Tanaman',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama tanaman harus diisi';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: jenisController,
                decoration: const InputDecoration(
                  labelText: 'Jenis Tanaman',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: tanggalController,
                decoration: const InputDecoration(
                  labelText: 'Tanggal Tanam',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_month),
                ),
                onTap: () async {
                  final DateTime? tanggalDipilih = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2026),
                    lastDate: DateTime(2030),
                  );
                  if (tanggalDipilih != null) {
                    final String tanggalFormat =
                        '${tanggalDipilih.day.toString().padLeft(2, '0')}/'
                        '${tanggalDipilih.month.toString().padLeft(2, '0')}/'
                        '${tanggalDipilih.year}';
                    setState(() {
                      tanggalController.text = tanggalFormat;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: umurPanenController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Umur Panen',
                  hintText: 'Dalam hari',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Aktif', child: Text('Aktif')),
                  DropdownMenuItem(value: 'Panen', child: Text('Panen')),
                  DropdownMenuItem(value: 'Gagal', child: Text('Gagal')),
                ],
                onChanged: (value) {
                  setState(() {
                    status = value!;
                  });
                },
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textWhite,
                ),
                onPressed: isSaving ? null : simpanTanaman,
                child: isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
