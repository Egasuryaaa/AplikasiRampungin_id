# 🔧 Backend API Fix - Booking dengan tukang_id yang Benar

## 📋 Ringkasan Masalah

Saat client Flutter mengirim request booking dengan `tukang_id: 7`, backend salah mengartikannya sebagai `users.id = 7` padahal seharusnya `profil_tukang.id = 7`. Ini menyebabkan transaksi masuk ke tukang yang salah.

**Contoh Kasus:**

- Client booking ke **Gani Firmansyah** (`profil_tukang.id = 7`, `users.id = 13`)
- Request: `{ "tukang_id": 7, ... }`
- Backend insert: `transaksi.tukang_id = 7`
- Hasil: Transaksi masuk ke **Agus Prakoso** (`users.id = 7`) ❌

**Yang seharusnya:**

- Transaksi masuk ke **Gani Firmansyah** (`profil_tukang.id = 7`) ✅

---

## 🗄️ Struktur Database (JANGAN DIUBAH)

```sql
-- Tabel users (akun login)
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  username VARCHAR(255),
  email VARCHAR(255),
  no_telp VARCHAR(20),
  nama_lengkap VARCHAR(255),
  foto_profil VARCHAR(500),
  alamat TEXT,
  kota VARCHAR(100),
  provinsi VARCHAR(100),
  poin INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  is_verified BOOLEAN DEFAULT false,
  id_role INTEGER,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Tabel profil_tukang (profile tukang)
CREATE TABLE profil_tukang (
  id SERIAL PRIMARY KEY,                           -- ✅ ID ini yang harus dipakai di transaksi
  user_id INTEGER REFERENCES users(id),            -- Foreign key ke users
  pengalaman_tahun INTEGER,
  tarif_per_jam DECIMAL(10,2),
  status_ketersediaan VARCHAR(20),
  radius_layanan_km INTEGER,
  bio TEXT,
  keahlian TEXT[],
  rata_rata_rating DECIMAL(3,2),
  total_rating INTEGER,
  total_pekerjaan_selesai INTEGER,
  nama_bank VARCHAR(100),
  nomor_rekening VARCHAR(50),
  nama_pemilik_rekening VARCHAR(255),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Tabel transaksi
CREATE TABLE transaksi (
  id SERIAL PRIMARY KEY,
  nomor_pesanan VARCHAR(50) UNIQUE,
  client_id INTEGER REFERENCES users(id),          -- Client user_id
  tukang_id INTEGER REFERENCES profil_tukang(id),  -- ✅ Harus referensi profil_tukang.id
  kategori_id INTEGER REFERENCES kategori(id),
  judul_layanan VARCHAR(255),
  deskripsi_layanan TEXT,
  lokasi_kerja TEXT,
  tanggal_jadwal DATE,
  waktu_jadwal TIME,
  estimasi_durasi_jam INTEGER,
  harga_dasar DECIMAL(10,2),
  biaya_tambahan DECIMAL(10,2),
  total_biaya DECIMAL(10,2),
  metode_pembayaran VARCHAR(20),
  status_pesanan VARCHAR(50),
  catatan_client TEXT,
  catatan_tukang TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

**Catatan Penting:**

- `transaksi.tukang_id` harus mereferensi `profil_tukang.id` (BUKAN `users.id`)
- `transaksi.client_id` mereferensi `users.id`

---

## 🛠️ Perbaikan yang Diperlukan

### 1. Endpoint: `POST /api/client/booking`

**File:** `src/routes/client/booking.routes.js` atau sejenisnya

#### ❌ Kode SALAH (Sebelum Perbaikan)

```javascript
router.post("/booking", authenticate, async (req, res) => {
  try {
    const {
      tukang_id,
      kategori_id,
      judul_layanan,
      deskripsi_layanan,
      lokasi_kerja,
      tanggal_jadwal,
      waktu_jadwal,
      estimasi_durasi_jam,
      harga_dasar,
      biaya_tambahan,
      metode_pembayaran,
      catatan_client,
    } = req.body;

    // ❌ MASALAH: Tidak ada validasi apakah tukang_id ada di profil_tukang
    // Backend mengasumsikan tukang_id adalah users.id

    const totalBiaya =
      harga_dasar * estimasi_durasi_jam + (biaya_tambahan || 0);
    const nomorPesanan = `TRX-${Date.now()}`;

    // ❌ Langsung insert tanpa validasi
    const transaksi = await prisma.transaksi.create({
      data: {
        nomor_pesanan: nomorPesanan,
        client_id: req.user.id,
        tukang_id: tukang_id, // ❌ Diasumsikan sebagai users.id
        kategori_id,
        judul_layanan,
        deskripsi_layanan,
        lokasi_kerja,
        tanggal_jadwal: new Date(tanggal_jadwal),
        waktu_jadwal,
        estimasi_durasi_jam,
        harga_dasar,
        biaya_tambahan: biaya_tambahan || 0,
        total_biaya: totalBiaya,
        metode_pembayaran,
        status_pesanan: "pending",
        catatan_client,
      },
    });

    // Deduct poin jika metode pembayaran poin
    if (metode_pembayaran === "poin") {
      await prisma.users.update({
        where: { id: req.user.id },
        data: {
          poin: {
            decrement: totalBiaya,
          },
        },
      });
    }

    res.status(201).json({
      status: "success",
      message: "Booking berhasil dibuat",
      data: {
        transaksi_id: transaksi.id,
        nomor_pesanan: transaksi.nomor_pesanan,
        status: transaksi.status_pesanan,
        total_biaya: transaksi.total_biaya,
        metode_pembayaran: transaksi.metode_pembayaran,
        poin_terpotong: metode_pembayaran === "poin",
      },
    });
  } catch (error) {
    console.error("Error creating booking:", error);
    res.status(500).json({
      status: "error",
      message: "Gagal membuat booking",
      error: error.message,
    });
  }
});
```

#### ✅ Kode BENAR (Setelah Perbaikan)

```javascript
router.post("/booking", authenticate, async (req, res) => {
  try {
    const {
      tukang_id,
      kategori_id,
      judul_layanan,
      deskripsi_layanan,
      lokasi_kerja,
      tanggal_jadwal,
      waktu_jadwal,
      estimasi_durasi_jam,
      harga_dasar,
      biaya_tambahan,
      metode_pembayaran,
      catatan_client,
    } = req.body;

    // ✅ PERBAIKAN 1: Validasi tukang_id ada di profil_tukang
    const profilTukang = await prisma.profil_tukang.findUnique({
      where: { id: tukang_id }, // ✅ Cari berdasarkan profil_tukang.id
      include: {
        users: true, // Include untuk validasi tambahan
      },
    });

    if (!profilTukang) {
      return res.status(404).json({
        status: "error",
        message: `Tukang dengan ID ${tukang_id} tidak ditemukan`,
      });
    }

    // ✅ PERBAIKAN 2: Validasi tukang aktif dan verified
    if (!profilTukang.users.is_active || !profilTukang.users.is_verified) {
      return res.status(400).json({
        status: "error",
        message: "Tukang tidak tersedia atau belum terverifikasi",
      });
    }

    // ✅ PERBAIKAN 3: Validasi kategori sesuai dengan tukang
    const tukangKategori = await prisma.tukang_kategori.findFirst({
      where: {
        tukang_id: tukang_id, // ✅ profil_tukang.id
        kategori_id: kategori_id,
      },
    });

    if (!tukangKategori) {
      return res.status(400).json({
        status: "error",
        message: "Tukang tidak memiliki keahlian dalam kategori ini",
      });
    }

    const totalBiaya =
      harga_dasar * estimasi_durasi_jam + (biaya_tambahan || 0);
    const nomorPesanan = `TRX-${Date.now()}`;

    // ✅ Validasi saldo poin client jika metode poin
    if (metode_pembayaran === "poin") {
      const client = await prisma.users.findUnique({
        where: { id: req.user.id },
        select: { poin: true },
      });

      if (client.poin < totalBiaya) {
        return res.status(400).json({
          status: "error",
          message: `Saldo poin tidak mencukupi. Saldo: ${client.poin}, Diperlukan: ${totalBiaya}`,
        });
      }
    }

    // ✅ PERBAIKAN 4: Insert dengan tukang_id yang sudah divalidasi
    const transaksi = await prisma.transaksi.create({
      data: {
        nomor_pesanan: nomorPesanan,
        client_id: req.user.id,
        tukang_id: profilTukang.id, // ✅ Gunakan profil_tukang.id yang sudah divalidasi
        kategori_id,
        judul_layanan,
        deskripsi_layanan,
        lokasi_kerja,
        tanggal_jadwal: new Date(tanggal_jadwal),
        waktu_jadwal,
        estimasi_durasi_jam,
        harga_dasar,
        biaya_tambahan: biaya_tambahan || 0,
        total_biaya: totalBiaya,
        metode_pembayaran,
        status_pesanan: "pending",
        catatan_client,
      },
    });

    // ✅ Deduct poin jika metode pembayaran poin
    if (metode_pembayaran === "poin") {
      await prisma.users.update({
        where: { id: req.user.id },
        data: {
          poin: {
            decrement: totalBiaya,
          },
        },
      });
    }

    // ✅ PERBAIKAN 5: Log untuk debugging
    console.log(
      `[BOOKING SUCCESS] Transaksi ${nomorPesanan} - Client: ${req.user.id}, Tukang: ${profilTukang.id} (User: ${profilTukang.user_id})`
    );

    res.status(201).json({
      status: "success",
      message: "Booking berhasil dibuat",
      data: {
        transaksi_id: transaksi.id,
        nomor_pesanan: transaksi.nomor_pesanan,
        status: transaksi.status_pesanan,
        total_biaya: transaksi.total_biaya,
        metode_pembayaran: transaksi.metode_pembayaran,
        poin_terpotong: metode_pembayaran === "poin",
      },
    });
  } catch (error) {
    console.error("[BOOKING ERROR]", error);
    res.status(500).json({
      status: "error",
      message: "Gagal membuat booking",
      error: error.message,
    });
  }
});
```

**Key Changes:**

1. ✅ Validasi `tukang_id` ada di tabel `profil_tukang`
2. ✅ Validasi tukang aktif dan terverifikasi
3. ✅ Validasi kategori sesuai dengan keahlian tukang
4. ✅ Validasi saldo poin client sebelum booking
5. ✅ Log transaksi untuk debugging
6. ✅ Gunakan `profilTukang.id` (bukan `tukang_id` langsung) untuk insert

---

### 2. Endpoint: `GET /api/client/tukang/:tukang_id`

**File:** `src/routes/client/tukang.routes.js` atau sejenisnya

#### ❌ Kode SALAH (Sebelum Perbaikan)

```javascript
router.get("/tukang/:tukang_id", authenticate, async (req, res) => {
  try {
    const tukangId = parseInt(req.params.tukang_id);

    const profil = await prisma.profil_tukang.findUnique({
      where: { id: tukangId },
      include: {
        users: true,
        tukang_kategori: {
          include: {
            kategori: true,
          },
        },
      },
    });

    if (!profil) {
      return res.status(404).json({
        status: "error",
        message: "Tukang tidak ditemukan",
      });
    }

    // ❌ MASALAH: Response mengirim tukang_id = user_id (SALAH!)
    res.json({
      status: "success",
      message: "Detail tukang berhasil diambil",
      data: {
        tukang_id: profil.user_id, // ❌ SALAH! Mengirim users.id
        user_id: profil.user_id,
        username: profil.users.username,
        email: profil.users.email,
        no_telp: profil.users.no_telp,
        nama_lengkap: profil.users.nama_lengkap,
        foto_profil: profil.users.foto_profil,
        alamat: profil.users.alamat,
        kota: profil.users.kota,
        provinsi: profil.users.provinsi,
        poin: profil.users.poin,
        is_active: profil.users.is_active,
        is_verified: profil.users.is_verified,
        profil_tukang: {
          id: profil.id,
          user_id: profil.user_id,
          pengalaman_tahun: profil.pengalaman_tahun,
          tarif_per_jam: profil.tarif_per_jam,
          status_ketersediaan: profil.status_ketersediaan,
          radius_layanan_km: profil.radius_layanan_km,
          bio: profil.bio,
          keahlian: profil.keahlian,
          rata_rata_rating: profil.rata_rata_rating,
          total_rating: profil.total_rating,
          total_pekerjaan_selesai: profil.total_pekerjaan_selesai,
          nama_bank: profil.nama_bank,
          nomor_rekening: profil.nomor_rekening,
          nama_pemilik_rekening: profil.nama_pemilik_rekening,
        },
        kategori: profil.tukang_kategori.map((tk) => ({
          id: tk.kategori.id,
          nama: tk.kategori.nama,
          deskripsi: tk.kategori.deskripsi,
        })),
      },
    });
  } catch (error) {
    console.error("Error getting tukang detail:", error);
    res.status(500).json({
      status: "error",
      message: "Gagal mengambil detail tukang",
    });
  }
});
```

#### ✅ Kode BENAR (Setelah Perbaikan)

```javascript
router.get("/tukang/:tukang_id", authenticate, async (req, res) => {
  try {
    const tukangId = parseInt(req.params.tukang_id);

    // ✅ Query profil_tukang dengan semua relasi
    const profil = await prisma.profil_tukang.findUnique({
      where: { id: tukangId }, // ✅ Cari berdasarkan profil_tukang.id
      include: {
        users: true,
        tukang_kategori: {
          include: {
            kategori: true,
          },
        },
      },
    });

    if (!profil) {
      return res.status(404).json({
        status: "error",
        message: "Tukang tidak ditemukan",
      });
    }

    // ✅ Query ratings (jika ada tabel rating)
    const ratings = await prisma.rating.findMany({
      where: { tukang_id: profil.id }, // ✅ profil_tukang.id
      include: {
        client: {
          select: {
            id: true,
            nama_lengkap: true,
            foto_profil: true,
          },
        },
      },
      orderBy: {
        created_at: "desc",
      },
      take: 10,
    });

    // ✅ Hitung rating stats
    const ratingStats = {
      total: ratings.length,
      rata_rata:
        ratings.length > 0
          ? ratings.reduce((sum, r) => sum + r.rating, 0) / ratings.length
          : 0,
      bintang_5: ratings.filter((r) => r.rating === 5).length,
      bintang_4: ratings.filter((r) => r.rating === 4).length,
      bintang_3: ratings.filter((r) => r.rating === 3).length,
      bintang_2: ratings.filter((r) => r.rating === 2).length,
      bintang_1: ratings.filter((r) => r.rating === 1).length,
    };

    // ✅ PERBAIKAN: Response dengan tukang_id = profil_tukang.id
    res.json({
      status: "success",
      message: "Detail tukang berhasil diambil",
      data: {
        tukang_id: profil.id, // ✅ BENAR! Kirim profil_tukang.id
        user_id: profil.user_id, // ✅ Info tambahan (users.id)
        username: profil.users.username,
        email: profil.users.email,
        no_telp: profil.users.no_telp,
        nama_lengkap: profil.users.nama_lengkap,
        foto_profil: profil.users.foto_profil,
        alamat: profil.users.alamat,
        kota: profil.users.kota,
        provinsi: profil.users.provinsi,
        kode_pos: profil.users.kode_pos,
        poin: profil.users.poin,
        is_active: profil.users.is_active,
        is_verified: profil.users.is_verified,
        id_role: profil.users.id_role,
        created_at: profil.users.created_at,
        updated_at: profil.users.updated_at,
        profil_tukang: {
          id: profil.id, // ✅ Sama dengan tukang_id di root
          user_id: profil.user_id,
          pengalaman_tahun: profil.pengalaman_tahun,
          tarif_per_jam: profil.tarif_per_jam,
          status_ketersediaan: profil.status_ketersediaan,
          radius_layanan_km: profil.radius_layanan_km,
          bio: profil.bio,
          keahlian: profil.keahlian,
          rata_rata_rating: ratingStats.rata_rata,
          total_rating: ratingStats.total,
          total_pekerjaan_selesai: profil.total_pekerjaan_selesai,
          nama_bank: profil.nama_bank,
          nomor_rekening: profil.nomor_rekening,
          nama_pemilik_rekening: profil.nama_pemilik_rekening,
          created_at: profil.created_at,
          updated_at: profil.updated_at,
        },
        kategori: profil.tukang_kategori.map((tk) => ({
          id: tk.kategori.id,
          nama: tk.kategori.nama,
          deskripsi: tk.kategori.deskripsi,
          is_active: tk.kategori.is_active,
          created_at: tk.kategori.created_at,
          updated_at: tk.kategori.updated_at,
        })),
        ratings: ratings.map((r) => ({
          id: r.id,
          client_id: r.client_id,
          client_nama: r.client.nama_lengkap,
          client_foto: r.client.foto_profil,
          rating: r.rating,
          komentar: r.komentar,
          created_at: r.created_at,
        })),
        rating_stats: ratingStats,
      },
    });

    // ✅ Log untuk debugging
    console.log(
      `[TUKANG DETAIL] Profil ID: ${profil.id}, User ID: ${profil.user_id}, Nama: ${profil.users.nama_lengkap}`
    );
  } catch (error) {
    console.error("[TUKANG DETAIL ERROR]", error);
    res.status(500).json({
      status: "error",
      message: "Gagal mengambil detail tukang",
      error: error.message,
    });
  }
});
```

**Key Changes:**

1. ✅ Response `tukang_id` sekarang kirim `profil_tukang.id` (BENAR!)
2. ✅ Field `user_id` tetap ada sebagai informasi tambahan
3. ✅ Konsistensi: `data.tukang_id = data.profil_tukang.id`
4. ✅ Include ratings dan rating_stats
5. ✅ Log untuk debugging

---

### 3. Endpoint: `GET /api/client/tukang` (Browse/List)

**File:** `src/routes/client/tukang.routes.js`

#### ✅ Pastikan Response Browse Juga Konsisten

```javascript
router.get("/tukang", authenticate, async (req, res) => {
  try {
    const {
      kategori_id,
      kota,
      provinsi,
      status_ketersediaan,
      min_rating,
      max_tarif,
      search,
      limit = 10,
      offset = 0,
    } = req.query;

    const whereConditions = {};
    const userWhereConditions = {};

    // Filter conditions
    if (kategori_id) {
      whereConditions.tukang_kategori = {
        some: {
          kategori_id: parseInt(kategori_id),
        },
      };
    }

    if (status_ketersediaan) {
      whereConditions.status_ketersediaan = status_ketersediaan;
    }

    if (min_rating) {
      whereConditions.rata_rata_rating = {
        gte: parseFloat(min_rating),
      };
    }

    if (max_tarif) {
      whereConditions.tarif_per_jam = {
        lte: parseFloat(max_tarif),
      };
    }

    if (kota) {
      userWhereConditions.kota = kota;
    }

    if (provinsi) {
      userWhereConditions.provinsi = provinsi;
    }

    if (search) {
      userWhereConditions.nama_lengkap = {
        contains: search,
        mode: "insensitive",
      };
    }

    if (Object.keys(userWhereConditions).length > 0) {
      whereConditions.users = userWhereConditions;
    }

    const [tukangs, total] = await Promise.all([
      prisma.profil_tukang.findMany({
        where: whereConditions,
        include: {
          users: true,
          tukang_kategori: {
            include: {
              kategori: true,
            },
          },
        },
        skip: parseInt(offset),
        take: parseInt(limit),
        orderBy: {
          rata_rata_rating: "desc",
        },
      }),
      prisma.profil_tukang.count({ where: whereConditions }),
    ]);

    // ✅ PERBAIKAN: Map response dengan tukang_id = profil_tukang.id
    const formattedTukangs = tukangs.map((profil) => ({
      tukang_id: profil.id, // ✅ BENAR! profil_tukang.id
      user_id: profil.user_id, // ✅ Info tambahan
      nama_lengkap: profil.users.nama_lengkap,
      foto_profil: profil.users.foto_profil,
      alamat: profil.users.alamat,
      kota: profil.users.kota,
      provinsi: profil.users.provinsi,
      pengalaman_tahun: profil.pengalaman_tahun,
      tarif_per_jam: profil.tarif_per_jam,
      rata_rata_rating: profil.rata_rata_rating,
      total_rating: profil.total_rating,
      total_pekerjaan_selesai: profil.total_pekerjaan_selesai,
      status_ketersediaan: profil.status_ketersediaan,
      radius_layanan_km: profil.radius_layanan_km,
      bio: profil.bio,
      keahlian: profil.keahlian,
      kategori: profil.tukang_kategori.map((tk) => ({
        id: tk.kategori.id,
        nama: tk.kategori.nama,
      })),
    }));

    res.json({
      status: "success",
      message: "Daftar tukang berhasil diambil",
      data: formattedTukangs,
      pagination: {
        total,
        limit: parseInt(limit),
        offset: parseInt(offset),
        has_more: parseInt(offset) + parseInt(limit) < total,
      },
    });
  } catch (error) {
    console.error("[BROWSE TUKANG ERROR]", error);
    res.status(500).json({
      status: "error",
      message: "Gagal mengambil daftar tukang",
      error: error.message,
    });
  }
});
```

---

## 🧪 Test Case Setelah Perbaikan

### Test 1: Get Detail Tukang

```bash
# Request
GET /api/client/tukang/7
Authorization: Bearer <token>

