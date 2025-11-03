# RAMPUNGIN.ID - ALUR APLIKASI LENGKAP

## 📱 CLIENT FLOW (Mobile App)

### 1️⃣ REGISTRASI & LOGIN

```
POST /api/auth/register
Body: {
  "username": "client_user",
  "email": "client@example.com",
  "password": "password123",
  "nama_lengkap": "Nama Lengkap",
  "no_telp": "08123456789",
  "role": "client",
  "alamat": "Alamat lengkap",
  "kota": "Kota",
  "provinsi": "Provinsi"
}

POST /api/auth/login
Body: {
  "username": "client_user",
  "password": "password123"
}
Response: { token, user, role }
```

**Status setelah register:**

- ✅ Langsung bisa login (is_active: true, is_verified: true by default)
- ✅ Saldo poin: 0 (bisa top-up nanti)

---

### 2️⃣ LIHAT DAFTAR TUKANG

#### A. Get Kategori (untuk filter)

```
GET /api/client/categories
Headers: Authorization: Bearer {token}

Response: [
  { id: 1, nama: "Tukang Listrik", deskripsi: "..." },
  { id: 2, nama: "Tukang AC", ... }
]
```

#### B. Browse Tukang (dengan filter)

```
GET /api/client/tukang?kategori_id=1&kota=Jakarta&status=tersedia&order_by=rata_rata_rating&order_dir=DESC
Headers: Authorization: Bearer {token}

Filter yang tersedia:
- kategori_id: Filter by kategori
- kota: Filter by lokasi tukang
- status: tersedia/tidak_tersedia
- min_rating: Minimum rating (contoh: 4.5)
- max_tarif: Maximum tarif per jam
- order_by: rata_rata_rating, tarif_per_jam, pengalaman_tahun
- order_dir: ASC, DESC
- limit & offset: Untuk pagination

Response: {
  data: [
    {
      id: 1,
      nama_lengkap: "Agus Listrik",
      foto_profil: "...",
      kota: "Jakarta",
      pengalaman_tahun: 8,
      tarif_per_jam: 75000,
      rata_rata_rating: 4.8,
      total_rating: 25,
      keahlian: ["instalasi", "perbaikan"],
      status_ketersediaan: "tersedia"
    }
  ],
  pagination: { ... }
}
```

#### C. Detail Tukang

```
GET /api/client/tukang/1
Headers: Authorization: Bearer {token}

Response: {
  // Profil lengkap tukang
  // Rating & ulasan dari client lain
  // Kategori keahlian
  // Rating statistics
}
```

---

### 3️⃣ DUA PILIHAN PEMBAYARAN

#### OPSI A: PEMBAYARAN POIN (QRIS)

**Flow Top-up POIN:**

1. **Request Top-up**

```
POST /api/client/topup
Headers: Authorization: Bearer {token}
Content-Type: multipart/form-data
Body:
- jumlah: 100000 (Rp 100,000)
- bukti_pembayaran: [file upload gambar QRIS]

Response: {
  status: "success",
  message: "Permintaan top-up berhasil. Menunggu verifikasi admin.",
  data: {
    id: 1,
    jumlah: 100000,
    status: "pending",
    kadaluarsa_pada: "2025-10-30 10:00:00" // 24 jam dari sekarang
  }
}
```

2. **Admin Verifikasi Top-up** (via Web Dashboard)

   - Admin cek bukti transfer QRIS
   - Jika valid → Approve → Saldo poin client bertambah
   - Jika invalid → Reject dengan alasan

3. **Check Status Top-up**

```
GET /api/client/topup
Headers: Authorization: Bearer {token}

Response: {
  data: [
    {
      id: 1,
      jumlah: 100000,
      status: "berhasil", // atau "pending", "ditolak", "kadaluarsa"
      bukti_pembayaran: "...",
      waktu_verifikasi: "2025-10-28 11:00:00",
      nama_admin: "Admin Name"
    }
  ]
}
```

4. **Booking dengan POIN**

