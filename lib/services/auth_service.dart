import '../core/api_client.dart';
import '../core/api_config.dart';
import '../models/user_model.dart';

/// Authentication Service
class AuthService {
  final ApiClient _client = ApiClient();

  // ==================== REGISTER ====================

  /// Register new user (client or tukang)
  ///
  /// Required params:
  /// - nama: User's full name
  /// - email: Email address
  /// - password: Password (min 8 characters)
  /// - no_hp: Phone number
  /// - alamat: Address
  /// - jenis_akun: 'client' or 'tukang'
  /// - id_kategori: Category ID (only for tukang)
  Future<AuthResponse> register({
    required String nama,
    required String email,
    required String password,
    required String noHp,
    required String alamat,
    required String jenisAkun, // 'client' or 'tukang'
    int? idKategori, // Required for tukang
  }) async {
    try {
      final body = {
        'nama': nama,
        'email': email,
        'password': password,
        'no_hp': noHp,
        'alamat': alamat,
        'jenis_akun': jenisAkun,
        if (idKategori != null) 'id_kategori': idKategori,
      };

      final response = await _client.post(
        ApiConfig.authRegister,
        body: body,
        requiresAuth: false,
      );

      final data = _client.parseResponse(response);
      final authResponse = AuthResponse.fromJson(data);

      // Save token if registration includes auto-login
      if (authResponse.token != null) {
        await _client.saveToken(authResponse.token!);
      }

      return authResponse;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  // ==================== LOGIN ====================

  /// Login user
  ///
  /// Required params:
  /// - email: Email address
  /// - password: Password
  ///
  /// Returns AuthResponse with JWT token (valid 30 days)
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

      // Save token
      if (authResponse.token != null) {
        await _client.saveToken(authResponse.token!);
      }

      return authResponse;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // ==================== LOGOUT ====================

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
