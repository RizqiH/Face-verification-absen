from flask import Flask, request, jsonify
from flask_cors import CORS
import cv2
import numpy as np
from insightface import app as face_app
import base64
from PIL import Image
import io
import os
from typing import List, Optional
import json
from pathlib import Path
import requests

app = Flask(__name__)
# Configure CORS to allow all origins and methods (for development)
# In production, restrict this to specific origins
CORS(app, resources={
    r"/*": {
        "origins": "*",
        "methods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        "allow_headers": ["Content-Type", "Authorization"]
    }
})

# Backend API URL for face embeddings
# Can be overridden via environment variable
BACKEND_API_URL = os.getenv('BACKEND_API_URL', 'http://localhost:8080/api/v1')

# Storage mode: 'database' (via backend API) or 'file' (JSON file)
STORAGE_MODE = os.getenv('STORAGE_MODE', 'database')  # Default to database

# Load InsightFace modelP
face_analyzer = None

def load_model():
    global face_analyzer
    try:
        # Initialize InsightFace with buffalo_l model (will auto-download if needed)
        # buffalo_l is the most accurate model for face recognition
        face_analyzer = face_app.FaceAnalysis(name='buffalo_l')
        # Use larger detection size for better accuracy (especially for smaller faces)
        # 640x640 provides good balance between accuracy and speed
        face_analyzer.prepare(ctx_id=-1, det_size=(640, 640))
        print("✅ InsightFace buffalo_l model loaded successfully")
        print(f"   Detection size: 640x640")
        print(f"   Context: CPU (ctx_id=-1)")
    except Exception as e:
        print(f"❌ Error loading InsightFace model: {e}")
        print("   Trying alternative initialization...")
        try:
            # Try with default settings
            face_analyzer = face_app.FaceAnalysis()
            face_analyzer.prepare(ctx_id=-1, det_size=(640, 640))
            print("⚠️  Model loaded with default settings (may be less accurate)")
        except Exception as e2:
            print(f"❌ Failed to load model: {e2}")
            face_analyzer = None

load_model()

def preprocess_image(image: Image.Image) -> np.ndarray:
    """Preprocess image for better face detection"""
    # Convert PIL to numpy
    img_array = np.array(image)
    
    # Convert RGB to BGR for OpenCV
    if len(img_array.shape) == 3 and img_array.shape[2] == 3:
        img_array = cv2.cvtColor(img_array, cv2.COLOR_RGB2BGR)
    elif len(img_array.shape) == 3 and img_array.shape[2] == 4:
        # Handle RGBA
        img_array = cv2.cvtColor(img_array, cv2.COLOR_RGBA2BGR)
    
    # Resize if too large (improve performance and detection)
    height, width = img_array.shape[:2]
    max_dimension = 1920  # Max width/height
    
    if height > max_dimension or width > max_dimension:
        scale = max_dimension / max(height, width)
        new_width = int(width * scale)
        new_height = int(height * scale)
        img_array = cv2.resize(img_array, (new_width, new_height), interpolation=cv2.INTER_AREA)
        print(f"Image resized: {width}x{height} -> {new_width}x{new_height}")
    
    # Enhance image quality for better detection
    # Convert to LAB color space for better contrast
    lab = cv2.cvtColor(img_array, cv2.COLOR_BGR2LAB)
    l, a, b = cv2.split(lab)
    
    # Apply CLAHE (Contrast Limited Adaptive Histogram Equalization) to L channel
    clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8, 8))
    l = clahe.apply(l)
    
    # Merge back and convert to BGR
    enhanced = cv2.merge([l, a, b])
    img_array = cv2.cvtColor(enhanced, cv2.COLOR_LAB2BGR)
    
    return img_array

