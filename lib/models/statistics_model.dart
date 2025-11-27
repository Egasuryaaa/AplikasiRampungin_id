/// Statistics Model - For both Client and Tukang statistics
class StatisticsModel {
  // Common fields
  final double? saldoPoin;
  final int? totalPekerjaanSelesai;
  final double? rataRataRating;
  final int? totalRating;

  // Transaction statistics
  final TransactionStats? transaksi;

  // Client-specific: Top-up statistics
  final TopupStats? topup;
  final int? ratingDiberikan;

  // Tukang-specific: Withdrawal statistics
  final WithdrawalStats? penarikan;
  final RatingBreakdown? ratingBreakdown;
  final double? pendapatanBulanIni;
  final int? pekerjaanBulanIni;

  StatisticsModel({
    this.saldoPoin,
    this.totalPekerjaanSelesai,
    this.rataRataRating,
    this.totalRating,
    this.transaksi,
    this.topup,
    this.ratingDiberikan,
    this.penarikan,
    this.ratingBreakdown,
    this.pendapatanBulanIni,
    this.pekerjaanBulanIni,
  });

  factory StatisticsModel.fromJson(Map<String, dynamic> json) {
    return StatisticsModel(
      saldoPoin:
          json['saldo_poin'] != null
              ? double.tryParse(json['saldo_poin'].toString())
              : null,
      totalPekerjaanSelesai:
          json['total_pekerjaan_selesai'] != null
              ? int.tryParse(json['total_pekerjaan_selesai'].toString())
              : null,
      rataRataRating:
          json['rata_rata_rating'] != null
              ? double.tryParse(json['rata_rata_rating'].toString())
              : null,
      totalRating:
          json['total_rating'] != null
              ? int.tryParse(json['total_rating'].toString())
              : null,
      transaksi:
          json['transaksi'] != null
              ? TransactionStats.fromJson(
                json['transaksi'] as Map<String, dynamic>,
              )
              : null,
      topup:
          json['topup'] != null
              ? TopupStats.fromJson(json['topup'] as Map<String, dynamic>)
              : null,
      ratingDiberikan:
          json['rating_diberikan'] != null
              ? int.tryParse(json['rating_diberikan'].toString())
              : null,
      penarikan:
          json['penarikan'] != null
              ? WithdrawalStats.fromJson(
                json['penarikan'] as Map<String, dynamic>,
              )
              : null,
      ratingBreakdown:
          json['rating_breakdown'] != null
              ? RatingBreakdown.fromJson(
                json['rating_breakdown'] as Map<String, dynamic>,
              )
              : null,
      pendapatanBulanIni:
          json['pendapatan_bulan_ini'] != null
              ? double.tryParse(json['pendapatan_bulan_ini'].toString())
              : null,
      pekerjaanBulanIni:
          json['pekerjaan_bulan_ini'] != null
              ? int.tryParse(json['pekerjaan_bulan_ini'].toString())
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'saldo_poin': saldoPoin,
      'total_pekerjaan_selesai': totalPekerjaanSelesai,
      'rata_rata_rating': rataRataRating,
      'total_rating': totalRating,
      'transaksi': transaksi?.toJson(),
      'topup': topup?.toJson(),
      'rating_diberikan': ratingDiberikan,
      'penarikan': penarikan?.toJson(),
      'rating_breakdown': ratingBreakdown?.toJson(),
      'pendapatan_bulan_ini': pendapatanBulanIni,
      'pekerjaan_bulan_ini': pekerjaanBulanIni,
    };
  }
}

/// Transaction Statistics
class TransactionStats {
  final int? total;
  final int? pending;
  final int? diterima;
  final int? dalamProses;
  final int? selesai;
  final int? dibatalkan;
  final int? ditolak;
  final double? totalPendapatan;
  final double? totalPengeluaran;

  TransactionStats({
    this.total,
    this.pending,
    this.diterima,
    this.dalamProses,
    this.selesai,
    this.dibatalkan,
    this.ditolak,
    this.totalPendapatan,
    this.totalPengeluaran,
  });

  factory TransactionStats.fromJson(Map<String, dynamic> json) {
    return TransactionStats(
      total:
          json['total'] != null ? int.tryParse(json['total'].toString()) : null,
      pending:
          json['pending'] != null
              ? int.tryParse(json['pending'].toString())
              : null,
      diterima:
          json['diterima'] != null
              ? int.tryParse(json['diterima'].toString())
              : null,
      dalamProses:
          json['dalam_proses'] != null
              ? int.tryParse(json['dalam_proses'].toString())
              : null,
      selesai:
          json['selesai'] != null
              ? int.tryParse(json['selesai'].toString())
              : null,
      dibatalkan:
          json['dibatalkan'] != null
              ? int.tryParse(json['dibatalkan'].toString())
              : null,
      ditolak:
          json['ditolak'] != null
              ? int.tryParse(json['ditolak'].toString())
              : null,
      totalPendapatan:
          json['total_pendapatan'] != null
              ? double.tryParse(json['total_pendapatan'].toString())
              : null,
      totalPengeluaran:
          json['total_pengeluaran'] != null
              ? double.tryParse(json['total_pengeluaran'].toString())
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'pending': pending,
      'diterima': diterima,
      'dalam_proses': dalamProses,
      'selesai': selesai,
      'dibatalkan': dibatalkan,
      'ditolak': ditolak,
      'total_pendapatan': totalPendapatan,
      'total_pengeluaran': totalPengeluaran,
    };
  }
}

