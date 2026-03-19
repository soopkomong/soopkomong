import json
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore

# Firebase Admin SDK가 필요합니다 (로컬에서 실행 시 필요)
# 하지만 MCP 환경에서는 firestore_add_document 툴을 사용하는 것이 안전합니다.
# 이 스크립트는 원칙적으로 사용자가 자신의 PC에서 실행하거나 가이드용입니다.

def migrate():
    try:
        with open('assets/templates.json', 'r', encoding='utf-8') as f:
            templates = json.load(f)
        
        print(f"총 {len(templates)}개의 템플릿을 발견했습니다.")
        
        # 실제 배포 환경에서는 ADC(Application Default Credentials)를 통해 인증됩니다.
        db = firestore.client()
        
        for t in templates:
            doc_id = t['templateId']
            db.collection('templates').document(doc_id).set(t)
            print(f"업로드 성공: {doc_id} ({t['name']})")
            
        print("마이그레이션 완료!")
        
    except Exception as e:
        print(f"에러 발생: {e}")

if __name__ == "__main__":
    print("Firestore 마이그레이션 도구")
    # 주의: 이 스크립트를 직접 실행하려면 firebase-admin 패키지가 설치되어 있어야 하며
    # GOOGLE_APPLICATION_CREDENTIALS 환경 변수가 설정되어 있어야 합니다.
    # migrate()
