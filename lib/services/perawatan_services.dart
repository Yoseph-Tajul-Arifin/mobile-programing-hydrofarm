import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/m_perawatan.dart';

class PerawatanService {
  // Gunakan URL Web App Apps Script kelas Anda
  static const String apiUrl =
      'https://script.google.com/macros/s/AKfycbxrxwlDICcmee-D6oYg9SU0Xhf4Dnu5Xdbf8I1-LxwaGhhN-Ay_X_Bay0mQogNwKjZhOg/exec';

  // READ - Mengambil seluruh jadwal perawatan
  static Future<List<Perawatan>> getPerawatan() async {
    final uri = Uri.parse(apiUrl)
        .replace(queryParameters: {'modul': 'perawatan'});

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception(
        'Gagal mengambil data perawatan. HTTP ${response.statusCode}',
      );
    }

    final Map<String, dynamic> hasil = jsonDecode(response.body);
    if (hasil['success'] != true) {
      throw Exception(hasil['message'] ?? 'Gagal mengambil data perawatan');
    }

    final List<dynamic> data = hasil['data'];
    return data.map((item) => Perawatan.fromJson(item)).toList();
  }

  // INSERT
  static Future<bool> insertPerawatan(Perawatan perawatan) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'text/plain; charset=utf-8'},
        body: jsonEncode({
          'modul': 'perawatan',
          'action': 'insert',
          'id_tanaman': perawatan.idTanaman,
          'tanggal_perawatan': perawatan.tanggalPerawatan,
          'jenis_perawatan': perawatan.jenisPerawatan,
          'catatan': perawatan.catatan,
          'status': perawatan.status,
        }),
      );

      // Penanganan redirect Google Apps Script pada Android
      http.Response hasilResponse = response;
      if (response.statusCode == 302) {
        final redirectUrl = response.headers['location'];
        if (redirectUrl == null) {
          throw Exception('URL redirect tidak ditemukan');
        }
        // Gunakan GET, jangan mengirim POST ulang
        hasilResponse = await http.get(Uri.parse(redirectUrl));
      }
      if (hasilResponse.statusCode != 200) {
        throw Exception(
          'Gagal menyimpan perawatan. HTTP ${hasilResponse.statusCode}',
        );
      }
      final hasil = jsonDecode(hasilResponse.body);
      if (hasil['success'] != true) {
        throw Exception(hasil['message'] ?? 'Gagal menambahkan perawatan');
      }
      return true;
    } catch (e) {
      throw Exception('Insert perawatan gagal: $e');
    }
  }

  // UPDATE STATUS
  static Future<bool> updateStatusPerawatan(String idJadwal) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'text/plain; charset=utf-8'},
        body: jsonEncode({
          'modul': 'perawatan',
          'action': 'update',
          'id_jadwal': idJadwal,
          'status': 'Selesai',
        }),
      );
      // Menangani redirect Google Apps Script di Android
      http.Response hasilResponse = response;
      if (response.statusCode == 302) {
        final redirectUrl = response.headers['location'];
        if (redirectUrl == null) {
          throw Exception('URL redirect tidak ditemukan');
        }
        // Jangan POST ulang, cukup ambil hasil dengan GET
        hasilResponse = await http.get(Uri.parse(redirectUrl));
      }
      if (hasilResponse.statusCode != 200) {
        throw Exception(
          'Gagal update status. HTTP ${hasilResponse.statusCode}',
        );
      }
      final hasil = jsonDecode(hasilResponse.body);
      if (hasil['success'] != true) {
        throw Exception(hasil['message'] ?? 'Gagal memperbarui status');
      }
      return true;
    } catch (e) {
      throw Exception('Update status perawatan gagal: $e');
    }
  }

  // DELETE
  static Future<bool> deletePerawatan(String idJadwal) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'text/plain; charset=utf-8'},
        body: jsonEncode({
          'modul': 'perawatan',
          'action': 'delete',
          'id_jadwal': idJadwal,
        }),
      );

      // Menangani redirect Google Apps Script
      http.Response hasilResponse = response;
      if (response.statusCode == 302) {
        final redirectUrl = response.headers['location'];
        if (redirectUrl == null) {
          throw Exception('URL redirect tidak ditemukan');
        }
        // Redirect cukup GET, jangan POST ulang
        hasilResponse = await http.get(Uri.parse(redirectUrl));
      }
      if (hasilResponse.statusCode != 200) {
        throw Exception(
          'Gagal menghapus perawatan. '
          'HTTP ${hasilResponse.statusCode}',
        );
      }
      final hasil = jsonDecode(hasilResponse.body);
      if (hasil['success'] != true) {
        throw Exception(hasil['message'] ?? 'Gagal menghapus perawatan');
      }
      return true;
    } catch (e) {
      throw Exception('Delete perawatan gagal: $e');
    }
  }
}
