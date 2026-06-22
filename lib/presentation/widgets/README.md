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
# ItemOption Widget

`ItemOption` adalah komponen *Molecule* berbasis `StatelessWidget` yang berfungsi sebagai kartu pilihan interaktif (mirip dengan *radio button* kustom). Widget ini sangat cocok digunakan untuk menampilkan daftar pilihan tunggal, seperti varian menu, ukuran porsi, atau tambahan *topping* dalam aplikasi.

---

## 🎯 Fitur Utama

* **Desain Interaktif & Dinamis:** Seluruh area kartu dapat diklik menggunakan `GestureDetector`. Warna *border* (garis tepi) secara otomatis berubah menjadi warna primer (`AppColors.primaryColor`) ketika item sedang dipilih.
* **Layout Terstruktur (Flexbox):** Memanfaatkan widget `Expanded` dengan rasio `flex: 3` (untuk judul & deskripsi) dan `flex: 1` (untuk harga & tombol radio) guna memastikan teks yang panjang tidak merusak tata letak *UI*.
* **Modular (Atomic Design):** Terintegrasi langsung dengan komponen *Atom* `RadioCircle`, memastikan konsistensi desain indikator pilihan di seluruh aplikasi.
* **Properti Opsional:** Mendukung penambahan `leadingIcon` (ikon awalan) dan `description` (teks detail) yang bersifat opsional, membuatnya fleksibel untuk berbagai kebutuhan tampilan.

---

## 📦 Dependencies (Ketergantungan)

Pastikan *packages* dan komponen internal berikut telah dikonfigurasi di dalam proyek Anda:

* `flutter/material.dart`
* `google_fonts` (Package)
* `AppColors` (Dari `testgetdata/core/theme/colors_theme.dart`).
* `RadioCircle` (Dari `testgetdata/presentation/widgets/atoms/radio_circle.dart` - Komponen *Atom* untuk indikator lingkaran).

---

## ⚙️ Properti (Parameter)

| Parameter | Tipe Data | Deskripsi | Status |
| :--- | :--- | :--- | :--- |
| `isSelected` | `bool` | Menentukan apakah kartu ini sedang dalam keadaan terpilih aktif atau tidak. | **Wajib** |
| `title` | `String` | Teks utama yang ditampilkan (contoh: "Es Teh Manis" atau "Ukuran Large"). | **Wajib** |
| `price` | `String` | Teks harga atau biaya tambahan (contoh: "+ Rp 5.000"). | **Wajib** |
| `onTap` | `VoidCallback` | Fungsi yang dijalankan ketika seluruh area kartu disentuh/diklik. | **Wajib** |
| `leadingIcon` | `IconData?` | Ikon opsional yang muncul di sebelah kiri `title`. | *Opsional* |
| `description` | `String?` | Teks deskripsi opsional yang muncul di bawah `title`. | *Opsional* |

---

## 🚀 Cara Penggunaan (Contoh)

Berikut adalah contoh implementasi `ItemOption` untuk memilih varian ukuran minuman menggunakan manajemen *state* lokal:

```dart
import 'package:flutter/material.dart';
// Sesuaikan import dengan struktur folder proyek Anda
import 'package:your_app/widgets/molecules/item_option.dart';

class VariantSelectionScreen extends StatefulWidget {
  @override
  _VariantSelectionScreenState createState() => _VariantSelectionScreenState();
}

class _VariantSelectionScreenState extends State<VariantSelectionScreen> {
  // Menyimpan ID atau nama opsi yang sedang dipilih
  String selectedSize = "Regular"; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pilih Ukuran')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ItemOption(
              title: "Regular",
              description: "Ukuran standar 16oz",
              price: "Rp 0",
              isSelected: selectedSize == "Regular",
              onTap: () {
                setState(() => selectedSize = "Regular");
              },
            ),
            ItemOption(
              title: "Large",
              description: "Lebih puas dengan 22oz",
              price: "+ Rp 4.000",
              isSelected: selectedSize == "Large",
              leadingIcon: Icons.local_drink_rounded,
              onTap: () {
                setState(() => selectedSize = "Large");
              },
            ),
          ],
        ),
      ),
    );
  }
}
```
# SlideToConfirm Widget

`SlideToConfirm` adalah widget kustom interaktif berbasis `StatefulWidget` yang mengharuskan pengguna untuk menggeser (*swipe/slide*) tombol ke arah kanan untuk mengonfirmasi suatu aksi. Widget ini sangat ideal untuk tindakan krusial guna mencegah ketidaksengajaan (*accidental taps*), seperti menyelesaikan pembayaran, menghapus data, atau mengirim pesanan.

