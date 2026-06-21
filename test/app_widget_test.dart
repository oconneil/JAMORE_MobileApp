import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jamore/app.dart';
import 'package:jamore/state/app_state.dart';
import 'package:provider/provider.dart';

import 'helpers.dart';

Widget testApp(AppState state) =>
    ChangeNotifierProvider.value(value: state, child: const JamoreApp());

void main() {
  testWidgets('login validates credentials and opens dashboard', (
    tester,
  ) async {
    final state = await createTestState();
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(testApp(state));

    expect(find.byKey(const Key('signInButton')), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('usernameField')),
      'nattawut.c',
    );
    await tester.enterText(find.byKey(const Key('passwordField')), 'jamore123');
    await tester.enterText(find.byKey(const Key('companyField')), 'JAMORE-TH');
    await tester.tap(find.byKey(const Key('signInButton')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();

    expect(state.isAuthenticated, isTrue);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('กชวรรณ เอนกลาภ'), findsOneWidget);
    expect(find.text('หัวหน้าวิศวกรพัฒนาซอฟต์แวร์'), findsOneWidget);
    expect(find.text('สวัสดีตอนเช้า'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dashboard avatar uses English employee initials', (
    tester,
  ) async {
    final state = await createTestState();
    await login(state);
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(testApp(state));
    await tester.pumpAndSettle();

    expect(find.text('KA'), findsOneWidget);
    expect(find.text('NJ'), findsNothing);
  });

  testWidgets('dashboard avatar shows employee image when ImgFile exists', (
    tester,
  ) async {
    final imageBytes = Uint8List.fromList(
      base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQIHWP4z8DwHwAFgAI/ScL1WQAAAABJRU5ErkJggg==',
      ),
    );
    final employeeGateway = FakeEmployeeGateway(
      imageFile: 'E2022-084.jpg',
      imageBytes: imageBytes,
    );
    final state = await createTestState(employeeGateway: employeeGateway);
    await login(state);
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(testApp(state));
    await tester.pumpAndSettle();

    expect(employeeGateway.requestedEmployeeImageId, 'E2022-084');
    expect(find.byKey(const Key('dashboardAvatarImage')), findsOneWidget);
    expect(find.byKey(const Key('dashboardAvatarInitials')), findsNothing);
  });

  testWidgets('invalid login displays localized error', (tester) async {
    final state = await createTestState();
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(testApp(state));
    await tester.enterText(
      find.byKey(const Key('usernameField')),
      'nattawut.c',
    );
    await tester.enterText(find.byKey(const Key('passwordField')), 'wrong');
    await tester.enterText(find.byKey(const Key('companyField')), 'JAMORE-TH');
    await tester.tap(find.byKey(const Key('signInButton')));
    await tester.pumpAndSettle();

    // The failure is surfaced in a centered alert dialog.
    expect(find.byType(Dialog), findsOneWidget);
    expect(find.byKey(const Key('loginError')), findsOneWidget);
    expect(find.text('ข้อมูลเข้าสู่ระบบไม่ถูกต้อง'), findsOneWidget);
  });

  for (final size in <Size>[
    const Size(390, 844),
    const Size(800, 1024),
    const Size(1280, 900),
  ]) {
    testWidgets('dashboard has no layout errors at ${size.width}px', (
      tester,
    ) async {
      final state = await createTestState();
      await login(state);
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(testApp(state));
      await tester.pump();

      if (size.width < 720) {
        expect(find.byType(NavigationBar), findsOneWidget);
      } else {
        expect(find.byType(NavigationRail), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('language selection updates the full app', (tester) async {
    final state = await createTestState();
    await login(state);
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(testApp(state));
    await tester.pumpAndSettle();

    state.navigate('/profile');
    await tester.pumpAndSettle();

    await state.setLocale('en');
    await tester.pumpAndSettle();

    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Sign out'), findsOneWidget);
    expect(find.text('Kotchawan Aneklap'), findsOneWidget);
    expect(find.text('Software Engineering'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('profile destination opens the designed profile screen', (
    tester,
  ) async {
    final state = await createTestState();
    await login(state);
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(testApp(state));
    await tester.pumpAndSettle();

    final profileDestination = find.descendant(
      of: find.byType(NavigationBar),
      matching: find.byIcon(Icons.person_rounded),
    );
    await tester.tap(profileDestination);
    await tester.pumpAndSettle();

    expect(state.location, '/profile');
    expect(find.byKey(const Key('profileHeader')), findsOneWidget);
    expect(find.text('วิศวกรรมซอฟต์แวร์'), findsOneWidget);
    expect(find.text('ระดับ'), findsNothing);
    expect(find.text('4ปี'), findsOneWidget);
    expect(find.text('2เดือน 2วัน'), findsOneWidget);
    expect(find.byKey(const Key('languageSelector')), findsOneWidget);
    expect(find.byKey(const Key('signOutButton')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('profile avatar shows employee image when ImgFile exists', (
    tester,
  ) async {
    final imageBytes = Uint8List.fromList(
      base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQIHWP4z8DwHwAFgAI/ScL1WQAAAABJRU5ErkJggg==',
      ),
    );
    final state = await createTestState(
      employeeGateway: FakeEmployeeGateway(
        imageFile: 'E2022-084.jpg',
        imageBytes: imageBytes,
      ),
    );
    await login(state);
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(testApp(state));
    await tester.pumpAndSettle();
    state.navigate('/profile');
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('profileAvatarImage')), findsOneWidget);
    expect(find.byKey(const Key('profileAvatarInitials')), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
