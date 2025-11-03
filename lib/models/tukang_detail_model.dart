import 'dart:convert';
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
      return null;
    }

    // Helper function to safely parse double from dynamic value
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      if (value is num) return value.toDouble();
      return null;
    }

    // Parse keahlian array
    List<String>? keahlian;
    if (json['keahlian'] != null) {
      if (json['keahlian'] is List) {
        keahlian = (json['keahlian'] as List).map((e) => e.toString()).toList();
      } else if (json['keahlian'] is String) {
        // Backend mengirim keahlian sebagai JSON string
        try {
          // Parse JSON string menjadi List
          final decoded = jsonDecode(json['keahlian'] as String);
          if (decoded is List) {
            keahlian = decoded.map((e) => e.toString()).toList();
          }
        } catch (e) {
          print('Error parsing keahlian JSON string: $e');
          keahlian = null;
        }
      }
    }

    // Parse kategori array
    List<CategoryInfo>? kategori;
    if (json['kategori'] != null && json['kategori'] is List) {
      kategori =
          (json['kategori'] as List)
              .map((e) => CategoryInfo.fromJson(e as Map<String, dynamic>))
              .toList();
    }

    // Parse ratings array
    List<RatingModel>? ratings;
    if (json['ratings'] != null && json['ratings'] is List) {
      ratings =
          (json['ratings'] as List)
              .map((e) => RatingModel.fromJson(e as Map<String, dynamic>))
              .toList();
    }

    // Parse rating stats
    RatingStats? ratingStats;
    if (json['rating_stats'] != null) {
      ratingStats = RatingStats.fromJson(
        json['rating_stats'] as Map<String, dynamic>,
      );
    }

    return TukangDetailModel(
      id: parseInt(json['id']),
      userId: parseInt(json['user_id']),
      namaLengkap: json['nama_lengkap'] as String?,
      email: json['email'] as String?,
      noTelp: json['no_telp'] as String?,
      fotoProfil: json['foto_profil'] as String?,
      alamat: json['alamat'] as String?,
      kota: json['kota'] as String?,
      provinsi: json['provinsi'] as String?,
      pengalamanTahun: parseInt(json['pengalaman_tahun']),
      tarifPerJam: parseDouble(json['tarif_per_jam']),
      bio: json['bio'] as String?,
      keahlian: keahlian,
      radiusLayananKm: parseInt(json['radius_layanan_km']),
      rataRataRating: parseDouble(json['rata_rata_rating']),
      totalRating: parseInt(json['total_rating']),
      totalPekerjaanSelesai: parseInt(json['total_pekerjaan_selesai']),
      statusKetersediaan: json['status_ketersediaan'] as String?,
      namaBank: json['nama_bank'] as String?,
      nomorRekening: json['nomor_rekening'] as String?,
      namaPemilikRekening: json['nama_pemilik_rekening'] as String?,
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
    // Safe parsing for id
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
