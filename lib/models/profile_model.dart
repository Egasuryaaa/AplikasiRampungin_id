/// Profile Model
class ProfileModel {
  final int? id;
  final String? username;
  final String? email;
  final String? namaLengkap;
  final String? noTelp;
  final String? alamat;
  final String? kota;
  final String? provinsi;
  final String? kodePos;
  final String? fotoProfil;
  final int? poin;
  final bool? isActive;
  final bool? isVerified;
  final DateTime? tanggalBergabung;
  final DateTime? updatedAt;
  final int? idRole;
  final RoleModel? role;

  ProfileModel({
    this.id,
    this.username,
    this.email,
    this.namaLengkap,
    this.noTelp,
    this.alamat,
    this.kota,
    this.provinsi,
    this.kodePos,
    this.fotoProfil,
    this.poin,
    this.isActive,
    this.isVerified,
    this.tanggalBergabung,
    this.updatedAt,
    this.idRole,
    this.role,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    int? parseIntValue(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    bool? parseBoolValue(dynamic value) {
      if (value == null) return null;
      if (value is bool) return value;
      if (value is String) {
        if (value.toLowerCase() == 'true' || value == '1' || value == 't')
          return true;
        if (value.toLowerCase() == 'false' || value == '0' || value == 'f')
          return false;
      }
      if (value is num) return value != 0;
      return null;
    }

    return ProfileModel(
      id: parseIntValue(json['id']),
      username: json['username'] as String?,
      email: json['email'] as String?,
      namaLengkap: json['nama_lengkap'] as String?,
      noTelp: json['no_telp'] as String?,
      alamat: json['alamat'] as String?,
      kota: json['kota'] as String?,
      provinsi: json['provinsi'] as String?,
      kodePos: json['kode_pos'] as String?,
      fotoProfil: json['foto_profil'] as String?,
      poin: parseIntValue(json['poin']),
      isActive: parseBoolValue(json['is_active']),
      isVerified: parseBoolValue(json['is_verified']),
      tanggalBergabung:
          json['tanggal_bergabung'] != null
              ? DateTime.parse(json['tanggal_bergabung'] as String)
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : null,
      idRole: parseIntValue(json['id_role']),
      role:
          json['role'] != null
              ? RoleModel.fromJson(json['role'] as Map<String, dynamic>)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'nama_lengkap': namaLengkap,
      'no_telp': noTelp,
      'alamat': alamat,
      'kota': kota,
      'provinsi': provinsi,
      'kode_pos': kodePos,
      'foto_profil': fotoProfil,
      'poin': poin,
      'is_active': isActive,
      'is_verified': isVerified,
      'tanggal_bergabung': tanggalBergabung?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'id_role': idRole,
      'role': role?.toJson(),
    };
  }

  // Helper method untuk get foto profil URL lengkap
  String? get fotoProfilUrl {
    if (fotoProfil == null || fotoProfil!.isEmpty) return null;
    return 'http://localhost/admintukang/$fotoProfil';
  }

  // CopyWith method untuk update data
  ProfileModel copyWith({
    int? id,
    String? username,
    String? email,
    String? namaLengkap,
    String? noTelp,
    String? alamat,
    String? kota,
    String? provinsi,
    String? kodePos,
    String? fotoProfil,
    int? poin,
    bool? isActive,
    bool? isVerified,
    DateTime? tanggalBergabung,
    DateTime? updatedAt,
    int? idRole,
    RoleModel? role,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      namaLengkap: namaLengkap ?? this.namaLengkap,
      noTelp: noTelp ?? this.noTelp,
      alamat: alamat ?? this.alamat,
      kota: kota ?? this.kota,
      provinsi: provinsi ?? this.provinsi,
      kodePos: kodePos ?? this.kodePos,
      fotoProfil: fotoProfil ?? this.fotoProfil,
      poin: poin ?? this.poin,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      tanggalBergabung: tanggalBergabung ?? this.tanggalBergabung,
      updatedAt: updatedAt ?? this.updatedAt,
      idRole: idRole ?? this.idRole,
      role: role ?? this.role,
    );
  }
}

/// Role Model
class RoleModel {
  final int? id;
  final String? name;
  final String? description;

  RoleModel({this.id, this.name, this.description});

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'] as int?,
      name: json['name'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'description': description};
  }
}
