# Rampungin.id API Integration

## 📚 Overview

Backend API integration sudah lengkap untuk aplikasi Rampungin.id dengan 33 endpoints yang mencakup authentication, client services, dan tukang services.

**Base URL:** `http://localhost/admintukang`  
**Authentication:** JWT Bearer Token (Valid 30 hari)

---

## 📁 Struktur Folder

```
lib/
├── core/
│   ├── api_config.dart       # Konfigurasi endpoint & constants
│   └── api_client.dart       # HTTP client dengan JWT management
├── models/
│   ├── user_model.dart       # Model user (client & tukang)
│   ├── transaction_model.dart # Model transaksi/pesanan
│   ├── rating_model.dart     # Model rating
│   ├── topup_model.dart      # Model topup POIN
│   ├── withdrawal_model.dart # Model penarikan saldo
│   └── statistics_model.dart # Model statistik tukang
└── services/
    ├── auth_service.dart     # Service authentication (5 endpoints)
    ├── client_service.dart   # Service client (14 endpoints)
    └── tukang_service.dart   # Service tukang (14 endpoints)
```

---

## 🔐 Authentication Service

### Import

```dart
import 'package:rampungin_id_userside/services/auth_service.dart';
```

### Methods

#### 1. Register (Daftar Akun Baru)

```dart
final authService = AuthService();

// Register Client
final response = await authService.register(
  nama: 'John Doe',
  email: 'john@example.com',
  password: 'password123',
  noHp: '081234567890',
  alamat: 'Jl. Contoh No. 123',
  jenisAkun: 'client',
);

// Register Tukang
final response = await authService.register(
  nama: 'Ahmad Tukang',
  email: 'ahmad@example.com',
  password: 'password123',
  noHp: '081234567890',
  alamat: 'Jl. Contoh No. 456',
  jenisAkun: 'tukang',
  idKategori: 1, // Required untuk tukang
);
```

#### 2. Login

```dart
final response = await authService.login(
  email: 'john@example.com',
  password: 'password123',
);

// Token otomatis tersimpan di SharedPreferences
print('Token: ${response.token}');
print('User: ${response.user?.nama}');
```

#### 3. Get Current User

```dart
final user = await authService.getCurrentUser();
print('Nama: ${user.nama}');
print('Email: ${user.email}');
print('Jenis Akun: ${user.jenisAkun}');
print('Saldo: ${user.saldo}');
```

#### 4. Change Password

```dart
await authService.changePassword(
  oldPassword: 'password123',
  newPassword: 'newpassword456',
);
```

#### 5. Logout

```dart
await authService.logout();
// Token otomatis dihapus dari SharedPreferences
```

---

## 👤 Client Service

### Import

```dart
import 'package:rampungin_id_userside/services/client_service.dart';
```

### Profile Management

```dart
final clientService = ClientService();

// Get Profile
final profile = await clientService.getProfile();

// Update Profile
final updatedProfile = await clientService.updateProfile(
  nama: 'John Doe Updated',
  noHp: '081234567890',
  alamat: 'Jl. Baru No. 999',
);
```

### Browse Tukang

```dart
// Get All Tukang
final allTukang = await clientService.getAllTukang();

// Search Tukang by Name
final searchResults = await clientService.searchTukang('tukang AC');

// Get Tukang by Category
final tukangAC = await clientService.getTukangByCategory(1);

// Get Tukang Detail
final tukangDetail = await clientService.getTukangDetail(5);

// Get Tukang Ratings
final ratings = await clientService.getTukangRatings(5);
```

### Transaction Management

```dart
// Create Transaction (Booking)
final transaction = await clientService.createTransaction(
  idTukang: 5,
  idKategori: 1,
  deskripsiPekerjaan: 'Service AC tidak dingin',
  alamatPekerjaan: 'Jl. Contoh No. 123, Jakarta',
  latitude: -6.2088,
  longitude: 106.8456,
  tanggalPekerjaan: '2025-06-15',
  waktuPekerjaan: '14:00',
  metodePembayaran: 'POIN', // or 'TUNAI'
  hargaPenawaran: 150000,
);

// Get All Transactions
final transactions = await clientService.getTransactions();

// Get Transaction Detail
final detail = await clientService.getTransactionDetail(10);

// Cancel Transaction
await clientService.cancelTransaction(10, 'Salah pilih waktu');
```