/// Top-up Statistics (Client only)
class TopupStats {
  final int? total;
  final int? pending;
  final int? berhasil;
  final int? ditolak;
  final int? kadaluarsa;
  final double? totalTopupBerhasil;

  TopupStats({
    this.total,
    this.pending,
    this.berhasil,
    this.ditolak,
    this.kadaluarsa,
    this.totalTopupBerhasil,
  });

  factory TopupStats.fromJson(Map<String, dynamic> json) {
    return TopupStats(
      total:
          json['total'] != null ? int.tryParse(json['total'].toString()) : null,
      pending:
          json['pending'] != null
              ? int.tryParse(json['pending'].toString())
              : null,
      berhasil:
          json['berhasil'] != null
              ? int.tryParse(json['berhasil'].toString())
              : null,
      ditolak:
          json['ditolak'] != null
              ? int.tryParse(json['ditolak'].toString())
              : null,
      kadaluarsa:
          json['kadaluarsa'] != null
              ? int.tryParse(json['kadaluarsa'].toString())
              : null,
      totalTopupBerhasil:
          json['total_topup_berhasil'] != null
              ? double.tryParse(json['total_topup_berhasil'].toString())
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'pending': pending,
      'berhasil': berhasil,
      'ditolak': ditolak,
      'kadaluarsa': kadaluarsa,
      'total_topup_berhasil': totalTopupBerhasil,
    };
  }
}

/// Withdrawal Statistics (Tukang only)
class WithdrawalStats {
  final int? total;
  final int? pending;
  final int? diproses;
  final int? selesai;
  final int? ditolak;
  final double? totalPenarikan;
  final double? totalBiayaAdmin;

  WithdrawalStats({
    this.total,
    this.pending,
    this.diproses,
    this.selesai,
    this.ditolak,
    this.totalPenarikan,
    this.totalBiayaAdmin,
  });

  factory WithdrawalStats.fromJson(Map<String, dynamic> json) {
    return WithdrawalStats(
      total:
          json['total'] != null ? int.tryParse(json['total'].toString()) : null,
      pending:
          json['pending'] != null
              ? int.tryParse(json['pending'].toString())
              : null,
      diproses:
          json['diproses'] != null
              ? int.tryParse(json['diproses'].toString())
              : null,
      selesai:
          json['selesai'] != null
              ? int.tryParse(json['selesai'].toString())
              : null,
      ditolak:
          json['ditolak'] != null
              ? int.tryParse(json['ditolak'].toString())
              : null,
      // FIX: Handle both 'total_penarikan' and 'total_ditarik' from API
      totalPenarikan:
          json['total_penarikan'] != null
              ? double.tryParse(json['total_penarikan'].toString())
              : json['total_ditarik'] != null
                  ? double.tryParse(json['total_ditarik'].toString())
                  : null,
      totalBiayaAdmin:
          json['total_biaya_admin'] != null
              ? double.tryParse(json['total_biaya_admin'].toString())
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'pending': pending,
      'diproses': diproses,
      'selesai': selesai,
      'ditolak': ditolak,
      'total_penarikan': totalPenarikan,
      'total_biaya_admin': totalBiayaAdmin,
    };
  }
}

/// Rating Breakdown (Tukang only)
class RatingBreakdown {
  final int? bintang5;
  final int? bintang4;
  final int? bintang3;
  final int? bintang2;
  final int? bintang1;

  RatingBreakdown({
    this.bintang5,
    this.bintang4,
    this.bintang3,
    this.bintang2,
    this.bintang1,
  });

  factory RatingBreakdown.fromJson(Map<String, dynamic> json) {
    return RatingBreakdown(
      bintang5:
          json['bintang_5'] != null
              ? int.tryParse(json['bintang_5'].toString())
              : null,
      bintang4:
          json['bintang_4'] != null
              ? int.tryParse(json['bintang_4'].toString())
              : null,
      bintang3:
          json['bintang_3'] != null
              ? int.tryParse(json['bintang_3'].toString())
              : null,
      bintang2:
          json['bintang_2'] != null
              ? int.tryParse(json['bintang_2'].toString())
              : null,
      bintang1:
          json['bintang_1'] != null
              ? int.tryParse(json['bintang_1'].toString())
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bintang_5': bintang5,
      'bintang_4': bintang4,
      'bintang_3': bintang3,
      'bintang_2': bintang2,
      'bintang_1': bintang1,
    };
  }
}