```
POST /api/client/booking
Headers: Authorization: Bearer {token}
Body: {
  "tukang_id": 7,
  "kategori_id": 1,
  "judul_layanan": "Instalasi listrik",
  "deskripsi_layanan": "Detail pekerjaan...",
  "lokasi_kerja": "Alamat lengkap",
  "tanggal_jadwal": "2025-10-30",
  "waktu_jadwal": "09:00:00",
  "estimasi_durasi_jam": 2,
  "harga_dasar": 150000,
  "biaya_tambahan": 0,
  "metode_pembayaran": "poin",  // 👈 POIN
  "catatan_client": "Catatan tambahan"
}

⚠️ VALIDASI:
- Cek saldo poin client >= total_biaya
- Jika cukup → auto-deduct poin dari client
- Jika tidak cukup → error "Saldo poin tidak cukup"

POIN FLOW:
✅ Saat booking: Poin client terpotong (poin_terpotong = true)
✅ Saat selesai: Poin otomatis transfer ke tukang
```

---

#### OPSI B: PEMBAYARAN TUNAI (Cash on Service)

**Flow Cash on Service:**

1. **Booking dengan TUNAI** (Tanpa Top-up)

```
POST /api/client/booking
Headers: Authorization: Bearer {token}
Body: {
  "tukang_id": 7,
  "kategori_id": 1,
  "judul_layanan": "Instalasi listrik",
  "deskripsi_layanan": "Detail pekerjaan...",
  "lokasi_kerja": "Alamat lengkap",
  "tanggal_jadwal": "2025-10-30",
  "waktu_jadwal": "09:00:00",
  "estimasi_durasi_jam": 2,
  "harga_dasar": 150000,
  "biaya_tambahan": 0,
  "metode_pembayaran": "tunai",  // 👈 TUNAI
  "catatan_client": "Catatan tambahan"
}

TUNAI FLOW:
✅ Saat booking: TIDAK ada pemotongan poin (poin_terpotong = false)
✅ Client bayar cash langsung ke tukang di lokasi
✅ Tukang konfirmasi sudah terima uang (lihat flow tukang)
```

2. **Client bayar CASH di lokasi**
   - Setelah pekerjaan selesai
   - Bayar langsung ke tukang
   - Tukang konfirmasi pembayaran di app

---

### 4️⃣ TRACKING TRANSAKSI

```
GET /api/client/transactions?status=selesai
Headers: Authorization: Bearer {token}

Filter:
- status: pending, diterima, dalam_proses, selesai, dibatalkan, ditolak
- metode_pembayaran: poin, tunai
- start_date, end_date: Filter by tanggal

Response: {
  data: [
    {
      nomor_pesanan: "TRX-20251028-0001",
      tukang: { nama, foto, rating },
      kategori: "Tukang Listrik",
      judul_layanan: "...",
      total_biaya: 150000,
      metode_pembayaran: "poin", // atau "tunai"
      status: "selesai",
      poin_terpotong: true, // false jika tunai
      sudah_dibayar_tunai: false, // true jika tunai dan sudah konfirmasi
      sudah_dirating: false,
      created_at: "..."
    }
  ]
}
```

---

### 5️⃣ BERI RATING & ULASAN

**Syarat:** Transaksi harus sudah selesai (status = 'selesai')

```
POST /api/client/rating
Headers: Authorization: Bearer {token}
Body: {
  "transaksi_id": 1,
  "rating": 5,  // 1-5 bintang
  "ulasan": "Kerja cepat dan rapi! Recommended."
}

Response: {
  status: "success",
  message: "Rating berhasil diberikan"
}

OTOMATIS:
✅ Update rata_rata_rating tukang
✅ Increment total_rating tukang
✅ Set sudah_dirating = true pada transaksi
```

---

### 6️⃣ DASHBOARD CLIENT

```
GET /api/client/statistics
Headers: Authorization: Bearer {token}

Response: {
  saldo_poin: 200000,
  transaksi: {
    total: 5,
    pending: 0,
    diterima: 1,
    dalam_proses: 0,
    selesai: 3,
    dibatalkan: 1,
    ditolak: 0,
    total_pengeluaran: 450000
  },
  topup: {
    total: 3,
    pending: 0,
    berhasil: 3,
    ditolak: 0,
    kadaluarsa: 0,
    total_topup_berhasil: 500000
  },
  rating_diberikan: 3
}
```

---

## 👨‍🔧 TUKANG FLOW (Mobile App)

### 1️⃣ REGISTRASI & VERIFIKASI

