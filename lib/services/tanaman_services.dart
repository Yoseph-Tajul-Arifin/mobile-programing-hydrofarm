import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/m_tanaman.dart';

class TanamanService {
  static const String apiUrl =
      'https://script.google.com/macros/s/AKfycbxrxwlDICcmee-D6oYg9SU0Xhf4Dnu5Xdbf8I1-LxwaGhhN-Ay_X_Bay0mQogNwKjZhOg/exec';

  // Read
  static Future<List<Tanaman>> getTanaman() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil data. HTTP ${response.statusCode}');
    }
    final Map<String, dynamic> hasil = jsonDecode(response.body);
    if (hasil['success'] != true) {
      throw Exception(hasil['message'] ?? 'Gagal mengambil data tanaman');
    }
    final List<dynamic> data = hasil['data'];
    return data.map((item) => Tanaman.fromJson(item)).toList();
  }

  // Insert
  // static Future<void> insertTanaman(Tanaman tanaman) async {
  //   final response = await http.post(
  //     Uri.parse(apiUrl),
  //     headers: {'Content-Type': 'text/plain; charset=utf-8'},
  //     body: jsonEncode({
  //       'action': 'insert',
  //       'nama_tanaman': tanaman.namaTanaman,
  //       'jenis_tanaman': tanaman.jenisTanaman,
  //       'tanggal_tanam': tanaman.tanggalTanam,
  //       'umur_panen': tanaman.umurPanen,
  //       'status': tanaman.status,
  //     }),
  //   );
  //   debugPrint('HTTP Status: ${response.statusCode}');
  //   debugPrint('Redirect URL: ${response.headers['location']}');
  //   debugPrint('Response Body: ${response.body}');
  //   if (response.statusCode != 200) {
  //     throw Exception('Gagal menyimpan tanaman. HTTP ${response.statusCode}');
  //   }
  //   final hasil = jsonDecode(response.body);
  //   if (hasil['success'] != true) {
  //     throw Exception(hasil['message'] ?? 'Gagal menyimpan tanaman');
  //   }
  // }

  // New Insert menangani error 302 di android
  static Future<void> insertTanaman(Tanaman tanaman) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'text/plain; charset=utf-8'},
      body: jsonEncode({
        'action': 'insert',
        'nama_tanaman': tanaman.namaTanaman,
        'jenis_tanaman': tanaman.jenisTanaman,
        'tanggal_tanam': tanaman.tanggalTanam,
        'umur_panen': tanaman.umurPanen,
        'status': tanaman.status,
      }),
    );
    http.Response hasilResponse = response;
    // Menangani redirect dari Google Apps Script
    if (response.statusCode == 302) {
      final redirectUrl = response.headers['location'];
      if (redirectUrl == null) {
        throw Exception('URL redirect tidak ditemukan');
      }
      // Mengambil respons JSON dari URL redirect
      hasilResponse = await http.get(Uri.parse(redirectUrl));
    }
    if (hasilResponse.statusCode != 200) {
      throw Exception(
        'Gagal menyimpan tanaman. HTTP ${hasilResponse.statusCode}',
      );
    }
    final hasil = jsonDecode(hasilResponse.body);
    if (hasil['success'] != true) {
      throw Exception(hasil['message'] ?? 'Gagal menyimpan tanaman');
    }
  }

  // Edit Update
  // static Future<void> updateTanaman(Tanaman tanaman) async {
  //   final response = await http.post(
  //     Uri.parse(apiUrl),
  //     headers: {'Content-Type': 'text/plain; charset=utf-8'},
  //     body: jsonEncode({
  //       'action': 'update',
  //       'id_tanaman': tanaman.idTanaman,
  //       'nama_tanaman': tanaman.namaTanaman,
  //       'jenis_tanaman': tanaman.jenisTanaman,
  //       'tanggal_tanam': tanaman.tanggalTanam,
  //       'umur_panen': tanaman.umurPanen,
  //       'status': tanaman.status,
  //     }),
  //   );
  //   if (response.statusCode != 200) {
  //     throw Exception('Gagal memperbarui tanaman. HTTP ${response.statusCode}');
  //   }
  //   final Map<String, dynamic> hasil = jsonDecode(response.body);
  //   if (hasil['success'] != true) {
  //     throw Exception(hasil['message'] ?? 'Gagal memperbarui tanaman');
  //   }
  // }

  // Edit Update menangani error 302
  static Future<void> updateTanaman(Tanaman tanaman) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'text/plain; charset=utf-8'},
      body: jsonEncode({
        'action': 'update',
        'id_tanaman': tanaman.idTanaman,
        'nama_tanaman': tanaman.namaTanaman,
        'jenis_tanaman': tanaman.jenisTanaman,
        'tanggal_tanam': tanaman.tanggalTanam,
        'umur_panen': tanaman.umurPanen,
        'status': tanaman.status,
      }),
    );
    http.Response hasilResponse = response;
    // Menangani redirect Google Apps Script
    if (response.statusCode == 302) {
      final redirectUrl = response.headers['location'];
      if (redirectUrl == null) {
        throw Exception('URL redirect Update tidak ditemukan');
      }
      hasilResponse = await http.get(Uri.parse(redirectUrl));
    }
    if (hasilResponse.statusCode != 200) {
      throw Exception(
        'Gagal memperbarui tanaman. HTTP ${hasilResponse.statusCode}',
      );
    }
    final hasil = jsonDecode(hasilResponse.body);
    if (hasil['success'] != true) {
      throw Exception(hasil['message'] ?? 'Gagal memperbarui tanaman');
    }
  }

  // Delete
  // static Future<void> deleteTanaman(String idTanaman) async {
  //   final response = await http.post(
  //     Uri.parse(apiUrl),
  //     headers: {'Content-Type': 'text/plain; charset=utf-8'},
  //     body: jsonEncode({'action': 'delete', 'id_tanaman': idTanaman}),
  //   );

  //   if (response.statusCode != 200) {
  //     throw Exception('Gagal menghapus tanaman. HTTP ${response.statusCode}');
  //   }

  //   final Map<String, dynamic> hasil = jsonDecode(response.body);

  //   if (hasil['success'] != true) {
  //     throw Exception(hasil['message'] ?? 'Gagal menghapus tanaman');
  //   }
  // }

  // Delete menangani error 302
  static Future<void> deleteTanaman(String idTanaman) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'text/plain; charset=utf-8'},
      body: jsonEncode({'action': 'delete', 'id_tanaman': idTanaman}),
    );
    http.Response hasilResponse = response;
    // Menangani redirect Google Apps Script
    if (response.statusCode == 302) {
      final redirectUrl = response.headers['location'];
      if (redirectUrl == null) {
        throw Exception('URL redirect Delete tidak ditemukan');
      }
      hasilResponse = await http.get(Uri.parse(redirectUrl));
    }

    if (hasilResponse.statusCode != 200) {
      throw Exception(
        'Gagal menghapus tanaman. HTTP ${hasilResponse.statusCode}',
      );
    }
    final hasil = jsonDecode(hasilResponse.body);
    if (hasil['success'] != true) {
      throw Exception(hasil['message'] ?? 'Gagal menghapus tanaman');
    }
  }
}
