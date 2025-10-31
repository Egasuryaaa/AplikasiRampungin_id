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
    return UserModel(
      id: json['id'] as int?,
      nama: json['nama'] as String?,
      email: json['email'] as String?,
      noHp: json['no_hp'] as String?,
      alamat: json['alamat'] as String?,
      jenisAkun: json['jenis_akun'] as String?,
      fotoProfile: json['foto_profile'] as String?,
      ktpPhoto: json['ktp_photo'] as String?,
      idKategori: json['id_kategori'] as int?,
      namaKategori: json['nama_kategori'] as String?,
      statusVerifikasi: json['status_verifikasi'] as String?,
      statusAktif: json['status_aktif'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      jumlahPesanan: json['jumlah_pesanan'] as int?,
      saldo: (json['saldo'] as num?)?.toDouble(),
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
    return AuthResponse(
      message: json['message'] as String?,
      token: json['token'] as String?,
      user:
          json['user'] != null
              ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'message': message, 'token': token, 'user': user?.toJson()};
  }
}
