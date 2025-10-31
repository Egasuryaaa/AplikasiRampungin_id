/// User Model (Client & Tukang)
class UserModel {
  final int? id;
  final String? nama;
  final String? email;
  final String? noHp;
  final String? alamat;
  final String? jenisAkun; // 'client' or 'tukang'
  final String? fotoProfile;
  final String? ktpPhoto;
  final int? idKategori;
  final String? namaKategori;
  final String? statusVerifikasi; // 'pending', 'verified', 'rejected'
  final String? statusAktif; // 'online', 'offline', 'busy'
  final double? rating;
  final int? jumlahPesanan;
  final double? saldo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    this.id,
    this.nama,
    this.email,
    this.noHp,
    this.alamat,
    this.jenisAkun,
    this.fotoProfile,
    this.ktpPhoto,
    this.idKategori,
    this.namaKategori,
    this.statusVerifikasi,
    this.statusAktif,
    this.rating,
    this.jumlahPesanan,
    this.saldo,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Parse id (could be String or int from backend)
    int? parsedId;
    if (json['id'] != null) {
      if (json['id'] is int) {
        parsedId = json['id'] as int;
      } else if (json['id'] is String) {
        parsedId = int.tryParse(json['id'] as String);
      }
    }

    // Map id_role to jenisAkun (role name from backend)
    String? jenisAkun;
    if (json['id_role'] != null) {
      final roleId = json['id_role'].toString();
      if (roleId == '2') {
        jenisAkun = 'client';
      } else if (roleId == '3') {
        jenisAkun = 'tukang';
      }
    }

    // Map is_verified to statusVerifikasi
    String? statusVerifikasi;
    if (json['is_verified'] != null) {
      final isVerified = json['is_verified'].toString().toLowerCase();
      statusVerifikasi =
          (isVerified == 't' || isVerified == 'true' || isVerified == '1')
              ? 'verified'
              : 'pending';
    }

    // Map is_active to statusAktif
    String? statusAktif;
    if (json['is_active'] != null) {
      final isActive = json['is_active'].toString().toLowerCase();
      statusAktif =
          (isActive == 't' || isActive == 'true' || isActive == '1')
              ? 'online'
              : 'offline';
    }

    // Parse id_kategori (could be String or int)
    int? parsedIdKategori;
    if (json['id_kategori'] != null) {
      if (json['id_kategori'] is int) {
        parsedIdKategori = json['id_kategori'] as int;
      } else if (json['id_kategori'] is String) {
        parsedIdKategori = int.tryParse(json['id_kategori'] as String);
      }
    }

    // Parse saldo/poin (could be String or num)
    double? parsedSaldo;
    if (json['poin'] != null) {
      if (json['poin'] is num) {
        parsedSaldo = (json['poin'] as num).toDouble();
      } else if (json['poin'] is String) {
        parsedSaldo = double.tryParse(json['poin'] as String);
      }
    } else if (json['saldo'] != null) {
      if (json['saldo'] is num) {
        parsedSaldo = (json['saldo'] as num).toDouble();
      } else if (json['saldo'] is String) {
        parsedSaldo = double.tryParse(json['saldo'] as String);
      }
    }

    return UserModel(
      id: parsedId,
      nama: json['nama_lengkap'] as String? ?? json['nama'] as String?,
      email: json['email'] as String?,
      noHp: json['no_telp'] as String? ?? json['no_hp'] as String?,
      alamat: json['alamat'] as String?,
      jenisAkun: jenisAkun ?? json['jenis_akun'] as String?,
      fotoProfile:
          json['foto_profil'] as String? ?? json['foto_profile'] as String?,
      ktpPhoto: json['ktp_photo'] as String?,
      idKategori: parsedIdKategori,
      namaKategori: json['nama_kategori'] as String?,
      statusVerifikasi:
          statusVerifikasi ?? json['status_verifikasi'] as String?,
      statusAktif: statusAktif ?? json['status_aktif'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      jumlahPesanan: json['jumlah_pesanan'] as int?,
      saldo: parsedSaldo,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'email': email,
      'no_hp': noHp,
      'alamat': alamat,
      'jenis_akun': jenisAkun,
      'foto_profile': fotoProfile,
      'ktp_photo': ktpPhoto,
      'id_kategori': idKategori,
      'nama_kategori': namaKategori,
      'status_verifikasi': statusVerifikasi,
      'status_aktif': statusAktif,
      'rating': rating,
      'jumlah_pesanan': jumlahPesanan,
      'saldo': saldo,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    int? id,
    String? nama,
    String? email,
    String? noHp,
    String? alamat,
    String? jenisAkun,
    String? fotoProfile,
    String? ktpPhoto,
    int? idKategori,
    String? namaKategori,
    String? statusVerifikasi,
    String? statusAktif,
    double? rating,
    int? jumlahPesanan,
    double? saldo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      noHp: noHp ?? this.noHp,
      alamat: alamat ?? this.alamat,
      jenisAkun: jenisAkun ?? this.jenisAkun,
      fotoProfile: fotoProfile ?? this.fotoProfile,
      ktpPhoto: ktpPhoto ?? this.ktpPhoto,
      idKategori: idKategori ?? this.idKategori,
      namaKategori: namaKategori ?? this.namaKategori,
      statusVerifikasi: statusVerifikasi ?? this.statusVerifikasi,
      statusAktif: statusAktif ?? this.statusAktif,
      rating: rating ?? this.rating,
      jumlahPesanan: jumlahPesanan ?? this.jumlahPesanan,
      saldo: saldo ?? this.saldo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Auth Response Model
class AuthResponse {
  final String? message;
  final String? token;
  final UserModel? user;

  AuthResponse({this.message, this.token, this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // Handle different response structures
    // Backend sends: {status, message, data: {token, user, role}}
    // We need to extract from 'data' object

    final data = json['data'] as Map<String, dynamic>?;

    return AuthResponse(
      message: json['message'] as String?,
      token: data?['token'] as String?,
      user:
          data?['user'] != null
              ? UserModel.fromJson(data!['user'] as Map<String, dynamic>)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'message': message, 'token': token, 'user': user?.toJson()};
  }
}
