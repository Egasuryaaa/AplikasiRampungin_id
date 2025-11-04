/// TopUp Model
class TopUpModel {
  final String? id;
  final String? userId;
  final double? jumlah;
  final String? metodePembayaran; // 'qris'
  final String? buktiPembayaran;
  final String? status; // 'pending', 'berhasil', 'ditolak', 'kadaluarsa'
  final String? diverifikasiOleh;
  final String? waktuVerifikasi;
  final String? alasanPenolakan;
  final String? kadaluarsaPada;
  final String? createdAt;
  final String? updatedAt;

  TopUpModel({
    this.id,
    this.userId,
    this.jumlah,
    this.metodePembayaran,
    this.buktiPembayaran,
    this.status,
    this.diverifikasiOleh,
    this.waktuVerifikasi,
    this.alasanPenolakan,
    this.kadaluarsaPada,
    this.createdAt,
    this.updatedAt,
  });

  factory TopUpModel.fromJson(Map<String, dynamic> json) {
    return TopUpModel(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString(),
      jumlah:
          json['jumlah'] != null
              ? double.tryParse(json['jumlah'].toString())
              : null,
      metodePembayaran: json['metode_pembayaran'] as String?,
      buktiPembayaran: json['bukti_pembayaran'] as String?,
      status: json['status'] as String?,
      diverifikasiOleh: json['diverifikasi_oleh']?.toString(),
      waktuVerifikasi: json['waktu_verifikasi'] as String?,
      alasanPenolakan: json['alasan_penolakan'] as String?,
      kadaluarsaPada: json['kadaluarsa_pada'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'jumlah': jumlah,
      'metode_pembayaran': metodePembayaran,
      'bukti_pembayaran': buktiPembayaran,
      'status': status,
      'diverifikasi_oleh': diverifikasiOleh,
      'waktu_verifikasi': waktuVerifikasi,
      'alasan_penolakan': alasanPenolakan,
      'kadaluarsa_pada': kadaluarsaPada,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
