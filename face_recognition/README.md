# Face Recognition Service

Service Python untuk face recognition menggunakan InsightFace.

## Setup

1. Install dependencies:
```bash
pip install -r requirements.txt
```

2. Download model InsightFace:
   - Download model `buffalo_l.onnx` dari [InsightFace](https://github.com/deepinsight/insightface)
   - Letakkan di folder `models/`

3. Run service:
```bash
python main.py
```

Service akan berjalan di `http://localhost:5000`

## Endpoints

### POST /upload-profile
Upload foto profil dan extract embedding.

**Request:**
- `photo`: File foto (multipart/form-data)
- `user_id`: ID user (form data)

**Response:**
```json
{
  "message": "Profile photo uploaded successfully",
  "embedding_id": "user_id"
}
```

### POST /verify
Verifikasi wajah dengan foto profil yang sudah tersimpan.

**Request:**
- `photo`: File foto (multipart/form-data)
- `user_id`: ID user (form data)

**Response:**
```json
{
  "verified": true,
  "similarity": 0.85,
  "threshold": 0.6
}
```

