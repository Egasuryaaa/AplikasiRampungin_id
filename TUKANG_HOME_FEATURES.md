# Dokumentasi Fitur Home Screen Tukang

## Overview
Home screen tukang memiliki 2 fitur utama untuk manajemen pesanan dan ketersediaan:
1. **Availability Toggle** - Mengubah status ketersediaan tukang
2. **Order Management** - Mengelola pesanan dengan action buttons berdasarkan status

---

## 1. Availability Status Selector (3 Categories)

### Lokasi UI
**File**: `lib/tukang_screens/content_bottom/home.dart`

Dropdown selector berada di header gradient (top section), sebelah kiri logout button.

### State Management
```dart
// State variables
String _availabilityStatus = 'tersedia'; // 'tersedia', 'sibuk', 'offline'
bool _isUpdatingAvailability = false;
```

### 3 Kategori Status
1. **Tersedia** (hijau) - Siap menerima pesanan baru
2. **Sibuk** (oranye) - Sedang ada pekerjaan, tidak bisa terima order
3. **Offline** (abu-abu) - Tidak aktif/istirahat

### Load Initial Status
```dart
Future<void> _loadProfile() async {
  try {
    final profile = await _tukangService.getProfileFull();
    if (mounted && profile.profilTukang != null) {
      setState(() {
        _availabilityStatus = profile.profilTukang!.statusKetersediaan ?? 'tersedia';
      });
    }
  } catch (e) {
    // Silently fail
  }
}
```

**Called in**: `initState()` → `_loadInitialData()`

### Update Availability
```dart
Future<void> _updateAvailability(String newStatus) async {
  setState(() { _isUpdatingAvailability = true; });
  
  try {
    await _tukangService.updateAvailability(newStatus);
    
    if (mounted) {
      setState(() {
        _availabilityStatus = newStatus;
        _isUpdatingAvailability = false;
      });
      
      String message;
      Color bgColor;
      
      switch (newStatus) {
        case 'tersedia':
          message = '✅ Status diubah menjadi Tersedia';
          bgColor = Colors.green;
          break;
        case 'sibuk':
          message = '⏱️ Status diubah menjadi Sibuk';
          bgColor = Colors.orange;
          break;
        case 'offline':
          message = '⏸️ Status diubah menjadi Offline';
          bgColor = Colors.grey;
          break;
        default:
          message = '✅ Status berhasil diubah';
          bgColor = Colors.blue;
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: bgColor),
      );
    }
  } catch (e) {
    // Show error snackbar & reset loading state
    setState(() { _isUpdatingAvailability = false; });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('❌ Gagal mengubah status: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
```

### UI Component (Dropdown Selector)
```dart
InkWell(
  onTap: _isUpdatingAvailability ? null : _showAvailabilityMenu,
  child: Container(
    decoration: BoxDecoration(
      color: _getAvailabilityColor().withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: _getAvailabilityColor(), width: 1.5),
    ),
    child: Row(
      children: [
        Icon(_getAvailabilityIcon(), color: _getAvailabilityColor()),
        Text(_getAvailabilityText()),
        Icon(Icons.arrow_drop_down),
      ],
    ),
  ),
)
```

### Helper Methods
```dart
Color _getAvailabilityColor() {
  switch (_availabilityStatus) {
    case 'tersedia': return Colors.green;
    case 'sibuk': return Colors.orange;
    case 'offline': return Colors.grey;
    default: return Colors.blue;
  }
}

IconData _getAvailabilityIcon() {
  switch (_availabilityStatus) {
    case 'tersedia': return Icons.check_circle;
    case 'sibuk': return Icons.access_time;
    case 'offline': return Icons.pause_circle;
    default: return Icons.help_outline;
  }
}

String _getAvailabilityText() {
  switch (_availabilityStatus) {
    case 'tersedia': return 'Tersedia';
    case 'sibuk': return 'Sibuk';
    case 'offline': return 'Offline';
    default: return 'Unknown';
  }
}
```

