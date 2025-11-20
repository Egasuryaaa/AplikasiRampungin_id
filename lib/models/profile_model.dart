class ProfileModel {
  final int id;
  final String username;
  final String email;
  final String namaLengkap;
  final String noTelp;
  final String alamat;
  final String kota;
  final String provinsi;
  final String kodePos;
  final String? fotoProfil;
  final int poin;
  final bool isActive;
  final bool isVerified;
  final String tanggalBergabung;
  final String updatedAt;
  final int idRole;
  final RoleModel role;

  ProfileModel({
    required this.id,
    required this.username,
    required this.email,
    required this.namaLengkap,
    required this.noTelp,
    required this.alamat,
    required this.kota,
    required this.provinsi,
    required this.kodePos,
    this.fotoProfil,
    required this.poin,
    required this.isActive,
    required this.isVerified,
    required this.tanggalBergabung,
    required this.updatedAt,
    required this.idRole,
    required this.role,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is String) return int.tryParse(v);
      if (v is double) return v.toInt();
      return null;
    }

    bool? parseBool(dynamic v) {
      if (v == null) return null;
      if (v is bool) return v;
      if (v is String) {
        final s = v.toLowerCase();
        if (s == 'true' || s == '1' || s == 't') return true;
        if (s == 'false' || s == '0' || s == 'f') return false;
      }
      if (v is num) return v != 0;
      return null;
    }

    String? parseString(dynamic v) {
      if (v == null) return null;
      return v.toString();
    }

    final roleJson = json['role'];

    return ProfileModel(
      id: parseInt(json['id']) ?? 0,
      username: parseString(json['username']) ?? '',
      email: parseString(json['email']) ?? '',
      namaLengkap: parseString(json['nama_lengkap']) ?? '',
      noTelp: parseString(json['no_telp']) ?? '',
      alamat: parseString(json['alamat']) ?? '',
      kota: parseString(json['kota']) ?? '',
      provinsi: parseString(json['provinsi']) ?? '',
      kodePos: parseString(json['kode_pos']) ?? '',
      fotoProfil: parseString(json['foto_profil']),
      poin: parseInt(json['poin']) ?? 0,
      isActive: parseBool(json['is_active']) ?? false,
      isVerified: parseBool(json['is_verified']) ?? false,
      tanggalBergabung: parseString(json['tanggal_bergabung']) ?? '',
      updatedAt: parseString(json['updated_at']) ?? '',
      idRole: parseInt(json['id_role']) ?? 0,
      role:
          roleJson != null && roleJson is Map<String, dynamic>
              ? RoleModel.fromJson(roleJson)
              : RoleModel(id: 0, name: '', description: ''),
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
      'tanggal_bergabung': tanggalBergabung,
      'updated_at': updatedAt,
      'id_role': idRole,
      'role': role.toJson(),
    };
  }

String getFullImageUrl(String baseUrl) {
  if (fotoProfil == null || fotoProfil!.isEmpty) {
    return '';
  }
  
  String imageUrl = fotoProfil!;
  
  // If already a full URL, return as is
  if (imageUrl.startsWith('http')) {
    return imageUrl;
  }
  
  // Remove leading slashes
  imageUrl = imageUrl.replaceFirst(RegExp(r'^/+'), '');
  
  // Construct full URL with provided baseUrl
  return '$baseUrl/$imageUrl';
}
}

class RoleModel {
  final int id;
  final String name;
  final String description;

  RoleModel({required this.id, required this.name, required this.description});

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'description': description};
  }
}

class UpdateProfileRequest {
  final String namaLengkap;
  final String email;
  final String noTelp;
  final String alamat;
  final String kota;
  final String provinsi;
  final String kodePos;

  UpdateProfileRequest({
    required this.namaLengkap,
    required this.email,
    required this.noTelp,
    required this.alamat,
    required this.kota,
    required this.provinsi,
    required this.kodePos,
  });

  Map<String, dynamic> toJson() {
    return {
      'nama_lengkap': namaLengkap,
      'email': email,
      'no_telp': noTelp,
      'alamat': alamat,
      'kota': kota,
      'provinsi': provinsi,
      'kode_pos': kodePos,
    };
  }
}
