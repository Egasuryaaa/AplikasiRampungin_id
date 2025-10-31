/// TopUp Model
class TopUpModel {
  final int? id;
  final int? idClient;
  final String? namaClient;
  final double? nominal;
  final String? metodePembayaran; // 'QRIS'
  final String? statusTopup; // 'pending', 'success', 'failed'
  final String? qrisUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TopUpModel({
    this.id,
    this.idClient,
    this.namaClient,
    this.nominal,
    this.metodePembayaran,
    this.statusTopup,
    this.qrisUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory TopUpModel.fromJson(Map<String, dynamic> json) {
    return TopUpModel(
      id: json['id'] as int?,
      idClient: json['id_client'] as int?,
      namaClient: json['nama_client'] as String?,
      nominal: (json['nominal'] as num?)?.toDouble(),
      metodePembayaran: json['metode_pembayaran'] as String?,
      statusTopup: json['status_topup'] as String?,
      qrisUrl: json['qris_url'] as String?,
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
      'nominal': nominal,
      'metode_pembayaran': metodePembayaran,
      'status_topup': statusTopup,
      'qris_url': qrisUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
