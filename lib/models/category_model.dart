/// Category Model for Tukang Categories
class CategoryModel {
  final int? id;
  final String? nama;
  final String? deskripsi;
  final String? icon;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CategoryModel({
    this.id,
    this.nama,
    this.deskripsi,
    this.icon,
    this.createdAt,
    this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      nama: json['nama'] as String?,
      deskripsi: json['deskripsi'] as String?,
      icon: json['icon'] as String?,
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
      'nama': nama,
      'deskripsi': deskripsi,
      'icon': icon,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