# Expected Response
{
  "status": "success",
  "message": "Detail tukang berhasil diambil",
  "data": {
    "tukang_id": 7,        // ✅ profil_tukang.id
    "user_id": 13,         // ✅ users.id (Gani)
    "nama_lengkap": "Gani Firmansyah",
    "email": "gani.ac@gmail.com",
    "profil_tukang": {
      "id": 7,             // ✅ Sama dengan tukang_id
      "user_id": 13,
      "pengalaman_tahun": 8,
      "tarif_per_jam": "95000",
      ...
    },
    "kategori": [...]
  }
}
```

### Test 2: Create Booking

```bash
# Request
POST /api/client/booking
Authorization: Bearer <token>
Content-Type: application/json

{
  "tukang_id": 7,              // profil_tukang.id (Gani)
  "kategori_id": 5,
  "judul_layanan": "Service AC",
  "deskripsi_layanan": "Service AC rutin",
  "lokasi_kerja": "Jl. Test No. 123",
  "tanggal_jadwal": "2025-11-25",
  "waktu_jadwal": "10:00:00",
  "estimasi_durasi_jam": 2,
  "harga_dasar": 50000,
  "biaya_tambahan": 0,
  "metode_pembayaran": "poin"
}

# Expected Response
{
  "status": "success",
  "message": "Booking berhasil dibuat",
  "data": {
    "transaksi_id": 18,
    "nomor_pesanan": "TRX-1764000000000",
    "status": "pending",
    "total_biaya": "100000",
    "metode_pembayaran": "poin",
    "poin_terpotong": true
  }
}
```

### Test 3: Verify di Database

```sql
-- Cek transaksi yang baru dibuat
SELECT
  t.id,
  t.nomor_pesanan,
  t.tukang_id,
  pt.id as profil_id,
  pt.user_id,
  u.nama_lengkap as nama_tukang,
  t.client_id,
  c.nama_lengkap as nama_client
