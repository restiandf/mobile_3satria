import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PenjualanController {
  final String baseUrl = '${dotenv.env['API_URL']}/api';

  Future<List<dynamic>> getPenjualan(String authToken) async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}/penjualan'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Accept': 'application/json',
        },
      );

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('data')) {
          return responseData['data'] as List<dynamic>;
        } else {
          throw Exception('Format response tidak sesuai');
        }
      } else {
        throw Exception('Gagal mengambil data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error detail: $e');
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  Future<List<dynamic>> getProduk(String authToken) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/product'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['data'];
      } else {
        throw Exception('Gagal mengambil data produk: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  Future<void> addPenjualan({
    required String authToken,
    required String salesArea,
    required String idProduk,
    required int terjual,
  }) async {
    try {
      final requestBody = {
        'salesArea': salesArea,
        'idProduk': idProduk,
        'terjual': terjual,
      };

      print('Request body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse('${baseUrl}/penjualan'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Gagal menambahkan data: ${response.body}');
      }
    } catch (e) {
      print('Error detail: $e');
      throw Exception('Gagal menambahkan data: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getProdukList(String authToken) async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}/product'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Gagal mengambil data produk: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> deletePenjualan(String id, String authToken) async {
    try {
      final response = await http.delete(
        Uri.parse('${baseUrl}/penjualan/$id'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Gagal menghapus data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> updatePenjualan(
    int id,
    String salesArea,
    int terjual,
    int idProduk,
    String authToken,
  ) async {
    final url = Uri.parse('${baseUrl}/penjualan/$id');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'salesArea': salesArea,
          'terjual': terjual,
          'idProduk': idProduk,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Gagal mengupdate data: ${response.body}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }
}
