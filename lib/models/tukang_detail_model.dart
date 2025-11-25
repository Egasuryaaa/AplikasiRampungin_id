import 'dart:developer' as developer;
import 'package:rampungin_id_userside/models/rating_model.dart';

/// Tukang Detail Model - Extended version with ratings and stats
class TukangDetailModel {
  final int? id;
  final int? userId;
  final String? namaLengkap;
  final String? email;
  final String? noTelp;
  final String? fotoProfil;
  final String? alamat;
  final String? kota;
  final String? provinsi;
  final int? pengalamanTahun;
  final double? tarifPerJam;
  final String? bio;
  final List<String>? keahlian;
  final int? radiusLayananKm;
  final double? rataRataRating;
  final int? totalRating;
  final int? totalPekerjaanSelesai;
  final String? statusKetersediaan;
  final String? namaBank;
  final String? nomorRekening;
  final String? namaPemilikRekening;
  final String? tanggalBergabung;
  final List<CategoryInfo>? kategori;
  final List<RatingModel>? ratings;
  final RatingStats? ratingStats;

  TukangDetailModel({
    this.id,
    this.userId,
    this.namaLengkap,
    this.email,
    this.noTelp,
    this.fotoProfil,
    this.alamat,
    this.kota,
    this.provinsi,
    this.pengalamanTahun,
    this.tarifPerJam,
    this.bio,
    this.keahlian,
    this.radiusLayananKm,
    this.rataRataRating,
    this.totalRating,
    this.totalPekerjaanSelesai,
    this.statusKetersediaan,
    this.namaBank,
    this.nomorRekening,
    this.namaPemilikRekening,
    this.tanggalBergabung,
    this.kategori,
    this.ratings,
    this.ratingStats,
  });

  factory TukangDetailModel.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse int from dynamic value
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      if (value is num) return value.toInt();