### Bottom Sheet Menu
```dart
void _showAvailabilityMenu() {
  showModalBottomSheet(
    context: context,
    builder: (context) => Column(
      children: [
        Text('Ubah Status Ketersediaan'),
        _buildAvailabilityOption('tersedia', 'Tersedia', Icons.check_circle, Colors.green),
        _buildAvailabilityOption('sibuk', 'Sibuk', Icons.access_time, Colors.orange),
        _buildAvailabilityOption('offline', 'Offline', Icons.pause_circle, Colors.grey),
      ],
    ),
  );
}

Widget _buildAvailabilityOption(String value, String label, IconData icon, Color color) {
  final isSelected = _availabilityStatus == value;
  return ListTile(
    leading: Icon(icon, color: color),
    title: Text(label, style: TextStyle(
      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
    )),
    trailing: isSelected ? Icon(Icons.check, color: color) : null,
    onTap: () {
      Navigator.pop(context);
      if (_availabilityStatus != value) {
        _updateAvailability(value);
      }
    },
  );
}
```

### Backend API
**Endpoint**: `PUT /api/tukang/availability`

**Service Method**: `TukangService.updateAvailability(String statusKetersediaan)`

**Request Body**:
```json
{
  "status_ketersediaan": "tersedia" // "tersedia", "sibuk", atau "offline"
}
```

**Response**:
```json
{
  "status": "success",
  "message": "Status ketersediaan berhasil diupdate",
  "data": {
    "id_tukang": 1,
    "status_ketersediaan": "tersedia",
    "updated_at": "2024-01-15 10:30:00"
  }
}
```

---

## 2. Order Management with Filter & Actions

### State Management
```dart
// State variables
String _selectedFilter = 'pending'; // Filter saat ini
List<TransactionModel> _pendingOrders = []; // Daftar pesanan
bool _isLoadingData = true; // Loading state
```

### Filter Status
4 filter yang tersedia:
- **pending** → "Baru"
- **diterima** → "Diterima"
- **dalam_proses** → "Dikerjakan"
- **selesai** → "Selesai"

### Load Orders with Filter
```dart
Future<void> _loadOrders() async {
  try {
    final orders = await _tukangService.getOrders(status: _selectedFilter);
    if (mounted) {
      setState(() {
        _pendingOrders = orders;
      });
    }
  } catch (e) {
    // Silently fail
  }
}
```

### Refresh Orders
```dart
void _refreshOrders() {
  setState(() { _isLoadingData = true; });
  _loadOrders().then((_) {
    if (mounted) {
      setState(() { _isLoadingData = false; });
    }
  });
}
```

**Called after**: Accept, Reject, Start, Complete, Confirm Tunai actions

### Filter Chip UI
```dart
Widget _buildFilterChip(String label, String value) {
  final isSelected = _selectedFilter == value;
  return InkWell(
    onTap: () {
      setState(() {
        _selectedFilter = value;
        _isLoadingData = true;
      });
      _loadOrders().then((_) {
        if (mounted) {
          setState(() { _isLoadingData = false; });
        }
      });
    },
    child: Container(
      decoration: BoxDecoration(
        gradient: isSelected 
          ? LinearGradient(colors: [Color(0xFFF3B950), Color(0xFFE8A63C)])
          : null,
        color: isSelected ? null : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label),
    ),
  );
}
```

### Order List UI
```dart
// Dalam build() method
_isLoadingData
  ? CircularProgressIndicator()
  : _pendingOrders.isEmpty
    ? Text('Tidak ada pesanan')
    : ListView.builder(
        itemCount: _pendingOrders.length,
        itemBuilder: (context, index) {
          return _buildJobOrderItem(_pendingOrders[index]);
        },
      )
```

---

## 3. Order Action Buttons by Status

### Mapping Status → Actions

