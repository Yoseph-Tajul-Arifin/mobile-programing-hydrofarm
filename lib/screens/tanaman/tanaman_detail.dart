import 'package:flutter/material.dart';
import 'package:hydrofarm_app/models/m_tanaman.dart';
import 'package:hydrofarm_app/screens/tanaman/tanaman_insert.dart';
import 'package:hydrofarm_app/services/tanaman_services.dart';
import 'package:hydrofarm_app/theme/app_colors.dart';

class TanamanDetail extends StatefulWidget {
  final Tanaman tanaman;
  const TanamanDetail({super.key, required this.tanaman});
  @override
  State<TanamanDetail> createState() => _TanamanDetailState();
}

class _TanamanDetailState extends State<TanamanDetail> {
  bool isDeleting = false;

  Future<void> hapusTanaman() async {
    if (isDeleting) return;

    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text(
          'Apakah Anda yakin ingin menghapus '
          '${widget.tanaman.namaTanaman}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (konfirmasi != true || !mounted) return;
    setState(() {
      isDeleting = true;
    });

    try {
      await TanamanService.deleteTanaman(widget.tanaman.idTanaman);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal menghapus: $e')));
    } finally {
      if (mounted) {
        setState(() {
          isDeleting = false;
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
            const Text(
              'Detail Tanaman',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF0B6B72),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final hasil = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TanamanInsert(tanaman: widget.tanaman),
                ),
              );
              // Old
              // if (hasil != null && hasil is Tanaman) {
              //   Navigator.pop(context, hasil);
              // }

              // Update
              if (!context.mounted) return;
              if (hasil == true) {
                Navigator.pop(context, true);
              }
            },
            icon: Icon(Icons.edit, color: AppColors.accent),
          ),
          // Old Button
          // IconButton(
          //   onPressed: () {
          //     showDialog(
          //       context: context,
          //       builder: (context) {
          //         return AlertDialog(
          //           title: Text('Hapus Tanaman'),
          //           content: Text('Hapus ${widget.tanaman.namaTanaman} ?'),
          //           actions: [
          //             TextButton(
          //               onPressed: () {
          //                 Navigator.pop(context);
          //               },
          //               child: Text('Batal'),
          //             ),
          //             ElevatedButton(
          //               onPressed: () {
          //                 Navigator.pop(context);
          //                 Navigator.pop(context, 'delete');
          //               },
          //               child: Text('Hapus'),
          //             ),
          //           ],
          //         );
          //       },
          //     );
          //   },
          //   icon: Icon(Icons.delete, color: AppColors.error),
          // ),
          IconButton(
            onPressed: isDeleting ? null : hapusTanaman,
            icon: isDeleting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.delete_outline),
            color: AppColors.error,
            tooltip: 'Hapus Tanaman',
            iconSize: 26,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.eco, size: 80, color: Colors.green),

            const SizedBox(height: 16),

            Text(
              widget.tanaman.namaTanaman,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            Text(
              widget.tanaman.jenisTanaman,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),

            const SizedBox(height: 24),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    detailItem("Nama Tanaman", widget.tanaman.namaTanaman),
                    detailItem("Tanggal Tanam", widget.tanaman.tanggalTanam),
                    detailItem(
                      "Umur Panen",
                      "${widget.tanaman.umurPanen} Hari",
                    ),
                    detailItem("Status", widget.tanaman.status),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget detailItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const Text(": "),
          Expanded(flex: 3, child: Text(value)),
        ],
      ),
    );
  }
}
