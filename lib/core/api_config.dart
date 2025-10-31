/// API Configuration for Rampungin.id Backend
class ApiConfig {
  // Base URL
  static const String baseUrl = 'http://localhost/admintukang';

  // Timeout durations
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Headers
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // ==================== AUTH ENDPOINTS ====================
  static const String authRegister = '/api/v1/auth/register';
  static const String authLogin = '/api/v1/auth/login';
  static const String authLogout = '/api/v1/auth/logout';
  static const String authMe = '/api/v1/auth/me';
  static const String authChangePassword = '/api/v1/auth/change-password';

  // ==================== CLIENT ENDPOINTS ====================
  // Profile
  static const String clientProfile = '/api/v1/client/profile';
  static const String clientUpdateProfile = '/api/v1/client/profile/update';

  // Browse Tukang
  static const String clientTukang = '/api/v1/client/tukang';
  static String clientTukangDetail(int id) => '/api/v1/client/tukang/$id';
  static String clientTukangSearch(String query) =>
      '/api/v1/client/tukang/search?q=$query';
  static String clientTukangCategory(int categoryId) =>
      '/api/v1/client/tukang/category/$categoryId';
  static String clientTukangRatings(int tukangId) =>
      '/api/v1/client/tukang/$tukangId/ratings';

  // Transactions (Client side)
  static const String clientTransactions = '/api/v1/client/transactions';
  static String clientTransactionDetail(int id) =>
      '/api/v1/client/transactions/$id';
  static const String clientCreateTransaction =
      '/api/v1/client/transactions/create';
  static String clientCancelTransaction(int id) =>
      '/api/v1/client/transactions/$id/cancel';

  // Rating
  static String clientRateTukang(int transactionId) =>
      '/api/v1/client/transactions/$transactionId/rate';

  // TopUp
  static const String clientTopup = '/api/v1/client/topup';
  static const String clientTopupHistory = '/api/v1/client/topup/history';

  // Balance
  static const String clientBalance = '/api/v1/client/balance';

  // ==================== TUKANG ENDPOINTS ====================
  // Profile
  static const String tukangProfile = '/api/v1/tukang/profile';
  static const String tukangUpdateProfile = '/api/v1/tukang/profile/update';
  static const String tukangUpdateStatus = '/api/v1/tukang/profile/status';
  static const String tukangUploadKtp = '/api/v1/tukang/profile/upload-ktp';

  // Orders (Tukang side)
  static const String tukangOrders = '/api/v1/tukang/orders';
  static String tukangOrderDetail(int id) => '/api/v1/tukang/orders/$id';
  static String tukangAcceptOrder(int id) => '/api/v1/tukang/orders/$id/accept';
  static String tukangRejectOrder(int id) => '/api/v1/tukang/orders/$id/reject';
  static String tukangStartOrder(int id) => '/api/v1/tukang/orders/$id/start';
  static String tukangCompleteOrder(int id) =>
      '/api/v1/tukang/orders/$id/complete';

  // Ratings (Tukang side)
  static const String tukangRatings = '/api/v1/tukang/ratings';

  // Earnings & Withdrawal
  static const String tukangEarnings = '/api/v1/tukang/earnings';
  static const String tukangWithdraw = '/api/v1/tukang/earnings/withdraw';
  static const String tukangWithdrawalHistory =
      '/api/v1/tukang/earnings/withdrawal-history';

  // Statistics
  static const String tukangStatistics = '/api/v1/tukang/statistics';

  // ==================== HELPER METHODS ====================
  static String getFullUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }

  static Map<String, String> getAuthHeaders(String token) {
    return {...headers, 'Authorization': 'Bearer $token'};
  }
}