| Status | Buttons | Actions |
|--------|---------|---------|
| `pending` | Terima (green) + Tolak (red) | `_acceptOrder()` / `_rejectOrder()` |
| `diterima` | Mulai Pekerjaan (blue) | `_startOrder()` |
| `dalam_proses` | Selesaikan Pekerjaan (green) | `_completeOrder()` |
| `selesai` + `tunai` | Konfirmasi Bayar Tunai (gold) | `_confirmTunaiPayment()` |

### Action Implementation

#### 1. Accept Order
```dart
Future<void> _acceptOrder(int orderId) async {
  try {
    await _tukangService.acceptOrder(orderId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Pesanan berhasil diterima')),
      );
      _refreshOrders();
    }
  } catch (e) {
    // Show error
  }
}
```

**Backend**: `PUT /api/tukang/orders/{id}/accept`

#### 2. Reject Order (with reason dialog)
```dart
Future<void> _rejectOrder(int orderId) async {
  final TextEditingController reasonController = TextEditingController();
  
  // Show dialog
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Tolak Pesanan'),
      content: TextField(
        controller: reasonController,
        decoration: InputDecoration(
          labelText: 'Alasan Penolakan',
          hintText: 'Masukkan alasan penolakan...',
        ),
        maxLines: 3,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            if (reasonController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Alasan tidak boleh kosong')),
              );
              return;
            }
            Navigator.pop(context, true);
          },
          child: Text('Tolak'),
        ),
      ],
    ),
  );
  
  // Call API if confirmed
  if (result == true && reasonController.text.trim().isNotEmpty) {
    try {
      await _tukangService.rejectOrder(orderId, reasonController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Pesanan berhasil ditolak')),
        );
        _refreshOrders();
      }
    } catch (e) {
      // Show error
    }
  }
}
```

**Backend**: `PUT /api/tukang/orders/{id}/reject`

**Request Body**:
```json
{
  "alasan_penolakan": "Jadwal tidak tersedia"
}
```

#### 3. Start Order
```dart
Future<void> _startOrder(int orderId) async {
  try {
    await _tukangService.startOrder(orderId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Pekerjaan dimulai')),
      );
      _refreshOrders();
    }
  } catch (e) {
    // Show error
  }
}
```

**Backend**: `PUT /api/tukang/orders/{id}/start`

#### 4. Complete Order
```dart
Future<void> _completeOrder(int orderId) async {
  try {
    await _tukangService.completeOrder(orderId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Pekerjaan selesai')),
      );
      _refreshOrders();
    }
  } catch (e) {
    // Show error
  }
}
```

**Backend**: `PUT /api/tukang/orders/{id}/complete`

**Optional Parameter**: `catatan_tukang` (String)

#### 5. Confirm Tunai Payment
```dart
Future<void> _confirmTunaiPayment(int orderId) async {
  try {
    await _tukangService.confirmTunaiPayment(orderId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Pembayaran tunai dikonfirmasi')),
      );
      _refreshOrders();
    }
  } catch (e) {
    // Show error
  }
}
```

**Backend**: `PUT /api/tukang/orders/{id}/confirm-tunai`

**Condition**: Hanya tampil jika `status == 'selesai'` DAN `metodePembayaran == 'tunai'`

### Action Button Builder
```dart
Widget _buildOrderActionButtons(TransactionModel order) {
  final status = order.statusPesanan?.toLowerCase() ?? '';
  
  if (status == 'pending') {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _rejectOrder(order.id!),
            icon: Icon(Icons.close),
            label: Text('Tolak'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _acceptOrder(order.id!),
            icon: Icon(Icons.check),
            label: Text('Terima'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
        ),
      ],
    );
  } else if (status == 'diterima') {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _startOrder(order.id!),
        icon: Icon(Icons.play_arrow),
        label: Text('Mulai Pekerjaan'),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
      ),
    );
  } else if (status == 'dalam_proses') {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _completeOrder(order.id!),
        icon: Icon(Icons.check_circle),
        label: Text('Selesaikan Pekerjaan'),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
      ),
    );
  } else if (status == 'selesai' && 
             order.metodePembayaran?.toLowerCase() == 'tunai') {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _confirmTunaiPayment(order.id!),
        icon: Icon(Icons.payments),
        label: Text('Konfirmasi Bayar Tunai'),
        style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFF3B950)),
      ),
    );
  }
  
  return SizedBox.shrink();
}
```

