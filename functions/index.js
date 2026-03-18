const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { setGlobalOptions } = require("firebase-functions/v2");
const admin = require("firebase-admin");

// Firebase Admin SDK 초기화
admin.initializeApp();

// 리전(지역) 설정 - 한국 사용자가 많다면 'asia-northeast3'(서울)를 권장합니다.
setGlobalOptions({ region: "asia-northeast3" });

/**
 * Firestore의 friend_requests 컬렉션에 새 문서가 생성될 때 실행 (v2 방식)
 */
exports.sendFriendRequestNotification = onDocumentCreated("friend_requests/{requestId}", async (event) => {
    // v2에서는 snap 대신 event.data를 사용합니다.
    const requestData = event.data.data();
    if (!requestData) {
        console.log("데이터가 없습니다.");
        return null;
    }

    const receiverId = requestData.receiverId;
    const senderName = requestData.senderName || '누군가';

    try {
        // 1. 수신자의 사용자 문서에서 FCM 토큰 가져오기
        const userDoc = await admin.firestore().collection('users').doc(receiverId).get();
        
        if (!userDoc.exists) {
            console.log(`수신자 문서가 없습니다: ${receiverId}`);
            return null;
        }

        const fcmToken = userDoc.data().fcmToken;
        if (!fcmToken) {
            console.log(`수신자의 FCM 토큰이 없습니다. (유저: ${receiverId})`);
            return null;
        }

        // 2. 푸시 알림 메시지 구성
        const message = {
            notification: {
                title: '새로운 친구 요청!',
                body: `${senderName}님이 숲코몽에서 친구를 요청했습니다.`,
            },
            data: {
                type: 'friend_request',
                senderId: requestData.senderId
            },
            token: fcmToken
        };

        // 3. 메시지 전송
        const response = await admin.messaging().send(message);
        console.log('푸시 알림 전송 성공:', response);
        return response;

    } catch (error) {
        console.error('푸시 알림 전송 중 에러 발생:', error);
        return null;
    }
});