import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  // Base URL initialization from the .env file
  final String baseUrl =
      '${dotenv.env['API_URL']}/api'; // Ensure the API_URL is defined in your .env

  // Function to handle GET requests
  Future<Map<String, dynamic>> _getRequest(
      String endpoint, String authToken) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      // Check if the status code is successful
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        // Handle error response with error message if available
        final responseBody = json.decode(response.body);
        throw Exception(
            'Gagal mengambil data dari $endpoint. Status code: ${response.statusCode}, Error: ${responseBody['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      // Catch any exception and rethrow with detailed error message
      throw Exception(
          'Terjadi kesalahan saat mengambil data dari $endpoint: $e');
    }
  }

  // Fetch Target Sales Data
  Future<Map<String, dynamic>> fetchTargetSalesData(String authToken) async {
    final response = await _getRequest('targetsSales', authToken);
    return {
      'targets': response['targets'],
      'total_jumlah_target_bulan_ini': response['total_jumlah_target_bulan_ini']
    };
  }

  // Fetch Penjualan Tercapai Data
  Future<Map<String, dynamic>> fetchPenjualanTercapaiData(
      String authToken) async {
    final response = await _getRequest('penjualan_tercapai', authToken);
    return {
      'penjualan_saya_bulan_ini': response['penjualan_saya_bulan_ini'],
      'penjualan_saya_bulan_sebelumnya':
          response['penjualan_saya_bulan_sebelumnya'],
      'penjualan_saya_tahun_ini': response['penjualan_saya_tahun_ini']
    };
  }

  // Get Dashboard Data
  Future<Map<String, dynamic>> getDashboardData(String authToken) async {
    try {
      final targetData = await fetchTargetSalesData(authToken);
      final penjualanData = await fetchPenjualanTercapaiData(authToken);

      // Konversi string ke num
      final result = {
        'data_target': targetData['targets'],
        'total_jumlah_target_bulan_ini':
            _parseToNum(targetData['total_jumlah_target_bulan_ini']),
        'penjualan_bulan_ini':
            _parseToNum(penjualanData['penjualan_saya_bulan_ini']),
        'penjualan_bulan_sebelumnya':
            _parseToNum(penjualanData['penjualan_saya_bulan_sebelumnya']),
        'penjualan_tahun_ini':
            _parseToNum(penjualanData['penjualan_saya_tahun_ini'])
      };

      return result;
    } catch (e) {
      throw Exception('Gagal mengambil data dashboard: $e');
    }
  }

  // Helper method untuk mengkonversi string ke num
  num _parseToNum(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value;
    if (value is String) {
      // Hapus karakter non-numerik (seperti Rp, koma, titik)
      String cleanValue = value.replaceAll(RegExp(r'[^0-9.]'), '');
      try {
        return num.parse(cleanValue);
      } catch (e) {
        print('Error parsing value: $value');
        return 0;
      }
    }
    return 0;
  }

  // Function to handle POST requests
  Future<Map<String, dynamic>> _postRequest(
      String endpoint, Map<String, dynamic> body, String authToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final responseBody = json.decode(response.body);
        throw Exception(
            'Gagal mengirim data ke $endpoint. Status code: ${response.statusCode}, Error: ${responseBody['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat mengirim data ke $endpoint: $e');
    }
  }

  // Function to handle PUT requests
  Future<Map<String, dynamic>> _putRequest(
      String endpoint, Map<String, dynamic> body, String authToken) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final responseBody = json.decode(response.body);
        throw Exception(
            'Gagal memperbarui data di $endpoint. Status code: ${response.statusCode}, Error: ${responseBody['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      throw Exception(
          'Terjadi kesalahan saat memperbarui data di $endpoint: $e');
    }
  }

  // Function to handle DELETE requests
  Future<Map<String, dynamic>> _deleteRequest(
      String endpoint, String authToken) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final responseBody = json.decode(response.body);
        throw Exception(
            'Gagal menghapus data di $endpoint. Status code: ${response.statusCode}, Error: ${responseBody['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      throw Exception(
          'Terjadi kesalahan saat menghapus data dari $endpoint: $e');
    }
  }
}