FROM transaksi t
JOIN profil_tukang pt ON t.tukang_id = pt.id
JOIN users u ON pt.user_id = u.id
JOIN users c ON t.client_id = c.id
WHERE t.nomor_pesanan = 'TRX-1764000000000';

-- Expected Result:
-- tukang_id = 7 (profil_tukang.id)
-- user_id = 13 (users.id untuk Gani)
-- nama_tukang = "Gani Firmansyah" ✅
```

### Test 4: Negative Test - Tukang ID Tidak Ada

```bash
# Request
POST /api/client/booking
{
  "tukang_id": 999,  // ID tidak ada
  ...
}

# Expected Response
{
  "status": "error",
  "message": "Tukang dengan ID 999 tidak ditemukan"
}
```

---

## 📊 Verifikasi Foreign Key Constraint

Pastikan foreign key sudah benar:

```sql
-- Cek foreign key di tabel transaksi
SELECT
  tc.constraint_name,
  tc.table_name,
  kcu.column_name,
  ccu.table_name AS foreign_table_name,
  ccu.column_name AS foreign_column_name
FROM
  information_schema.table_constraints AS tc
  JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
  JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
WHERE tc.table_name = 'transaksi'
  AND kcu.column_name = 'tukang_id';

-- Expected Result:
-- transaksi.tukang_id → profil_tukang.id ✅
```

Jika FK masih ke `users.id`, perlu diperbaiki:

```sql
-- DROP constraint lama (jika salah)
ALTER TABLE transaksi
DROP CONSTRAINT IF EXISTS transaksi_tukang_id_fkey;

