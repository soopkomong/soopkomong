import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soopkomong/domain/entities/app_user.dart';
import 'package:soopkomong/domain/entities/friend_request.dart';
import 'package:soopkomong/domain/repositories/friend_repository.dart';
import 'package:soopkomong/presentation/providers/auth_provider.dart';
import 'package:soopkomong/presentation/providers/friend_provider.dart';
import 'package:soopkomong/presentation/providers/friend_request_provider.dart';

class MockFriendRepository extends Mock implements FriendRepository {}

void main() {
  late MockFriendRepository mockFriendRepo;

  setUp(() {
    mockFriendRepo = MockFriendRepository();
  });

  test('userProvider가 로딩 중일 때 friendRequestProvider는 즉시 빈 리스트([])를 방출해야 함', () async {
    final container = ProviderContainer(
      overrides: [
        friendRepositoryProvider.overrideWithValue(mockFriendRepo),
        userProvider.overrideWith((ref) => const Stream.empty()),
      ],
    );
    addTearDown(container.dispose);

    // StreamProvider의 첫 번째 데이터([])가 나올 때까지 대기
    final result = await container.read(friendRequestProvider.future);
    
    expect(result, isEmpty);
    // 상태가 AsyncData인지 확인
    expect(container.read(friendRequestProvider), isA<AsyncData<List<FriendRequest>>>());
  });

  test('userProvider가 데이터를 가지고 있을 때 friendRepo의 데이터를 반환해야 함', () async {
    final testUser = AppUser(id: 'test-user-id');
    final requests = [
      FriendRequest(
        id: 'req-1',
        senderId: 'sender-1',
        senderName: '보낸이',
        senderPhotoUrl: null,
        receiverId: 'test-user-id',
        status: FriendRequestStatus.pending,
        notified: false,
        timestamp: DateTime.now(),
      ),
    ];

    when(() => mockFriendRepo.getPendingFriendRequests('test-user-id'))
        .thenAnswer((_) => Stream.value(requests));

    final container = ProviderContainer(
      overrides: [
        friendRepositoryProvider.overrideWithValue(mockFriendRepo),
        userProvider.overrideWith((ref) => Stream.value(testUser)),
      ],
    );
    addTearDown(container.dispose);

    // 데이터가 로드될 때까지 대기
    final result = await container.read(friendRequestProvider.future);
    
    expect(result, requests);
    expect(container.read(friendRequestProvider).value, requests);
  });

  test('userProvider가 에러 상태일 때 friendRequestProvider도 에러를 전파해야 함', () async {
    final exception = Exception('Auth Error');
    
    final container = ProviderContainer(
      overrides: [
        friendRepositoryProvider.overrideWithValue(mockFriendRepo),
        userProvider.overrideWith((ref) => Stream.error(exception)),
      ],
    );
    addTearDown(container.dispose);

    // .future는 스트림의 에러를 throw함
    expect(container.read(friendRequestProvider.future), throwsA(isA<Exception>()));
    
    // 비동기 작업이 완료되도록 대기
    await pumpEventQueue();
    
    final state = container.read(friendRequestProvider);
    expect(state, isA<AsyncError>());
    expect(state.error, exception);
  });
}
