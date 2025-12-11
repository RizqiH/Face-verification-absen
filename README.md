# Face Verification Attendance System

Aplikasi absensi dengan face verification menggunakan InsightFace, dibangun dengan Flutter (mobile), Go (backend), dan Python (face recognition service).

---

## Struktur Proyek

```
face_verification/
├── lib/                    # Flutter app (Clean Architecture)
│   ├── core/              # Core utilities, constants, theme
│   ├── data/              # Data layer (repositories, datasources, models)
│   ├── domain/            # Domain layer (entities, repositories, use cases)
│   └── presentation/      # Presentation layer (pages, bloc)
├── backend/               # Go backend API
│   └── internal/
│       ├── config/        # Configuration
│       ├── database/      # Database connection
│       ├── handlers/      # HTTP handlers
│       ├── middleware/    # Middleware (auth, CORS)
│       ├── models/        # Data models
│       ├── repositories/  # Repository pattern
│       └── services/      # Business logic
├── face_recognition/      # Python service untuk face recognition
│   └── main.py           # Flask app dengan InsightFace
└── database/             # Database schema
    └── schema.sql
```

---

## Setup

### 1. Database MySQL

```bash

```

Atau import melalui MySQL client.

### 2. Backend Go

```bash
cd backend
go mod download
go run main.go
```

Backend akan berjalan di `http://localhost:8080`

Buat file `.env`:

```env
PORT=8080
DB_HOST=localhost
DB_USER=dbuse_elu
DB_PASSWORD=dbpassword_elu
DB_NAME=face_verification
DB_PORT=3306
JWT_SECRET=your-secret-key-change-in-production(isikuncilu)
FACE_RECOGNITION_URL=http://localhost:5000
CLOUDINARY_CLOUD_NAME=isikuncilu
CLOUDINARY_API_KEY=isikuncilu
CLOUDINARY_API_SECRET=isikuncilu
```

> **Catatan:** Untuk Cloudinary, daftar di [cloudinary.com](https://cloudinary.com) dan dapatkan credentials. Lihat `CLOUDINARY_SETUP.md` untuk panduan lengkap.

### 3. Face Recognition Service (Python)

```bash
cd face_recognition
pip install -r requirements.txt

# Download InsightFace model
# Download buffalo_l.onnx dari https://github.com/deepinsight/insightface
# Letakkan di folder models/

# Set environment variables (optional)
export BACKEND_API_URL=http://localhost:8080/api/v1  # Default
export STORAGE_MODE=database  # Options: 'database' (default) or 'file'

python main.py
```

Service akan berjalan di `http://localhost:5001`

### 4. Flutter App

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

---

## Fitur

- Clean Architecture di Flutter
- Face verification dengan InsightFace
- Clock In/Clock Out dengan foto selfie
- Location tracking
- RESTful API dengan Go
- JWT Authentication
- MySQL Database

---

## API Endpoints

### Auth

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/auth/login` | Login |
| GET | `/api/v1/auth/me` | Get current user |

### Attendance

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/attendance/clock-in` | Clock in |
| POST | `/api/v1/attendance/clock-out` | Clock out |
| GET | `/api/v1/attendance/today` | Get today's attendance |
| GET | `/api/v1/attendance/history` | Get attendance history |

### User

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/user/upload-profile-photo` | Upload profile photo |

---

## Face Recognition Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/upload-profile` | Upload profile photo dan extract embedding |
| POST | `/verify` | Verify face dengan foto profil |

---

## Teknologi

- **Flutter** - Mobile app framework
- **Go** - Backend API
- **Python** - Face recognition service
- **MySQL** - Database
- **InsightFace** - Face recognition model
- **Cloudinary** - Cloud image storage
- **JWT** - Authentication

---

## License

MIT License

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.# Face-verification-absen
