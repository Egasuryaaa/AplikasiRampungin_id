/// Withdrawal Model (Tukang earnings withdrawal)
class WithdrawalModel {
  final int? id;
  final int? tukangId;
  final String? namaTukang;
  final double? jumlah;
  final double? biayaAdmin;
  final double? jumlahBersih;
  final String? nomorRekening;
  final String? namaBank;
  final String? namaPemilikRekening;
  final String? status; // 'pending', 'diproses', 'selesai', 'ditolak'
  final String? alasanPenolakan;
  final int? diprosesOleh;
  final String? namaAdmin;
  final String? buktiTransfer;
  final DateTime? waktuDiproses;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  WithdrawalModel({
    this.id,
    this.tukangId,
    this.namaTukang,
    this.jumlah,
    this.biayaAdmin,
    this.jumlahBersih,
    this.nomorRekening,
    this.namaBank,
    this.namaPemilikRekening,
    this.status,
    this.alasanPenolakan,
    this.diprosesOleh,
    this.namaAdmin,
    this.buktiTransfer,
    this.waktuDiproses,
    this.createdAt,
    this.updatedAt,
  });

  factory WithdrawalModel.fromJson(Map<String, dynamic> json) {
    return WithdrawalModel(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      tukangId:
          json['tukang_id'] != null
              ? int.tryParse(json['tukang_id'].toString())
              : null,
      namaTukang: json['nama_tukang'] as String?,
      jumlah:
          json['jumlah'] != null
              ? double.tryParse(json['jumlah'].toString())
              : null,
      biayaAdmin:
          json['biaya_admin'] != null
              ? double.tryParse(json['biaya_admin'].toString())
              : null,
      jumlahBersih:
          json['jumlah_bersih'] != null
              ? double.tryParse(json['jumlah_bersih'].toString())
              : null,
      nomorRekening: json['nomor_rekening'] as String?,
      namaBank: json['nama_bank'] as String?,
      namaPemilikRekening: json['nama_pemilik_rekening'] as String?,
      status: json['status'] as String?,
      alasanPenolakan: json['alasan_penolakan'] as String?,
      diprosesOleh:
          json['diproses_oleh'] != null
              ? int.tryParse(json['diproses_oleh'].toString())
              : null,
      namaAdmin: json['nama_admin'] as String?,
      buktiTransfer: json['bukti_transfer'] as String?,
      waktuDiproses:
          json['waktu_diproses'] != null
              ? DateTime.tryParse(json['waktu_diproses'] as String)
              : null,
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
      'tukang_id': tukangId,
      'nama_tukang': namaTukang,
      'jumlah': jumlah,
      'biaya_admin': biayaAdmin,
      'jumlah_bersih': jumlahBersih,
      'nomor_rekening': nomorRekening,
      'nama_bank': namaBank,
      'nama_pemilik_rekening': namaPemilikRekening,
      'status': status,
      'alasan_penolakan': alasanPenolakan,
      'diproses_oleh': diprosesOleh,
      'nama_admin': namaAdmin,
      'bukti_transfer': buktiTransfer,
      'waktu_diproses': waktuDiproses?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