```
POST /api/auth/register
Body: {
  "username": "agus_listrik",
  "email": "agus@example.com",
  "password": "password123",
  "nama_lengkap": "Agus Prasetyo",
  "no_telp": "08123456789",
  "role": "tukang",  // 👈 Role TUKANG
  "alamat": "Alamat lengkap",
  "kota": "Jakarta",
  "provinsi": "DKI Jakarta",

  // Data khusus tukang
  "pengalaman_tahun": 8,
  "tarif_per_jam": 75000,
  "bio": "Ahli instalasi listrik...",
  "keahlian": ["instalasi listrik", "perbaikan"],
  "kategori_ids": [1, 15],  // ID kategori keahlian
  "nama_bank": "BCA",
  "nomor_rekening": "1234567890",
  "nama_pemilik_rekening": "Agus Prasetyo"
}

Response: {
  status: "success",
  message: "Registrasi berhasil. Menunggu verifikasi admin.",
  data: {
    user: { ..., is_verified: false }  // 👈 Belum verified
  }
}
```

**Status setelah register:**

- ⏳ is_verified: **false** (menunggu verifikasi admin)
- ⏳ Tidak bisa menerima order sampai verified
- ✅ Admin verifikasi via Web Dashboard → is_verified: true

---

### 2️⃣ MENGATUR PROFIL

```
GET /api/tukang/profile
Headers: Authorization: Bearer {token}

Response: {
  user: {
    id, username, email, nama_lengkap, foto_profil,
    poin, is_verified, tanggal_bergabung
  },
  profil_tukang: {
    pengalaman_tahun, tarif_per_jam, bio, keahlian,
    radius_layanan_km, rata_rata_rating, total_rating,
    total_pekerjaan_selesai, status_ketersediaan,
    nama_bank, nomor_rekening
  },
  kategori: [
    { id: 1, nama: "Tukang Listrik" }
  ]
}
```

```
PUT /api/tukang/profile
Headers: Authorization: Bearer {token}
Body: {
  "nama_lengkap": "Agus Prasetyo Updated",
  "email": "agus.new@gmail.com",
  "no_telp": "08123456789",
  "alamat": "Alamat baru",
  "kota": "Jakarta",
  "pengalaman_tahun": 9,
  "tarif_per_jam": 80000,
  "bio": "Updated bio...",
  "keahlian": ["instalasi", "perbaikan", "CCTV"],
  "radius_layanan_km": 15,
  "nama_bank": "BCA",
  "nomor_rekening": "1234567890",
  "foto_profil": "base64_image_string" // optional
}
```

**Update Status Ketersediaan:**

```
PUT /api/tukang/availability
Headers: Authorization: Bearer {token}
Body: {
  "status_ketersediaan": "tersedia"  // atau "tidak_tersedia"
}

⚠️ Jika "tidak_tersedia":
- Client tidak akan melihat tukang ini di browse list
- Tidak bisa menerima order baru
```

---

### 3️⃣ MENERIMA / MENOLAK PESANAN

#### A. Lihat Pesanan Masuk

```
GET /api/tukang/orders?status=pending
Headers: Authorization: Bearer {token}

Response: {
  data: [
    {
      id: 1,
      nomor_pesanan: "TRX-20251028-0001",
      client: { nama, foto, no_telp },
      kategori: "Tukang Listrik",
      judul_layanan: "Instalasi stop kontak",
      lokasi_kerja: "Alamat client",
      tanggal_jadwal: "2025-10-30",
      waktu_jadwal: "09:00:00",
      total_biaya: 150000,
      metode_pembayaran: "poin", // atau "tunai"
      status: "pending",
      catatan_client: "Catatan dari client",
      created_at: "..."
    }
  ]
}
```

#### B. Accept Order

```
PUT /api/tukang/orders/1/accept
Headers: Authorization: Bearer {token}

Response: {
  status: "success",
  message: "Pesanan berhasil diterima"
}

STATUS CHANGE: pending → diterima
```

#### C. Reject Order

```
PUT /api/tukang/orders/1/reject
Headers: Authorization: Bearer {token}
Body: {
  "alasan_penolakan": "Jadwal bertabrakan dengan pekerjaan lain"
}

Response: {
  status: "success",
  message: "Pesanan berhasil ditolak"
}

STATUS CHANGE: pending → ditolak
```

---

### 4️⃣ UPDATE STATUS PEKERJAAN

#### A. Start Work (Mulai Kerjakan)

```
PUT /api/tukang/orders/1/start
Headers: Authorization: Bearer {token}

Response: {
  status: "success",
  message: "Pekerjaan dimulai"
}

STATUS CHANGE: diterima → dalam_proses
WAKTU: waktu_mulai_aktual = sekarang
```

#### B. Complete Work (Selesaikan Pekerjaan)