def extract_embedding(image: Image.Image) -> Optional[np.ndarray]:
    """Extract face embedding from image using InsightFace with improved preprocessing"""
    if face_analyzer is None:
        return None
    
    try:
        # Preprocess image for better detection
        img_array = preprocess_image(image)
        
        # Detect faces and extract embeddings
        faces = face_analyzer.get(img_array)
        
        if len(faces) == 0:
            print("[EXTRACT] No face detected in image")
            return None
        
        # Get the face with the largest bounding box (most likely to be the main face)
        # Calculate face area and select the largest one
        largest_face = max(faces, key=lambda f: (f.bbox[2] - f.bbox[0]) * (f.bbox[3] - f.bbox[1]))
        
        print(f"[EXTRACT] Found {len(faces)} face(s), using largest face")
        print(f"[EXTRACT] Face bbox: {largest_face.bbox}")
        print(f"[EXTRACT] Face detection confidence: {largest_face.det_score:.4f}")
        
        # Get embedding
        embedding = largest_face.normed_embedding
        
        # Normalize embedding to ensure unit length (extra safety)
        embedding = embedding / np.linalg.norm(embedding)
        
        return embedding
    except Exception as e:
        print(f"[EXTRACT] Error extracting embedding: {e}")
        import traceback
        traceback.print_exc()
        return None

def cosine_similarity(embedding1: np.ndarray, embedding2: np.ndarray) -> float:
    """Calculate cosine similarity between two embeddings"""
    return np.dot(embedding1, embedding2)

# Persistent storage for embeddings using JSON file
import json
import os

EMBEDDINGS_FILE = 'embeddings_store.json'

def load_embeddings():
    """Load embeddings from persistent storage"""
    global embeddings_store
    if os.path.exists(EMBEDDINGS_FILE):
        try:
            with open(EMBEDDINGS_FILE, 'r') as f:
                data = json.load(f)
                embeddings_store = data
                print(f"Loaded {len(embeddings_store)} embeddings from storage")
        except Exception as e:
            print(f"Error loading embeddings: {e}")
            embeddings_store = {}
    else:
        embeddings_store = {}

def save_embeddings():
    """Save embeddings to persistent storage"""
    try:
        with open(EMBEDDINGS_FILE, 'w') as f:
            json.dump(embeddings_store, f, indent=2)
        print(f"Saved {len(embeddings_store)} embeddings to storage")
    except Exception as e:
        print(f"Error saving embeddings: {e}")

# Persistent storage file path (for file mode)
EMBEDDINGS_FILE = os.path.join(os.path.dirname(__file__), 'embeddings_store.json')

def load_embedding_from_database(user_id: str) -> Optional[dict]:
    """Load embedding from database via backend API"""
    try:
        url = f"{BACKEND_API_URL}/embeddings/user/{user_id}"
        response = requests.get(url, timeout=5)
        if response.status_code == 200:
            data = response.json()
            return {
                'embedding': json.loads(data['embedding']),  # Parse JSON string to list
                'user_id': data['user_id']
            }
        elif response.status_code == 404:
            return None
        else:
            print(f"⚠️  Error loading embedding from database: {response.status_code}")
            return None
    except Exception as e:
        print(f"⚠️  Error loading embedding from database: {e}")
        return None

def save_embedding_to_database(user_id: str, embedding: np.ndarray) -> bool:
    """Save embedding to database via backend API"""
    try:
        url = f"{BACKEND_API_URL}/embeddings"
        embedding_json = json.dumps(embedding.tolist())
        payload = {
            'user_id': user_id,
            'embedding': embedding_json
        }
        response = requests.post(url, json=payload, timeout=10)
        if response.status_code == 200:
            print(f"💾 Saved embedding to database for user: {user_id}")
            return True
        else:
            print(f"❌ Error saving embedding to database: {response.status_code} - {response.text}")
            return False
    except Exception as e:
        print(f"❌ Error saving embedding to database: {e}")
        return False

def load_embeddings_file():
    """Load embeddings from JSON file (legacy file mode)"""
    global embeddings_store
    if os.path.exists(EMBEDDINGS_FILE):
        try:
            with open(EMBEDDINGS_FILE, 'r') as f:
                data = json.load(f)
                embeddings_store = data
                print(f"✅ Loaded {len(embeddings_store)} embeddings from file")
                print(f"   Available users: {list(embeddings_store.keys())}")
        except Exception as e:
            print(f"⚠️  Error loading embeddings: {e}")
            embeddings_store = {}
    else:
        embeddings_store = {}
        print("📝 No existing embeddings file, starting fresh")

