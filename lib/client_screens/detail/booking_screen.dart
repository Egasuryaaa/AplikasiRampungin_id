import 'package:flutter/material.dart';
import 'package:rampungin_id_userside/services/client_service.dart';
import 'package:rampungin_id_userside/models/user_model.dart';

class BookingScreen extends StatefulWidget {
  final UserModel tukangData;
  final double? hargaDasar; // Optional default price

  const BookingScreen({super.key, required this.tukangData, this.hargaDasar});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final ClientService _clientService = ClientService();

  // Form controllers
  final TextEditingController _lokasiController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();
  final TextEditingController _hargaDasarController = TextEditingController();
  final TextEditingController _biayaTambahanController =
      TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _estimasiDurasi = 1;
  String _metodePembayaran = 'poin'; // 'poin' or 'tunai'
  bool _isLoading = false;

  // Selected services
  String? _selectedLayanan;

  @override
  void initState() {
    super.initState();
    // Set default values
    _hargaDasarController.text = widget.hargaDasar?.toString() ?? '50000';
    
    // Set default layanan dari keahlian pertama jika ada
    final daftarLayanan = _getDaftarLayanan();
    if (daftarLayanan.isNotEmpty) {
      _selectedLayanan = daftarLayanan.first;
    }
  }

  @override
  void dispose() {
    _lokasiController.dispose();
    _catatanController.dispose();
    _hargaDasarController.dispose();
    _biayaTambahanController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  double _calculateTotal() {
    final hargaDasar = double.tryParse(_hargaDasarController.text) ?? 0;
    final biayaTambahan = double.tryParse(_biayaTambahanController.text) ?? 0;
    return (hargaDasar * _estimasiDurasi) + biayaTambahan;
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal jadwal'))
      );
      return;
    }

    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih waktu jadwal'))
      );
      return;
    }

    if (_selectedLayanan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih jenis layanan'))
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final hargaDasar = double.tryParse(_hargaDasarController.text) ?? 0;
      final biayaTambahan = double.tryParse(_biayaTambahanController.text) ?? 0;

      // Buat judul layanan dari kategori dan layanan yang dipilih
      final judulLayanan = '${widget.tukangData.namaKategori ?? "Layanan"} - $_selectedLayanan';
      
      // Buat deskripsi dari bio tukang atau layanan yang dipilih
      final deskripsiLayanan = widget.tukangData.bio ?? 
          'Layanan $_selectedLayanan oleh ${widget.tukangData.nama}';

      final transaction = await _clientService.createBooking(
        tukangId: widget.tukangData.id!,
        kategoriId: widget.tukangData.idKategori ?? 1,
        judulLayanan: judulLayanan,
        deskripsiLayanan: deskripsiLayanan,
        lokasiKerja: _lokasiController.text,
        tanggalJadwal:
            '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}',
        waktuJadwal:
            '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}:00',
        estimasiDurasiJam: _estimasiDurasi,
        hargaDasar: hargaDasar,
        biayaTambahan: biayaTambahan,
        metodePembayaran: _metodePembayaran,
        catatanClient:
            _catatanController.text.isNotEmpty ? _catatanController.text : null,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Booking Berhasil'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pesanan Anda berhasil dibuat!'),
                const SizedBox(height: 8),
                Text('Nomor Pesanan: ${transaction.id ?? 'N/A'}'),
                const SizedBox(height: 4),
                Text('Status: ${transaction.statusPesanan ?? 'pending'}'),
                const SizedBox(height: 4),
                Text('Metode: ${_metodePembayaran.toUpperCase()}'),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Close booking screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF3B950),
                ),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat booking: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Helper method untuk mendapatkan daftar keahlian spesifik dari tukang
  List<String> _getDaftarLayanan() {
    final List<String> layanan = [];
    
    // Tambahkan keahlian spesifik dari data profil tukang
    if (widget.tukangData.profilTukang != null && 
        widget.tukangData.profilTukang!['keahlian'] != null) {
      if (widget.tukangData.profilTukang!['keahlian'] is List) {
        final keahlianList = (widget.tukangData.profilTukang!['keahlian'] as List)
            .map((e) => e.toString())
            .where((e) => e.isNotEmpty)
            .toList();
        layanan.addAll(keahlianList);
      } else if (widget.tukangData.profilTukang!['keahlian'] is String) {
        final keahlianString = widget.tukangData.profilTukang!['keahlian'] as String;
        final keahlianList = keahlianString.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        layanan.addAll(keahlianList);
      }
    }
    
    // Jika tidak ada keahlian spesifik, gunakan kata kunci dari bio
    if (layanan.isEmpty && widget.tukangData.bio != null && widget.tukangData.bio!.isNotEmpty) {
      // Ambil kata kunci dari bio (exclude kategori)
      final bioKeywords = widget.tukangData.bio!
          .split('.')
          .where((sentence) => sentence.trim().isNotEmpty)
          .map((sentence) => sentence.trim())
          .where((sentence) => !sentence.toLowerCase().contains('tukang'))
          .toList();
      
      layanan.addAll(bioKeywords);
    }
    
    // Jika masih kosong, buat default options berdasarkan kategori
    if (layanan.isEmpty) {
      final kategori = widget.tukangData.namaKategori?.toLowerCase() ?? '';
      if (kategori.contains('listrik')) {
        layanan.addAll(['Instalasi Listrik', 'Perbaikan Listrik', 'Pemasangan Lampu']);
      } else if (kategori.contains('bangunan')) {
        layanan.addAll(['Renovasi', 'Perbaikan Bangunan', 'Konstruksi']);
      } else {
        layanan.add('Layanan ${widget.tukangData.namaKategori ?? "Umum"}');
      }
    }
    
    // Hapus duplikat
    return layanan.toSet().toList();
  }

  @override
  Widget build(BuildContext context) {
    final daftarLayanan = _getDaftarLayanan();
    
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3B950),
        title: const Text('Buat Booking'),
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tukang Info Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: const Color(0xFFF3B950).withOpacity(0.2),
                          child: const Icon(
                            Icons.person,
                            size: 30,
                            color: Color(0xFFF3B950),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.tukangData.nama ?? 'Tukang',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                widget.tukangData.namaKategori ?? 'Kategori',
                                style: const TextStyle(color: Colors.grey),
                              ),
                              if (widget.hargaDasar != null)
                                Text(
                                  'Rp ${widget.hargaDasar?.toStringAsFixed(0)}/jam',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Kategori (Read-only, dari data tukang)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.category, color: Colors.grey),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Kategori',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                widget.tukangData.namaKategori ?? 'Tidak tersedia',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Pilih Jenis Layanan (dari keahlian spesifik tukang)
                  const Text(
                    'Jenis Layanan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (daftarLayanan.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedLayanan,
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: daftarLayanan
                            .map(
                              (layanan) => DropdownMenuItem(
                                value: layanan,
                                child: Text(layanan),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedLayanan = value;
                          });
                        },
                        hint: const Text('Pilih jenis layanan'),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: const Text(
                        'Tidak ada layanan tersedia',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Deskripsi Layanan (auto-generated)
                  if (_selectedLayanan != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[100]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Deskripsi Layanan:',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.tukangData.bio ?? 
                                'Layanan $_selectedLayanan oleh ${widget.tukangData.nama}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Lokasi Kerja
                  TextFormField(
                    controller: _lokasiController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Lokasi Kerja',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lokasi harus diisi';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Tanggal & Waktu
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: _selectDate,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedDate == null
                                      ? 'Pilih Tanggal'
                                      : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: _selectTime,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedTime == null
                                      ? 'Pilih Waktu'
                                      : '${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Estimasi Durasi
                  const Text('Estimasi Durasi (jam)'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: DropdownButton<int>(
                      value: _estimasiDurasi,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: List.generate(12, (index) => index + 1)
                          .map(
                            (hour) => DropdownMenuItem(
                              value: hour,
                              child: Text('$hour jam'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _estimasiDurasi = value!;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Harga Dasar
                  TextFormField(
                    controller: _hargaDasarController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Harga Dasar per Jam',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      prefixText: 'Rp ',
                    ),
                    onChanged: (_) => setState(() {}),
                  ),

                  const SizedBox(height: 16),

                  // Biaya Tambahan
                  TextFormField(
                    controller: _biayaTambahanController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Biaya Tambahan (opsional)',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      prefixText: 'Rp ',
                    ),
                    onChanged: (_) => setState(() {}),
                  ),

                  const SizedBox(height: 16),

                  // Metode Pembayaran
                  const Text('Metode Pembayaran'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () {
                                setState(() {
                                  _metodePembayaran = 'poin';
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: const Color(0xFFF3B950),
                                          width: 2,
                                        ),
                                      ),
                                      child: Center(
                                        child: Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: _metodePembayaran == 'poin'
                                                ? const Color(0xFFF3B950)
                                                : Colors.transparent,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'POIN',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'Bayar dengan saldo',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () {
                                setState(() {
                                  _metodePembayaran = 'tunai';
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: const Color(0xFFF3B950),
                                          width: 2,
                                        ),
                                      ),
                                      child: Center(
                                        child: Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: _metodePembayaran == 'tunai'
                                                ? const Color(0xFFF3B950)
                                                : Colors.transparent,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'TUNAI',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'Bayar di lokasi',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Catatan
                  TextFormField(
                    controller: _catatanController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Catatan (opsional)',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Total
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3B950).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Biaya:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Rp ${_calculateTotal().toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  
                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitBooking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF3B950),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              'Buat Booking',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}