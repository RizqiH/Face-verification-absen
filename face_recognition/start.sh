#!/bin/bash

# Script untuk menjalankan Face Recognition Service

cd "$(dirname "$0")"

# Aktifkan virtual environment
source venv/bin/activate

# Jalankan service
echo "Starting Face Recognition Service on http://localhost:5000"
python main.py

