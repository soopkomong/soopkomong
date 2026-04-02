import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soopkomong/domain/entities/app_user.dart';
import 'package:soopkomong/presentation/mypage/widgets/profile_card.dart';
import 'package:soopkomong/presentation/providers/auth_provider.dart';
import 'package:soopkomong/presentation/providers/locale_provider.dart';
import 'package:soopkomong/core/enums/app_locale.dart';
import 'package:intl/intl.dart';

// Mock Notifier for Locale
class MockLocaleNotifier extends LocaleNotifier {
  final AppLocale _initialLocale;
  MockLocaleNotifier(this._initialLocale);

  @override
  AppLocale build() => _initialLocale;
}

void main() {
  testWidgets('ProfileCard displays total steps correctly with formatting (Korean)', (WidgetTester tester) async {
    // 1. Mock 데이터 준비
    const testSteps = 1234567;
    final stepFormat = NumberFormat('#,###');
    final expectedStepText = '총 ${stepFormat.format(testSteps)} 걸음';

    final mockUser = AppUser(
      id: 'test-user',
      displayName: '장보고',
      totalSteps: testSteps,
    );

    // 2. 위젯 렌더링 (Providers Override)
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userProvider.overrideWith((ref) => Stream.value(mockUser)),
          localeProvider.overrideWith(() => MockLocaleNotifier(AppLocale.ko)),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: ProfileCard(),
          ),
        ),
      ),
    );

    // StreamProvider 값이 로드될 때까지 대기
    await tester.pump(); 

    // 3. 검증
    expect(find.text('장보고'), findsOneWidget);
    expect(find.text(expectedStepText), findsOneWidget);
  });

  testWidgets('ProfileCard displays total steps correctly (English)', (WidgetTester tester) async {
    const testSteps = 50000;
    final mockUser = AppUser(
      id: 'test-user',
      displayName: 'John Doe',
      totalSteps: testSteps,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userProvider.overrideWith((ref) => Stream.value(mockUser)),
          localeProvider.overrideWith(() => MockLocaleNotifier(AppLocale.en)),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: ProfileCard(),
          ),
        ),
      ),
    );

    await tester.pump();

    // 영어일 때 포맷 확인: "50,000 Total Steps"
    expect(find.text('50,000 Total Steps'), findsOneWidget);
  });

  testWidgets('ProfileCard displays "0 Total Steps" for new user (English)', (WidgetTester tester) async {
    final mockUser = AppUser(
      id: 'test-user',
      displayName: 'Newbie',
      totalSteps: 0,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userProvider.overrideWith((ref) => Stream.value(mockUser)),
          localeProvider.overrideWith(() => MockLocaleNotifier(AppLocale.en)),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: ProfileCard(),
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('0 Total Steps'), findsOneWidget);
  });
}
