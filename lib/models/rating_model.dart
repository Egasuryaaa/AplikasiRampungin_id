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
    return RatingModel(
      id: json['id'] as int?,
      idTransaksi: json['id_transaksi'] as int?,
      idClient: json['id_client'] as int?,
      namaClient: json['nama_client'] as String?,
      idTukang: json['id_tukang'] as int?,
      namaTukang: json['nama_tukang'] as String?,
      rating: json['rating'] as int?,
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
