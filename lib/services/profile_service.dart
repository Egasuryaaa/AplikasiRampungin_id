import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class ProfileService {
  final String baseUrl = 'http://localhost/admintukang/api';

  // Get profile
  Future<Map<String, dynamic>> getProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/client/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['message'] ?? 'Gagal mengambil data profil');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Update profile without photo (JSON)
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
      final response = await http.put(
        Uri.parse('$baseUrl/client/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'nama_lengkap': namaLengkap,
          'email': email,
          'no_telp': noTelp,
          'alamat': alamat,
          'kota': kota,
          'provinsi': provinsi,
          'kode_pos': kodePos,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['message'] ?? 'Gagal update profil');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Update profile with photo (Multipart)
  Future<Map<String, dynamic>> updateProfileWithPhoto({
    required String token,
    required String namaLengkap,
    required String email,
    required String noTelp,
    required String alamat,
    required String kota,
    required String provinsi,
    required String kodePos,
    required File fotoProfil,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/client/profile'),
      );

      // Add headers
      request.headers['Authorization'] = 'Bearer $token';

      // Add fields
      request.fields['nama_lengkap'] = namaLengkap;
      request.fields['email'] = email;
      request.fields['no_telp'] = noTelp;
      request.fields['alamat'] = alamat;
      request.fields['kota'] = kota;
      request.fields['provinsi'] = provinsi;
      request.fields['kode_pos'] = kodePos;

      // Add photo file
      final mimeType = lookupMimeType(fotoProfil.path);
      final mimeTypeParts = mimeType?.split('/');

      request.files.add(
        await http.MultipartFile.fromPath(
          'foto_profil',
          fotoProfil.path,
          contentType:
              mimeType != null && mimeTypeParts != null
                  ? MediaType(mimeTypeParts[0], mimeTypeParts[1])
                  : null,
        ),
      );

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['message'] ?? 'Gagal update profil');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Update profile with photo (Multipart) using raw bytes + filename.
  /// This is web-friendly because it doesn't require `dart:io` File access.
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
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/client/profile'),
      );

      // Add headers
      request.headers['Authorization'] = 'Bearer $token';

      // Add fields
      request.fields['nama_lengkap'] = namaLengkap;
      request.fields['email'] = email;
      request.fields['no_telp'] = noTelp;
      request.fields['alamat'] = alamat;
      request.fields['kota'] = kota;
      request.fields['provinsi'] = provinsi;
      request.fields['kode_pos'] = kodePos;

      // Determine mime type from filename
      final mimeType = lookupMimeType(fotoProfilFilename);
      final mimeTypeParts = mimeType?.split('/');

      request.files.add(
        http.MultipartFile.fromBytes(
          'foto_profil',
          fotoProfilBytes,
          filename: fotoProfilFilename,
          contentType:
              mimeType != null && mimeTypeParts != null
                  ? MediaType(mimeTypeParts[0], mimeTypeParts[1])
                  : null,
        ),
      );

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['message'] ?? 'Gagal update profil');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