      developer.log(
        'WARNING: parseInt received unexpected type: ${value.runtimeType} for value: $value',
        name: 'TukangDetailModel',
      );
      return null;
    }

    // Helper function to safely parse double from dynamic value
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      if (value is num) return value.toDouble();

      developer.log(
        'WARNING: parseDouble received unexpected type: ${value.runtimeType} for value: $value',
        name: 'TukangDetailModel',
      );
      return null;
    }

    // Log incoming JSON untuk debugging
    developer.log(
      'TukangDetailModel.fromJson - All keys: ${json.keys.join(', ')}',
      name: 'TukangDetailModel',
    );

    // Extract profil_tukang data
    final profilTukang = json['profil_tukang'] as Map<String, dynamic>?;
    developer.log(
      'Profil Tukang keys: ${profilTukang?.keys.join(', ')}',
      name: 'TukangDetailModel',
    );

    // Parse keahlian array - PERBAIKAN: Handle string dengan koma
    List<String>? keahlian;
    if (profilTukang?['keahlian'] != null) {
      if (profilTukang!['keahlian'] is List) {
        keahlian =
            (profilTukang['keahlian'] as List)
                .map((e) => e.toString())
                .toList();
      } else if (profilTukang['keahlian'] is String) {
        final keahlianString = profilTukang['keahlian'] as String;
        // Split by comma and trim each item
        keahlian = keahlianString.split(',').map((e) => e.trim()).toList();
        developer.log(
          'Parsed keahlian from string: $keahlian',
          name: 'TukangDetailModel',
        );
      }
    }

    // Parse kategori array
    List<CategoryInfo>? kategori;
    if (json['kategori'] != null && json['kategori'] is List) {
      try {
        kategori =
            (json['kategori'] as List)
                .map((e) => CategoryInfo.fromJson(e as Map<String, dynamic>))
                .toList();
        developer.log(
          'Parsed ${kategori.length} kategori items',
          name: 'TukangDetailModel',
        );
      } catch (e, stackTrace) {
        developer.log(
          'Error parsing kategori: $e',
          name: 'TukangDetailModel',
          error: e,
          stackTrace: stackTrace,
        );
        kategori = null;
      }
    }

    // Parse ratings array
    List<RatingModel>? ratings;
    if (json['ratings'] != null && json['ratings'] is List) {
      try {
        ratings =
            (json['ratings'] as List)
                .map((e) => RatingModel.fromJson(e as Map<String, dynamic>))
                .toList();
        developer.log(
          'Parsed ${ratings.length} ratings items',
          name: 'TukangDetailModel',
        );
      } catch (e, stackTrace) {
        developer.log(
          'Error parsing ratings: $e',
          name: 'TukangDetailModel',
          error: e,
          stackTrace: stackTrace,
        );
        ratings = null;
      }
    }

    // Parse rating stats
    RatingStats? ratingStats;
    if (json['rating_stats'] != null) {
      try {
        ratingStats = RatingStats.fromJson(
          json['rating_stats'] as Map<String, dynamic>,
        );
        developer.log(
          'Parsed rating stats: total=${ratingStats.total}',
          name: 'TukangDetailModel',
        );
      } catch (e, stackTrace) {
        developer.log(
          'Error parsing rating_stats: $e',
          name: 'TukangDetailModel',
          error: e,
          stackTrace: stackTrace,
        );
        ratingStats = null;
      }
    }

    // Parse tarif dari profil_tukang - PERBAIKAN: Ambil dari nested object
    double? tarifPerJam;
    if (profilTukang?['tarif_per_jam'] != null) {
      tarifPerJam = parseDouble(profilTukang!['tarif_per_jam']);
      developer.log(
        'Parsed tarif_per_jam from profil_tukang: $tarifPerJam',
        name: 'TukangDetailModel',
      );
    } else if (json['tarif_per_jam'] != null) {
      tarifPerJam = parseDouble(json['tarif_per_jam']);
      developer.log(
        'Parsed tarif_per_jam from root: $tarifPerJam',
        name: 'TukangDetailModel',
      );
    }

    // Parse pengalaman tahun dari profil_tukang
    int? pengalamanTahun;
    if (profilTukang?['pengalaman_tahun'] != null) {
      pengalamanTahun = parseInt(profilTukang!['pengalaman_tahun']);
      developer.log(
        'Parsed pengalaman_tahun from profil_tukang: $pengalamanTahun',
        name: 'TukangDetailModel',
      );
    }

    // Parse total pekerjaan selesai dari profil_tukang
    int? totalPekerjaanSelesai;
    if (profilTukang?['total_pekerjaan_selesai'] != null) {
      totalPekerjaanSelesai = parseInt(
        profilTukang!['total_pekerjaan_selesai'],
      );
      developer.log(
        'Parsed total_pekerjaan_selesai from profil_tukang: $totalPekerjaanSelesai',
        name: 'TukangDetailModel',
      );
    }

    // Parse status ketersediaan dari profil_tukang - PERBAIKAN PENTING
    String? statusKetersediaan;
    if (profilTukang?['status_ketersediaan'] != null) {
      statusKetersediaan = profilTukang!['status_ketersediaan'] as String;
      developer.log(
        'Parsed status_ketersediaan from profil_tukang: $statusKetersediaan',
        name: 'TukangDetailModel',
      );
    }

    // Parse bio dari profil_tukang
    String? bio;
    if (profilTukang?['bio'] != null) {
      bio = profilTukang!['bio'] as String;
      developer.log(
        'Parsed bio from profil_tukang: $bio',
        name: 'TukangDetailModel',
      );
    }

    // Parse radius layanan dari profil_tukang
    int? radiusLayananKm;
    if (profilTukang?['radius_layanan_km'] != null) {
      radiusLayananKm = parseInt(profilTukang!['radius_layanan_km']);
      developer.log(
        'Parsed radius_layanan_km from profil_tukang: $radiusLayananKm',
        name: 'TukangDetailModel',
      );
    }

    // Parse rating stats dari profil_tukang atau root
    double? rataRataRating;
    if (profilTukang?['rata_rata_rating'] != null) {
      rataRataRating = parseDouble(profilTukang!['rata_rata_rating']);
    } else if (json['rata_rata_rating'] != null) {
      rataRataRating = parseDouble(json['rata_rata_rating']);
    }

    int? totalRating;
    if (profilTukang?['total_rating'] != null) {
      totalRating = parseInt(profilTukang!['total_rating']);
    } else if (json['total_rating'] != null) {
      totalRating = parseInt(json['total_rating']);
    }

    // Parse ID yang benar dari profil_tukang, bukan dari root
    final profilTukangId =
        profilTukang != null ? parseInt(profilTukang['id']) : null;
    final parsedTukangId = parseInt(json['tukang_id']);
    final parsedId = parseInt(json['id']);
    // userId ada di profil_tukang.user_id atau di root json['id'] (yang merupakan users.id)
    final parsedUserId =
        profilTukang != null
            ? parseInt(profilTukang['user_id'])
            : parseInt(json['id']);

    developer.log(
      'Parsing TukangDetailModel - profil_tukang.id: $profilTukangId, root id (users.id): $parsedId, profil_tukang.user_id: $parsedUserId',
      name: 'TukangDetailModel',
    );

    return TukangDetailModel(
      id: profilTukangId ?? parsedTukangId ?? parsedId,
      userId: parsedUserId, // userId untuk booking (users.id)
      namaLengkap: json['nama_lengkap'] as String?,
      email: json['email'] as String?,
      noTelp: json['no_telp'] as String?,
      fotoProfil: json['foto_profil'] as String?,
      alamat: json['alamat'] as String?,
      kota: json['kota'] as String?,
      provinsi: json['provinsi'] as String?,
      pengalamanTahun: pengalamanTahun,
      tarifPerJam: tarifPerJam,
      bio: bio,
      keahlian: keahlian,
      radiusLayananKm: radiusLayananKm,
      rataRataRating: rataRataRating,
      totalRating: totalRating,
      totalPekerjaanSelesai: totalPekerjaanSelesai,
      statusKetersediaan: statusKetersediaan,
      namaBank: profilTukang?['nama_bank'] as String?,
      nomorRekening: profilTukang?['nomor_rekening'] as String?,
      namaPemilikRekening: profilTukang?['nama_pemilik_rekening'] as String?,
      tanggalBergabung: json['tanggal_bergabung'] as String?,
      kategori: kategori,
      ratings: ratings,
      ratingStats: ratingStats,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'nama_lengkap': namaLengkap,
      'email': email,
      'no_telp': noTelp,
      'foto_profil': fotoProfil,
      'alamat': alamat,
      'kota': kota,
      'provinsi': provinsi,
      'pengalaman_tahun': pengalamanTahun,
      'tarif_per_jam': tarifPerJam,
      'bio': bio,
      'keahlian': keahlian,
      'radius_layanan_km': radiusLayananKm,
      'rata_rata_rating': rataRataRating,
      'total_rating': totalRating,
      'total_pekerjaan_selesai': totalPekerjaanSelesai,
      'status_ketersediaan': statusKetersediaan,
      'nama_bank': namaBank,
      'nomor_rekening': nomorRekening,
      'nama_pemilik_rekening': namaPemilikRekening,
      'tanggal_bergabung': tanggalBergabung,
      'kategori': kategori?.map((e) => e.toJson()).toList(),
      'ratings': ratings?.map((e) => e.toJson()).toList(),
      'rating_stats': ratingStats?.toJson(),
    };
  }
}

