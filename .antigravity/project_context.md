# Project Context: Kompak App (Flutter)

## 🎯 Tujuan Dokumen
Dokumen ini adalah panduan utama (Project Context) untuk AI Assistant (Antigravity/Cline). **AI WAJIB membaca dan mematuhi panduan ini sebelum melakukan perubahan kode, refactoring, atau menambahkan fitur baru.**

## 🛠️ Tech Stack & Dependencies
- **Framework**: Flutter (SDK `^3.12.2`)
- **State Management**: BLoC (`flutter_bloc`) & `equatable`
- **Dependency Injection**: `get_it` & `injectable`
- **Routing**: `auto_route`
- **Networking**: `dio`
- **Data Serialization**: `json_annotation` & `json_serializable`
- **Local Storage**: `shared_preferences`
- **UI & Assets**: `flutter_svg`
- **Code Generation**: `build_runner`, `injectable_generator`, `auto_route_generator`

## 📂 Struktur Direktori (Feature-First Architecture)
Proyek ini menggunakan arsitektur berbasis fitur (Feature-First / Domain-Driven).

```text
lib/
├── core/                  # Kode inti yang digunakan di seluruh aplikasi (global)
│   ├── di/                # Setup Dependency Injection (get_it & injectable)
│   ├── network/           # Konfigurasi Dio, interceptors, error handling
│   └── routes/            # Setup AutoRoute dan guards
├── features/              # Fitur-fitur spesifik aplikasi
│   └── [feature_name]/    # Contoh: auth, home, profile
│       ├── data/          # Models, Data Sources (Remote/Local), Repositories Impl
│       ├── domain/        # Entities, Repositories Interface, Usecases
│       └── presentation/  # UI (Pages, Widgets) dan State Management (BLoC/Cubit)
└── main.dart              # Entry point aplikasi
```

## 📜 Aturan & Best Practices (Coding Guidelines)

### 1. Dependency Injection (`get_it` & `injectable`)
- Dilarang membuat instance service/repository secara manual (misal: `Repository()`).
- Gunakan `@injectable`, `@lazySingleton`, atau `@singleton` dari package `injectable`.
- Jalankan `dart run build_runner build -d` setelah menambahkan dependency baru.

### 2. State Management (`flutter_bloc`)
- Gunakan **Cubit** untuk state yang sederhana (hanya butuh emit state).
- Gunakan **BLoC** (dengan events) untuk interaksi user yang kompleks (debounce, form handling yang rumit, dll).
- Pastikan state selalu bersifat *immutable*. Gunakan class dengan `final` properties dan pastikan meng-override `props` karena kita menggunakan `Equatable`.

### 3. Routing (`auto_route`)
- Semua navigasi halaman wajib menggunakan `auto_route`.
- Definisikan route di `lib/core/routes/` menggunakan anotasi `@RoutePage()`.
- Jangan gunakan `Navigator.push()` bawaan Flutter kecuali sangat terpaksa untuk dialog/bottom sheet sederhana.

### 4. Networking (`dio`)
- Semua panggilan API wajib menggunakan `Dio` yang di-configure di `lib/core/network/`.
- Jangan menggunakan package `http` biasa.
- Tangani error secara global menggunakan Dio Interceptors.

### 5. Data Serialization
- Selalu gunakan `json_annotation` untuk Model (DTO/Response).
- Generate file `.g.dart` menggunakan `build_runner`.
- Dilarang parsing JSON secara manual (misal: `json['key']` secara langsung tanpa class model).

### 6. Assets & UI
- Gunakan `flutter_svg` untuk menampilkan icon atau gambar berformat vektor (SVG).
- Gambar dan asset statis diletakkan di folder `assets/images/`.

## ⚡ Workflow Pengembangan AI
1. **Pahami Konteks**: Selalu cek struktur direktori saat ini sebelum menulis/mengubah kode.
2. **Generasi Kode**: Ingatkan pengguna jika kamu menambahkan model atau DI baru agar mereka/kamu menjalankan perintah `dart run build_runner build -d`.
3. **Pemisahan Logika**: Jangan mencampur UI (Widgets) dengan Business Logic. Semua logic API/Data harus ada di Data/Domain layer, lalu diakses UI melalui BLoC.

---
*Catatan untuk AI: Jadikan dokumen ini sebagai acuan mutlak untuk setiap task di dalam proyek `kompak_app`.*