---

## 🎯 Fitur Utama

* **Interaksi Geser yang Mulus:** Menggunakan `GestureDetector` untuk melacak posisi `onHorizontalDragUpdate` secara *real-time*.
* **Sistem *Auto-Snap*:** Dilengkapi dengan logika *threshold* sebesar 40% (`maxDrag * 0.4`). Jika pengguna melepas geseran sebelum mencapai 40%, tombol akan kembali ke posisi awal. Jika melewati 40%, tombol otomatis meluncur hingga ujung dan mengeksekusi aksi.
* **Efek Teks Dinamis (*ShaderMask*):** Memiliki dua lapis teks (hitam dan putih). Seiring dengan bergesernya *thumb* (tombol bulat), widget menggunakan `ShaderMask` dan `LinearGradient` untuk membuat efek seolah-olah teks berubah warna menjadi putih mengikuti area yang terisi oleh warna utama (*primary color*).
* **Responsif:** Menggunakan `LayoutBuilder` untuk menyesuaikan lebar secara otomatis mengikuti batasan lebar layar (*parent constraints*).

---

## 📦 Dependencies (Ketergantungan)

Pastikan file dan konfigurasi tema berikut tersedia di proyek Anda:

* `flutter/material.dart`
* `AppColors` (Dari `testgetdata/core/theme/colors_theme.dart` - *digunakan untuk warna background saat diisi dan warna tombol*).

---

## ⚙️ Properti (Parameter)

| Parameter | Tipe Data | Deskripsi | Default |
| :--- | :--- | :--- | :--- |
| `onConfirmed` | `VoidCallback` | **[Wajib]** Fungsi yang akan dipanggil ketika *slider* berhasil digeser melewati ambang batas 40% atau sampai ujung. | - |
| `placeholder` | `String?` | Teks petunjuk yang ditampilkan di tengah *slider*. | `'Geser ke kanan'` |
| `fontSize` | `double` | Ukuran *font* untuk teks `placeholder`. | `14` |

---

## 🚀 Cara Penggunaan (Contoh)

Berikut adalah contoh implementasi `SlideToConfirm` di dalam halaman *checkout* atau konfirmasi:

```dart
import 'package:flutter/material.dart';
// Sesuaikan import dengan struktur folder proyek Anda
import 'package:your_app/widgets/slide_to_confirm.dart';

class CheckoutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Konfirmasi Pembayaran')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SlideToConfirm(
              placeholder: 'Geser untuk Bayar',
              fontSize: 16,
              onConfirmed: () {
                // Logika ketika konfirmasi berhasil dilakukan
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pembayaran Berhasil!')),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

```
# ImagePickerBottomSheet Widget

`ImagePickerBottomSheet` adalah widget *Organism* berbasis `StatelessWidget` yang dirancang untuk ditampilkan sebagai *Bottom Sheet*. Widget ini menyediakan antarmuka bagi pengguna untuk memilih gambar (melalui Kamera atau Galeri) atau menghapus gambar yang sudah dipilih sebelumnya. 

Secara internal, widget ini secara otomatis mengompresi gambar yang dipilih sebelum mengembalikan *path* (lokasi file) gambar tersebut ke komponen induk.

---

## 🎯 Fitur Utama

* **Pilihan Multi-Sumber:** Menggunakan paket `image_picker` untuk mengambil gambar langsung dari kamera perangkat atau memilih dari galeri.
* **Kompresi Otomatis:** Menggunakan `flutter_image_compress` untuk mengecilkan ukuran file secara otomatis (kualitas 70%, resolusi maksimal 1024x1024) dan menyimpannya di direktori sementara (*temporary directory*). Ini sangat krusial untuk mencegah beban memori tinggi (*Out of Memory*) dan mempercepat proses *upload* ke *backend*.
* **Opsi Hapus (Delete):** Menyediakan tombol "Hapus" yang akan mengirimkan nilai `null` untuk me-reset state gambar pada halaman utama.
* **Penutupan Otomatis:** Otomatis memanggil `Navigator.pop(context)` setelah gambar berhasil diproses atau saat opsi "Hapus" dipilih.

---

## 📦 Dependencies (Ketergantungan)

Pastikan *packages* dan komponen eksternal berikut terdaftar di `pubspec.yaml` dan diimpor dengan benar:

* `flutter/material.dart`
* `image_picker` (Package)
* `flutter_image_compress` (Package)
* `path_provider` (Package)
* `google_fonts` (Package)
* `hugeicons` (Package)
* `AppColors` (Dari `testgetdata/core/theme/colors_theme.dart`).
* `OptionItem` (Komponen sub-widget dari `testgetdata/presentation/widgets/organisms/image_picker_bottom_sheet/widgets/option_item.dart`).

---

## ⚙️ Properti (Parameter)

| Parameter | Tipe Data | Deskripsi |
| :--- | :--- | :--- |
| `titleBottomSheet` | `String` | Judul yang akan ditampilkan di bagian atas *bottom sheet* (contoh: "Pilih Foto Profil"). |
| `onImageSelected` | `Function(String?)` | *Callback* yang mengembalikan *path* (lokasi direktori lokal) dari gambar yang sudah dikompresi. Akan mengembalikan `null` jika pengguna memilih opsi "Hapus". |

---

## 🚀 Cara Penggunaan (Contoh)

Karena widget ini adalah *Bottom Sheet*, pemanggilannya harus dilakukan melalui fungsi `showModalBottomSheet` bawaan Flutter. Berikut contoh penggunaannya:

```dart
import 'dart:io';
import 'package:flutter/material.dart';
// Sesuaikan import dengan struktur folder proyek Anda
import 'package:your_app/widgets/organisms/image_picker_bottom_sheet.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  String? selectedImagePath;

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Agar border radius atas terlihat
      builder: (BuildContext context) {
        return ImagePickerBottomSheet(
          titleBottomSheet: "Pilih Foto Profil",
          onImageSelected: (String? compressedPath) {
            setState(() {
              selectedImagePath = compressedPath;
            });
            // compressedPath siap untuk di-upload ke API
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profil')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: selectedImagePath != null 
                  ? FileImage(File(selectedImagePath!)) 
                  : null,
              child: selectedImagePath == null ? const Icon(Icons.person) : null,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showImagePicker,
              child: const Text('Ubah Foto'),
            ),
          ],
        ),
      ),
    );
  }
}
```
# CustomToggle Widget

`CustomToggle` adalah komponen *Atom* berbasis `StatelessWidget` yang berfungsi sebagai tombol sakelar kustom (*custom switch/toggle*). Berbeda dengan `Switch` bawaan Flutter, widget ini menawarkan kontrol penuh terhadap desain visual, transisi warna, ukuran tombol, serta dukungan aksesibilitas yang lebih matang.

---

## 🎯 Fitur Utama

* **Animasi Transisi Mulus:** Memanfaatkan gabungan `AnimatedContainer` (untuk transisi warna latar belakang) dan `AnimatedAlign` (untuk pergeseran posisi tombol bulatan secara horizontal) dengan durasi 200ms dan kurva `Curves.easeInOut`.
* **Ramah Aksesibilitas & Testing (*Semantics*):** Dibungkus dengan widget `Semantics` serta memiliki `identifier` khusus (`toggleButton`). Hal ini mempermudah *screen reader* membaca komponen dan membantu tim QA dalam menulis skrip *automated UI testing*.
* **Label Opsional Terintegrasi:** Menyediakan parameter `label` opsional yang otomatis menyusun teks di sebelah kiri tombol sakelar dengan jarak yang presisi jika diisi.
* **Arsitektur Komponen Terkontrol (*Controlled Component*):** Tidak menyimpan state internal (*stateless*), melainkan bergantung penuh pada nilai `value` yang dikirim dari *parent* dan mengembalikan perubahan lewat *callback* `onChanged`.

---

## 📦 Dependencies (Ketergantungan)

Pastikan file konfigurasi warna berikut sudah tersedia di dalam proyek Anda:

* `flutter/material.dart`
* `AppColors` (Dari `testgetdata/core/theme/colors_theme.dart`).

---

## ⚙️ Properti (Parameter)

| Parameter | Tipe Data | Deskripsi | Status |
| :--- | :--- | :--- | :--- |
| `value` | `bool` | Status aktif (`true`) atau tidak aktif (`false`) dari tombol toggle. | **Wajib** |
| `onChanged` | `ValueChanged<bool>` | *Callback function* yang dipanggil setiap kali pengguna menekan tombol toggle untuk mengubah status nilai. | **Wajib** |
| `label` | `String?` | Teks keterangan atau judul yang dipasang di sebelah kiri tombol toggle. | *Opsional* |

---

