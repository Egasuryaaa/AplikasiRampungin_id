/// Tukang Profile Model - Extended profile for Tukang role
class TukangProfileModel {
  final int? id;
  final String? email;
  final String? namaLengkap;
  final String? noTelp;
  final String? alamat;
  final String? kota;
  final String? provinsi;
  final String? fotoProfil;
  final double? poin;
  final bool? isActive;
  final bool? isVerified;
  final int? idRole;
  final ProfilTukang? profilTukang;
  final List<KategoriTukang>? kategori;

  TukangProfileModel({
    this.id,
    this.email,
    this.namaLengkap,
    this.noTelp,
    this.alamat,
    this.kota,
    this.provinsi,
    this.fotoProfil,
    this.poin,
    this.isActive,
    this.isVerified,
    this.idRole,
    this.profilTukang,
    this.kategori,
  });

  factory TukangProfileModel.fromJson(Map<String, dynamic> json) {
    // Safe parsing helper
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      if (value is num) return value.toInt();
      return null;
    }

    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      if (value is num) return value.toDouble();
      return null;
    }

    bool? parseBool(dynamic value) {
      if (value == null) return null;
      if (value is bool) return value;
      if (value is String) {
        return value.toLowerCase() == 't' ||
            value.toLowerCase() == 'true' ||
            value == '1';
      }
      if (value is int) return value == 1;
      return null;
    }

    // Parse kategori list
    List<KategoriTukang>? kategoriList;
    if (json['kategori'] is List) {
      kategoriList =
          (json['kategori'] as List)
              .map((e) => KategoriTukang.fromJson(e as Map<String, dynamic>))
              .toList();
    }

    return TukangProfileModel(
      id: parseInt(json['id']),
      email: json['email'] as String?,
      namaLengkap: json['nama_lengkap'] as String?,
      noTelp: json['no_telp'] as String?,
      alamat: json['alamat'] as String?,
      kota: json['kota'] as String?,
      provinsi: json['provinsi'] as String?,
      fotoProfil: json['foto_profil'] as String?,
      poin: parseDouble(json['poin']),
      isActive: parseBool(json['is_active']),
      isVerified: parseBool(json['is_verified']),
      idRole: parseInt(json['id_role']),
      profilTukang:
          json['profil_tukang'] != null
              ? ProfilTukang.fromJson(
                json['profil_tukang'] as Map<String, dynamic>,
              )
              : null,
      kategori: kategoriList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nama_lengkap': namaLengkap,
      'no_telp': noTelp,
      'alamat': alamat,
      'kota': kota,
      'provinsi': provinsi,
      'foto_profil': fotoProfil,
      'poin': poin,
      'is_active': isActive,
      'is_verified': isVerified,
      'id_role': idRole,
      'profil_tukang': profilTukang?.toJson(),
      'kategori': kategori?.map((e) => e.toJson()).toList(),
    };
  }
}

/// Profil Tukang Details
class ProfilTukang {
  final int? id;
  final int? userId;
  final int? pengalamanTahun;
  final double? tarifPerJam;
  final String? statusKetersediaan;
  final int? radiusLayananKm;
  final String? bio;
  final List<String>? keahlian;
  final double? rataRataRating;
  final int? totalRating;
  final int? totalPekerjaanSelesai;
  final String? namaBank;
  final String? nomorRekening;
  final String? namaPemilikRekening;

  ProfilTukang({
    this.id,
    this.userId,
    this.pengalamanTahun,
    this.tarifPerJam,
    this.statusKetersediaan,
    this.radiusLayananKm,
    this.bio,
    this.keahlian,
    this.rataRataRating,
    this.totalRating,
    this.totalPekerjaanSelesai,
    this.namaBank,
    this.nomorRekening,
    this.namaPemilikRekening,
  });

  factory ProfilTukang.fromJson(Map<String, dynamic> json) {
    // Safe parsing helper
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      if (value is num) return value.toInt();
      return null;
    }

    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      if (value is num) return value.toDouble();
      return null;
    }

    // Parse keahlian array
    List<String>? keahlianList;
    if (json['keahlian'] != null) {
      if (json['keahlian'] is String) {
        // Handle JSON string
        try {
          final decoded = json['keahlian'] as String;
          if (decoded.startsWith('[')) {
            keahlianList =
                decoded
                    .replaceAll('[', '')
                    .replaceAll(']', '')
                    .replaceAll('"', '')
                    .split(',')
                    .map((e) => e.trim())
                    .toList();
          }
        } catch (e) {
          keahlianList = [];
        }
      } else if (json['keahlian'] is List) {
        keahlianList =
            (json['keahlian'] as List).map((e) => e.toString()).toList();
      }
    }

    return ProfilTukang(
      id: parseInt(json['id']),
      userId: parseInt(json['user_id']),
      pengalamanTahun: parseInt(json['pengalaman_tahun']),
      tarifPerJam: parseDouble(json['tarif_per_jam']),
      statusKetersediaan: json['status_ketersediaan'] as String?,
      radiusLayananKm: parseInt(json['radius_layanan_km']),
      bio: json['bio'] as String?,
      keahlian: keahlianList,
      rataRataRating: parseDouble(json['rata_rata_rating']),
      totalRating: parseInt(json['total_rating']),
      totalPekerjaanSelesai: parseInt(json['total_pekerjaan_selesai']),
      namaBank: json['nama_bank'] as String?,
      nomorRekening: json['nomor_rekening'] as String?,
      namaPemilikRekening: json['nama_pemilik_rekening'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'pengalaman_tahun': pengalamanTahun,
      'tarif_per_jam': tarifPerJam,
      'status_ketersediaan': statusKetersediaan,
      'radius_layanan_km': radiusLayananKm,
      'bio': bio,
      'keahlian': keahlian,
      'rata_rata_rating': rataRataRating,
      'total_rating': totalRating,
      'total_pekerjaan_selesai': totalPekerjaanSelesai,
      'nama_bank': namaBank,
      'nomor_rekening': nomorRekening,
      'nama_pemilik_rekening': namaPemilikRekening,
    };
  }
}

/// Kategori Tukang
class KategoriTukang {
  final int? id;
  final String? nama;
  final String? deskripsi;

  KategoriTukang({this.id, this.nama, this.deskripsi});

  factory KategoriTukang.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    return KategoriTukang(
      id: parseInt(json['id']),
      nama: json['nama'] as String?,
      deskripsi: json['deskripsi'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'nama': nama, 'deskripsi': deskripsi};
  }
}
