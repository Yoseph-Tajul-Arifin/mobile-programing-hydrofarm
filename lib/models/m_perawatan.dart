class Perawatan {
  final String idJadwal;
  final String idTanaman;
  final String tanggalPerawatan;
  final String jenisPerawatan;
  final String catatan;
  final String status;

  Perawatan({
    required this.idJadwal,
    required this.idTanaman,
    required this.tanggalPerawatan,
    required this.jenisPerawatan,
    required this.catatan,
    required this.status,
  });

  factory Perawatan.fromJson(Map<String, dynamic> json) {
    return Perawatan(
      idJadwal: json['id_jadwal'].toString(),
      idTanaman: json['id_tanaman'].toString(),
      tanggalPerawatan: json['tanggal_perawatan'].toString(),
      jenisPerawatan: json['jenis_perawatan'].toString(),
      catatan: json['catatan'].toString(),
      status: json['status'].toString(),
    );
  }
}
