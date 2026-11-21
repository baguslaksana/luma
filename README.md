# Luma — Simple E-Learning Platform (Flutter Developer Track B)

Aplikasi mobile pembelajaran online berbasis **Flutter & Dart** dengan fitur Role-Based (Siswa & Pengajar), dirancang sesuai spesifikasi **Technical Assessment: Simple E-Learning Platform (Track B)**.

> **Catatan:** Seluruh aplikasi ini — mulai dari desain UI/UX, arsitektur kode, implementasi fitur, hingga dokumentasi — dibuat sepenuhnya menggunakan bantuan **AI (Artificial Intelligence)**.

---

## 1. Pemenuhan Kriteria Fitur Wajib (Section B1)

| Fitur Wajib | Kriteria Minimum | Status |
|---|---|:---:|
| **Course List** | Menampilkan daftar course beserta judul dan informasi singkat. | Lengkap |
| **Course Detail** | Menampilkan deskripsi course dan daftar lesson. | Lengkap |
| **Lesson Selection** | Student dapat memilih lesson yang akan ditonton. | Lengkap |
| **Video Streaming / View** | Video bisa diputar melalui alur download/streaming. | Lengkap |
| **Player Control** | Mendukung play, pause, seek, dan menangani loading/error. | Lengkap |
| **Navigation** | Pengguna dapat kembali ke daftar course atau memilih lesson lain. | Lengkap |

---

## 2. Keputusan Teknis & Alasan Pemilihan Library (Section B2)

### A. State Management — Riverpod (`flutter_riverpod: ^2.6.1`)
1. **Compile-Time Safe** — menghilangkan `ProviderNotFoundException` pada runtime.
2. **Decoupled from BuildContext** — sinkronisasi status video player dan caching data tanpa terikat widget tree.
3. **AutoDispose Lifecycle** — controller video dan listener otomatis di-dispose saat widget ditutup, menjamin 0% memory leak.

### B. Pemutar Video — `youtube_player_iframe` & `video_player`
1. **Zero-Crash Resilience** — jika stream gagal, otomatis beralih ke video lokal `assets/videos/sample_lesson.mp4`.
2. **Player Control Lengkap** — Play, Pause, Seekbar slider, Skip ±10s, Speed rate 0.75x–2.0x.

### C. Arsitektur — Clean Architecture (3-Tier)
* **Presentation Layer:** Widget UI, State, dan Notifier (Riverpod).
* **Domain Layer:** Entitas murni Dart dan Use Cases bisnis tanpa dependensi framework.
* **Data Layer:** Model/DTO, Repositori konkret, dan Data Source (PostgreSQL + in-memory fallback).
* **Service Locator:** Injeksi dependensi terpusat untuk penggantian data source.

### D. UI/UX
* **Typography:** Google Fonts Poppins.
* **Skeleton Shimmer Loading:** Menggantikan loading spinner konvensional, bebas overflow.
* **Bottom Navigation Bar:** Floating pill, respons sentuhan instan, haptic feedback.

---

## 3. System Design, ERD, Flowchart & Model Data (Section 4)

Seluruh diagram visual tersedia di direktori [`docs/diagrams/`](docs/diagrams/).

### A. System Design — Komponen Utama & Alur Data
![System Design](docs/diagrams/system_design.png)

### B. Flowchart — Alur Siswa & Alur Guru
![Flowchart](docs/diagrams/flowchart_diagram.png)

### C. ERD — Entity-Relationship Diagram (PostgreSQL)
![ERD](docs/diagrams/erd_diagram.png)

### D. Rancangan Model Data & Kontrak API / Mock Data
![API & Data Model](docs/diagrams/api_data_model.png)

### Panduan Migrasi ke REST API Nyata
Pada `lib/core/di/service_locator.dart`, cukup ganti satu baris data source:
```dart
// Dari:
courseRemoteDataSource = PostgresCourseDataSource();
// Menjadi:
courseRemoteDataSource = CourseApiDataSource(http.Client());
```
Seluruh Domain Layer dan UI Layer akan langsung bekerja tanpa perubahan.

---

## 4. Cara Menjalankan Aplikasi

### Prasyarat
- Flutter SDK `>=3.3.0` · Android Studio / VS Code · Emulator atau perangkat fisik

### Akun Demo
| Role | Email | Password | Nama |
|---|---|---|---|
| **Siswa** | `siswa@luma.com` | `siswa` | ARI BAGUS |
| **Pengajar** | `pengajar@luma.com` | `pengajar` | Drs. Bambang Sudarsono, M.Pd. |

Tersedia juga fitur **Sign Up** untuk membuat akun baru.

### Langkah Menjalankan
```bash
flutter pub get
flutter test
flutter run
```

### Database PostgreSQL (Opsional)
Aplikasi memiliki in-memory fallback. Untuk menjalankan PostgreSQL lokal:
```bash
cd backend && docker compose up -d
psql -h localhost -U luma_user -d luma_elearning -f database/schema.sql
```

---

## 5. Catatan Keterbatasan (Limitations)

1. **Offline Download:** Fokus pada progressive streaming + local fallback asset. Fitur download ke storage lokal dapat ditambahkan via `flutter_downloader`.
2. **Koneksi Jaringan:** Video online membutuhkan internet aktif. Jika terputus, otomatis beralih ke video lokal bawaan.
3. **Session Token:** Autentikasi terintegrasi PostgreSQL dan in-memory cache. JWT token refresh dapat ditambahkan untuk skala enterprise.
