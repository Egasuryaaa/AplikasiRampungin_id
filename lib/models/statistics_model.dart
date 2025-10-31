/// Statistics Model (Tukang statistics)
class StatisticsModel {
  final int? totalPesanan;
  final int? pesananSelesai;
  final int? pesananDitolak;
  final double? totalPendapatan;
  final double? rataRataRating;
  final int? totalUlasan;
  final Map<String, int>? pesananPerBulan;
  final Map<String, double>? pendapatanPerBulan;

  StatisticsModel({
    this.totalPesanan,
    this.pesananSelesai,
    this.pesananDitolak,
    this.totalPendapatan,
    this.rataRataRating,
    this.totalUlasan,
    this.pesananPerBulan,
    this.pendapatanPerBulan,
  });

  factory StatisticsModel.fromJson(Map<String, dynamic> json) {
    return StatisticsModel(
      totalPesanan: json['total_pesanan'] as int?,
      pesananSelesai: json['pesanan_selesai'] as int?,
      pesananDitolak: json['pesanan_ditolak'] as int?,
      totalPendapatan: (json['total_pendapatan'] as num?)?.toDouble(),
      rataRataRating: (json['rata_rata_rating'] as num?)?.toDouble(),
      totalUlasan: json['total_ulasan'] as int?,
      pesananPerBulan:
          json['pesanan_per_bulan'] != null
              ? Map<String, int>.from(json['pesanan_per_bulan'] as Map)
              : null,
      pendapatanPerBulan:
          json['pendapatan_per_bulan'] != null
              ? (json['pendapatan_per_bulan'] as Map).map(
                (key, value) =>
                    MapEntry(key.toString(), (value as num).toDouble()),
              )
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_pesanan': totalPesanan,
      'pesanan_selesai': pesananSelesai,
      'pesanan_ditolak': pesananDitolak,
      'total_pendapatan': totalPendapatan,
      'rata_rata_rating': rataRataRating,
      'total_ulasan': totalUlasan,
      'pesanan_per_bulan': pesananPerBulan,
      'pendapatan_per_bulan': pendapatanPerBulan,
    };
  }
}