### Rating

```dart
// Rate Tukang (after transaction completed)
final rating = await clientService.rateTukang(
  transactionId: 10,
  rating: 5,
  ulasan: 'Sangat memuaskan, kerja cepat dan rapi!',
);
```

### TopUp & Balance

```dart
// Create TopUp (QRIS)
final topup = await clientService.createTopup(100000);
print('QRIS URL: ${topup.qrisUrl}');

// Get TopUp History
final history = await clientService.getTopupHistory();

// Get Balance
final balance = await clientService.getBalance();
print('Saldo POIN: Rp $balance');
```

---

## 🔨 Tukang Service

### Import

```dart
import 'package:rampungin_id_userside/services/tukang_service.dart';
```

### Profile Management

```dart
final tukangService = TukangService();

// Get Profile
final profile = await tukangService.getProfile();

// Update Profile
final updatedProfile = await tukangService.updateProfile(
  nama: 'Ahmad Tukang Updated',
  noHp: '081234567890',
);

// Update Status (Online/Offline/Busy)
await tukangService.updateStatus('online'); // 'online', 'offline', 'busy'

// Upload KTP
await tukangService.uploadKtp('/path/to/ktp_photo.jpg');
```

### Order Management

```dart
// Get All Orders
final orders = await tukangService.getOrders();

// Get Order Detail
final orderDetail = await tukangService.getOrderDetail(10);

// Accept Order
await tukangService.acceptOrder(10);

// Reject Order
await tukangService.rejectOrder(10, 'Jadwal penuh');

// Start Order (mark as in progress)
await tukangService.startOrder(10);

// Complete Order
await tukangService.completeOrder(10, 200000); // harga_akhir
```

### Ratings

```dart
// Get All Ratings Received
final ratings = await tukangService.getRatings();

for (var rating in ratings) {
  print('Rating: ${rating.rating}/5 - ${rating.ulasan}');
}
```

### Earnings & Withdrawal

```dart
// Get Earnings Summary
final earnings = await tukangService.getEarnings();
print('Total Pendapatan: ${earnings['total_pendapatan']}');
print('Saldo Tersedia: ${earnings['saldo_tersedia']}');

// Request Withdrawal
final withdrawal = await tukangService.requestWithdrawal(
  nominal: 500000,
  nomorRekening: '1234567890',
  namaBank: 'BCA',
  atasNama: 'Ahmad Tukang',
);

// Get Withdrawal History
final withdrawalHistory = await tukangService.getWithdrawalHistory();
```

### Statistics

```dart
// Get Statistics
final stats = await tukangService.getStatistics();

print('Total Pesanan: ${stats.totalPesanan}');
print('Pesanan Selesai: ${stats.pesananSelesai}');
print('Rata-rata Rating: ${stats.rataRataRating}');
print('Total Pendapatan: ${stats.totalPendapatan}');
```

---

## 🛠️ Error Handling

Semua service methods menggunakan `try-catch` untuk error handling:

```dart
try {
  final user = await authService.login(
    email: 'john@example.com',
    password: 'password123',
  );
  print('Login success: ${user.token}');
} catch (e) {
  print('Login failed: $e');
  // Show error to user
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Login gagal: $e')),
  );
}
```

### ApiException

Custom exception untuk HTTP errors:

```dart
try {
  await clientService.createTransaction(...);
} on ApiException catch (e) {
  print('Status Code: ${e.statusCode}');
  print('Error Message: ${e.message}');

  if (e.statusCode == 401) {
    // Token expired, redirect to login
    Navigator.pushReplacementNamed(context, '/login');
  } else if (e.statusCode == 400) {
    // Validation error
    print('Invalid input');
  }
}
```

---

## 📝 Model Classes

### UserModel

```dart
class UserModel {
  final int? id;
  final String? nama;
  final String? email;
  final String? noHp;
  final String? alamat;
  final String? jenisAkun;        // 'client' or 'tukang'
  final String? statusVerifikasi; // 'pending', 'verified', 'rejected'
  final String? statusAktif;      // 'online', 'offline', 'busy'
  final double? rating;
  final int? jumlahPesanan;
  final double? saldo;
  // ... more fields
}
```