def save_embeddings_file():
    """Save embeddings to JSON file (legacy file mode)"""
    try:
        with open(EMBEDDINGS_FILE, 'w') as f:
            json.dump(embeddings_store, f, indent=2)
        print(f"💾 Saved {len(embeddings_store)} embeddings to {EMBEDDINGS_FILE}")
    except Exception as e:
        print(f"❌ Error saving embeddings: {e}")

# In-memory cache for embeddings (used in both modes for performance)
embeddings_cache = {}

# Initialize based on storage mode
if STORAGE_MODE == 'file':
    embeddings_store = {}
    load_embeddings_file()
    print(f"📁 Storage mode: FILE (using {EMBEDDINGS_FILE})")
else:
    embeddings_store = {}  # Not used in database mode
    print(f"🗄️  Storage mode: DATABASE (using {BACKEND_API_URL})")

@app.route('/health', methods=['GET'])
def health():
    return jsonify({"status": "ok"})

@app.route('/upload-profile', methods=['POST'])
def upload_profile():
    """Upload profile photo and extract embedding"""
    try:
        if 'photo' not in request.files:
            return jsonify({"error": "No photo provided"}), 400
        
        file = request.files['photo']
        user_id = request.form.get('user_id')
        
        if not user_id:
            return jsonify({"error": "user_id is required"}), 400
        
        # Read image
        image = Image.open(io.BytesIO(file.read()))
        
        # Extract embedding with improved preprocessing
        embedding = extract_embedding(image)
        if embedding is None:
            return jsonify({"error": "Failed to extract face embedding. Please ensure your face is clearly visible and well-lit."}), 400
        
        # Verify embedding quality (should be normalized)
        embedding_norm = np.linalg.norm(embedding)
        if abs(embedding_norm - 1.0) > 0.01:
            print(f"[UPLOAD] ⚠️  Embedding norm is {embedding_norm:.4f}, normalizing...")
            embedding = embedding / embedding_norm
        
        # Store embedding based on storage mode
        embedding_list = embedding.tolist()
        
        if STORAGE_MODE == 'database':
            # Save to database via backend API
            success = save_embedding_to_database(user_id, embedding)
            if not success:
                return jsonify({"error": "Failed to save embedding to database"}), 500
            
            # Also cache in memory for faster access
            embeddings_cache[user_id] = {
                'embedding': embedding_list,
                'user_id': user_id
            }
            print(f"[UPLOAD] ✅ Profile photo uploaded and saved to DATABASE for user: {user_id}")
        else:
            # Save to file (legacy mode)
            embeddings_store[user_id] = {
                'embedding': embedding_list,
                'user_id': user_id
            }
            save_embeddings_file()
            print(f"[UPLOAD] ✅ Profile photo uploaded and saved to FILE for user: {user_id}")
        
        print(f"[UPLOAD] Embedding shape: {embedding.shape}")
        print(f"[UPLOAD] Embedding norm: {np.linalg.norm(embedding):.4f}")
        
        return jsonify({
            "message": "Profile photo uploaded successfully",
            "embedding_id": user_id
        }), 200
        
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/verify', methods=['POST'])
def verify():
    """Verify face against stored profile"""
    try:
        print(f"[VERIFY] Request received")
        
        if 'photo' not in request.files:
            print("[VERIFY] Error: No photo provided")
            return jsonify({"error": "No photo provided"}), 400
        
        file = request.files['photo']
        user_id = request.form.get('user_id')
        
        print(f"[VERIFY] User ID: {user_id}")
        
        if not user_id:
            print("[VERIFY] Error: user_id is required")
            return jsonify({"error": "user_id is required"}), 400
        
        # Read image first
        try:
            image = Image.open(io.BytesIO(file.read()))
            print(f"[VERIFY] Image loaded: {image.size}")
        except Exception as e:
            print(f"[VERIFY] Error reading image: {e}")
            return jsonify({"error": f"Invalid image file: {str(e)}"}), 400
        
        # Extract embedding from new photo
        print(f"[VERIFY] Extracting embedding from photo...")
        new_embedding = extract_embedding(image)
        if new_embedding is None:
            print(f"[VERIFY] Error: Failed to extract face embedding (no face detected)")
            return jsonify({"error": "No face detected in photo. Please ensure your face is clearly visible."}), 400
        
        print(f"[VERIFY] Embedding extracted successfully")
        
        # Get stored embedding based on storage mode
        stored_embedding_data = None
        
        if STORAGE_MODE == 'database':
            # Try cache first
            if user_id in embeddings_cache:
                stored_embedding_data = embeddings_cache[user_id]
                print(f"[VERIFY] ✅ Found user {user_id} in cache")
            else:
                # Load from database
                print(f"[VERIFY] Loading embedding from database for user: {user_id}")
                stored_embedding_data = load_embedding_from_database(user_id)
                if stored_embedding_data:
                    # Cache it for next time
                    embeddings_cache[user_id] = stored_embedding_data
                    print(f"[VERIFY] ✅ Loaded and cached embedding from database")
        else:
            # Load from file (legacy mode)
            load_embeddings_file()
            if user_id in embeddings_store:
                stored_embedding_data = embeddings_store[user_id]
                print(f"[VERIFY] ✅ Found user {user_id} in file store")
        
        # Check if user has stored embedding
        if stored_embedding_data is None:
            print(f"[VERIFY] ❌ Error: User {user_id} profile not found")
            if STORAGE_MODE == 'file':
                print(f"[VERIFY] Available users: {list(embeddings_store.keys())}")
            return jsonify({"error": "User profile not found. Please upload profile photo first."}), 404
        
        print(f"[VERIFY] ✅ User {user_id} profile found")
        
        # Get stored embedding
        stored_embedding = np.array(stored_embedding_data['embedding'])
        print(f"[VERIFY] Stored embedding shape: {stored_embedding.shape}, New embedding shape: {new_embedding.shape}")
        
        # Ensure embeddings are normalized
        new_embedding = new_embedding / np.linalg.norm(new_embedding)
        stored_embedding = stored_embedding / np.linalg.norm(stored_embedding)
        
        # Calculate cosine similarity (dot product of normalized vectors)
        similarity = cosine_similarity(new_embedding, stored_embedding)
        
        # Improved threshold for better accuracy and easier detection
        # Cosine similarity range: 1.0 = identical, 0.0 = completely different
        # For normalized embeddings from buffalo_l model:
        # - 0.50-0.55: Too lenient (false positives)
        # - 0.55-0.60: Lenient but acceptable for same person in different conditions
        # - 0.60-0.65: Good balance for usability (recommended)
        # - 0.65-0.70: Stricter (may reject legitimate matches)
        # - 0.70+: Very strict (high security but lower usability)
        
        # Adaptive threshold: Lower for easier detection, but still secure
        base_threshold = 0.62  # Lowered from 0.70 for better usability
        
        # Use the threshold
        threshold = base_threshold
        verified = bool(similarity >= threshold)
        
        # Calculate confidence percentage
        confidence_pct = min(100.0, max(0.0, (similarity / 1.0) * 100))
        
        print(f"[VERIFY] Result - User: {user_id}")
        print(f"[VERIFY] Similarity: {similarity:.4f} ({confidence_pct:.1f}% confidence)")
        print(f"[VERIFY] Threshold: {threshold:.4f}")
        print(f"[VERIFY] Verified: {'✅ YES' if verified else '❌ NO'}")
        
        if not verified and similarity > 0.55:
            print(f"[VERIFY] ⚠️  Close match but below threshold (diff: {threshold - similarity:.4f})")
        
        return jsonify({
            "verified": verified,  # Now it's Python bool, JSON serializable
            "similarity": float(similarity),
            "threshold": float(threshold)
        }), 200
        
    except Exception as e:
        import traceback
        error_trace = traceback.format_exc()
        print(f"[VERIFY] Exception occurred: {str(e)}")
        print(f"[VERIFY] Traceback:\n{error_trace}")
        return jsonify({"error": str(e), "message": "Verification failed. Please try again."}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001, debug=True)

