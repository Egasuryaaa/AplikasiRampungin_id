import 'dart:convert';
import 'package:logger/logger.dart';
import '../core/api_client.dart';
import '../core/api_config.dart';

class ProfileService {
  final ApiClient _apiClient = ApiClient();
  final Logger _logger = Logger();

  /// Get client profile
  /// Token is handled automatically by ApiClient
  Future<Map<String, dynamic>> getProfile(String token) async {
    try {
      _logger.d('📱 ProfileService: Getting profile...');
      
      final response = await _apiClient.get(
        ApiConfig.clientProfile,
        requiresAuth: true,
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        _logger.i('✅ Profile retrieved successfully');
        return data;
      } else {
        _logger.e('❌ Failed to get profile: ${data['message']}');
        throw Exception(data['message'] ?? 'Gagal mengambil data profil');
      }
    } catch (e) {
      _logger.e('💥 Error in getProfile: $e');
      throw Exception('Failed to get profile: $e');
    }
  }

  /// Update profile without photo (JSON)
  /// Token is handled automatically by ApiClient
  Future<Map<String, dynamic>> updateProfileJson({
    required String token,
    required String namaLengkap,
    required String email,
    required String noTelp,
    required String alamat,
    required String kota,
    required String provinsi,
    required String kodePos,
  }) async {
    try {
      _logger.d('📝 ProfileService: Updating profile (JSON)...');
      
      final response = await _apiClient.put(
        ApiConfig.clientProfile,
        body: {
          'nama_lengkap': namaLengkap,
          'email': email,
          'no_telp': noTelp,
          'alamat': alamat,
          'kota': kota,
          'provinsi': provinsi,
          'kode_pos': kodePos,
        },
        requiresAuth: true,
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        _logger.i('✅ Profile updated successfully');
        return data;
      } else {
        _logger.e('❌ Failed to update profile: ${data['message']}');
        throw Exception(data['message'] ?? 'Gagal update profil');
      }
    } catch (e) {
      _logger.e('💥 Error in updateProfileJson: $e');
      throw Exception('Failed to update profile: $e');
    }
  }

  /// Update profile with photo using bytes (web-compatible)
  /// Token is handled automatically by ApiClient
  /// Uses PUT method via method spoofing for CodeIgniter compatibility
  Future<Map<String, dynamic>> updateProfileWithPhotoBytes({
    required String token,
    required String namaLengkap,
    required String email,
    required String noTelp,
    required String alamat,
    required String kota,
    required String provinsi,
    required String kodePos,
    required List<int> fotoProfilBytes,
    required String fotoProfilFilename,
  }) async {
    try {
      _logger.d('📸 ProfileService: Updating profile with photo (PUT)...');
      
      final streamedResponse = await _apiClient.putMultipart(
        ApiConfig.clientProfile,
        'foto_profil',
        fotoProfilBytes,
        fotoProfilFilename,
        fields: {
          'nama_lengkap': namaLengkap,
          'email': email,
          'no_telp': noTelp,
          'alamat': alamat,
          'kota': kota,
          'provinsi': provinsi,
          'kode_pos': kodePos,
        },
        requiresAuth: true,
      );

      // Convert StreamedResponse to Response
      final responseBody = await streamedResponse.stream.bytesToString();
      
      _logger.d('Response status: ${streamedResponse.statusCode}');
      _logger.d('Response body: $responseBody');

      // Handle non-200 responses
      if (streamedResponse.statusCode != 200) {
        _logger.e('❌ Server returned ${streamedResponse.statusCode}');
        _logger.e('Response body: $responseBody');
        
        // Try to parse error message
        try {
          final errorData = json.decode(responseBody);
          throw Exception(errorData['message'] ?? 'Server error: ${streamedResponse.statusCode}');
        } catch (_) {
          // If response is not JSON (like HTML error page)
          throw Exception('Server error ${streamedResponse.statusCode}: Failed to update profile');
        }
      }

      // Parse successful response
      final data = json.decode(responseBody);

      if (data['status'] == 'success') {
        _logger.i('✅ Profile with photo updated successfully');
        return data;
      } else {
        _logger.e('❌ Failed to update profile with photo: ${data['message']}');
        throw Exception(data['message'] ?? 'Gagal update foto profil');
      }
    } catch (e) {
      _logger.e('💥 Error in updateProfileWithPhotoBytes: $e');
      throw Exception('Failed to update profile with photo: $e');
    }
  }
}