### TransactionModel

```dart
class TransactionModel {
  final int? id;
  final int? idClient;
  final int? idTukang;
  final String? deskripsiPekerjaan;
  final String? statusPesanan;    // 'pending', 'accepted', 'in_progress', 'completed', 'cancelled'
  final String? metodePembayaran; // 'POIN' or 'TUNAI'
  final double? hargaPenawaran;
  final double? hargaAkhir;
  // ... more fields
}
```

---

## 🔑 JWT Token Management

Token otomatis dikelola oleh `ApiClient`:

```dart
// Token disimpan otomatis saat login/register
await authService.login(...);

// Token digunakan otomatis di setiap API call
final profile = await clientService.getProfile(); // Token included automatically

// Token dihapus otomatis saat logout
await authService.logout();

// Manual token management (optional)
final apiClient = ApiClient();
await apiClient.saveToken('your_jwt_token');
final token = await apiClient.getToken();
await apiClient.removeToken();
```

---

## 🚀 Usage Example dalam Widget

```dart
import 'package:flutter/material.dart';
import 'package:rampungin_id_userside/services/auth_service.dart';
import 'package:rampungin_id_userside/services/client_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);

    try {
      final response = await _authService.login(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Navigate to home based on account type
      if (response.user?.jenisAkun == 'client') {
        Navigator.pushReplacementNamed(context, '/client-home');
      } else {
        Navigator.pushReplacementNamed(context, '/tukang-home');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login gagal: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _handleLogin,
                    child: Text('Login'),
                  ),
          ],
        ),
      ),
    );
  }
}
```

---

## 📦 Dependencies

Pastikan dependencies berikut sudah ada di `pubspec.yaml`:

```yaml
dependencies:
  http: ^1.1.0
  shared_preferences: ^2.2.2
  dio: ^5.4.0 # Optional (untuk future enhancement)
  logger: ^2.0.2
```

---

## ✅ Next Steps

1. **Run `flutter pub get`** ✅ (Sudah selesai)
2. **Integrate services ke UI screens:**
   - Update `client_screens/Login/login.dart` untuk menggunakan `AuthService`
   - Update `tukang_screens/Login/login.dart` untuk menggunakan `AuthService`
   - Update `client_screens/content_bottom/home_screen.dart` untuk menggunakan `ClientService.getAllTukang()`
   - Update form booking menggunakan `ClientService.createTransaction()`
3. **Test API integration:**
   - Pastikan backend running di `http://localhost/admintukang`
   - Test login/register
   - Test browse tukang
   - Test booking flow
4. **Handle loading states & error messages**
5. **Add state management** (Provider/Riverpod/Bloc) untuk global state

---

## 📞 API Endpoint Summary

### Authentication (5)

- POST `/api/v1/auth/register` - Register user
- POST `/api/v1/auth/login` - Login
- POST `/api/v1/auth/logout` - Logout
- GET `/api/v1/auth/me` - Get current user
- POST `/api/v1/auth/change-password` - Change password

### Client (14)

- Profile: GET/PUT `/api/v1/client/profile`
- Browse: GET `/api/v1/client/tukang` (+ search, category, detail, ratings)
- Transactions: GET/POST `/api/v1/client/transactions` (+ detail, create, cancel)
- Rating: POST `/api/v1/client/transactions/{id}/rate`
- TopUp: POST `/api/v1/client/topup` (+ history)
- Balance: GET `/api/v1/client/balance`

### Tukang (14)

- Profile: GET/PUT `/api/v1/tukang/profile` (+ status, upload KTP)
- Orders: GET `/api/v1/tukang/orders` (+ detail, accept, reject, start, complete)
- Ratings: GET `/api/v1/tukang/ratings`
- Earnings: GET `/api/v1/tukang/earnings` (+ withdraw, history)
- Statistics: GET `/api/v1/tukang/statistics`

---

## 🎯 Status

✅ API Configuration  
✅ HTTP Client dengan JWT  
✅ Model Classes (6 models)  
✅ Auth Service (5 endpoints)  
✅ Client Service (14 endpoints)  
✅ Tukang Service (14 endpoints)  
✅ Error Handling  
✅ Flutter Analyze: No issues found!

**Total: 33 endpoints siap digunakan!**
