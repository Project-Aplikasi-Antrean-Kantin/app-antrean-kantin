# TimePicker Widget

`TimePicker` adalah widget kustom dan *reusable* (dapat digunakan kembali) yang dibangun dengan Flutter. Widget ini menyediakan antarmuka interaktif yang memudahkan pengguna untuk memilih waktu menggunakan `showTimePicker` bawaan Material Design.

Widget ini menampilkan sebuah `TextFormField` *read-only* (hanya baca) yang bersanding dengan tombol ikon jam. Keduanya dapat diklik untuk memunculkan dialog pemilihan waktu.

---

## 🎯 Fitur Utama

* **Integrasi Native Picker:** Menggunakan `showTimePicker` dari Material Design Flutter untuk pengalaman pengguna yang familier.
* **Desain Kustom:** Dilengkapi dengan styling kustom menggunakan `GoogleFonts` dan border radius yang membulat (20px).
* **Ikon Interaktif:** Menggunakan paket `hugeicons` (`strokeRoundedClock02`) sebagai tombol pemicu alternatif di sebelah *text field*.
* **Format Otomatis:** Memformat waktu yang dipilih secara otomatis menjadi string dengan format `HH:mm:00`.

---

## 📦 Dependencies (Ketergantungan)

Pastikan *packages* dan *files* berikut sudah tersedia dan terkonfigurasi di dalam proyek Anda:

* `flutter/material.dart`
* `google_fonts` (Package)
* `hugeicons` (Package)
* `AppColors` (Dari `testgetdata/core/theme/colors_theme.dart`)

*(Catatan: Import `custom_form_field.dart` saat ini tidak digunakan secara langsung di dalam blok kode widget ini dan dapat dihapus jika memang tidak diperlukan).*

---

## ⚙️ Properti (Parameter)

Widget ini menerima beberapa parameter yang wajib diisi (*required*):

| Parameter | Tipe Data | Deskripsi |
| :--- | :--- | :--- |
| `label` | `String` | Label untuk *picker*. *(Catatan: Parameter ini dilempar ke konstruktor namun belum diimplementasikan ke dalam UI di kode saat ini)*. |
| `selectedTime` | `String` | Nilai waktu saat ini yang ditampilkan pada *text field*. Format string harus berupa `HH:mm` atau `HH:mm:ss`. |
| `onTimeChanged` | `Function(String)` | *Callback function* yang akan memicu perubahan state ketika pengguna selesai memilih waktu yang baru. |

---

## 🚀 Cara Penggunaan (Contoh)

Berikut adalah contoh bagaimana mengimplementasikan widget `TimePicker` di dalam sebuah `StatefulWidget`:

```dart
import 'package:flutter/material.dart';
// Sesuaikan import dengan lokasi file TimePicker Anda
import 'package:your_app/widgets/time_picker.dart'; 

class MyFormScreen extends StatefulWidget {
  @override
  _MyFormScreenState createState() => _MyFormScreenState();
}

class _MyFormScreenState extends State<MyFormScreen> {
  // 1. Definisikan state untuk menyimpan waktu yang dipilih
  String mySelectedTime = "08:30:00"; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contoh Penggunaan TimePicker')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 2. Panggil widget TimePicker
            TimePicker(
              label: "Waktu Mulai",
              selectedTime: mySelectedTime,
              onTimeChanged: (newTime) {
                // 3. Perbarui state ketika waktu baru dipilih
                setState(() {
                  mySelectedTime = newTime;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

```
# StepProgress Widget

`StepProgress` adalah widget kustom berbasis `StatefulWidget` yang berfungsi untuk menampilkan indikator proses (langkah demi langkah) secara horizontal. Widget ini dilengkapi dengan animasi garis progres yang berjalan (*looping*) pada langkah yang sedang aktif dan fitur *tooltip* interaktif.

Widget ini sangat cocok digunakan untuk melacak status pesanan, pengiriman, atau proses *checkout*.

---

## 🎯 Fitur Utama

