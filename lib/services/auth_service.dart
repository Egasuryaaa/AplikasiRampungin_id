import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/api_client.dart';
import '../core/api_config.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiClient _client = ApiClient();

  // ==================== REGISTER ====================
  Future<AuthResponse> register(Map<String, dynamic> registrationData) async {
    try {
      final Map<String, String> body = {
        "username": registrationData['username'] ?? "",
        "email": registrationData['email'] ?? "",
        "password": registrationData['password'] ?? "",
        "nama_lengkap": registrationData['namaLengkap'] ?? "",
        "no_telp": registrationData['noTelp'] ?? "",
        "role": registrationData['role'] ?? "",
        "alamat": registrationData['alamat'] ?? "",
        "kota": registrationData['kota'] ?? "",
        "provinsi": registrationData['provinsi'] ?? "",
        "kode_pos": registrationData['kodePos'] ?? "",
      };

      if (registrationData['role'] == 'tukang') {
        body.addAll({
          'pengalaman_tahun': '${registrationData['pengalaman_tahun'] ?? 0}',
          'tarif_per_jam': '${registrationData['tarif_per_jam'] ?? 0}',
          'bio': registrationData['bio'] ?? '',
          'keahlian': (registrationData['keahlian'] as List).join(','),
          'kategori_ids': registrationData['kategori_ids'] ?? '[]',
          'nama_bank': registrationData['nama_bank'] ?? '',
          'nomor_rekening': registrationData['nomor_rekening'] ?? '',
          'nama_pemilik_rekening':
              registrationData['nama_pemilik_rekening'] ?? '',
        });
      }

      // Handle optional photo if provided
      File? fotoProfil = registrationData['fotoProfil'];

      http.Response response;

      if (fotoProfil != null) {
        final streamedResponse = await _client.postMultipart(
          ApiConfig.authRegister,
          'foto_profil',
          fotoProfil.path,
          fields: body,
          requiresAuth: false,
        );

        response = await http.Response.fromStream(streamedResponse);
      } else {
        response = await _client.post(
          ApiConfig.authRegister,
          body: body,
          requiresAuth: false,
        );
      }

      final data = _client.parseResponse(response);
      return AuthResponse.fromJson(data);
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  // ==================== LOGIN ====================
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final body = {'email': email, 'password': password};

      final response = await _client.post(
        ApiConfig.authLogin,
        body: body,
        requiresAuth: false,
      );

      final data = _client.parseResponse(response);
      final authResponse = AuthResponse.fromJson(data);

      if (authResponse.token != null) {
        await _client.saveToken(authResponse.token!);
      }

      return authResponse;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  } // ==================== LOGOUT ====================

  /// Logout current user
  /// Blacklists the current JWT token
  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await _client.post(
        ApiConfig.authLogout,
        requiresAuth: true,
      );

      final data = _client.parseResponse(response);

      // Remove token from local storage
      await _client.removeToken();

      return data;
    } catch (e) {
      // Remove token even if API call fails
      await _client.removeToken();
      throw Exception('Logout failed: $e');
    }
  }

  // ==================== GET CURRENT USER ====================

  /// Get current authenticated user's profile
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _client.get(ApiConfig.authMe, requiresAuth: true);

      final data = _client.parseResponse(response);

      // API returns user object inside 'data' key
      if (data['data'] != null) {
        return UserModel.fromJson(data['data'] as Map<String, dynamic>);
      }

      return UserModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  // ==================== CHANGE PASSWORD ====================

  /// Change user password
  ///
  /// Required params:
  /// - old_password: Current password
  /// - new_password: New password (min 8 characters)
  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final body = {'old_password': oldPassword, 'new_password': newPassword};

      final response = await _client.post(
        ApiConfig.authChangePassword,
        body: body,
        requiresAuth: true,
      );

      return _client.parseResponse(response);
    } catch (e) {
      throw Exception('Change password failed: $e');
    }
  }

  // ==================== HELPER METHODS ====================

  /// Check if user is currently authenticated
  Future<bool> isAuthenticated() async {
    return await _client.isAuthenticated();
  }

  /// Get stored JWT token
  Future<String?> getToken() async {
    return await _client.getToken();
  }
}
