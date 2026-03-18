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
        // Firestore ID는 대소문자를 구분하므로, 입력된 receiverId를 그대로 사용합니다.
        const userDoc = await admin.firestore().collection('users').doc(receiverId).get();
        
        if (!userDoc.exists) {
            console.log(`[경고] 수신자 문서가 존재하지 않음: ${receiverId}`);
            return null;
        }

        const userData = userDoc.data();
        const fcmToken = userData.fcmToken;
        
        if (!fcmToken) {
            console.log(`[정보] 수신자의 FCM 토큰이 없음 (유저: ${receiverId}, 이름: ${userData.displayName || '미설정'})`);
            return null;
        }

        // 2. 푸시 알림 메시지 구성 (Android/iOS 안정성 강화)
        const message = {
            notification: {
                title: '새로운 친구 요청!',
                body: `${senderName}님이 숲코몽에서 친구를 요청했습니다.`,
            },
            data: {
                type: 'friend_request',
                senderId: requestData.senderId,
                click_action: 'FLUTTER_NOTIFICATION_CLICK'
            },
            android: {
                priority: 'high',
                notification: {
                    channelId: 'high_importance_channel',
                    clickAction: 'FLUTTER_NOTIFICATION_CLICK'
                }
            },
            apns: {
                payload: {
                    aps: {
                        contentAvailable: true,
                        badge: 1,
                        sound: 'default'
                    }
                }
            },
            token: fcmToken
        };

        // 3. 메시지 전송
        const response = await admin.messaging().send(message);
        console.log(`[성공] 푸시 알림 전송 완료 (수신자: ${receiverId}):`, response);
        return response;

    } catch (error) {
        console.error(`[에러] 푸시 알림 전송 중 실패 (수신자: ${receiverId}):`, error);
        return null;
    }
});