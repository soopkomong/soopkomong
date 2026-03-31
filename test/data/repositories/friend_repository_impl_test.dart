import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soopkomong/data/repositories/friend_repository_impl.dart';
import 'package:soopkomong/domain/entities/app_user.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FriendRepositoryImpl repository;

  // 테스트용 유저 데이터
  final userA = AppUser(
    id: 'user_a',
    displayName: 'User A',
    email: 'user_a@test.com',
    userCode: 'CODE_A',
    hasName: true,
  );

  final userB = AppUser(
    id: 'user_b',
    displayName: 'User B',
    email: 'user_b@test.com',
    userCode: 'CODE_B',
    hasName: true,
  );

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();
    repository = FriendRepositoryImpl(fakeFirestore);

    // 유저 초기 데이터 Firestore 주입 (타입 명시)
    await fakeFirestore.collection('users').doc(userA.id).set(<String, dynamic>{
      'displayName': userA.displayName,
      'email': userA.email,
      'user_code': userA.userCode,
      'has_name': true,
      'friends': <String>[],
      'friendships': <String, dynamic>{},
    });

    await fakeFirestore.collection('users').doc(userB.id).set(<String, dynamic>{
      'displayName': userB.displayName,
      'email': userB.email,
      'user_code': userB.userCode,
      'has_name': true,
      'friends': <String>[],
      'friendships': <String, dynamic>{},
    });
  });

  group('FriendRepositoryImpl Unit Tests', () {
    test('sendFriendRequest: Successfully creates a request document', () async {
      await repository.sendFriendRequest(userA, userB.id);

      final requests = await fakeFirestore.collection('friend_requests').get();
      expect(requests.docs.length, 1);
      expect(requests.docs.first['senderId'], userA.id);
      expect(requests.docs.first['receiverId'], userB.id);
      expect(requests.docs.first['status'], 'pending');
    });

    test('sendFriendRequest: Throws exception on duplicate request (Outbound)', () async {
      await repository.sendFriendRequest(userA, userB.id);

      expect(
        () => repository.sendFriendRequest(userA, userB.id),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('이미 친구 요청을 보냈습니다'))),
      );
    });

    test('sendFriendRequest: Throws exception if receiving pending request exist (Inbound)', () async {
      await repository.sendFriendRequest(userB, userA.id);

      expect(
        () => repository.sendFriendRequest(userA, userB.id),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('상대방으로부터 받은 친구 요청이 이미 있습니다'))),
      );
    });

    test('acceptFriendRequest: Updates both users and request status', () async {
      await repository.sendFriendRequest(userA, userB.id);
      final requestId = (await fakeFirestore.collection('friend_requests').get()).docs.first.id;

      final friendRequest = (await repository.getPendingFriendRequests(userB.id).first).first;
      await repository.acceptFriendRequest(userB, friendRequest);

      final requestDoc = await fakeFirestore.collection('friend_requests').doc(requestId).get();
      expect(requestDoc['status'], 'accepted');

      final docA = await fakeFirestore.collection('users').doc(userA.id).get();
      final docB = await fakeFirestore.collection('users').doc(userB.id).get();

      expect((docA['friends'] as List).contains(userB.id), true);
      expect((docB['friends'] as List).contains(userA.id), true);
    });

    test('removeFriend: Removes friend from both users and cleans up requests', () async {
      await repository.sendFriendRequest(userA, userB.id);
      final friendRequest = (await repository.getPendingFriendRequests(userB.id).first).first;
      await repository.acceptFriendRequest(userB, friendRequest);

      await repository.removeFriend(userA.id, userB.id);

      final docA = await fakeFirestore.collection('users').doc(userA.id).get();
      final docB = await fakeFirestore.collection('users').doc(userB.id).get();

      expect((docA['friends'] as List).contains(userB.id), false);
      expect((docB['friends'] as List).contains(userA.id), false);

      final requests = await fakeFirestore.collection('friend_requests').get();
      expect(requests.docs.isEmpty, true);
    });
  });
}
