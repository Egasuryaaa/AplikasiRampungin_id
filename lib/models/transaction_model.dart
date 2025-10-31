/// Transaction/Order Model
class TransactionModel {
  final int? id;
  final int? idClient;
  final String? namaClient;
  final String? noHpClient;
  final int? idTukang;
  final String? namaTukang;
  final String? noHpTukang;
  final int? idKategori;
  final String? namaKategori;
  final String? deskripsiPekerjaan;
  final String? alamatPekerjaan;
  final double? latitude;
  final double? longitude;
  final String? tanggalPekerjaan;
  final String? waktuPekerjaan;
  final String?
  statusPesanan; // 'pending', 'accepted', 'in_progress', 'completed', 'cancelled'
  final String? metodePembayaran; // 'POIN' or 'TUNAI'
  final double? hargaPenawaran;
  final double? hargaAkhir;
  final String? alasanPembatalan;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TransactionModel({
    this.id,
    this.idClient,
    this.namaClient,
    this.noHpClient,
    this.idTukang,
    this.namaTukang,
    this.noHpTukang,
    this.idKategori,
    this.namaKategori,
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
    this.createdAt,
    this.updatedAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as int?,
      idClient: json['id_client'] as int?,
      namaClient: json['nama_client'] as String?,
      noHpClient: json['no_hp_client'] as String?,
      idTukang: json['id_tukang'] as int?,
      namaTukang: json['nama_tukang'] as String?,
      noHpTukang: json['no_hp_tukang'] as String?,
      idKategori: json['id_kategori'] as int?,
      namaKategori: json['nama_kategori'] as String?,
      deskripsiPekerjaan: json['deskripsi_pekerjaan'] as String?,
      alamatPekerjaan: json['alamat_pekerjaan'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      tanggalPekerjaan: json['tanggal_pekerjaan'] as String?,
      waktuPekerjaan: json['waktu_pekerjaan'] as String?,
      statusPesanan: json['status_pesanan'] as String?,
      metodePembayaran: json['metode_pembayaran'] as String?,
      hargaPenawaran: (json['harga_penawaran'] as num?)?.toDouble(),
      hargaAkhir: (json['harga_akhir'] as num?)?.toDouble(),
      alasanPembatalan: json['alasan_pembatalan'] as String?,
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
      'id_client': idClient,
      'nama_client': namaClient,
      'no_hp_client': noHpClient,
      'id_tukang': idTukang,
      'nama_tukang': namaTukang,
      'no_hp_tukang': noHpTukang,
      'id_kategori': idKategori,
      'nama_kategori': namaKategori,
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
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
