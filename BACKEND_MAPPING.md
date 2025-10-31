# Backend API Field Mapping

## Response Structure

```json
{
  "status": "success" | "error",
  "message": "...",
  "data": {
    // actual data here
  }
}
```

## User Fields Mapping

### Backend → Flutter Model

| Backend Field  | Type          | Flutter Field      | Type     | Notes                 |
| -------------- | ------------- | ------------------ | -------- | --------------------- |
| `id`           | int/string    | `id`               | int      | Parse string to int   |
| `username`     | string        | -                  | -        | Not used in model     |
| `email`        | string        | `email`            | string   | Direct                |
| `nama_lengkap` | string        | `nama`             | string   | Direct                |
| `no_telp`      | string        | `noHp`             | string   | Direct                |
| `alamat`       | string        | `alamat`           | string   | Direct                |
| `foto_profil`  | string        | `fotoProfile`      | string   | Direct                |
| `poin`         | int/string    | `saldo`            | double   | Parse to double       |
| `is_active`    | boolean (t/f) | `statusAktif`      | string   | t→online, f→offline   |
| `is_verified`  | boolean (t/f) | `statusVerifikasi` | string   | t→verified, f→pending |
| `id_role`      | int/string    | `jenisAkun`        | string   | 2→client, 3→tukang    |
| `created_at`   | timestamp     | `createdAt`        | DateTime | Parse                 |
| `updated_at`   | timestamp     | `updatedAt`        | DateTime | Parse                 |

### Tukang Additional Fields

| Backend Field                           | Flutter Field   | Notes           |
| --------------------------------------- | --------------- | --------------- |
| `profil_tukang.pengalaman_tahun`        | -               | Not in model    |
| `profil_tukang.tarif_per_jam`           | -               | Not in model    |
| `profil_tukang.bio`                     | -               | Not in model    |
| `profil_tukang.keahlian`                | -               | Not in model    |
| `profil_tukang.rata_rata_rating`        | `rating`        | Direct          |
| `profil_tukang.total_pekerjaan_selesai` | `jumlahPesanan` | Direct          |
| `profil_tukang.status_ketersediaan`     | `statusAktif`   | tersedia→online |

## Transaction Fields Mapping

| Backend Field         | Flutter Field      | Notes               |
| --------------------- | ------------------ | ------------------- |
| `id`                  | `id`               | Parse string to int |
| `nomor_pesanan`       | `nomorPesanan`     | Direct              |
| `client_id`           | `idClient`         | Parse to int        |
| `tukang_id`           | `idTukang`         | Parse to int        |
| `kategori_id`         | `idKategori`       | Parse to int        |
| `judul_layanan`       | `judulLayanan`     | Direct              |
| `deskripsi_layanan`   | `deskripsiLayanan` | Direct              |
| `lokasi_kerja`        | `lokasiKerja`      | Direct              |
| `tanggal_jadwal`      | `tanggalJadwal`    | Parse to DateTime   |
| `waktu_jadwal`        | `waktuJadwal`      | Time string         |
| `estimasi_durasi_jam` | `estimasiDurasi`   | int                 |
| `total_biaya`         | `totalBiaya`       | Parse to double     |
| `metode_pembayaran`   | `metodePembayaran` | Direct              |
| `status`              | `statusPesanan`    | Direct              |
| `created_at`          | `createdAt`        | Parse               |

## Statistics Fields Mapping

| Backend Field                | Flutter Field               | Notes           |
| ---------------------------- | --------------------------- | --------------- |
| `saldo_poin`                 | `saldoPoin`                 | Parse to double |
| `total_pekerjaan_selesai`    | `totalPekerjaanSelesai`     | int             |
| `rata_rata_rating`           | `rataRataRating`            | Parse to double |
| `transaksi.total`            | `transaksi.total`           | int             |
| `transaksi.pending`          | `transaksi.pending`         | int             |
| `transaksi.selesai`          | `transaksi.selesai`         | int             |
| `transaksi.total_pendapatan` | `transaksi.totalPendapatan` | Parse to double |
