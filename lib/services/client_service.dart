import 'package:http/http.dart' as http;
import '../core/api_client.dart';
import '../core/api_config.dart';
import '../models/user_model.dart';
import '../models/transaction_model.dart';
import '../models/rating_model.dart';
import '../models/topup_model.dart';
import '../models/category_model.dart';
import '../models/statistics_model.dart';
import '../models/tukang_detail_model.dart';

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
  /// Supports both JSON and multipart (with photo upload)
  Future<UserModel> updateProfile({
    String? nama,
    String? email,
    String? noHp,
    String? alamat,
    String? kota,
    String? provinsi,
    String? fotoProfilePath,
  }) async {
    try {
      final Map<String, String> fields = {
        if (nama != null) 'nama_lengkap': nama,
        if (email != null) 'email': email,
        if (noHp != null) 'no_telp': noHp,
        if (alamat != null) 'alamat': alamat,
        if (kota != null) 'kota': kota,
        if (provinsi != null) 'provinsi': provinsi,
      };

      http.Response response;

      // If photo is provided, use multipart
      if (fotoProfilePath != null && fotoProfilePath.isNotEmpty) {
        final streamedResponse = await _client.postMultipart(
          ApiConfig.clientProfile,
          'foto_profil',
          fotoProfilePath,
          fields: fields,
          requiresAuth: true,
        );
        response = await http.Response.fromStream(streamedResponse);
      } else {
        // Otherwise use regular PUT
        final body = fields.map((key, value) => MapEntry(key, value));
        response = await _client.put(ApiConfig.clientProfile, body: body);
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

  // ==================== CATEGORIES ====================

  /// Get all categories
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _client.get(ApiConfig.clientCategories);
      final data = _client.parseResponse(response);

      final List<dynamic> categoryList = data['data'] ?? [];
      return categoryList.map((json) => CategoryModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get categories: $e');
    }
  }

  // ==================== BROWSE TUKANG ====================

  /// Browse tukang with filters
  Future<List<UserModel>> browseTukang({
    int? kategoriId,
    String? kota,
    String? status,
    double? minRating,
    int? maxTarif,
    String? orderBy,
    String? orderDir,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, String>{
        if (kategoriId != null) 'kategori_id': kategoriId.toString(),
        if (kota != null) 'kota': kota,
        if (status != null) 'status': status,
        if (minRating != null) 'min_rating': minRating.toString(),
        if (maxTarif != null) 'max_tarif': maxTarif.toString(),
        if (orderBy != null) 'order_by': orderBy,
        if (orderDir != null) 'order_dir': orderDir,
        if (limit != null) 'limit': limit.toString(),
        if (offset != null) 'offset': offset.toString(),
      };

      var url = ApiConfig.clientTukang;
      if (queryParams.isNotEmpty) {
        final query = queryParams.entries
            .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
            .join('&');
        url = '$url?$query';
      }

      final response = await _client.get(url);
      final data = _client.parseResponse(response);

      final List<dynamic> tukangList = data['data'] ?? [];
      return tukangList.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to browse tukang: $e');
    }
  }

  /// Get tukang detail by ID (Full detail with ratings)
  Future<TukangDetailModel> getTukangDetailFull(int tukangId) async {
    try {
      print('ClientService: Fetching tukang detail for ID: $tukangId');

      final response = await _client.get(
        ApiConfig.clientTukangDetail(tukangId),
      );

      print('ClientService: Response received');

      final data = _client.parseResponse(response);

      print('ClientService: Response parsed successfully');
      print('ClientService: Data keys: ${data.keys.toList()}');

      if (data['data'] != null) {
        print('ClientService: Creating TukangDetailModel from data');
        return TukangDetailModel.fromJson(data['data'] as Map<String, dynamic>);
      }

      print('ClientService: Creating TukangDetailModel from root');
      return TukangDetailModel.fromJson(data);
    } catch (e, stackTrace) {
      print('ClientService: Error getting tukang detail: $e');
      print('ClientService: Stack trace: $stackTrace');
      throw Exception('Failed to get tukang detail: $e');
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

  /// Search tukang
  Future<List<UserModel>> searchTukang({
    required String keyword,
    int? kategoriId,
    String? kota,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, String>{
        'keyword': keyword,
        if (kategoriId != null) 'kategori_id': kategoriId.toString(),
        if (kota != null) 'kota': kota,
        if (limit != null) 'limit': limit.toString(),
        if (offset != null) 'offset': offset.toString(),
      };

      final query = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final response = await _client.get(
        '${ApiConfig.clientSearchTukang}?$query',
      );
      final data = _client.parseResponse(response);

      final List<dynamic> tukangList = data['data'] ?? [];
      return tukangList.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search tukang: $e');
    }
  }

  // ==================== BOOKING & TRANSACTIONS ====================

  /// Create booking
  Future<TransactionModel> createBooking({
    required int tukangId,
    required int kategoriId,
    required String judulLayanan,
    required String deskripsiLayanan,
    required String lokasiKerja,
    required String tanggalJadwal,
    required String waktuJadwal,
    required int estimasiDurasiJam,
    required double hargaDasar,
    double? biayaTambahan,
    required String metodePembayaran, // 'poin' or 'tunai'
    String? catatanClient,
  }) async {
    try {
      final body = {
        'tukang_id': tukangId,
        'kategori_id': kategoriId,
        'judul_layanan': judulLayanan,
        'deskripsi_layanan': deskripsiLayanan,
        'lokasi_kerja': lokasiKerja,
        'tanggal_jadwal': tanggalJadwal,
        'waktu_jadwal': waktuJadwal,
        'estimasi_durasi_jam': estimasiDurasiJam,
        'harga_dasar': hargaDasar,
        'biaya_tambahan': biayaTambahan ?? 0,
        'metode_pembayaran': metodePembayaran,
        if (catatanClient != null) 'catatan_client': catatanClient,
      };

      final response = await _client.post(ApiConfig.clientBooking, body: body);

      final data = _client.parseResponse(response);

      if (data['data'] != null) {
        return TransactionModel.fromJson(data['data'] as Map<String, dynamic>);
      }
      return TransactionModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  /// Get all client transactions
  Future<List<TransactionModel>> getTransactions({
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

      var url = ApiConfig.clientTransactions;
      if (queryParams.isNotEmpty) {
        final query = queryParams.entries
            .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
            .join('&');
        url = '$url?$query';
      }

      final response = await _client.get(url);
      final data = _client.parseResponse(response);

      final List<dynamic> transactionList = data['data'] ?? [];
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

  /// Cancel transaction
  Future<Map<String, dynamic>> cancelTransaction(
    int transactionId,
    String alasanPembatalan,
  ) async {
    try {
      final body = {'alasan_pembatalan': alasanPembatalan};

      final response = await _client.put(
        ApiConfig.clientCancelTransaction(transactionId),
        body: body,
      );

      return _client.parseResponse(response);
    } catch (e) {
      throw Exception('Failed to cancel transaction: $e');
    }
  }

  // ==================== RATING ====================

  /// Submit rating
  Future<RatingModel> submitRating({
    required int transaksiId,
    required int rating,
    required String ulasan,
  }) async {
    try {
      final body = {
        'transaksi_id': transaksiId,
        'rating': rating,
        'ulasan': ulasan,
      };

      final response = await _client.post(ApiConfig.clientRating, body: body);

      final data = _client.parseResponse(response);

      if (data['data'] != null) {
        return RatingModel.fromJson(data['data'] as Map<String, dynamic>);
      }
      return RatingModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to submit rating: $e');
    }
  }

  // ==================== TOPUP ====================

  /// Request top-up (QRIS payment)
  Future<TopUpModel> requestTopup({
    required double jumlah,
    required String buktiPembayaranPath,
  }) async {
    try {
      final response = await _client.postMultipart(
        ApiConfig.clientTopup,
        'bukti_pembayaran',
        buktiPembayaranPath,
        fields: {'jumlah': jumlah.toString()},
      );

      final responseBody = await response.stream.bytesToString();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Parse the response if needed
        return TopUpModel.fromJson({'jumlah': jumlah, 'status': 'pending'});
      } else {
        throw ApiException(
          statusCode: response.statusCode,
          message: responseBody,
        );
      }
    } catch (e) {
      throw Exception('Failed to request topup: $e');
    }
  }

  /// Get top-up history
  Future<List<TopUpModel>> getTopupHistory({
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

      var url = ApiConfig.clientTopup;
      if (queryParams.isNotEmpty) {
        final query = queryParams.entries
            .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
            .join('&');
        url = '$url?$query';
      }

      final response = await _client.get(url);
      final data = _client.parseResponse(response);

      final List<dynamic> topupList = data['data'] ?? [];
      return topupList.map((json) => TopUpModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get topup history: $e');
    }
  }

  // ==================== STATISTICS ====================

  /// Get client statistics
  Future<StatisticsModel> getStatistics() async {
    try {
      final response = await _client.get(ApiConfig.clientStatistics);
      final data = _client.parseResponse(response);

      return StatisticsModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get statistics: $e');
    }
  }
}
