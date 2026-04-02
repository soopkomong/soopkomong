import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:soopkomong/domain/entities/app_user.dart';
import 'package:soopkomong/domain/entities/friend_request.dart';
import 'package:soopkomong/domain/repositories/auth_repository.dart';
import 'package:soopkomong/domain/repositories/friend_repository.dart';
import 'package:soopkomong/presentation/providers/auth_provider.dart';
import 'package:soopkomong/presentation/providers/friend_provider.dart';
import 'package:soopkomong/presentation/friends/widgets/friends_view_model.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockFriendRepository extends Mock implements FriendRepository {}
class FakeAppUser extends Fake implements AppUser {}
class FakeFriendRequest extends Fake implements FriendRequest {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockFriendRepository mockFriendRepository;
  late ProviderContainer container;
  late AppUser testUser;

  setUpAll(() {
    registerFallbackValue(FakeAppUser());
    registerFallbackValue(FakeFriendRequest());
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockFriendRepository = MockFriendRepository();

    testUser = AppUser(
      id: 'test_user_id',
      displayName: 'Test User',
      email: 'test@example.com',
    );

    // Mock currentUser getter
    when(() => mockAuthRepository.currentUser).thenReturn(testUser);

    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepository),
        friendRepositoryProvider.overrideWithValue(mockFriendRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('FriendsViewModel Notification Logic Tests', () {
    test('acceptFriendRequest calls friendRepo.acceptFriendRequest with current user', () async {
      // Arrange
      final request = FriendRequest(
        id: 'req_123',
        senderId: 'sender_456',
        senderName: 'Sender',
        receiverId: 'test_user_id',
        status: FriendRequestStatus.pending,
        notified: false,
        timestamp: DateTime.now(),
      );

      when(() => mockFriendRepository.acceptFriendRequest(any(), any()))
          .thenAnswer((_) async {});

      final viewModel = container.read(friendsViewModelProvider.notifier);

      // Act
      await viewModel.acceptFriendRequest(request);

      // Assert
      verify(() => mockFriendRepository.acceptFriendRequest(testUser, request)).called(1);
    });

    test('declineFriendRequest calls friendRepo.declineFriendRequest', () async {
      // Arrange
      const String requestId = 'req_123';
      when(() => mockFriendRepository.declineFriendRequest(any()))
          .thenAnswer((_) async {});

      final viewModel = container.read(friendsViewModelProvider.notifier);

      // Act
      await viewModel.declineFriendRequest(requestId);

      // Assert
      verify(() => mockFriendRepository.declineFriendRequest(requestId)).called(1);
    });

    test('markAllPendingRequestsAsNotified calls friendRepo with current user id', () async {
      // Arrange
      when(() => mockFriendRepository.markAllPendingRequestsAsNotified(any()))
          .thenAnswer((_) async {});

      final viewModel = container.read(friendsViewModelProvider.notifier);

      // Act
      await viewModel.markAllPendingRequestsAsNotified();

      // Assert
      verify(() => mockFriendRepository.markAllPendingRequestsAsNotified(testUser.id)).called(1);
    });

    test('markNotified calls friendRepo.markNotified', () async {
      // Arrange
      const String requestId = 'req_123';
      when(() => mockFriendRepository.markNotified(any()))
          .thenAnswer((_) async {});

      final viewModel = container.read(friendsViewModelProvider.notifier);

      // Act
      await viewModel.markNotified(requestId);

      // Assert
      verify(() => mockFriendRepository.markNotified(requestId)).called(1);
    });

    test('deleteNotification calls friendRepo.deleteNotification', () async {
      // Arrange
      const String requestId = 'req_123';
      when(() => mockFriendRepository.deleteNotification(any()))
          .thenAnswer((_) async {});

      final viewModel = container.read(friendsViewModelProvider.notifier);

      // Act
      await viewModel.deleteNotification(requestId);

      // Assert
      verify(() => mockFriendRepository.deleteNotification(requestId)).called(1);
    });

    test('does not call friendRepo if user is not logged in', () async {
      // Arrange
      when(() => mockAuthRepository.currentUser).thenReturn(null);
      final viewModel = container.read(friendsViewModelProvider.notifier);
      final request = FriendRequest(
        id: 'req_123',
        senderId: 'sender_456',
        senderName: 'Sender',
        receiverId: 'test_user_id',
        status: FriendRequestStatus.pending,
        notified: false,
        timestamp: DateTime.now(),
      );

      // Act
      await viewModel.acceptFriendRequest(request);
      await viewModel.markAllPendingRequestsAsNotified();

      // Assert
      verifyNever(() => mockFriendRepository.acceptFriendRequest(any(), any()));
      verifyNever(() => mockFriendRepository.markAllPendingRequestsAsNotified(any()));
    });
  });
}
