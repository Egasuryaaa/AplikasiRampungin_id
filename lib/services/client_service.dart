import '../core/api_client.dart';
import '../core/api_config.dart';
import '../models/user_model.dart';
import '../models/transaction_model.dart';
import '../models/rating_model.dart';
import '../models/topup_model.dart';

/// Client Service - Handles all client-related endpoints
class ClientService {
  final ApiClient _client = ApiClient();

  // ==================== PROFILE ====================

  /// Get client profile
  Future<UserModel> getProfile() async {
    try {
      final response = await _client.get(ApiConfig.clientProfile);
      final data = _client.parseResponse(response);

      if (data['data'] != null) {
        return UserModel.fromJson(data['data'] as Map<String, dynamic>);
      }
      return UserModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get profile: $e');
    }
  }

  /// Update client profile
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
        ApiConfig.clientUpdateProfile,
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

  // ==================== BROWSE TUKANG ====================

  /// Get all tukang (workers)
  Future<List<UserModel>> getAllTukang() async {
    try {
      final response = await _client.get(ApiConfig.clientTukang);
      final data = _client.parseResponse(response);

      final List<dynamic> tukangList = data['data'] ?? data['tukang'] ?? [];
      return tukangList.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get tukang list: $e');
    }
  }

  /// Get tukang detail by ID
  Future<UserModel> getTukangDetail(int tukangId) async {
    try {
      final response = await _client.get(
        ApiConfig.clientTukangDetail(tukangId),
      );
      final data = _client.parseResponse(response);

      if (data['data'] != null) {
        return UserModel.fromJson(data['data'] as Map<String, dynamic>);
      }
      return UserModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get tukang detail: $e');
    }
  }

  /// Search tukang by name
  Future<List<UserModel>> searchTukang(String query) async {
    try {
      final response = await _client.get(ApiConfig.clientTukangSearch(query));
      final data = _client.parseResponse(response);

      final List<dynamic> tukangList = data['data'] ?? data['results'] ?? [];
      return tukangList.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search tukang: $e');
    }
  }

  /// Get tukang by category
  Future<List<UserModel>> getTukangByCategory(int categoryId) async {
    try {
      final response = await _client.get(
        ApiConfig.clientTukangCategory(categoryId),
      );
      final data = _client.parseResponse(response);

      final List<dynamic> tukangList = data['data'] ?? data['tukang'] ?? [];
      return tukangList.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get tukang by category: $e');
    }
  }