/// Category Info Model
class CategoryInfo {
  final int? id;
  final String? nama;

  CategoryInfo({this.id, this.nama});

  factory CategoryInfo.fromJson(Map<String, dynamic> json) {
    int? id;
    if (json['id'] != null) {
      if (json['id'] is int) {
        id = json['id'];
      } else if (json['id'] is String) {
        id = int.tryParse(json['id']);
      }
    }

    return CategoryInfo(id: id, nama: json['nama'] as String?);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'nama': nama};
  }
}

/// Rating Statistics Model
class RatingStats {
  final int? total;
  final double? rataRata;
  final int? bintang5;
  final int? bintang4;
  final int? bintang3;
  final int? bintang2;
  final int? bintang1;

  RatingStats({
    this.total,
    this.rataRata,
    this.bintang5,
    this.bintang4,
    this.bintang3,
    this.bintang2,
    this.bintang1,
  });

  factory RatingStats.fromJson(Map<String, dynamic> json) {
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

    return RatingStats(
      total: parseInt(json['total']),
      rataRata: parseDouble(json['rata_rata']),
      bintang5: parseInt(json['bintang_5']),
      bintang4: parseInt(json['bintang_4']),
      bintang3: parseInt(json['bintang_3']),
      bintang2: parseInt(json['bintang_2']),
      bintang1: parseInt(json['bintang_1']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'rata_rata': rataRata,
      'bintang_5': bintang5,
      'bintang_4': bintang4,
      'bintang_3': bintang3,
      'bintang_2': bintang2,
      'bintang_1': bintang1,
    };
  }
}
