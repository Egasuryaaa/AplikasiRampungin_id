
import 'dart:developer' as developer;

class TransactionModel {
  final int? id;
  final String? nomorPesanan;
  final int? idClient;
  final String? namaClient;
  final String? noHpClient;
  final int? idTukang;
  final String? namaTukang;
  final String? fotoTukang;
  final double? rataRataRating;
  final String? noHpTukang;
  final int? idKategori;
  final String? namaKategori;
  final String? judulLayanan;
  final String? deskripsiPekerjaan;
  final String? alamatPekerjaan;
  final double? latitude;
  final double? longitude;
  final String? tanggalPekerjaan;
  final String? waktuPekerjaan;
  final String?
  statusPesanan; // 'pending', 'diterima', 'dalam_proses', 'selesai', 'dibatalkan', 'ditolak'
  final String? metodePembayaran; // 'poin' or 'tunai'
  final double? hargaPenawaran;
  final double? hargaAkhir;
  final String? alasanPembatalan;
  final String? catatanClient;
  final String? catatanTukang;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TransactionModel({
    this.id,
    this.nomorPesanan,
    this.idClient,
    this.namaClient,
    this.noHpClient,
    this.idTukang,
    this.namaTukang,
    this.fotoTukang,
    this.rataRataRating,
    this.noHpTukang,
    this.idKategori,
    this.namaKategori,
    this.judulLayanan,
    this.deskripsiPekerjaan,
    this.alamatPekerjaan,
    this.latitude,
    this.longitude,
    this.tanggalPekerjaan,
    this.waktuPekerjaan,
    this.statusPesanan,
    this.metodePembayaran,
    this.hargaPenawaran,
    this.hargaAkhir,
    this.alasanPembatalan,
    this.catatanClient,
    this.catatanTukang,
    this.createdAt,
    this.updatedAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
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

    developer.log(
      'TransactionModel: Parsing transaction ID ${json['id']}',
      name: 'TransactionModel',
    );
    developer.log(
      'TransactionModel: Status = ${json['status']}',
      name: 'TransactionModel',
    );
    developer.log(
      'TransactionModel: Judul = ${json['judul_layanan']}',
      name: 'TransactionModel',
    );

    return TransactionModel(
      id: parseInt(json['id']),
      nomorPesanan: json['nomor_pesanan'] as String?,
      idClient: parseInt(json['client_id'] ?? json['id_client']),
      namaClient: json['nama_client'] as String?,
      noHpClient: json['no_hp_client'] as String?,
      idTukang: parseInt(json['tukang_id'] ?? json['id_tukang']),
      namaTukang: json['nama_tukang'] as String?,
      fotoTukang: json['foto_tukang'] as String?,
      rataRataRating: parseDouble(json['rata_rata_rating']),
      noHpTukang: json['no_hp_tukang'] as String?,
      idKategori: parseInt(json['kategori_id'] ?? json['id_kategori']),
      namaKategori: json['nama_kategori'] as String?,
      judulLayanan: json['judul_layanan'] as String?,
      deskripsiPekerjaan:
          json['deskripsi_layanan'] ?? json['deskripsi_pekerjaan'] as String?,
      alamatPekerjaan:
          json['lokasi_kerja'] ?? json['alamat_pekerjaan'] as String?,
      latitude: parseDouble(json['latitude']),
      longitude: parseDouble(json['longitude']),
      tanggalPekerjaan:
          json['tanggal_jadwal'] ?? json['tanggal_pekerjaan'] as String?,
      waktuPekerjaan:
          json['waktu_jadwal'] ?? json['waktu_pekerjaan'] as String?,
      statusPesanan: json['status'] ?? json['status_pesanan'] as String?,
      metodePembayaran: json['metode_pembayaran'] as String?,
      hargaPenawaran: parseDouble(
        json['harga_dasar'] ?? json['harga_penawaran'],
      ),
      hargaAkhir: parseDouble(json['total_biaya'] ?? json['harga_akhir']),
      alasanPembatalan: json['alasan_pembatalan'] as String?,
      catatanClient: json['catatan_client'] as String?,
      catatanTukang: json['catatan_tukang'] as String?,
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'] as String)
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.tryParse(json['updated_at'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nomor_pesanan': nomorPesanan,
      'id_client': idClient,
      'nama_client': namaClient,
      'no_hp_client': noHpClient,
      'id_tukang': idTukang,
      'nama_tukang': namaTukang,
      'foto_tukang': fotoTukang,
      'rata_rata_rating': rataRataRating,
      'no_hp_tukang': noHpTukang,
      'id_kategori': idKategori,
      'nama_kategori': namaKategori,
      'judul_layanan': judulLayanan,
      'deskripsi_pekerjaan': deskripsiPekerjaan,
      'alamat_pekerjaan': alamatPekerjaan,
      'latitude': latitude,
      'longitude': longitude,
      'tanggal_pekerjaan': tanggalPekerjaan,
      'waktu_pekerjaan': waktuPekerjaan,
      'status_pesanan': statusPesanan,
      'metode_pembayaran': metodePembayaran,
      'harga_penawaran': hargaPenawaran,
      'harga_akhir': hargaAkhir,
      'alasan_pembatalan': alasanPembatalan,
      'catatan_client': catatanClient,
      'catatan_tukang': catatanTukang,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