-- ADD constraint baru (yang benar)
ALTER TABLE transaksi
ADD CONSTRAINT transaksi_tukang_id_fkey
FOREIGN KEY (tukang_id)
REFERENCES profil_tukang(id)
ON DELETE RESTRICT
ON UPDATE CASCADE;
```

---

## 🔍 Debugging Tips

### 1. Enable Logging di Backend

```javascript
// Tambahkan middleware untuk log semua request booking
router.use("/booking", (req, res, next) => {
  console.log("[BOOKING REQUEST]", {
    method: req.method,
    body: req.body,
    user_id: req.user?.id,
    timestamp: new Date().toISOString(),
  });
  next();
});
```

### 2. Log Setiap Insert Transaksi

```javascript
// Setelah create transaksi
console.log("[TRANSAKSI CREATED]", {
  transaksi_id: transaksi.id,
  nomor_pesanan: transaksi.nomor_pesanan,
  tukang_id: transaksi.tukang_id,
  client_id: transaksi.client_id,
  profil_tukang_id: profilTukang.id,
  tukang_user_id: profilTukang.user_id,
});
```

### 3. Query Untuk Monitoring

```sql
-- Cek transaksi hari ini dengan detail tukang
SELECT
  t.id,
  t.nomor_pesanan,
  t.created_at,
  t.tukang_id as transaksi_tukang_id,
  pt.id as profil_tukang_id,
  pt.user_id as tukang_user_id,
  u.nama_lengkap as nama_tukang,
  CASE
    WHEN t.tukang_id = pt.id THEN 'BENAR ✅'
    ELSE 'SALAH ❌'
  END as status_mapping
