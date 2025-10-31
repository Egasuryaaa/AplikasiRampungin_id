import '../core/api_client.dart';
import '../core/api_config.dart';
import '../models/user_model.dart';
import '../models/transaction_model.dart';
import '../models/rating_model.dart';
import '../models/withdrawal_model.dart';
import '../models/statistics_model.dart';

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
  ///
  /// Optional params: nama, no_hp, alamat, foto_profile
  Future<UserModel> updateProfile({
    String? nama,
    String? noHp,
    String? alamat,
    String? fotoProfile,
  }) async {
    try {
      final body = {
        if (nama != null) 'nama': nama,
        if (noHp != null) 'no_hp': noHp,
        if (alamat != null) 'alamat': alamat,
        if (fotoProfile != null) 'foto_profile': fotoProfile,
      };

      final response = await _client.put(
        ApiConfig.tukangUpdateProfile,
        body: body,
      );

      final data = _client.parseResponse(response);

      if (data['data'] != null) {
        return UserModel.fromJson(data['data'] as Map<String, dynamic>);
      }
      return UserModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  /// Update tukang status (online/offline/busy)
  ///
  /// Required params:
  /// - status_aktif: 'online', 'offline', or 'busy'
  Future<Map<String, dynamic>> updateStatus(String statusAktif) async {
    try {
      final body = {'status_aktif': statusAktif};

      final response = await _client.put(
        ApiConfig.tukangUpdateStatus,
        body: body,
      );

      return _client.parseResponse(response);
    } catch (e) {
      throw Exception('Failed to update status: $e');
    }
  }

  /// Upload KTP photo (multipart form data)
  ///
  /// Required params:
  /// - ktpFilePath: Absolute path to KTP image file
  Future<Map<String, dynamic>> uploadKtp(String ktpFilePath) async {
    try {
      final response = await _client.postMultipart(
        ApiConfig.tukangUploadKtp,
        'ktp_photo',
        ktpFilePath,
      );

      // Read response stream
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'message': 'KTP uploaded successfully',
          'status': response.statusCode,
        };
      } else {
        throw ApiException(
          statusCode: response.statusCode,
          message: responseBody,
        );
      }
    } catch (e) {
      throw Exception('Failed to upload KTP: $e');
    }
  }

  // ==================== ORDERS ====================

  /// Get all tukang orders
  Future<List<TransactionModel>> getOrders() async {
    try {
      final response = await _client.get(ApiConfig.tukangOrders);
      final data = _client.parseResponse(response);

      final List<dynamic> orderList = data['data'] ?? data['orders'] ?? [];
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
      final response = await _client.post(ApiConfig.tukangAcceptOrder(orderId));

      return _client.parseResponse(response);
    } catch (e) {
      throw Exception('Failed to accept order: $e');
    }
  }

  /// Reject order
  ///
  /// Required params:
  /// - alasan_penolakan: Rejection reason
  Future<Map<String, dynamic>> rejectOrder(
    int orderId,
    String alasanPenolakan,
  ) async {
    try {
      final body = {'alasan_penolakan': alasanPenolakan};

      final response = await _client.post(
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
      final response = await _client.post(ApiConfig.tukangStartOrder(orderId));

      return _client.parseResponse(response);
    } catch (e) {
      throw Exception('Failed to start order: $e');
    }
  }

  /// Complete order
  ///
  /// Required params:
  /// - harga_akhir: Final price
  Future<Map<String, dynamic>> completeOrder(
    int orderId,
    double hargaAkhir,
  ) async {
    try {
      final body = {'harga_akhir': hargaAkhir};

      final response = await _client.post(
        ApiConfig.tukangCompleteOrder(orderId),
        body: body,
      );

      return _client.parseResponse(response);
    } catch (e) {
      throw Exception('Failed to complete order: $e');
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

  /// Get tukang earnings summary
  Future<Map<String, dynamic>> getEarnings() async {
    try {
      final response = await _client.get(ApiConfig.tukangEarnings);
      return _client.parseResponse(response);
    } catch (e) {
      throw Exception('Failed to get earnings: $e');
    }
  }

  /// Request withdrawal
  ///
  /// Required params:
  /// - nominal: Amount to withdraw
  /// - nomor_rekening: Bank account number
  /// - nama_bank: Bank name
  /// - atas_nama: Account holder name
  Future<WithdrawalModel> requestWithdrawal({
    required double nominal,
    required String nomorRekening,
    required String namaBank,
    required String atasNama,
  }) async {
    try {
      final body = {
        'nominal': nominal,
        'nomor_rekening': nomorRekening,
        'nama_bank': namaBank,
        'atas_nama': atasNama,
      };

      final response = await _client.post(ApiConfig.tukangWithdraw, body: body);

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
  Future<List<WithdrawalModel>> getWithdrawalHistory() async {
    try {
      final response = await _client.get(ApiConfig.tukangWithdrawalHistory);
      final data = _client.parseResponse(response);

      final List<dynamic> withdrawalList =
          data['data'] ?? data['history'] ?? [];
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
