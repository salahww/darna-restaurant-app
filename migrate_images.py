"""
Product Images Migration Script
Migrates product images from local assets to Firebase Storage with WebP compression
"""

import os
import json
from pathlib import Path
from PIL import Image
import io

try:
    import firebase_admin
    from firebase_admin import credentials, storage, firestore
except ImportError:
    print("❌ Firebase Admin SDK not installed!")
    print("📦 Run: pip install firebase-admin pillow")
    exit(1)


def compress_to_webp(image_path, max_size=800, quality=80):
    """Convert image to WebP format with compression"""
    # Open image
    img = Image.open(image_path)
    
    # Convert RGBA to RGB if needed (WebP doesn't support transparency well)
    if img.mode in ('RGBA', 'LA', 'P'):
        background = Image.new('RGB', img.size, (255, 255, 255))
        if img.mode == 'P':
            img = img.convert('RGBA')
        background.paste(img, mask=img.split()[-1] if img.mode == 'RGBA' else None)
        img = background
    
    # Resize if needed
    if max(img.size) > max_size:
        ratio = max_size / max(img.size)
        new_size = tuple(int(dim * ratio) for dim in img.size)
        img = img.resize(new_size, Image.Resampling.LANCZOS)
    
    # Save as WebP
    buffer = io.BytesIO()
    img.save(buffer, format='WebP', quality=quality, method=6)
    
    return buffer.getvalue()


def main():
    print("🚀 Starting Product Images Migration to Firebase Storage\n")
    
    # Paths
    assets_dir = Path("assets/images/products")
    service_account_path = "firebase-service-account.json"
    
    # Check if assets directory exists
    if not assets_dir.exists():
        print(f"❌ Assets directory not found: {assets_dir}")
        return
    
    # Check for service account key
    if not Path(service_account_path).exists():
        print("❌ Firebase service account key not found!")
        print("\n📋 Steps to get service account key:")
        print("1. Go to Firebase Console → Project Settings → Service Accounts")
        print("2. Click 'Generate New Private Key'")
        print("3. Save as 'firebase-service-account.json' in project root")
        print("\n⚠️ For security, add to .gitignore!")
        return
    
    # Initialize Firebase Admin
    try:
        cred = credentials.Certificate(service_account_path)
        firebase_admin.initialize_app(cred, {
            'storageBucket': 'darnaa-51787.firebasestorage.app'
        })
        print("✅ Firebase Admin SDK initialized\n")
    except Exception as e:
        print(f"❌ Failed to initialize Firebase: {e}")
        return
    
    bucket = storage.bucket()
    db = firestore.client()
    
    # Get all PNG images
    image_files = list(assets_dir.glob("*.png"))
    print(f"📸 Found {len(image_files)} images to migrate\n")
    
    success_count = 0
    error_count = 0
    
    for image_file in image_files:
        try:
            product_name = image_file.stem  # Filename without extension
            print(f"📤 Processing: {image_file.name}")
            
            # Read original size
            original_size = image_file.stat().st_size
            
            # Compress to WebP
            webp_data = compress_to_webp(image_file, max_size=800, quality=80)
            compressed_size = len(webp_data)
            
            savings = ((original_size - compressed_size) / original_size * 100)
            print(f"   📊 {original_size:,} → {compressed_size:,} bytes (-{savings:.1f}%)")
            
            # Upload to Firebase Storage
            blob = bucket.blob(f'product_images/{product_name}.webp')
            blob.upload_from_string(
                webp_data,
                content_type='image/webp'
            )
            
            # Set cache control
            blob.cache_control = 'public, max-age=31536000'
            blob.patch()
            
            # Make public
            blob.make_public()
            download_url = blob.public_url
            
            print(f"   ✅ Uploaded: {download_url}")
            
            # Update Firestore products
            old_path = f"assets/images/products/{image_file.name}"
            products_ref = db.collection('products')
            query = products_ref.where('imageUrl', '==', old_path).get()
            
            updated_count = 0
            for doc in query:
                doc.reference.update({'imageUrl': download_url})
                updated_count += 1
                print(f"   🔄 Updated Firestore: {doc.id}")
            
            if updated_count == 0:
                print(f"   ⚠️  No matching products in Firestore")
            
            success_count += 1
            print()
            
        except Exception as e:
            print(f"   ❌ Error: {e}\n")
            error_count += 1
    
    print("=" * 60)
    print("✅ Migration Complete!")
    print(f"   Success: {success_count}")
    print(f"   Errors: {error_count}")
    print("=" * 60)


if __name__ == "__main__":
    main()
