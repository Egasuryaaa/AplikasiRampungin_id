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
  final TextEditingController _judulLayananManualController =
      TextEditingController(); // Fallback manual input

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _estimasiDurasi = 1;
  String _metodePembayaran = 'poin'; // 'poin' or 'tunai'
  bool _isLoading = false;
  bool _isLoadingKeahlian = true;

  // Selected services
  String? _selectedLayanan;
  List<String> _daftarKeahlian = [];

  @override
  void initState() {
    super.initState();
    // Set default values
    _hargaDasarController.text = widget.hargaDasar?.toString() ?? '50000';

    // Fetch keahlian dari API
    _fetchKeahlianFromAPI();
  }

  /// Fetch keahlian dari API detail tukang
  Future<void> _fetchKeahlianFromAPI() async {
    setState(() {
      _isLoadingKeahlian = true;
    });

    try {
      // Ambil detail tukang dari API
      final tukangDetail = await _clientService.getTukangDetailFull(
        widget.tukangData.id!,
      );

      // Extract keahlian dari model
      if (tukangDetail.keahlian != null && tukangDetail.keahlian!.isNotEmpty) {
        setState(() {
          _daftarKeahlian = tukangDetail.keahlian!;
          // Set default ke keahlian pertama
          if (_daftarKeahlian.isNotEmpty) {
            _selectedLayanan = _daftarKeahlian.first;
          }
          _isLoadingKeahlian = false;
        });
      } else {
        // Jika tidak ada keahlian dari API, list kosong (tidak ada fallback)
        setState(() {
          _daftarKeahlian = [];
          _selectedLayanan = null;
          _isLoadingKeahlian = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching keahlian: $e');
      // Jika error, list kosong
      setState(() {
        _daftarKeahlian = [];
        _selectedLayanan = null;
        _isLoadingKeahlian = false;
      });
    }
  }

  @override
  void dispose() {
    _lokasiController.dispose();
    _catatanController.dispose();
    _hargaDasarController.dispose();
    _biayaTambahanController.dispose();
    _judulLayananManualController.dispose();
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pilih tanggal jadwal')));
      return;
    }

    if (_selectedTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pilih waktu jadwal')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final hargaDasar = double.tryParse(_hargaDasarController.text) ?? 0;
      final biayaTambahan = double.tryParse(_biayaTambahanController.text) ?? 0;

      // Ambil judul layanan dari dropdown atau manual input
      final judulLayanan =
          _daftarKeahlian.isNotEmpty
              ? '${widget.tukangData.namaKategori ?? "Layanan"} - $_selectedLayanan'
              : '${widget.tukangData.namaKategori ?? "Layanan"} - ${_judulLayananManualController.text}';

      // Buat deskripsi dari bio tukang atau layanan yang dipilih
      final layananName =
          _daftarKeahlian.isNotEmpty
              ? _selectedLayanan
              : _judulLayananManualController.text;
      final deskripsiLayanan =
          widget.tukangData.bio ??
          'Layanan $layananName oleh ${widget.tukangData.nama}';

      debugPrint(
        'Creating booking with userId (as tukangId): ${widget.tukangData.userId}, '
        'kategoriId: ${widget.tukangData.idKategori}',
      );
      debugPrint(
        'DEBUG - widget.tukangData.userId: ${widget.tukangData.userId}',
      );
      debugPrint(
        'DEBUG - widget.tukangData.id (profil_tukang.id): ${widget.tukangData.id}',
      );
      debugPrint(
        'DEBUG - Will send to API (tukang_id field): ${widget.tukangData.userId}',
      );

      final transaction = await _clientService.createBooking(
        tukangId: widget.tukangData.userId!,
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
          builder: (context) {
            final displayLayanan =
                _daftarKeahlian.isNotEmpty
                    ? _selectedLayanan
                    : _judulLayananManualController.text;

            return AlertDialog(
              title: const Text('Booking Berhasil'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pesanan Anda berhasil dibuat!'),
                  const SizedBox(height: 8),
                  Text('Layanan: $displayLayanan'),
                  const SizedBox(height: 4),
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
            );
          },
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

  @override
  Widget build(BuildContext context) {
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
                          backgroundColor: const Color(
                            0xFFF3B950,
                          ).withOpacity(0.2),
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

                  // Kategori Chips (dari data kategoriList - DATA ASLI dari API)
                  Builder(
                    builder: (context) {
                      // Ambil data kategori dari widget (null safety)
                      List<Map<String, dynamic>> listKategori =
                          widget.tukangData.kategoriList ?? [];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Kategori Keahlian',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                listKategori
                                    .map(
                                      (kategori) => Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFF8E1),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: const Color(0xFFFFE0B2),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.category_outlined,
                                              size: 16,
                                              color: Color(0xFF6D4C41),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              kategori['nama']?.toString() ??
                                                  'N/A',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF6D4C41),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                    .toList(),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Pilih Jenis Layanan (dari keahlian spesifik tukang)
                  const Text(
                    'Jenis Layanan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (_isLoadingKeahlian)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: const Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 12),
                          Text('Memuat layanan...'),
                        ],
                      ),
                    )
                  else if (_daftarKeahlian.isNotEmpty)
                    DropdownButtonFormField<String>(
                      initialValue: _selectedLayanan,
                      isExpanded: true,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        hintText: 'Pilih jenis layanan',
                        errorStyle: const TextStyle(fontSize: 12),
                      ),
                      items:
                          _daftarKeahlian
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Pilih salah satu jenis layanan';
                        }
                        return null;
                      },
                    )
                  else
                    // Manual input jika tidak ada keahlian dari API
                    TextFormField(
                      controller: _judulLayananManualController,
                      decoration: const InputDecoration(
                        labelText: 'Judul Layanan (Manual)',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Masukkan judul layanan',
                        helperText:
                            'Tukang belum menambahkan keahlian, masukkan manual',
                        helperStyle: TextStyle(color: Colors.orange),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Judul layanan harus diisi';
                        }
                        return null;
                      },
                    ),

                  const SizedBox(height: 16),

                  // Deskripsi Layanan (auto-generated)
                  if (_selectedLayanan != null ||
                      _judulLayananManualController.text.isNotEmpty)
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
                                'Layanan ${_selectedLayanan ?? _judulLayananManualController.text} oleh ${widget.tukangData.nama}',
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
                      items:
                          List.generate(12, (index) => index + 1)
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
                                            color:
                                                _metodePembayaran == 'poin'
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
                                            color:
                                                _metodePembayaran == 'tunai'
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
                      child:
                          _isLoading
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
