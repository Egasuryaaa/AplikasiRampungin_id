/// Rating Model
class RatingModel {
  final int? id;
  final int? idTransaksi;
  final int? idClient;
  final String? namaClient;
  final int? idTukang;
  final String? namaTukang;
  final int? rating; // 1-5
  final String? ulasan;
  final DateTime? createdAt;

  RatingModel({
    this.id,
    this.idTransaksi,
    this.idClient,
    this.namaClient,
    this.idTukang,
    this.namaTukang,
    this.rating,
    this.ulasan,
    this.createdAt,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse int from dynamic value
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      if (value is num) return value.toInt();
      return null;
    }

    return RatingModel(
      id: parseInt(json['id']),
      idTransaksi: parseInt(json['transaksi_id'] ?? json['id_transaksi']),
      idClient: parseInt(json['client_id'] ?? json['id_client']),
      namaClient: json['nama_client'] as String?,
      idTukang: parseInt(json['tukang_id'] ?? json['id_tukang']),
      namaTukang: json['nama_tukang'] as String?,
      rating: parseInt(json['rating']),
      ulasan: json['ulasan'] as String?,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_transaksi': idTransaksi,
      'id_client': idClient,
      'nama_client': namaClient,
      'id_tukang': idTukang,
      'nama_tukang': namaTukang,
      'rating': rating,
      'ulasan': ulasan,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
