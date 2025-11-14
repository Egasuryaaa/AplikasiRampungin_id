import 'dart:convert' show json;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'api_config.dart';

/// HTTP Client with JWT Token Management
class ApiClient {
  static final Logger _logger = Logger();
  static const String _tokenKey = 'jwt_token';

  // Singleton pattern
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  // ==================== TOKEN MANAGEMENT ====================

  /// Save JWT token to local storage
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    _logger.i('Token saved successfully');
  }

  /// Get JWT token from local storage
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Remove JWT token (for logout)
  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    _logger.i('Token removed successfully');
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ==================== HTTP METHODS ====================

  /// GET Request
  Future<http.Response> get(String endpoint, {bool requiresAuth = true}) async {
    final url = Uri.parse(ApiConfig.getFullUrl(endpoint));
    final headers = await _buildHeaders(requiresAuth);

    _logger.d('GET $url');

    try {
      final response = await http
          .get(url, headers: headers)
          .timeout(ApiConfig.connectionTimeout);

      _logResponse(response);
      return response;
    } catch (e) {
      _logger.e('GET request failed: $e');
      rethrow;
    }
  }

  /// POST Request
  Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    final url = Uri.parse(ApiConfig.getFullUrl(endpoint));
    final headers = await _buildHeaders(requiresAuth);

    _logger.d('POST $url');
    _logger.d('POST $url');
    if (body != null) {
      _logger.d('Body keys: ${body.keys.join(", ")}');
    }

    try {
      final response = await http
          .post(
            url,
            headers: headers,
            body: body != null ? json.encode(body) : null,
          )
          .timeout(ApiConfig.connectionTimeout);

      _logResponse(response);
      return response;
    } catch (e) {
      _logger.e('POST request failed: $e');
      _logger.e('Full URL: $url');
      _logger.e('Headers sent: $headers');
      rethrow;
    }
  }

  /// PUT Request
  Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    final url = Uri.parse(ApiConfig.getFullUrl(endpoint));
    final headers = await _buildHeaders(requiresAuth);

    _logger.d('PUT $url');
    if (body != null) {
      _logger.d('Body keys: ${body.keys.join(", ")}');
    }

    try {
      final response = await http
          .put(
            url,
            headers: headers,
            body: body != null ? json.encode(body) : null,
          )
          .timeout(ApiConfig.connectionTimeout);

      _logResponse(response);
      return response;
    } catch (e) {
      _logger.e('PUT request failed: $e');
      rethrow;
    }
  }

  /// PUT Request with Form Data (for CodeIgniter compatibility)
  Future<http.Response> putFormData(
    String endpoint, {
    Map<String, String>? fields,
    bool requiresAuth = true,
  }) async {
    final url = Uri.parse(ApiConfig.getFullUrl(endpoint));
    final token = requiresAuth ? await getToken() : null;

    _logger.d('PUT FORM DATA $url');
    _logger.d('Fields: $fields');

    try {
      final request = http.MultipartRequest('POST', url);

      // Add _method field for PUT method spoofing (CodeIgniter requirement)
      if (fields != null) {
        request.fields.addAll(fields);
      }
      request.fields['_method'] = 'PUT';

      // Add auth header
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      final streamedResponse = await request.send().timeout(
        ApiConfig.connectionTimeout,
      );
      final response = await http.Response.fromStream(streamedResponse);

      _logResponse(response);
      return response;
    } catch (e) {
      _logger.e('PUT FORM DATA request failed: $e');
      rethrow;
    }
  }

  /// DELETE Request
  Future<http.Response> delete(
    String endpoint, {
    bool requiresAuth = true,
  }) async {
    final url = Uri.parse(ApiConfig.getFullUrl(endpoint));
    final headers = await _buildHeaders(requiresAuth);

    _logger.d('DELETE $url');

    try {
      final response = await http
          .delete(url, headers: headers)
          .timeout(ApiConfig.connectionTimeout);

      _logResponse(response);
      return response;
    } catch (e) {
      _logger.e('DELETE request failed: $e');
      rethrow;
    }
  }

  /// POST Multipart Request (for file uploads like KTP)
  /// Uses bytes instead of path for web compatibility
  Future<http.StreamedResponse> postMultipart(
    String endpoint,
    String fieldName,
    List<int> fileBytes,
    String filename, {
    Map<String, String>? fields,
    bool requiresAuth = true,
  }) async {
    final url = Uri.parse(ApiConfig.getFullUrl(endpoint));
    final token = requiresAuth ? await getToken() : null;

    _logger.d('POST MULTIPART $url');

    try {
      final request = http.MultipartRequest('POST', url);

      // Add auth header
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add file using bytes (web-compatible)
      // Determine content type from filename extension
      String? mimeType;
      final ext = filename.toLowerCase().split('.').last;
      if (ext == 'jpg' || ext == 'jpeg') {
        mimeType = 'image/jpeg';
      } else if (ext == 'png') {
        mimeType = 'image/png';
      } else if (ext == 'gif') {
        mimeType = 'image/gif';
      } else if (ext == 'webp') {
        mimeType = 'image/webp';
      }

      _logger.d(
        '📎 Uploading file: $filename (${fileBytes.length} bytes, type: $mimeType)',
      );

      request.files.add(
        http.MultipartFile.fromBytes(
          fieldName,
          fileBytes,
          filename: filename,
          contentType: mimeType != null ? MediaType.parse(mimeType) : null,
        ),
      );

      // Add other fields
      if (fields != null) {
        request.fields.addAll(fields);
        _logger.d('📝 Fields: $fields');
      }

      final response = await request.send();

      _logger.i('Multipart response: ${response.statusCode}');
      return response;
    } catch (e) {
      _logger.e('Multipart request failed: $e');
      rethrow;
    }
  }

  // ==================== HELPER METHODS ====================

  /// Build request headers with optional JWT token
  Future<Map<String, String>> _buildHeaders(bool requiresAuth) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      } else {
        _logger.w('Auth required but no token found');
      }
    }

    return headers;
  }

  /// Log HTTP response for debugging
  void _logResponse(http.Response response) {
    _logger.i('Response ${response.statusCode}');

    if (response.statusCode >= 400) {
      _logger.e('Error response: ${response.body}');
    } else {
      _logger.d('Response body: ${response.body}');
    }
  }

  /// Parse JSON response
  Map<String, dynamic> parseResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: response.body,
      );
    }
  }
}

/// Custom exception for API errors
class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