## 🚀 Cara Penggunaan (Contoh)

Berikut adalah contoh cara memasang `CustomToggle` di dalam halaman pengaturan aplikasi:

```dart
import 'package:flutter/material.dart';
// Sesuaikan import dengan struktur folder proyek Anda
import 'package:your_app/widgets/atoms/custom_toggle.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // 1. Inisialisasi variabel state
  bool isNotificationEnabled = false;
  bool isDarkMode = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Contoh 1: Menggunakan Label
            CustomToggle(
              label: "Aktifkan Notifikasi",
              value: isNotificationEnabled,
              onChanged: (newValue) {
                setState(() {
                  isNotificationEnabled = newValue;
                });
              },
            ),
            const SizedBox(height: 16),
            // Contoh 2: Tanpa Label (Hanya tombol toggle saja)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Mode Gelap"),
                CustomToggle(
                  value: isDarkMode,
                  onChanged: (newValue) {
                    setState(() {
                      isDarkMode = newValue;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

```
# StatusPesanan Widget

`StatusPesanan` adalah komponen *Atom* (atau komponen *UI Reusable*) berbasis `StatelessWidget` yang berfungsi sebagai label penanda (*status badge*) untuk melacak tahapan pesanan. Widget ini secara otomatis memetakan kode status string menjadi visual yang mudah dipahami melalui kombinasi teks terjemahan, warna kontras, dan ikon yang relevan.

---

## 🎯 Fitur Utama

* **Pemetaan Status Komprehensif:** Mendukung siklus hidup transaksi yang lengkap mulai dari alur normal (*incoming*, *processing*, *ready*, *done*) hingga penanganan kendala (*pending*, *failed payment*, *refund*).
* **Geometri Skalabel (*Proportional Scaling*):** Menggunakan satu parameter acuan `size` untuk menghitung ukuran teks, ikon, jarak antar elemen (*spacing*), hingga ketebalan bantalan dalam (*padding*) secara proporsional.
* **Integrasi Multi-Library Ikon:** Memadukan dua paket ikon populer, yaitu `Iconsax` dan `HugeIcons`, untuk mendapatkan representasi visual terbaik di setiap statusnya.
* **Layout Efisien:** Menggunakan `MainAxisSize.min` pada komponen `Row` sehingga lebar *badge* otomatis menciut pas mengikuti panjang teks status yang ditampilkan.

---

## 📦 Dependencies (Ketergantungan)

Pastikan paket-paket berikut telah terinstal dan terkonfigurasi di berkas `pubspec.yaml` Anda:

* `flutter/material.dart`
* `google_fonts` (Package)
* `hugeicons` (Package)
* `iconsax_flutter` (Package)
* `AppColors` (Dari `testgetdata/core/theme/colors_theme.dart`)

---

## ⚙️ Properti (Parameter)

| Parameter | Tipe Data | Deskripsi | Default |
| :--- | :--- | :--- | :--- |
| `status` | `String` | **[Wajib]** Kode kunci status dari backend/database (contoh: `'pesanan_masuk'`, `'selesai'`). | - |
| `size` | `double` | *[Opsional]* Basis ukuran font teks. Ukuran ikon dan padding akan ikut membesar/mengecil mengikuti nilai ini. | `16` |

---

## 📊 Daftar Pemetaan Status (Mapping Reference)

Widget ini menerjemahkan nilai parameter `status` ke dalam bentuk visual berikut:

| Nilai String (`status`) | Teks Tampilan | Ikon Utama | Warna Badge |
| :--- | :--- | :--- | :--- |
| `'pesanan_masuk'` | Masuk | `Iconsax.login_1_copy` | `warningColor400` (Kuning Muda) |
| `'pesanan_diproses'` | Diproses | `Iconsax.repeat` | `warningColor` (Kuning/Oranye) |
| `'siap_diambil'` | Siap Diambil | `Iconsax.flag_2` | `secondaryColor` |
| `'siap_diantar'` | Siap Diantar | `Iconsax.reserve` | `primaryColor300` |
| `'diantar'` | Diantar | `Iconsax.routing` | `primaryColor` *(Fallback)* |
| `'selesai'` | Selesai | `Iconsax.tick_circle` | `successColor` (Hijau) |
| `'pending'` | Pending | `HugeIcons.strokeRoundedLoading03` | `whiteColor600` (Abu-abu) |
| `'gagal_bayar'` | Gagal Bayar | `Iconsax.money_remove` | `errorColor` (Merah) |
| `'refund_selesai'` | Refund | `Iconsax.directbox_send` | `blackColor` (Hitam) |

