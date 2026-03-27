import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
import json
import os

# 1. Firebase Admin SDK 초기화
# 서비스 계정 키 파일 경로 (프로젝트 루트에 serviceAccountKey.json이 있다고 가정)
CERT_PATH = '../serviceAccountKey.json'

if not os.path.exists(CERT_PATH):
    print(f"Error: {CERT_PATH} 파일이 존재하지 않습니다.")
    print("Firebase 콘솔 -> 프로젝트 설정 -> 서비스 계정에서 '새 비공개 키 생성' 후")
    print("파일 이름을 'serviceAccountKey.json'으로 변경하여 프로젝트 루트에 저장해 주세요.")
    exit(1)

cred = credentials.Certificate(CERT_PATH)
firebase_admin.initialize_app(cred)
db = firestore.client()

def upload_collection(file_path, collection_name, id_field, is_locations_root=False):
    print(f"Uploading {file_path} to {collection_name}...")
    
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
        
    if is_locations_root:
        items = data.get('locations', [])
    else:
        items = data

    batch = db.batch()
    count = 0
    
    for item in items:
        doc_id = str(item.get(id_field))
        if not doc_id or doc_id == 'None':
            continue
            
        doc_ref = db.collection(collection_name).document(doc_id)
        batch.set(doc_ref, item)
        count += 1
        
        # Firestore batch는 최대 500개까지 가능
        if count % 500 == 0:
            batch.commit()
            batch = db.batch()
            print(f"  {count} items committed...")

    batch.commit()
    print(f"Successfully uploaded {count} items to {collection_name}.\n")

if __name__ == "__main__":
    # 파일 경로 설정 (scripts 폴더 기준)
    ASSETS_DIR = '../assets'
    
    # 1. 국문 장소 정보
    upload_collection(
        os.path.join(ASSETS_DIR, 'locations.json'), 
        'locations', 
        'id', 
        is_locations_root=True
    )
    
    # 2. 영문 장소 정보
    upload_collection(
        os.path.join(ASSETS_DIR, 'en_locations.json'), 
        'locations_en', 
        'id'
    )
    
    # 3. 국문 캐릭터 정보
    upload_collection(
        os.path.join(ASSETS_DIR, 'templates.json'), 
        'soopkomon_templates', 
        'templateId'
    )
    
    # 4. 영문 캐릭터 정보
    upload_collection(
        os.path.join(ASSETS_DIR, 'en_templates.json'), 
        'soopkomon_templates_en', 
        'templateId'
    )

    print("All uploads completed!")