* **Animasi Progres:** Garis penghubung ke langkah yang sedang aktif memiliki animasi pergerakan secara *real-time*.
* **Tooltip Interaktif:** Menggunakan `Tooltip` bawaan Flutter yang memunculkan teks judul (`title`) dari setiap langkah saat ikon di-tap.
* **Indikator Warna Dinamis:** Otomatis mengubah warna ikon dan garis berdasarkan status penyelesaian:
  * Selesai (*Completed*): Warna info/sukses (`AppColors.infoColor`).
  * Belum dicapai (*Pending*): Abu-abu.
* **Status Khusus Refund:** Terdapat parameter `isRefund` yang jika bernilai `true`, akan menghentikan animasi progres dan mengubah warna *step* ke-2 (index 1) menjadi merah (`AppColors.errorColor`).

---

## 📦 Dependencies (Ketergantungan)

Pastikan *packages* dan *files* berikut tersedia di proyek Anda:

* `flutter/material.dart`
* `hugeicons` (Package)
* `AppColors` (Dari `testgetdata/core/theme/colors_theme.dart`)
* `StepModel` (Dari `testgetdata/data/model/step_model.dart` - *pastikan model ini memiliki properti `title` dan `icon`*).

*(Catatan: Import `iconsax_flutter` saat ini tidak digunakan di dalam blok kode widget ini dan dapat dihapus jika tidak diperlukan).*

---

## ⚙️ Properti (Parameter)

| Parameter | Tipe Data | Deskripsi | Default |
| :--- | :--- | :--- | :--- |
| `currentStep` | `int` | **[Wajib]** Menentukan langkah mana yang sedang aktif saat ini. Berjalan berdasarkan panjang list `steps`. | - |
| `steps` | `List<StepModel>` | **[Wajib]** Daftar model langkah yang berisi informasi seperti judul (*title*) dan ikon (*icon*). | - |
| `isRefund` | `bool` | *[Opsional]* Flag khusus. Jika `true`, garis animasi berhenti dan *step* dengan index 1 menjadi warna *error*. | `false` |

---

## 🚀 Cara Penggunaan (Contoh)

Berikut adalah contoh cara mengimplementasikan widget `StepProgress` di halaman Anda:

```dart
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
// Sesuaikan import di bawah ini:
import 'package:your_app/widgets/step_progress.dart';
import 'package:your_app/models/step_model.dart'; 

class OrderTrackerScreen extends StatefulWidget {
  @override
  _OrderTrackerScreenState createState() => _OrderTrackerScreenState();
}

class _OrderTrackerScreenState extends State<OrderTrackerScreen> {
  // 1. Definisikan langkah-langkahnya (sesuaikan dengan struktur StepModel Anda)
  final List<StepModel> mySteps = [
    StepModel(title: "Pesanan Dibuat", icon: HugeIcons.strokeRoundedPackage),
    StepModel(title: "Diproses", icon: HugeIcons.strokeRoundedSettings01),
    StepModel(title: "Dikirim", icon: HugeIcons.strokeRoundedTruck01),
    StepModel(title: "Selesai", icon: HugeIcons.strokeRoundedCheckmarkBadge01),
  ];

  int activeStep = 2; // Berarti sedang di tahap "Diproses" menuju "Dikirim"
  bool isRefunded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lacak Pesanan')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 2. Panggil widget StepProgress
            StepProgress(
              currentStep: activeStep,
              steps: mySteps,
              isRefund: isRefunded,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isRefunded = !isRefunded;
                });
              },
              child: Text(isRefunded ? 'Batalkan Refund' : 'Simulasikan Refund'),
            )
          ],
        ),
      ),
    );
  }
}
```

# ImageByUrl Widget

`ImageByUrl` adalah komponen UI (*reusable widget*) berbasis `StatefulWidget` yang bertugas untuk memuat gambar dari URL jaringan, mengunduhnya, dan menyimpannya ke dalam *cache* lokal (menggunakan `ImageCacheManager`). 