---

## 🚀 Cara Penggunaan (Contoh)

Berikut adalah contoh bagaimana menampilkan `StatusPesanan` di dalam kartu daftar riwayat transaksi:

```dart
import 'package:flutter/material.dart';
// Sesuaikan import dengan struktur folder proyek Anda
import 'package:your_app/widgets/atoms/status_pesanan.dart';

class OrderCardItem extends StatelessWidget {
  final String orderId;
  final String currentStatus; // Nilai didapat dari API/Database

  const OrderCardItem({
    Key? key,
    required this.orderId,
    required this.currentStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Nota: #$orderId", style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text("Total: Rp 35.000"),
              ],
            ),
            // Implementasi StatusPesanan dengan ukuran kustom (14px)
            StatusPesanan(
              status: currentStatus, 
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
```
# CustomSnackbar Utility

`CustomSnackbar` adalah sebuah utilitas manajemen notifikasi global (*contextless snackbar*) yang memanfaatkan sistem `Overlay` bawaan Flutter. Utilitas ini dirancang agar dapat dipanggil dari mana saja di dalam kode proyek Anda tanpa bergantung pada objek `BuildContext`.

Dengan desain minimalis, transisi animasi terpadu (*slide* dan *fade*), serta fitur penyesuaian posisi otomatis saat papan ketik (*keyboard*) aktif, komponen ini sangat mendukung tercapainya struktur kode yang modular dan *maintainable*.

---

## 🎯 Fitur Utama

* **Pemanggilan Tanpa Context (*Contextless*):** Cukup daftarkan `navigatorKey` sekali di awal, Anda bisa memanggil notifikasi dari lapisan *Business Logic* (seperti BLoC, Riverpod, atau Service) tanpa menyisipkan `BuildContext`.
* **Empat Tipe Status Terintegrasi:** Menyediakan tema siap pakai untuk status `success` (hijau), `info` (biru), `warning` (oranye), dan `error` (merah).
* **Animasi Transisi Khusus:** Memadukan komponen `SlideTransition` (`Curves.easeOutCubic`) dan `FadeTransition` untuk memberikan efek kemunculan yang halus dari arah bawah layar.
* **Ramah Terhadap Safe Area & Keyboard:** Menggunakan kombinasi dinamis antara `MediaQuery.padding.bottom` dan `MediaQuery.viewInsets.bottom`. Jika keyboard perangkat terbuka, letak posisi *snackbar* akan otomatis bergeser naik ke atas keyboard agar tidak terhalang.
* **Pembersihan Memori Aman:** Rutinitas pengisapan objek (*auto-dismiss*) menggunakan `Timer` yang otomatis dibersihkan (*canceled*) saat widget dilepas (*disposed*) untuk menjamin tidak adanya kebocoran memori (*memory leak*).

---

## 📦 Dependencies (Ketergantungan)

* `flutter/material.dart`
* `dart:async` (Untuk pengelolaan objek `Timer`).

---

## ⚙️ Cara Setup Global (Langkah Awal)

Sebelum menggunakan `CustomSnackbar`, Anda harus menginisialisasi kunci navigator (`GlobalKey<NavigatorState>`) di dalam file utama aplikasi Anda (biasanya pada `main.dart` atau file konfigurasi router):

### 1. Definisikan Global Key
```dart
// Buat key secara global atau di dalam file app_router.dart Anda
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
```
```dart
import 'package:flutter/material.dart';
// Sesuaikan dengan letak path berkas CustomSnackbar Anda
import 'package:your_app/utils/custom_snackbar.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App',
      // 🅰️ Pasang key ke MaterialApp
      navigatorKey: navigatorKey, 
      builder: (context, child) {
        // 🅱️ Inisialisasi CustomSnackbar sebelum aplikasi berjalan penuh
        CustomSnackbar.init(navigatorKey); 
        return child!;
      },
      home: const HomeScreen(),
    );
  }
}
```
```dart
CustomSnackbar.success("Data berhasil disimpan ke database!");
CustomSnackbar.info("Pembaruan sistem akan dilakukan pukul 00:00 WIB.");
CustomSnackbar.warning("Koneksi internet Anda tidak stabil.");
CustomSnackbar.error("Gagal memproses transaksi. Silakan coba lagi.");
CustomSnackbar.success(
  "Data dipulihkan!",
  duration: const Duration(seconds: 5), // Tampil lebih lama
);
```