```
PUT /api/tukang/orders/1/complete
Headers: Authorization: Bearer {token}
Body: {
  "catatan_tukang": "Semua instalasi sudah selesai dengan baik" // optional
}

Response: {
  status: "success",
  message: "Pekerjaan selesai"
}

STATUS CHANGE: dalam_proses → selesai
WAKTU: waktu_selesai_aktual = sekarang

POIN LOGIC:
✅ Jika metode_pembayaran = "poin":
   - Poin otomatis transfer dari client ke tukang
   - Client sudah bayar saat booking

✅ Jika metode_pembayaran = "tunai":
   - Menunggu konfirmasi pembayaran cash (lihat step C)
```

#### C. Confirm Cash Payment (Khusus TUNAI)

```
PUT /api/tukang/orders/1/confirm-tunai
Headers: Authorization: Bearer {token}

Response: {
  status: "success",
  message: "Pembayaran tunai berhasil dikonfirmasi"
}

⚠️ Hanya bisa dipanggil jika:
- metode_pembayaran = "tunai"
- status = "selesai"
- sudah_dibayar_tunai = false

AFTER CONFIRM:
✅ sudah_dibayar_tunai = true
✅ waktu_konfirmasi_pembayaran_tunai = sekarang
✅ Transaksi COMPLETE (client bisa kasih rating)
```

---

### 5️⃣ LIHAT RIWAYAT ORDER

```
GET /api/tukang/orders?status=selesai&metode_pembayaran=poin
Headers: Authorization: Bearer {token}

Filter:
- status: pending, diterima, dalam_proses, selesai, ditolak, dibatalkan
- metode_pembayaran: poin, tunai
- start_date, end_date

Response: {
  data: [
    {
      nomor_pesanan: "...",
      client: { nama, foto },
      judul_layanan: "...",
      total_biaya: 150000,
      metode_pembayaran: "poin", // atau "tunai"
      status: "selesai",
      sudah_dibayar_tunai: true, // jika tunai
      created_at: "...",
      waktu_selesai_aktual: "..."
    }
  ]
}
```

---

### 6️⃣ LIHAT RATING & ULASAN

```
GET /api/tukang/ratings
Headers: Authorization: Bearer {token}

Response: {
  data: [
    {
      transaksi_id: 1,
      nomor_pesanan: "TRX-20251028-0001",
      client: { nama, foto },
      rating: 5,
      ulasan: "Kerja cepat dan rapi!",
      judul_layanan: "Instalasi stop kontak",
      created_at: "2025-10-30 11:30:00"
    }
  ],
  summary: {
    rata_rata_rating: 4.8,
    total_rating: 25,
    bintang_5: 15,
    bintang_4: 8,
    bintang_3: 2,
    bintang_2: 0,
    bintang_1: 0
  }
}
```

---

### 7️⃣ WITHDRAW POIN (Hanya untuk transaksi POIN)

#### A. Request Withdrawal

```
POST /api/tukang/withdrawal
Headers: Authorization: Bearer {token}
Body: {
  "jumlah": 400000,  // Minimum: Rp 50,000
  "nama_bank": "BCA",
  "nomor_rekening": "1234567890",
  "nama_pemilik_rekening": "Agus Prasetyo"
}

VALIDASI:
- Minimum withdrawal: Rp 50,000
- Biaya admin: 2% (max Rp 5,000)
- Saldo poin cukup

CALCULATION:
- Biaya admin = jumlah * 0.02 (max 5000)
- Jumlah bersih = jumlah - biaya_admin
- Saldo poin tukang = saldo_poin - jumlah

Response: {
  status: "success",
  message: "Permintaan penarikan berhasil. Menunggu proses admin.",
  data: {
    id: 1,
    jumlah: 400000,
    biaya_admin: 5000,
    jumlah_bersih: 395000,
    status: "pending"
  }
}
```

#### B. Check Withdrawal History

```
GET /api/tukang/withdrawal
Headers: Authorization: Bearer {token}

Response: {
  data: [
    {
      id: 1,
      jumlah: 400000,
      biaya_admin: 5000,
      jumlah_bersih: 395000,
      nama_bank: "BCA",
      nomor_rekening: "1234567890",
      status: "selesai", // pending, diproses, selesai, ditolak
      bukti_transfer: "uploads/withdrawal/bukti_xxx.jpg",
      waktu_diproses: "2025-10-25 14:00:00",
      nama_admin: "Admin Name"
    }
  ]
}
```

