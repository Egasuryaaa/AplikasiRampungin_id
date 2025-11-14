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

  // Browse Tukang
  static const String clientCategories = '/api/client/categories';
  static const String clientTukang = '/api/client/tukang';
  static String clientTukangDetail(int id) => '/api/client/tukang/$id';
  static const String clientSearchTukang = '/api/client/search-tukang';

  // Transactions (Client side) - Booking
  static const String clientBooking = '/api/client/booking';
  static const String clientTransactions = '/api/client/transactions';
  static String clientTransactionDetail(int id) =>
      '/api/client/transactions/$id';
  static String clientCancelTransaction(int id) =>
      '/api/client/transactions/$id/cancel';

  // Rating
  static const String clientRating = '/api/client/rating';

  // TopUp
  static const String clientTopup = '/api/client/topup';

  // Statistics
  static const String clientStatistics = '/api/client/statistics';

  // ==================== TUKANG ENDPOINTS ====================
  // Profile
  static const String tukangProfile = '/api/tukang/profile';
  static const String tukangAvailability = '/api/tukang/availability';

  // Categories
  static const String tukangCategories = '/api/tukang/categories';

  // Orders (Tukang side)
  static const String tukangOrders = '/api/tukang/orders';
  static String tukangOrderDetail(int id) => '/api/tukang/orders/$id';
  static String tukangAcceptOrder(int id) => '/api/tukang/orders/$id/accept';
  static String tukangRejectOrder(int id) => '/api/tukang/orders/$id/reject';
  static String tukangStartOrder(int id) => '/api/tukang/orders/$id/start';
  static String tukangCompleteOrder(int id) =>
      '/api/tukang/orders/$id/complete';
  static String tukangConfirmTunai(int id) =>
      '/api/tukang/orders/$id/confirm-tunai';

  // Ratings (Tukang side)
  static const String tukangRatings = '/api/tukang/ratings';

  // Withdrawal
  static const String tukangWithdrawal = '/api/tukang/withdrawal';

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
