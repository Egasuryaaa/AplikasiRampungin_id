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
  static const String authRegister = '/api/auth/register';
  static const String authLogin = '/api/auth/login';
  static const String authLogout = '/api/auth/logout';
  static const String authMe = '/api/auth/me';
  static const String authChangePassword = '/api/auth/change-password';

  // ==================== CLIENT ENDPOINTS ====================
  // Profile
  static const String clientProfile = '/api/client/profile';
  static const String clientUpdateProfile = '/api/client/profile/update';

  // Browse Tukang
  static const String clientTukang = '/api/client/tukang';
  static String clientTukangDetail(int id) => '/api/client/tukang/$id';
  static String clientTukangSearch(String query) =>
      '/api/client/tukang/search?q=$query';
  static String clientTukangCategory(int categoryId) =>
      '/api/client/tukang/category/$categoryId';
  static String clientTukangRatings(int tukangId) =>
      '/api/client/tukang/$tukangId/ratings';

  // Transactions (Client side)
  static const String clientTransactions = '/api/client/transactions';
  static String clientTransactionDetail(int id) =>
      '/api/client/transactions/$id';
  static const String clientCreateTransaction =
      '/api/client/transactions/create';
  static String clientCancelTransaction(int id) =>
      '/api/client/transactions/$id/cancel';

  // Rating
  static String clientRateTukang(int transactionId) =>
      '/api/client/transactions/$transactionId/rate';

  // TopUp
  static const String clientTopup = '/api/client/topup';
  static const String clientTopupHistory = '/api/client/topup/history';

  // Balance
  static const String clientBalance = '/api/client/balance';

  // ==================== TUKANG ENDPOINTS ====================
  // Profile
  static const String tukangProfile = '/api/tukang/profile';
  static const String tukangUpdateProfile = '/api/tukang/profile/update';
  static const String tukangUpdateStatus = '/api/tukang/profile/status';
  static const String tukangUploadKtp = '/api/tukang/profile/upload-ktp';

  // Orders (Tukang side)
  static const String tukangOrders = '/api/tukang/orders';
  static String tukangOrderDetail(int id) => '/api/tukang/orders/$id';
  static String tukangAcceptOrder(int id) => '/api/tukang/orders/$id/accept';
  static String tukangRejectOrder(int id) => '/api/tukang/orders/$id/reject';
  static String tukangStartOrder(int id) => '/api/tukang/orders/$id/start';
  static String tukangCompleteOrder(int id) =>
      '/api/tukang/orders/$id/complete';

  // Ratings (Tukang side)
  static const String tukangRatings = '/api/tukang/ratings';

  // Earnings & Withdrawal
  static const String tukangEarnings = '/api/tukang/earnings';
  static const String tukangWithdraw = '/api/tukang/earnings/withdraw';
  static const String tukangWithdrawalHistory =
      '/api/tukang/earnings/withdrawal-history';

  // Statistics
  static const String tukangStatistics = '/api/tukang/statistics';

  // ==================== HELPER METHODS ====================
  static String getFullUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }

  static Map<String, String> getAuthHeaders(String token) {
    return {...headers, 'Authorization': 'Bearer $token'};
  }
}