**Admin Process Withdrawal** (via Web Dashboard):

- Admin transfer uang ke rekening tukang
- Upload bukti transfer
- Status: pending → diproses → selesai

---

### 8️⃣ DASHBOARD TUKANG

```
GET /api/tukang/statistics
Headers: Authorization: Bearer {token}

Response: {
  saldo_poin: 350000,
  total_pekerjaan_selesai: 30,
  rata_rata_rating: 4.8,
  total_rating: 25,
  transaksi: {
    total: 35,
    pending: 2,
    diterima: 1,
    dalam_proses: 1,
    selesai: 30,
    dibatalkan: 0,
    ditolak: 1,
    total_pendapatan: 4650000
  },
  penarikan: {
    total: 8,
    pending: 1,
    diproses: 0,
    selesai: 6,
    ditolak: 1,
    total_penarikan: 3500000,
    total_biaya_admin: 70000
  },
  rating_breakdown: {
    bintang_5: 15,
    bintang_4: 8,
    bintang_3: 2,
    bintang_2: 0,
    bintang_1: 0
  },
  pendapatan_bulan_ini: 450000,
  pekerjaan_bulan_ini: 5
}
```

---

## 🔄 STATUS TRANSAKSI FLOW

```
NORMAL FLOW (POIN):
pending → diterima → dalam_proses → selesai
   ↓         ↓              ↓           ↓
  (1)       (2)            (3)         (4)

(1) Client booking → poin terpotong
(2) Tukang accept order
(3) Tukang start work
(4) Tukang complete → poin transfer ke tukang → client kasih rating
```

```
NORMAL FLOW (TUNAI):
pending → diterima → dalam_proses → selesai → confirm_tunai
   ↓         ↓              ↓           ↓           ↓
  (1)       (2)            (3)         (4)         (5)

(1) Client booking → TIDAK potong poin
(2) Tukang accept order
(3) Tukang start work
(4) Tukang complete
(5) Tukang confirm sudah terima cash → client kasih rating
```

```
CANCEL/REJECT FLOW:
pending → ditolak (by tukang)
pending → dibatalkan (by client)
diterima → dibatalkan (by client)
```

---

## ⚠️ BUSINESS RULES

### POIN (QRIS) Rules:

1. ✅ Client harus top-up dulu (via QRIS) → admin verify
2. ✅ Saat booking, poin auto-deduct dari client
3. ✅ Jika saldo tidak cukup → error "Saldo poin tidak cukup"
4. ✅ Saat pekerjaan selesai, poin auto-transfer ke tukang
5. ✅ Tukang bisa withdraw poin ke rekening bank (min Rp 50k)

### TUNAI (Cash on Service) Rules:

1. ✅ Client TIDAK perlu top-up
2. ✅ Saat booking, TIDAK ada pemotongan poin
3. ✅ Client bayar CASH langsung ke tukang di lokasi
4. ✅ Tukang confirm pembayaran setelah terima uang
5. ✅ Tukang TIDAK bisa withdraw (karena sudah terima cash)

### Verification Rules:

- ✅ Client: Auto-verified setelah register
- ⏳ Tukang: Perlu verifikasi admin (is_verified = false)
- ⏳ Tukang tidak bisa terima order sampai verified

### Rating Rules:

- ✅ Hanya bisa rating jika transaksi selesai
- ✅ Rating 1-5 bintang
- ✅ Auto-update rata_rata_rating tukang
- ✅ Satu transaksi hanya bisa dirating 1x

---

## 📊 SUMMARY

### Client Journey:

1. Register → Login → Browse Tukang → Pilih Tukang
2. **Opsi A:** Top-up POIN → Booking (auto-deduct poin)
3. **Opsi B:** Booking langsung → Bayar CASH di lokasi
4. Tracking transaksi → Beri rating setelah selesai

### Tukang Journey:

1. Register → Verifikasi Admin → Login
2. Atur profil & keahlian → Set availability
3. Terima/Tolak pesanan → Update status (start → complete)
4. **POIN:** Withdraw ke bank
5. **TUNAI:** Confirm pembayaran cash
6. Lihat rating & riwayat order

---

**🎯 Key Features:**

- ✅ Dual payment system (POIN vs TUNAI)
- ✅ POIN: Traceable, secure, admin-verified
- ✅ TUNAI: Instant booking, no top-up needed
- ✅ Rating & review system
- ✅ Real-time order tracking
- ✅ Withdrawal system for tukang (POIN only)
