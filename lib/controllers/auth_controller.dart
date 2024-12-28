import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences

class AuthController {
  late String baseUrl;
  String? token; // Token will be stored here

  // Constructor untuk inisialisasi baseUrl
  AuthController() {
    baseUrl =
        "${dotenv.env['API_URL']}/api/loginUser"; // Membaca URL API dari .env
  }

  // Method untuk login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse(baseUrl);

    try {
      // Login request
      final loginResponse = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
        },
        body: {
          'email': email,
          'password': password,
        },
      );

      if (loginResponse.statusCode == 200) {
        final loginData = json.decode(loginResponse.body);

        if (loginData['status']) {
          token = loginData['token'];

          // Get user details seperti di Laravel
          final userUrl = Uri.parse("${dotenv.env['API_URL']}/api/users/me");
          final userResponse = await http.get(
            userUrl,
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          );

          final userData = json.decode(userResponse.body);

          // Simpan data ke SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('auth_token', token!);
          prefs.setString('has_name', userData['name']);
          prefs.setString('has_email', userData['email']);
          prefs.setString('role_user', userData['role']);
          prefs.setString('user_id', userData['id'].toString());
          prefs.setBool('has_auth', true);

          return {
            'status': true,
            'message': loginData['message'],
            'token': token,
            'user': userData,
            'role': userData['role'],
          };
        }
      }

      return {
        'status': false,
        'message': 'Email atau Password salah!',
      };
    } catch (e) {
      return {
        'status': false,
        'message': 'Error: $e',
      };
    }
  }

  // Method untuk logout
  Future<Map<String, dynamic>> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return {'status': false, 'message': 'User not logged in'};
      }

      final url = Uri.parse("${dotenv.env['API_URL']}/api/logout");

      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Hapus semua data dari SharedPreferences
        await prefs.remove('auth_token');
        await prefs.remove('has_name');
        await prefs.remove('has_email');
        await prefs.remove('role_user');
        await prefs.remove('user_id');
        await prefs.remove('has_auth');

        return {
          'status': true,
          'message': 'Logout berhasil',
        };
      }

      return {
        'status': false,
        'message': 'Logout gagal',
      };
    } catch (e) {
      return {
        'status': false,
        'message': 'Error: $e',
      };
    }
  }

  // Method untuk mengambil info pengguna dari SharedPreferences
  Future<Map<String, dynamic>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      return {'status': false, 'message': 'User not logged in'};
    }

    // Ambil data pengguna dari SharedPreferences secara individual
    final name = prefs.getString('has_name');
    final email = prefs.getString('has_email');
    final role = prefs.getString('role_user');
    final userId = prefs.getString('user_id');

    if (name != null && email != null && role != null && userId != null) {
      // Buat Map user dari data individual
      Map<String, dynamic> user = {
        'id': userId,
        'name': name,
        'email': email,
        'role': role,
      };

      return {'status': true, 'user': user, 'role': role};
    } else {
      return {
        'status': false,
        'message': 'Data pengguna tidak lengkap di penyimpanan lokal'
      };
    }
  }

  // Method untuk melakukan request ke API yang dilindungi menggunakan token
  Future<Map<String, dynamic>> fetchData() async {
    if (token == null) {
      return {'status': false, 'message': 'User not logged in'};
    }

    final url = Uri.parse("${dotenv.env['API_URL']}/api/protectedEndpoint");

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization':
              'Bearer $token', // Sertakan token dalam header Authorization
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'status': true,
          'data': data,
        };
      } else {
        return {
          'status': false,
          'message': 'Failed to fetch data.',
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'Error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> getUserProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse("${dotenv.env['API_URL']}/api/users/me"),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Gagal mengambil profil pengguna');
      }
    } catch (e) {
      print('Error detail: $e');
      rethrow;
    }
  }
}
