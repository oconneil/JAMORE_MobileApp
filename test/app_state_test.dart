import 'package:flutter_test/flutter_test.dart';
import 'package:jamore/data/models.dart';

import 'helpers.dart';

void main() {
  group('AppState domain rules', () {
    test(
      'validates demo credentials and persists remembered session',
      () async {
        final store = MemoryStore();
        final auth = FakeAuthGateway();
        final state = await createTestState(store: store, authGateway: auth);

        expect(
          await state.login(
            username: 'wrong',
            password: 'wrong',
            companyId: 'JAMORE-TH',
            rememberMe: true,
          ),
          isFalse,
        );
        expect(await login(state), isTrue);
        expect(state.currentUser?.employeeId, 'E2022-084');
        expect(state.currentEmployee?.employeeId, 'E2022-084');
        expect(state.currentEmployeeResponse, isNotNull);
        expect(state.employeeDisplayName(isThai: true), 'กชวรรณ เอนกลาภ');
        expect(state.employeeDisplayName(isThai: false), 'Kotchawan Aneklap');
        expect(
          state.employeePositionName(isThai: true),
          'หัวหน้าวิศวกรพัฒนาซอฟต์แวร์',
        );
        expect(
          state.employeePositionName(isThai: false),
          'Software Development Engineer Leader',
        );

        final restored = await createTestState(store: store, authGateway: auth);
        expect(restored.isAuthenticated, isTrue);
        expect(restored.location, '/dashboard');
      },
    );

    test('skips employee API when user has no EmployeeID', () async {
      final employeeGateway = FakeEmployeeGateway();
      final state = await createTestState(
        userGateway: FakeUserGateway(employeeId: null),
        employeeGateway: employeeGateway,
      );

      expect(await login(state), isTrue);
      expect(employeeGateway.requestedEmployeeId, isNull);
      expect(state.currentEmployeeResponse, isNull);
      expect(state.currentEmployee, isNull);
      expect(state.location, '/dashboard');
    });

    test('hides position when employee PositionID is missing', () async {
      final state = await createTestState(
        employeeGateway: FakeEmployeeGateway(positionId: null),
      );

      expect(await login(state), isTrue);
      expect(state.employeePositionName(isThai: true), isNull);
      expect(state.employeePositionName(isThai: false), isNull);
    });

    test('counts weekdays and supports half day', () async {
      final state = await createTestState();
      expect(
        state.workingDays(DateTime(2026, 6, 22), DateTime(2026, 6, 26)),
        5,
      );
      expect(
        state.workingDays(
          DateTime(2026, 6, 22),
          DateTime(2026, 6, 22),
          halfDay: true,
        ),
        .5,
      );
      expect(
        state.workingDays(DateTime(2026, 6, 27), DateTime(2026, 6, 28)),
        0,
      );
    });

    test('submitting and cancelling leave mutates local data', () async {
      final state = await createTestState();
      final before = state.data.leaveRequests.length;
      final request = await state.submitLeave(
        kind: LeaveKind.annual,
        start: DateTime(2026, 6, 22),
        end: DateTime(2026, 6, 22),
        days: 1,
        reason: 'Test request',
      );

      expect(state.data.leaveRequests.length, before + 1);
      expect(request.status, RequestStatus.pending);

      await state.cancelLeave(request.id);
      expect(state.data.leaveRequests.first.status, RequestStatus.cancelled);
    });

    test('clock in and clock out follow the two-state sequence', () async {
      var now = DateTime(2026, 6, 20, 8, 30);
      final state = await createTestState(clock: () => now);

      expect(state.todayLog, isNull);
      await state.recordTime();
      expect(state.todayLog?.isWorking, isTrue);

      now = DateTime(2026, 6, 20, 17, 45);
      await state.recordTime();
      expect(state.todayLog?.isWorking, isFalse);
      expect(state.todayLog?.clockOut, now);

      await state.recordTime();
      expect(state.todayLog?.clockOut, now);
    });

    test('approval rejection records reason and timestamp', () async {
      final state = await createTestState();
      final item = state.data.teamApprovals.first;

      await state.decideApproval(item.id, false, reason: 'Capacity');

      final updated = state.data.teamApprovals.first;
      expect(updated.status, RequestStatus.rejected);
      expect(updated.decisionReason, 'Capacity');
      expect(updated.decidedAt, isNotNull);
    });
  });
}