  /// Get tukang ratings
  Future<List<RatingModel>> getTukangRatings(int tukangId) async {
    try {
      final response = await _client.get(
        ApiConfig.clientTukangRatings(tukangId),
      );
      final data = _client.parseResponse(response);

      final List<dynamic> ratingList = data['data'] ?? data['ratings'] ?? [];
      return ratingList.map((json) => RatingModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get tukang ratings: $e');
    }
  }

  // ==================== TRANSACTIONS ====================

  /// Get all client transactions
  Future<List<TransactionModel>> getTransactions() async {
    try {
      final response = await _client.get(ApiConfig.clientTransactions);
      final data = _client.parseResponse(response);

      final List<dynamic> transactionList =
          data['data'] ?? data['transactions'] ?? [];
      return transactionList
          .map((json) => TransactionModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get transactions: $e');
    }
  }

  /// Get transaction detail
  Future<TransactionModel> getTransactionDetail(int transactionId) async {
    try {
      final response = await _client.get(
        ApiConfig.clientTransactionDetail(transactionId),
      );
      final data = _client.parseResponse(response);

      if (data['data'] != null) {
        return TransactionModel.fromJson(data['data'] as Map<String, dynamic>);
      }
      return TransactionModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get transaction detail: $e');
    }
  }

  /// Create new transaction (booking)
  ///
  /// Required params:
  /// - id_tukang: Tukang ID
  /// - id_kategori: Category ID
  /// - deskripsi_pekerjaan: Job description
  /// - alamat_pekerjaan: Job address
  /// - latitude, longitude: Location coordinates
  /// - tanggal_pekerjaan: Date (YYYY-MM-DD)
  /// - waktu_pekerjaan: Time (HH:MM)
  /// - metode_pembayaran: 'POIN' or 'TUNAI'
  /// - harga_penawaran: Offer price
  Future<TransactionModel> createTransaction({
    required int idTukang,
    required int idKategori,
    required String deskripsiPekerjaan,
    required String alamatPekerjaan,
    required double latitude,
    required double longitude,
    required String tanggalPekerjaan,
    required String waktuPekerjaan,
    required String metodePembayaran, // 'POIN' or 'TUNAI'
    required double hargaPenawaran,
  }) async {
    try {
      final body = {
        'id_tukang': idTukang,
        'id_kategori': idKategori,
        'deskripsi_pekerjaan': deskripsiPekerjaan,
        'alamat_pekerjaan': alamatPekerjaan,
        'latitude': latitude,
        'longitude': longitude,
        'tanggal_pekerjaan': tanggalPekerjaan,
        'waktu_pekerjaan': waktuPekerjaan,
        'metode_pembayaran': metodePembayaran,
        'harga_penawaran': hargaPenawaran,
      };

      final response = await _client.post(
        ApiConfig.clientCreateTransaction,
        body: body,
      );

      final data = _client.parseResponse(response);

      if (data['data'] != null) {
        return TransactionModel.fromJson(data['data'] as Map<String, dynamic>);
      }
      return TransactionModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to create transaction: $e');
    }
  }

  /// Cancel transaction
  ///
  /// Required params:
  /// - alasan_pembatalan: Cancellation reason
  Future<Map<String, dynamic>> cancelTransaction(
    int transactionId,
    String alasanPembatalan,
  ) async {
    try {
      final body = {'alasan_pembatalan': alasanPembatalan};

      final response = await _client.post(
        ApiConfig.clientCancelTransaction(transactionId),
        body: body,
      );

      return _client.parseResponse(response);
    } catch (e) {
      throw Exception('Failed to cancel transaction: $e');
    }
  }

  // ==================== RATING ====================

  /// Rate tukang after transaction complete
  ///
  /// Required params:
  /// - rating: 1-5 stars
  /// - ulasan: Review text
  Future<RatingModel> rateTukang({
    required int transactionId,
    required int rating,
    required String ulasan,
  }) async {
    try {
      final body = {'rating': rating, 'ulasan': ulasan};

      final response = await _client.post(
        ApiConfig.clientRateTukang(transactionId),
        body: body,
      );

      final data = _client.parseResponse(response);

      if (data['data'] != null) {
        return RatingModel.fromJson(data['data'] as Map<String, dynamic>);
      }
      return RatingModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to rate tukang: $e');
    }
  }

  // ==================== TOPUP ====================

  /// Create topup request (QRIS payment)
  ///
  /// Required params:
  /// - nominal: Amount to topup
  Future<TopUpModel> createTopup(double nominal) async {
    try {
      final body = {'nominal': nominal};

      final response = await _client.post(ApiConfig.clientTopup, body: body);

      final data = _client.parseResponse(response);

      if (data['data'] != null) {
        return TopUpModel.fromJson(data['data'] as Map<String, dynamic>);
      }
      return TopUpModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to create topup: $e');
    }
  }

  /// Get topup history
  Future<List<TopUpModel>> getTopupHistory() async {
    try {
      final response = await _client.get(ApiConfig.clientTopupHistory);
      final data = _client.parseResponse(response);

      final List<dynamic> topupList = data['data'] ?? data['history'] ?? [];
      return topupList.map((json) => TopUpModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get topup history: $e');
    }
  }

  // ==================== BALANCE ====================

  /// Get client balance (POIN)
  Future<double> getBalance() async {
    try {
      final response = await _client.get(ApiConfig.clientBalance);
      final data = _client.parseResponse(response);

      if (data['saldo'] != null) {
        return (data['saldo'] as num).toDouble();
      } else if (data['balance'] != null) {
        return (data['balance'] as num).toDouble();
      }

      return 0.0;
    } catch (e) {
      throw Exception('Failed to get balance: $e');
    }
  }
}