FROM transaksi t
LEFT JOIN profil_tukang pt ON t.tukang_id = pt.id
LEFT JOIN users u ON pt.user_id = u.id
WHERE DATE(t.created_at) = CURRENT_DATE
ORDER BY t.created_at DESC;
```

---

## ✅ Checklist Perbaikan

- [ ] **Endpoint POST /api/client/booking**

  - [ ] Tambah validasi `tukang_id` ada di `profil_tukang`
  - [ ] Tambah validasi tukang aktif & verified
  - [ ] Tambah validasi kategori sesuai keahlian
  - [ ] Tambah validasi saldo poin (jika metode poin)
  - [ ] Gunakan `profilTukang.id` untuk insert transaksi
  - [ ] Tambah logging untuk debugging

- [ ] **Endpoint GET /api/client/tukang/:tukang_id**

  - [ ] Response `tukang_id` kirim `profil_tukang.id`
  - [ ] Konsistensi: `data.tukang_id = data.profil_tukang.id`
  - [ ] Include ratings dan rating_stats
  - [ ] Tambah logging untuk debugging

- [ ] **Endpoint GET /api/client/tukang (Browse)**

  - [ ] Response `tukang_id` kirim `profil_tukang.id`
  - [ ] Konsistensi di semua item list

- [ ] **Database Verification**

  - [ ] Cek foreign key `transaksi.tukang_id` → `profil_tukang.id`
  - [ ] Test query join transaksi-profil_tukang-users

- [ ] **Testing**
  - [ ] Test get detail tukang (response benar)
  - [ ] Test create booking (insert ke tukang yang benar)
  - [ ] Test negative case (tukang_id tidak ada)
  - [ ] Verify di database (query join)

---

## 📞 Support

Jika ada pertanyaan atau issue setelah implementasi, silakan:

1. Cek log di console backend
2. Run query SQL untuk verify data
3. Check response API dengan Postman/Insomnia
4. Hubungi team frontend dengan hasil test

---

**Dokumen ini dibuat untuk memperbaiki bug booking tukang_id tanpa mengubah struktur database.**

Last Updated: 