### Order Item Card UI
```dart
Widget _buildJobOrderItem(TransactionModel order) {
  // Status badge dengan warna dinamis
  Color statusColor;
  String statusText;
  
  switch (order.statusPesanan?.toLowerCase()) {
    case 'pending':
      statusColor = Colors.orange;
      statusText = 'Menunggu';
      break;
    case 'diterima':
      statusColor = Colors.blue;
      statusText = 'Diterima';
      break;
    case 'dalam_proses':
      statusColor = Colors.purple;
      statusText = 'Dikerjakan';
      break;
    case 'selesai':
      statusColor = Colors.green;
      statusText = 'Selesai';
      break;
    default:
      statusColor = Colors.grey;
      statusText = order.statusPesanan ?? 'Unknown';
  }
  
  return Container(
    child: Column(
      children: [
        // Order Info
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DetailOrder()),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF8B4513), Color(0xFF7A3E0F)],
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Icon(Icons.person, color: Colors.white),
                ),
                
                SizedBox(width: 16),
                
                // Order Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.judulLayanan ?? 'Pesanan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(order.namaClient ?? 'Client'),
                      Text('Rp ${order.hargaAkhir?.toStringAsFixed(0) ?? '0'}'),
                    ],
                  ),
                ),
                
                // Status Badge
                Container(
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(statusText, style: TextStyle(color: statusColor)),
                ),
              ],
            ),
          ),
        ),
        
        // Action Buttons
        _buildOrderActionButtons(order),
      ],
    ),
  );
}
```

---

## Service Layer (TukangService)

All methods already implemented in `lib/services/tukang_service.dart`:

### 1. Update Availability
```dart
Future<Map<String, dynamic>> updateAvailability(String statusKetersediaan) async {
  return await _apiClient.put(
    '/tukang/availability',
    body: {'status_ketersediaan': statusKetersediaan},
  );
}
```

### 2. Get Orders with Filter
```dart
Future<List<TransactionModel>> getOrders({String? status, ...}) async {
  final queryParams = <String, dynamic>{};
  if (status != null) queryParams['status'] = status;
  
  final response = await _apiClient.get(
    '/tukang/orders',
    queryParameters: queryParams,
  );
  
  final orders = (response['data'] as List)
      .map((json) => TransactionModel.fromJson(json))
      .toList();
  return orders;
}
```

### 3. Accept Order
```dart
Future<Map<String, dynamic>> acceptOrder(int orderId) async {
  return await _apiClient.put('/tukang/orders/$orderId/accept');
}
```

### 4. Reject Order
```dart
Future<Map<String, dynamic>> rejectOrder(int orderId, String alasanPenolakan) async {
  return await _apiClient.put(
    '/tukang/orders/$orderId/reject',
    body: {'alasan_penolakan': alasanPenolakan},
  );
}
```

### 5. Start Order
```dart
Future<Map<String, dynamic>> startOrder(int orderId) async {
  return await _apiClient.put('/tukang/orders/$orderId/start');
}
```

### 6. Complete Order
```dart
Future<Map<String, dynamic>> completeOrder(int orderId, {String? catatanTukang}) async {
  final body = catatanTukang != null ? {'catatan_tukang': catatanTukang} : null;
  return await _apiClient.put('/tukang/orders/$orderId/complete', body: body);
}
```

### 7. Confirm Tunai Payment
```dart
Future<Map<String, dynamic>> confirmTunaiPayment(int orderId) async {
  return await _apiClient.put('/tukang/orders/$orderId/confirm-tunai');
}
```

---

## Model: TransactionModel

**File**: `lib/models/transaction_model.dart`

