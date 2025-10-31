// EXAMPLE: Cara mengintegrasikan AuthService ke existing login screen
// File: lib/client_screens/Login/login.dart (contoh modifikasi)

import 'package:flutter/material.dart';
import 'package:rampungin_id_userside/services/auth_service.dart';
import 'package:rampungin_id_userside/services/client_service.dart';
import 'package:rampungin_id_userside/models/user_model.dart';

// NOTE: Ini adalah contoh cara integrasi, bukan file lengkap
// Anda perlu merge code ini dengan file login.dart yang sudah ada

class LoginScreenExample extends StatefulWidget {
  @override
  _LoginScreenExampleState createState() => _LoginScreenExampleState();
}

class _LoginScreenExampleState extends State<LoginScreenExample> {
  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  // Check if user already logged in
  Future<void> _checkAuthentication() async {
    final isAuth = await _authService.isAuthenticated();
    if (isAuth && mounted) {
      // Get user info and navigate to appropriate home
      try {
        final user = await _authService.getCurrentUser();
        _navigateToHome(user);
      } catch (e) {
        // Token invalid, stay on login
        print('Token invalid: $e');
      }
    }
  }

  // Handle login with API
  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted && response.user != null) {
        _navigateToHome(response.user!);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Login gagal: ${e.toString()}';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_errorMessage!), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Navigate based on user type
  void _navigateToHome(UserModel user) {
    if (user.jenisAkun == 'client') {
      Navigator.pushReplacementNamed(context, '/client-home');
    } else if (user.jenisAkun == 'tukang') {
      // Check verification status for tukang
      if (user.statusVerifikasi == 'verified') {
        Navigator.pushReplacementNamed(context, '/tukang-home');
      } else if (user.statusVerifikasi == 'pending') {
        // Show pending verification message
        showDialog(
          context: context,
          builder:
              (ctx) => AlertDialog(
                title: Text('Verifikasi Pending'),
                content: Text(
                  'Akun Anda sedang dalam proses verifikasi. Mohon tunggu.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text('OK'),
                  ),
                ],
              ),
        );
      } else {
        // Rejected
        showDialog(
          context: context,
          builder:
              (ctx) => AlertDialog(
                title: Text('Verifikasi Ditolak'),
                content: Text('Akun Anda ditolak. Silakan hubungi admin.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text('OK'),
                  ),
                ],
              ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Icon(Icons.home_repair_service, size: 100, color: Colors.blue),
            SizedBox(height: 32),

            // Email field
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 16),

            // Password field
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 24),

            // Error message
            if (_errorMessage != null)
              Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              ),

            // Login button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                child:
                    _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('Login', style: TextStyle(fontSize: 16)),
              ),
            ),
            SizedBox(height: 16),

            // Register link
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: Text('Belum punya akun? Daftar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

// ===============================================
// EXAMPLE: Register Screen
// ===============================================

class RegisterScreenExample extends StatefulWidget {
  @override
  _RegisterScreenExampleState createState() => _RegisterScreenExampleState();
}

class _RegisterScreenExampleState extends State<RegisterScreenExample> {
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _noHpController = TextEditingController();
  final _alamatController = TextEditingController();

  String _jenisAkun = 'client'; // 'client' or 'tukang'
  int? _selectedKategori;
  bool _isLoading = false;

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.register(
        nama: _namaController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        noHp: _noHpController.text.trim(),
        alamat: _alamatController.text.trim(),
        jenisAkun: _jenisAkun,
        idKategori: _jenisAkun == 'tukang' ? _selectedKategori : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registrasi berhasil! Silakan login.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Back to login
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registrasi gagal: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Account type selector
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(value: 'client', label: Text('Client')),
                  ButtonSegment(value: 'tukang', label: Text('Tukang')),
                ],
                selected: {_jenisAkun},
                onSelectionChanged: (Set<String> value) {
                  setState(() => _jenisAkun = value.first);
                },
              ),
              SizedBox(height: 16),

              // Form fields
              TextFormField(
                controller: _namaController,
                decoration: InputDecoration(labelText: 'Nama Lengkap'),
                validator: (v) => v!.isEmpty ? 'Nama wajib diisi' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v!.isEmpty ? 'Email wajib diisi' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator:
                    (v) => v!.length < 8 ? 'Password minimal 8 karakter' : null,
              ),
              TextFormField(
                controller: _noHpController,
                decoration: InputDecoration(labelText: 'No. HP'),
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? 'No. HP wajib diisi' : null,
              ),
              TextFormField(
                controller: _alamatController,
                decoration: InputDecoration(labelText: 'Alamat'),
                maxLines: 3,
                validator: (v) => v!.isEmpty ? 'Alamat wajib diisi' : null,
              ),

              // Category selector for tukang
              if (_jenisAkun == 'tukang')
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(labelText: 'Kategori'),
                  value: _selectedKategori,
                  items: [
                    DropdownMenuItem(value: 1, child: Text('AC')),
                    DropdownMenuItem(value: 2, child: Text('Bangunan')),
                    DropdownMenuItem(value: 3, child: Text('Elektronik')),
                    DropdownMenuItem(value: 4, child: Text('Listrik')),
                    DropdownMenuItem(value: 5, child: Text('Cleaning Service')),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedKategori = value);
                  },
                  validator: (v) => v == null ? 'Kategori wajib dipilih' : null,
                ),

              SizedBox(height: 24),

              // Register button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  child:
                      _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text('Daftar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===============================================
// EXAMPLE: Browse Tukang with API
// ===============================================

class BrowseTukangExample extends StatefulWidget {
  @override
  _BrowseTukangExampleState createState() => _BrowseTukangExampleState();
}

class _BrowseTukangExampleState extends State<BrowseTukangExample> {
  final _clientService = ClientService();
  List<UserModel> _tukangList = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTukang();
  }

  Future<void> _loadTukang() async {
    setState(() => _isLoading = true);

    try {
      final tukangList = await _clientService.getAllTukang();
      setState(() {
        _tukangList = tukangList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $_errorMessage'),
              ElevatedButton(onPressed: _loadTukang, child: Text('Retry')),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Pilih Tukang')),
      body: ListView.builder(
        itemCount: _tukangList.length,
        itemBuilder: (context, index) {
          final tukang = _tukangList[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  tukang.fotoProfile != null
                      ? NetworkImage(tukang.fotoProfile!)
                      : null,
              child: tukang.fotoProfile == null ? Icon(Icons.person) : null,
            ),
            title: Text(tukang.nama ?? 'Unnamed'),
            subtitle: Text(
              '${tukang.namaKategori} • ⭐ ${tukang.rating?.toStringAsFixed(1)}',
            ),
            trailing: Text(
              tukang.statusAktif == 'online' ? '🟢 Online' : '⚫ Offline',
            ),
            onTap: () {
              // Navigate to tukang detail
              Navigator.pushNamed(context, '/tukang-detail', arguments: tukang);
            },
          );
        },
      ),
    );
  }
}
