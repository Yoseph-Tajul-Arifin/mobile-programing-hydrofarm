import 'package:flutter/material.dart';
import 'package:hydrofarm_app/models/m_tanaman.dart';
import 'package:hydrofarm_app/screens/tanaman/tanaman_detail.dart';
import 'package:hydrofarm_app/screens/tanaman/tanaman_insert.dart';
import 'package:hydrofarm_app/theme/app_colors.dart';

// tambahan
import 'package:hydrofarm_app/services/tanaman_services.dart';

class TanamanScreen extends StatefulWidget {
  TanamanScreen({super.key});

  @override
  State<TanamanScreen> createState() => _TanamanScreenState();
}

class _TanamanScreenState extends State<TanamanScreen> {
  // Koneksi API
  Future<void> ujiKoneksiAPI() async {
    try {
      final data = await TanamanService.getTanaman();

      debugPrint('Jumlah tanaman: ${data.length}');

      for (final tanaman in data) {
        debugPrint('${tanaman.idTanaman} - ${tanaman.namaTanaman}');
      }
    } catch (e) {
      debugPrint('Error API: $e');
    }
  }

  // Old Source Data
  // final List<Tanaman> daftarTanaman = [
  //   Tanaman(
  //     idTanaman: 'T001',
  //     namaTanaman: 'Selada',
  //     jenisTanaman: 'Sayuran Daun',
  //     tanggalTanam: '01/09/2026',
  //     umurPanen: 35,
  //     status: 'Aktif',
  //   ),
  //   Tanaman(
  //     idTanaman: 'T002',
  //     namaTanaman: 'Pakcoy',
  //     jenisTanaman: 'Sayuran Daun',
  //     tanggalTanam: '28/08/2026',
  //     umurPanen: 30,
  //     status: 'Aktif',
  //   ),
  //   Tanaman(
  //     idTanaman: 'T003',
  //     namaTanaman: 'Kangkung',
  //     jenisTanaman: 'Sayuran Daun',
  //     tanggalTanam: '25/08/2026',
  //     umurPanen: 25,
  //     status: 'Aktif',
  //   ),
  // ];

  // New Source Data
  List<Tanaman> daftarTanaman = [];
  bool isLoading = true;
  String? errorMessage;
  Future<void> loadTanaman() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final data = await TanamanService.getTanaman();
      if (!mounted) return;
      setState(() {
        daftarTanaman = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadTanaman();
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
              'Data Tanaman',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF0B6B72),
              ),
            ),
          ],
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(errorMessage!, textAlign: TextAlign.center),
                    SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: loadTanaman,
                      child: Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            )
          : daftarTanaman.isEmpty
          ? Center(child: Text('Belum ada data tanaman'))
          : ListView.builder(
              itemCount: daftarTanaman.length,
              itemBuilder: (context, index) {
                final tanaman = daftarTanaman[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.eco, color: Colors.green),
                    title: Text(tanaman.namaTanaman),
                    subtitle: Text(tanaman.jenisTanaman),
                    trailing: Text(tanaman.status),
                    onTap: () async {
                      final hasil = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TanamanDetail(tanaman: tanaman),
                        ),
                      );

                      // Old
                      // if (hasil != null) {
                      //   if (hasil is Tanaman) {
                      //     setState(() {
                      //       daftarTanaman[index] = hasil;
                      //     });
                      //   } else if (hasil == 'delete') {
                      //     setState(() {
                      //       daftarTanaman.removeAt(index);
                      //     });
                      //   }
                      // }

                      // Update
                      if (!mounted) return;
                      if (hasil == true) {
                        await loadTanaman();
                      }
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.success,
        foregroundColor: Colors.white,
        onPressed: () async {
          final hasil = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TanamanInsert()),
          );

          if (!mounted) return;
          if (hasil == true) {
            await loadTanaman();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
