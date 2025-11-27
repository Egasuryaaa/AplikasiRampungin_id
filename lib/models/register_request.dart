import 'dart:io';

class RegisterRequest {
  // Required fields
  final String username;
  final String email;
  final String password;
  final String namaLengkap;
  final String noTelp;
  final String role; // "client" atau "tukang"

  // Optional user fields
  final File? fotoProfil;
  final String? alamat;
  final String? kota;
  final String? provinsi;
  final String? kodePos;

  // Optional tukang fields (hanya untuk role = "tukang")
  final int? pengalamanTahun;
  final double? tarifPerJam;
  final String? bio;
  final List<String>? keahlian;
  final List<int>? kategoriIds;
  final String? namaBank;
  final String? nomorRekening;
  final String? namaPemilikRekening;

  RegisterRequest({
    required this.username,
    required this.email,
    required this.password,
    required this.namaLengkap,
    required this.noTelp,
    required this.role,
    this.fotoProfil,
    this.alamat,
    this.kota,
    this.provinsi,
    this.kodePos,
    // Tukang fields
    this.pengalamanTahun,
    this.tarifPerJam,
    this.bio,
    this.keahlian,
    this.kategoriIds,
    this.namaBank,
    this.nomorRekening,
    this.namaPemilikRekening,
  });

  /// Convert to Map for API request
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'username': username,
      'email': email,
      'password': password,
      'nama_lengkap': namaLengkap,
      'no_telp': noTelp,
      'role': role,
    };

    // Add optional user fields if not null
    if (alamat != null) data['alamat'] = alamat;
    if (kota != null) data['kota'] = kota;
    if (provinsi != null) data['provinsi'] = provinsi;
    if (kodePos != null) data['kode_pos'] = kodePos;

    // Add tukang-specific fields if role is tukang
    if (role == 'tukang') {
      if (pengalamanTahun != null) {
        data['pengalaman_tahun'] = pengalamanTahun;
      }
      if (tarifPerJam != null) data['tarif_per_jam'] = tarifPerJam;
      if (bio != null) data['bio'] = bio;
      if (keahlian != null && keahlian!.isNotEmpty) {
        data['keahlian'] = keahlian;
      }
      if (kategoriIds != null && kategoriIds!.isNotEmpty) {
        data['kategori_ids'] = kategoriIds!.join(',');
      }
      if (namaBank != null) data['nama_bank'] = namaBank;
      if (nomorRekening != null) data['nomor_rekening'] = nomorRekening;
      if (namaPemilikRekening != null) {
        data['nama_pemilik_rekening'] = namaPemilikRekening;
      }
    }

    return data;
  }
}
