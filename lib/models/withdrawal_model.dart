/// Withdrawal Model (Tukang earnings withdrawal)
class WithdrawalModel {
  final int? id;
  final int? idTukang;
  final String? namaTukang;
  final double? nominal;
  final String? nomorRekening;
  final String? namaBank;
  final String? atasNama;
  final String?
  statusPenarikan; // 'pending', 'processed', 'completed', 'rejected'
  final String? alasanPenolakan;
  final DateTime? createdAt;
  final DateTime? processedAt;

  WithdrawalModel({
    this.id,
    this.idTukang,
    this.namaTukang,
    this.nominal,
    this.nomorRekening,
    this.namaBank,
    this.atasNama,
    this.statusPenarikan,
    this.alasanPenolakan,
    this.createdAt,
    this.processedAt,
  });

  factory WithdrawalModel.fromJson(Map<String, dynamic> json) {
    return WithdrawalModel(
      id: json['id'] as int?,
      idTukang: json['id_tukang'] as int?,
      namaTukang: json['nama_tukang'] as String?,
      nominal: (json['nominal'] as num?)?.toDouble(),
      nomorRekening: json['nomor_rekening'] as String?,
      namaBank: json['nama_bank'] as String?,
      atasNama: json['atas_nama'] as String?,
      statusPenarikan: json['status_penarikan'] as String?,
      alasanPenolakan: json['alasan_penolakan'] as String?,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : null,
      processedAt:
          json['processed_at'] != null
              ? DateTime.parse(json['processed_at'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_tukang': idTukang,
      'nama_tukang': namaTukang,
      'nominal': nominal,
      'nomor_rekening': nomorRekening,
      'nama_bank': namaBank,
      'atas_nama': atasNama,
      'status_penarikan': statusPenarikan,
      'alasan_penolakan': alasanPenolakan,
      'created_at': createdAt?.toIso8601String(),
      'processed_at': processedAt?.toIso8601String(),
    };
  }
}
