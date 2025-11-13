import 'package:http/http.dart' as http;
import '../core/api_client.dart';
import '../core/api_config.dart';
import '../models/user_model.dart';
import '../models/transaction_model.dart';
import '../models/rating_model.dart';
import '../models/withdrawal_model.dart';
import '../models/statistics_model.dart';
import '../models/tukang_profile_model.dart';

/// Tukang Service - Handles all tukang-related endpoints
class TukangService {
  final ApiClient _client = ApiClient();

  // ==================== PROFILE ====================

  /// Get tukang profile
  Future<UserModel> getProfile() async {
    try {
      final response = await _client.get(ApiConfig.tukangProfile);
      final data = _client.parseResponse(response);

      if (data['data'] != null) {
        return UserModel.fromJson(data['data'] as Map<String, dynamic>);
      }
      return UserModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get profile: $e');
    }
  }

  /// Update tukang profile
  /// Supports both JSON and multipart (with photo upload)
  Future<UserModel> updateProfile({
    String? nama,
    String? email,
    String? noHp,
    String? alamat,
    String? kota,
    String? provinsi,
    int? pengalamanTahun,
    double? tarifPerJam,
    String? bio,
    List<String>? keahlian,
    int? radiusLayananKm,
    String? namaBank,
    String? nomorRekening,
    String? namaPemilikRekening,
    List<int>? fotoProfileBytes,
    String? fotoProfileFilename,
  }) async {
    try {
      final Map<String, String> fields = {
        if (nama != null) 'nama_lengkap': nama,
        if (email != null) 'email': email,
        if (noHp != null) 'no_telp': noHp,
        if (alamat != null) 'alamat': alamat,
        if (kota != null) 'kota': kota,
        if (provinsi != null) 'provinsi': provinsi,
        if (pengalamanTahun != null)
          'pengalaman_tahun': pengalamanTahun.toString(),
        if (tarifPerJam != null) 'tarif_per_jam': tarifPerJam.toString(),
        if (bio != null) 'bio': bio,
        if (keahlian != null) 'keahlian': keahlian.join(','),
        if (radiusLayananKm != null)
          'radius_layanan_km': radiusLayananKm.toString(),
        if (namaBank != null) 'nama_bank': namaBank,
        if (nomorRekening != null) 'nomor_rekening': nomorRekening,
        if (namaPemilikRekening != null)
          'nama_pemilik_rekening': namaPemilikRekening,
      };

      http.Response response;

      // If photo is provided, use multipart
      if (fotoProfileBytes != null && fotoProfileFilename != null) {
        final streamedResponse = await _client.postMultipart(
          ApiConfig.tukangProfile,
          'foto_profil',
          fotoProfileBytes,
          fotoProfileFilename,
          fields: fields,
          requiresAuth: true,
        );
        response = await http.Response.fromStream(streamedResponse);
      } else {
        // Otherwise use regular PUT
        final body = fields.map((key, value) => MapEntry(key, value));
        response = await _client.put(ApiConfig.tukangProfile, body: body);
      }

      final data = _client.parseResponse(response);

      if (data['data'] != null) {
        return UserModel.fromJson(data['data'] as Map<String, dynamic>);
      }
      return UserModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  /// Update tukang availability status
  Future<Map<String, dynamic>> updateAvailability(
    String statusKetersediaan,
  ) async {
    try {
      final body = {'status_ketersediaan': statusKetersediaan};

      final response = await _client.put(
        ApiConfig.tukangAvailability,
        body: body,
      );

      return _client.parseResponse(response);
    } catch (e) {
      throw Exception('Failed to update availability: $e');
    }
  }

  /// Get tukang profile (Full detail with profil_tukang and kategori)
  Future<TukangProfileModel> getProfileFull() async {
    try {
      final response = await _client.get(ApiConfig.tukangProfile);
      final data = _client.parseResponse(response);

      if (data['data'] != null) {
        return TukangProfileModel.fromJson(
          data['data'] as Map<String, dynamic>,
        );
      }
      throw Exception('No profile data found');
    } catch (e) {
      throw Exception('Failed to get profile: $e');
    }
  }

  /// Update tukang profile (JSON format - sesuai API spec)
  Future<TukangProfileModel> updateProfileFull({
    required String namaLengkap,
    required String email,
    required String noTelp,
    required String alamat,
    required String kota,
    required String provinsi,
    required int pengalamanTahun,
    required double tarifPerJam,
    required String bio,
    required List<String> keahlian,
    required int radiusLayananKm,
    required String namaBank,
    required String nomorRekening,
    required String namaPemilikRekening,
    List<int>? kategoriIds,
    String? fotoProfil, // Base64 string (optional)
  }) async {
    try {
      final body = {
        'nama_lengkap': namaLengkap,
        'email': email,
        'no_telp': noTelp,
        'alamat': alamat,
        'kota': kota,
        'provinsi': provinsi,
        'pengalaman_tahun': pengalamanTahun,
        'tarif_per_jam': tarifPerJam,
        'bio': bio,
        'keahlian': keahlian,
        'radius_layanan_km': radiusLayananKm,
        'nama_bank': namaBank,
        'nomor_rekening': nomorRekening,
        'nama_pemilik_rekening': namaPemilikRekening,
        if (kategoriIds != null && kategoriIds.isNotEmpty)
          'kategori_ids': kategoriIds,
        if (fotoProfil != null) 'foto_profil': fotoProfil,
      };

      // Use PUT method as per API spec
      final response = await _client.put(ApiConfig.tukangProfile, body: body);

      final data = _client.parseResponse(response);

      // If backend returns success but null data, fetch the updated profile
      if (data['status'] == 'success') {
        // Fetch updated profile after successful update
        return await getProfileFull();
      }

      throw Exception(
        'Update profile failed: ${data['message'] ?? 'Unknown error'}',
      );
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // ==================== ORDERS ====================

  /// Get all tukang orders with filters
  Future<List<TransactionModel>> getOrders({
    String? status,
    String? metodePembayaran,
    String? startDate,
    String? endDate,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, String>{
        if (status != null) 'status': status,
        if (metodePembayaran != null) 'metode_pembayaran': metodePembayaran,
        if (startDate != null) 'start_date': startDate,
        if (endDate != null) 'end_date': endDate,
        if (limit != null) 'limit': limit.toString(),
        if (offset != null) 'offset': offset.toString(),
      };

      var url = ApiConfig.tukangOrders;
      if (queryParams.isNotEmpty) {
        final query = queryParams.entries
            .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
            .join('&');
        url = '$url?$query';
      }

      final response = await _client.get(url);
      final data = _client.parseResponse(response);

      final List<dynamic> orderList = data['data'] ?? [];
      return orderList.map((json) => TransactionModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get orders: $e');
    }
  }

  /// Get order detail
  Future<TransactionModel> getOrderDetail(int orderId) async {
    try {
      final response = await _client.get(ApiConfig.tukangOrderDetail(orderId));
      final data = _client.parseResponse(response);

      if (data['data'] != null) {
        return TransactionModel.fromJson(data['data'] as Map<String, dynamic>);
      }
      return TransactionModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get order detail: $e');
    }
  }

  /// Accept order
  Future<Map<String, dynamic>> acceptOrder(int orderId) async {
    try {
      final response = await _client.put(ApiConfig.tukangAcceptOrder(orderId));

      return _client.parseResponse(response);
    } catch (e) {
      throw Exception('Failed to accept order: $e');
    }
  }

  /// Reject order
  Future<Map<String, dynamic>> rejectOrder(
    int orderId,
    String alasanPenolakan,
  ) async {
    try {
      final body = {'alasan_penolakan': alasanPenolakan};

      final response = await _client.put(
        ApiConfig.tukangRejectOrder(orderId),
        body: body,
      );

      return _client.parseResponse(response);
    } catch (e) {
      throw Exception('Failed to reject order: $e');
    }
  }

  /// Start order (mark as in progress)
  Future<Map<String, dynamic>> startOrder(int orderId) async {
    try {
      final response = await _client.put(ApiConfig.tukangStartOrder(orderId));

      return _client.parseResponse(response);
    } catch (e) {
      throw Exception('Failed to start order: $e');
    }
  }

  /// Complete order
  Future<Map<String, dynamic>> completeOrder(
    int orderId, {
    String? catatanTukang,
  }) async {
    try {
      final body = {if (catatanTukang != null) 'catatan_tukang': catatanTukang};

      final response = await _client.put(
        ApiConfig.tukangCompleteOrder(orderId),
        body: body,
      );

      return _client.parseResponse(response);
    } catch (e) {
      throw Exception('Failed to complete order: $e');
    }
  }

  /// Confirm tunai payment (for cash on service)
  Future<Map<String, dynamic>> confirmTunaiPayment(int orderId) async {
    try {
      final response = await _client.put(ApiConfig.tukangConfirmTunai(orderId));

      return _client.parseResponse(response);
    } catch (e) {
      throw Exception('Failed to confirm tunai payment: $e');
    }
  }

  // ==================== RATINGS ====================

  /// Get all ratings received by tukang
  Future<List<RatingModel>> getRatings() async {
    try {
      final response = await _client.get(ApiConfig.tukangRatings);
      final data = _client.parseResponse(response);

      final List<dynamic> ratingList = data['data'] ?? data['ratings'] ?? [];
      return ratingList.map((json) => RatingModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get ratings: $e');
    }
  }

  // ==================== EARNINGS & WITHDRAWAL ====================

  /// Request withdrawal
  Future<WithdrawalModel> requestWithdrawal({
    required double jumlah,
    required String nomorRekening,
    required String namaBank,
    required String namaPemilikRekening,
  }) async {
    try {
      final body = {
        'jumlah': jumlah,
        'nomor_rekening': nomorRekening,
        'nama_bank': namaBank,
        'nama_pemilik_rekening': namaPemilikRekening,
      };

      final response = await _client.post(
        ApiConfig.tukangWithdrawal,
        body: body,
      );

      final data = _client.parseResponse(response);

      if (data['data'] != null) {
        return WithdrawalModel.fromJson(data['data'] as Map<String, dynamic>);
      }
      return WithdrawalModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to request withdrawal: $e');
    }
  }

  /// Get withdrawal history
  Future<List<WithdrawalModel>> getWithdrawalHistory({
    String? status,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, String>{
        if (status != null) 'status': status,
        if (limit != null) 'limit': limit.toString(),
        if (offset != null) 'offset': offset.toString(),
      };

      var url = ApiConfig.tukangWithdrawal;
      if (queryParams.isNotEmpty) {
        final query = queryParams.entries
            .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
            .join('&');
        url = '$url?$query';
      }

      final response = await _client.get(url);
      final data = _client.parseResponse(response);

      final List<dynamic> withdrawalList = data['data'] ?? [];
      return withdrawalList
          .map((json) => WithdrawalModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get withdrawal history: $e');
    }
  }

  // ==================== STATISTICS ====================

  /// Get tukang statistics (orders, earnings, ratings)
  Future<StatisticsModel> getStatistics() async {
    try {
      final response = await _client.get(ApiConfig.tukangStatistics);
      final data = _client.parseResponse(response);

      if (data['data'] != null) {
        return StatisticsModel.fromJson(data['data'] as Map<String, dynamic>);
      }
      return StatisticsModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get statistics: $e');
    }
  }
}
