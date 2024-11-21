import firebase_admin
from firebase_admin import credentials, firestore, storage
import sys
import time

def initialize_firebase():
    # Firebase 인증 정보를 제공하는 서비스 계정 키 파일을 다운로드하고 경로를 설정합니다.
    cred = credentials.Certificate('univ-capstone2024-firebase-adminsdk-e5qv1-deb3ea0dca.json')
    firebase_admin.initialize_app(cred, {
        'storageBucket': 'univ-capstone2024.appspot.com'  # Firebase Storage 버킷 설정
    })
    return firestore.client()

def upload_video_to_storage(user_id):
    bucket = storage.bucket()  # Firebase Storage 버킷에 접근
    video_path = 'videos/test.mp4'
    
    # 파일을 Firebase Storage에 업로드
    blob = bucket.blob(f'users/{user_id}/models/test.mp4')
    blob.upload_from_filename(video_path)
    blob.make_public()  # 파일을 공개 설정 (공개 URL을 사용할 수 있게 설정)

    return blob.public_url

def add_video_url_to_firestore(db, user_id, video_url):
    # Firestore에 video URL을 추가합니다.
    doc_ref = db.collection('users').document(user_id).collection('models').document('model1')  # 문서 ID는 예시입니다.
    doc_ref.set({
        'videoUrl': video_url
    })
    print(f'Video URL {video_url} added to Firestore under users/{user_id}/models/model1')

def main():
    user_id = sys.argv[1]  # Express에서 전달한 userId
    db = initialize_firebase()
    
    # 5초 대기 후 파일 업로드 및 Firestore에 URL 추가
    time.sleep(5)  # 5초 대기
    
    video_url = upload_video_to_storage(user_id)  # Firebase Storage에 비디오 업로드
    add_video_url_to_firestore(db, user_id, video_url)  # Firestore에 URL 추가

if __name__ == "__main__":
    main()