Widget ini secara otomatis akan menampilkan *placeholder* saat gambar sedang dimuat, dan menampilkan *error widget* (atau gambar *dummy* bawaan) jika proses pemuatan gagal.

---

## 🎯 Fitur Utama

* **Sistem Caching Otomatis:** Terintegrasi dengan `ImageCacheManager` untuk memastikan gambar yang sama tidak perlu diunduh berulang kali.
* **Pembersihan URL (*URL Sanitization*):** Mampu mendeteksi dan menghapus `MasbroConstants.baseUrl` secara otomatis untuk mencegah pemanggilan URL yang ganda/salah.
* **Penanganan Error Bawaan:** Memiliki filter khusus untuk menolak pemanggilan gambar *default* bawaan server (`/assets/images/default-image.jpg`) dan melempar *error* agar gambar *dummy* lokal yang ditampilkan.
* **Fleksibel:** Mendukung kustomisasi ukuran (`width`, `height`), jenis *fitting* gambar (`BoxFit`), serta menyediakan ruang untuk widget `placeholder` dan `errorWidget` kustom.

---

## 📦 Dependencies (Ketergantungan)

Pastikan file dan *assets* berikut tersedia di proyek Anda:

* `dart:io` (Untuk menangani objek `File`).
* `flutter/material.dart`
* `MasbroConstants` (Dari `testgetdata/data/constants.dart`).
* `ImageCacheManager` (Dari `testgetdata/utils/image_cache_manager.dart`).
* **Asset Gambar Lokal:** Pastikan Anda memiliki gambar `assets/images/dummy.jpeg` yang terdaftar di `pubspec.yaml` sebagai gambar *fallback* (cadangan).

---

## ⚙️ Properti (Parameter)

| Parameter | Tipe Data | Deskripsi | Default |
| :--- | :--- | :--- | :--- |
| `url` | `String` | **[Wajib]** URL atau *path* gambar yang akan dimuat. | - |
| `width` | `double` | Lebar dari gambar yang ditampilkan. | `100` |
| `height` | `double` | Tinggi dari gambar yang ditampilkan. | `100` |
| `fit` | `BoxFit` | Menentukan bagaimana gambar disesuaikan ke dalam kotak ruangnya. | `BoxFit.cover` |
| `placeholder` | `Widget?` | Widget kustom yang tampil selama proses memuat (*loading*). | Gambar `dummy.jpeg` |
| `errorWidget` | `Widget?` | Widget kustom yang tampil jika gambar gagal dimuat. | Gambar `dummy.jpeg` |

---

## 🚀 Cara Penggunaan (Contoh)

Berikut adalah contoh implementasi `ImageByUrl` di dalam halaman aplikasi:

```dart
import 'package:flutter/material.dart';
// Sesuaikan import dengan struktur folder Anda
import 'package:your_app/widgets/image_by_url.dart';

class ProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // 1. Penggunaan bawaan (Default)
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: const ImageByUrl(
              url: '[https://example.com/user/profile.jpg](https://example.com/user/profile.jpg)',
              width: 80,
              height: 80,
            ),
          ),
          const SizedBox(width: 16),
          // 2. Penggunaan dengan Placeholder dan Error Widget Kustom
          const Expanded(
            child: ImageByUrl(
              url: '/api/v1/product/123.png', // Akan otomatis disanitasi jika ada baseUrl
              width: double.infinity,
              height: 150,
              fit: BoxFit.contain,
              placeholder: Center(child: CircularProgressIndicator()),
              errorWidget: Center(child: Icon(Icons.broken_image, color: Colors.red)),
            ),
          ),
        ],
      ),
    );
  }
}
```
# ItemCart Widget

`ItemCart` adalah komponen *Organism* berbasis `StatelessWidget` yang berfungsi untuk menampilkan baris item di dalam keranjang belanja (*cart*). Widget ini merangkai beberapa komponen lebih kecil (seperti gambar, informasi produk, dan tombol *counter*) menjadi satu antarmuka yang kohesif.