### Key Fields untuk Order Management
```dart
class TransactionModel {
  final int? id;
  final String? nomorPesanan;
  final String? namaClient;
  final String? judulLayanan;
  final String? statusPesanan; // 'pending', 'diterima', 'dalam_proses', 'selesai', 'dibatalkan', 'ditolak'
  final String? metodePembayaran; // 'poin' or 'tunai'
  final double? hargaAkhir;
  final String? catatanClient;
  final String? catatanTukang;
  // ... other fields
}
```

### fromJson Mapping
Backend field → Flutter field:
- `status` → `statusPesanan`
- `total_biaya` → `hargaAkhir`
- `metode_pembayaran` → `metodePembayaran`

---

## Testing Checklist

### Availability Status Selector
- [ ] Initial status loads correctly from API (tersedia/sibuk/offline)
- [ ] Dropdown button shows current status with correct color and icon
- [ ] Bottom sheet menu shows all 3 options
- [ ] Tapping option closes menu and updates status
- [ ] API call updates backend status
- [ ] Success snackbar shows correct message for each status
- [ ] Error handling shows error snackbar
- [ ] Disabled state during API call (no double-tap)
- [ ] Status persists after app restart
- [ ] Selected option shows checkmark in menu

### Order Filter
- [ ] All 4 filter chips render correctly
- [ ] Selected filter has gold gradient
- [ ] Tapping filter fetches filtered orders
- [ ] Loading indicator shows during fetch
- [ ] Empty state shows when no orders

### Order Actions - Pending
- [ ] Two buttons (Terima/Tolak) show for pending orders
- [ ] Accept button updates status to 'diterima'
- [ ] Reject button shows dialog
- [ ] Reject dialog validates empty reason
- [ ] Reject API call includes reason
- [ ] Order list refreshes after action

### Order Actions - Diterima
- [ ] Single "Mulai Pekerjaan" button shows
- [ ] Button updates status to 'dalam_proses'
- [ ] Success snackbar shows
- [ ] Order moves to "Dikerjakan" filter

### Order Actions - Dalam Proses
- [ ] Single "Selesaikan Pekerjaan" button shows
- [ ] Button updates status to 'selesai'
- [ ] Order moves to "Selesai" filter

### Order Actions - Selesai (Tunai)
- [ ] "Konfirmasi Bayar Tunai" button only shows for tunai orders
- [ ] Button calls confirm-tunai endpoint
- [ ] Button disappears after confirmation
- [ ] Non-tunai orders don't show button

### UI/UX
- [ ] Smooth animations on state changes
- [ ] No jank when switching filters
- [ ] Error states are user-friendly
- [ ] Consistent color scheme (green/orange/blue/gold)
- [ ] Responsive on different screen sizes

---

## Known Issues & Future Enhancements

### Current Limitations
1. **No Refresh Indicator**: User must manually switch filters to refresh
2. **No Filter Badge Count**: Can't see how many orders per status
3. **No Pagination**: All orders load at once (may be slow for many orders)
4. **No Order Detail Integration**: Action buttons should pass order data to detail screen

### Recommended Enhancements
1. Add pull-to-refresh on order list
2. Show count badges on filter chips (e.g., "Baru (5)")
3. Implement pagination/infinite scroll for large order lists
4. Add confirmation dialog for "Selesaikan Pekerjaan"
5. Show order details in-place (expandable card) before navigating to detail screen
6. Add optional note input for "Complete Order" action
7. Cache filter state (persist selected filter)
8. Add real-time updates (WebSocket/polling) for new orders

---

## Related Documentation
- **Backend API**: See `listapi.txt` (Endpoints 23-30)
- **Photo Upload**: See `BACKEND_UPLOAD_HANDLER.md`
- **Service Layer**: See `lib/services/tukang_service.dart`
- **Models**: See `lib/models/transaction_model.dart`

---

*Last Updated: 2024-01-15*
*Feature Implementation: Tukang Home Screen Order Management & Availability Toggle*
