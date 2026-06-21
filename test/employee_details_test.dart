import 'package:flutter_test/flutter_test.dart';
import 'package:jamore/domain/entities/employee_details.dart';

void main() {
  test('calculates tenure as full calendar years, months, and days', () {
    final employee = EmployeeDetails(
      employeeId: 'E2022-084',
      startDate: DateTime(2022, 4, 18),
    );

    final tenure = employee.tenureAsOf(DateTime(2026, 6, 21));

    expect(tenure?.years, 4);
    expect(tenure?.months, 2);
    expect(tenure?.days, 3);
  });

  test('clamps leap-day anniversary to the last day of February', () {
    final employee = EmployeeDetails(
      employeeId: 'E2020-001',
      startDate: DateTime(2020, 2, 29),
    );

    final tenure = employee.tenureAsOf(DateTime(2021, 2, 28));

    expect(tenure?.years, 1);
    expect(tenure?.months, 0);
    expect(tenure?.days, 0);
  });

  test('returns no tenure when start date is in the future', () {
    final employee = EmployeeDetails(
      employeeId: 'E2026-001',
      startDate: DateTime(2026, 7, 1),
    );

    expect(employee.tenureAsOf(DateTime(2026, 6, 21)), isNull);
  });
}