---

## 🎯 Fitur Utama

* **Pendekatan Atomic Design:** Menggabungkan komponen eksternal terpisah seperti `BuildImageItemCart` (gambar item), `InfoItemCart` (teks dan tombol *edit*), dan `Counter` (*molecule* untuk mengatur jumlah).
* **Kalkulasi Harga Dinamis:** Menghitung total harga per item secara otomatis (`harga * jumlah`) dan memformatnya menjadi string mata uang menggunakan `FormatCurrency`.
* **Layout Responsif & Anti-Overflow:** Menggunakan `ConstrainedBox` untuk membatasi lebar bagian teks maksimal setengah dari lebar layar (layar dibagi dua agar bagian *Counter* tidak tergeser keluar batas layar).
* **Delegasi State (*State Delegation*):** Sebagai widget *stateless*, komponen ini mendelegasikan semua perubahan data (*increment*, *decrement*, ubah nilai manual) ke *parent widget* melalui *callback*.

---

## 📦 Dependencies (Ketergantungan)

Pastikan *packages* dan komponen internal berikut tersedia di dalam proyek:

* `flutter/material.dart`
* `google_fonts` (Package)
* `CartMenuModel` (Dari `testgetdata/data/model/cart_menu_modelllll.dart` - *Catatan: pastikan penamaan file ini (`modelllll`) memang disengaja atau perlu di-rename*).
* `FormatCurrency` (Utility format uang).
* `Counter` (Komponen *Molecules*).
* `BuildImageItemCart` & `InfoItemCart` (Sub-komponen *Organisms*).

---

## ⚙️ Properti (Parameter)

Widget ini membutuhkan beberapa parameter wajib untuk berfungsi:

| Parameter | Tipe Data | Deskripsi |
| :--- | :--- | :--- |
| `item` | `CartMenuModel` | **[Wajib]** Data model yang memuat informasi menu (nama, harga, jumlah saat ini). |
| `onEdit` | `VoidCallback` | **[Wajib]** Fungsi yang dipanggil ketika pengguna ingin mengedit *notes* atau varian item (diteruskan ke `InfoItemCart`). |
| `onIncrement` | `VoidCallback` | **[Wajib]** Fungsi penambah jumlah item (diteruskan ke `Counter`). |
| `onDecrement` | `VoidCallback` | **[Wajib]** Fungsi pengurang jumlah item (diteruskan ke `Counter`). |
| `onCountChanged` | `ValueChanged<int>`| **[Wajib]** Fungsi untuk menangani perubahan jumlah secara langsung/manual (diteruskan ke `Counter`). |

---

## 🚀 Cara Penggunaan (Contoh)

Berikut adalah contoh penggunaan `ItemCart` di dalam sebuah `ListView.builder` pada halaman keranjang:

```dart
import 'package:flutter/material.dart';
// Sesuaikan import dengan struktur folder Anda
import 'package:your_app/widgets/organisms/item_cart.dart';
import 'package:your_app/models/cart_menu_model.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Contoh list data keranjang
  List<CartMenuModel> cartItems = [
    CartMenuModel(id: '1', name: 'Nasi Goreng', menuPrice: 20000, count: 2),
    CartMenuModel(id: '2', name: 'Es Teh Manis', menuPrice: 5000, count: 1),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Keranjang Pesanan')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: cartItems.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final currentItem = cartItems[index];

          return ItemCart(
            item: currentItem,
            onEdit: () {
              // Logika memunculkan modal/dialog edit varian
              print("Edit item: ${currentItem.name}");
            },
            onIncrement: () {
              setState(() => currentItem.count++);
            },
            onDecrement: () {
              if (currentItem.count > 1) {
                setState(() => currentItem.count--);
              }
            },
            onCountChanged: (newValue) {
              setState(() => currentItem.count = newValue);
            },
          );
        },
      ),
    );
  }
}
```
