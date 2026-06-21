# JAMORE HRM

JAMORE HRM lets an employee authenticate against JAMORE Universe, enter the selected company's customer environment, and manage daily HR workflows.

## Language

**Authenticated session**:
The signed-in employee context containing the Universe token, customer token, selected company, user profile, and optional employee profile.
_Avoid_: Login state, auth blob

**Customer environment**:
The selected company's JAMORE server and customer token used for company-scoped requests after Universe authentication.
_Avoid_: Tenant API, secondary backend

**HR workspace**:
The employee's current locale, session flags, leave requests, overtime requests, approvals, and work logs as one persisted snapshot.
_Avoid_: DemoData, app data

**Leave request**:
An employee request to consume a leave balance over one or more working days.

**Overtime request**:
An employee request to record paid work outside regular hours at an approved rate.
_Avoid_: OT item

**Work log**:
An employee's daily clock-in and clock-out record.
_Avoid_: Time item
