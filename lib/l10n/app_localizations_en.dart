// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Jamore';

  @override
  String get hrm => 'HRM';

  @override
  String get welcome => 'Hello';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get signInContinue => 'Sign in to continue';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get companyId => 'Company ID';

  @override
  String get companyFound => 'Company found';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get signIn => 'Sign in';

  @override
  String get or => 'or';

  @override
  String get useFaceId => 'Use Face ID';

  @override
  String get show => 'Show';

  @override
  String get hide => 'Hide';

  @override
  String get invalidCredentials => 'Invalid sign-in details';

  @override
  String get loginFailed => 'Sign-in failed';

  @override
  String get tryAgain => 'Try again';

  @override
  String get biometricUnavailable =>
      'Sign in with your password at least once first';

  @override
  String get dashboard => 'Home';

  @override
  String get leave => 'Leave';

  @override
  String get worktime => 'Time';

  @override
  String get overtime => 'OT';

  @override
  String get profile => 'Profile';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get workingToday => 'Working today';

  @override
  String get clockIn => 'Clock in';

  @override
  String get clockOut => 'Clock out';

  @override
  String get quickActions => 'Quick actions';

  @override
  String get manageQuickActions => 'Manage quick actions';

  @override
  String get manage => 'Manage';

  @override
  String get quickActionsDashboardPreview => 'Home preview';

  @override
  String quickActionsShownCount(int count) {
    return 'Showing $count actions';
  }

  @override
  String get quickActionsEmpty =>
      'No actions are visible — use a switch below to show one';

  @override
  String get quickActionsAdd => 'Add quick actions';

  @override
  String get quickActionsAll => 'All actions';

  @override
  String get quickActionsAllHint => 'Show, hide, or remove';

  @override
  String get quickActionsRemoved => 'Removed actions';

  @override
  String get restore => 'Restore';

  @override
  String get remove => 'Remove';

  @override
  String get quickActionLeave => 'Leave';

  @override
  String get quickActionOvertime => 'Overtime';

  @override
  String get quickActionShift => 'Shift';

  @override
  String get quickActionPayslip => 'Payslip';

  @override
  String get quickActionTeam => 'Team';

  @override
  String get quickActionHolidays => 'Holidays';

  @override
  String get quickActionExpense => 'Expense';

  @override
  String get quickActionNews => 'News';

  @override
  String get requestLeave => 'Request leave';

  @override
  String get requestOt => 'Request OT';

  @override
  String get shift => 'Shift';

  @override
  String get leaveBalance => 'Leave balance';

  @override
  String get otThisMonth => 'OT this month';

  @override
  String get scheduleToday => 'Today\'s schedule';

  @override
  String get announcements => 'Announcements';

  @override
  String get holidays => 'Upcoming holidays';

  @override
  String get birthdays => 'Team birthdays';

  @override
  String get seeAll => 'See all';

  @override
  String get days => 'days';

  @override
  String get hours => 'hrs';

  @override
  String get baht => 'THB';

  @override
  String get annualLeave => 'Annual leave';

  @override
  String get sickLeave => 'Sick leave';

  @override
  String get personalLeave => 'Personal leave';

  @override
  String get maternityLeave => 'Maternity leave';

  @override
  String get leaveHistory => 'Leave history';

  @override
  String get teamCalendar => 'Team calendar';

  @override
  String get pendingApprovals => 'Approvals';

  @override
  String get all => 'All';

  @override
  String get approved => 'Approved';

  @override
  String get pending => 'Pending';

  @override
  String get rejected => 'Rejected';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get newLeaveRequest => 'New leave request';

  @override
  String get leaveType => 'Leave type';

  @override
  String get dateRange => 'Date range';

  @override
  String get fromDate => 'From';

  @override
  String get toDate => 'To';

  @override
  String get leaveDays => 'Leave days';

  @override
  String get reason => 'Reason';

  @override
  String get reasonHint => 'Enter a reason...';

  @override
  String get attachmentOptional => 'Attachment (optional)';

  @override
  String get chooseFile => 'Choose a certificate or other file';

  @override
  String get submitRequest => 'Submit request';

  @override
  String get leaveSubmitted => 'Leave request submitted';

  @override
  String get waitingManager => 'Waiting for manager approval';

  @override
  String get leaveDetail => 'Leave details';

  @override
  String get approvalTimeline => 'Approval timeline';

  @override
  String get submitted => 'Submitted';

  @override
  String get managerReview => 'Manager review';

  @override
  String get hrApproval => 'HR approval';

  @override
  String get cancelRequest => 'Cancel request';

  @override
  String get confirmCancel => 'Cancel this request?';

  @override
  String get teamPending => 'Pending team leave';

  @override
  String get approve => 'Approve';

  @override
  String get reject => 'Reject';

  @override
  String get confirmApprove => 'Approve this request?';

  @override
  String get rejectionReason => 'Rejection reason';

  @override
  String get requiredField => 'This field is required';

  @override
  String get invalidDateRange => 'End date must not be before start date';

  @override
  String get insufficientBalance =>
      'Leave duration exceeds the available balance';

  @override
  String get noWorkingDays => 'The selected range has no working days';

  @override
  String get filePickerUnavailable =>
      'A real picker will be enabled with the platform adapter';

  @override
  String get fileRules => 'PDF, JPG, PNG up to 5 MB';

  @override
  String get overtimeSummary => 'OT summary';

  @override
  String get newOtRequest => 'New OT request';

  @override
  String get otDate => 'OT date';

  @override
  String get timeRange => 'Time range';

  @override
  String get start => 'Start';

  @override
  String get end => 'End';

  @override
  String get otHours => 'Hours';

  @override
  String get otRate => 'OT rate';

  @override
  String get weekday => 'Weekday';

  @override
  String get dayOff => 'Day off';

  @override
  String get publicHoliday => 'Public holiday';

  @override
  String get otReasonHint => 'Describe the work...';

  @override
  String get estimatedOt => 'Estimated OT pay';

  @override
  String get otSubmitted => 'OT request submitted';

  @override
  String get otDetail => 'OT details';

  @override
  String get invalidTimeRange => 'End time must be after start time';

  @override
  String get worktimeTitle => 'Worktime';

  @override
  String get worktimeTracker => 'Worktime tracker';

  @override
  String get today => 'Today';

  @override
  String get locationVerified => 'Location verified';

  @override
  String get checkInTime => 'Clock in';

  @override
  String get checkOutTime => 'Clock out';

  @override
  String get notClockedIn => 'Not clocked in';

  @override
  String get working => 'Working';

  @override
  String get finished => 'Finished';

  @override
  String get thisWeek => 'This week';

  @override
  String get totalHours => 'Total hours';

  @override
  String get late => 'Late';

  @override
  String get recentHistory => 'Recent history';

  @override
  String get workHistory => 'Work history';

  @override
  String get verifyLocation => 'Verify location';

  @override
  String get insideOffice => 'Inside office area';

  @override
  String get nextSelfie => 'Next — take selfie';

  @override
  String get selfie => 'Selfie';

  @override
  String get placeFace => 'Place your face inside the frame';

  @override
  String get faceVerified => 'Face verified';

  @override
  String get checking => 'Checking...';

  @override
  String get confirm => 'Confirm';

  @override
  String get timeRecorded => 'Time recorded';

  @override
  String get personalInfo => 'Personal information';

  @override
  String get positionTeam => 'Position and team';

  @override
  String get documentsPayslips => 'Documents and payslips';

  @override
  String get notifications => 'Notifications';

  @override
  String get language => 'Language';

  @override
  String get thai => 'ไทย';

  @override
  String get english => 'English';

  @override
  String get resetDemoData => 'Reset demo data';

  @override
  String get resetConfirm => 'All changes will be deleted. Continue?';

  @override
  String get signOut => 'Sign out';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get featureNotDesigned =>
      'This area is not specified in the source design yet';

  @override
  String get back => 'Back';

  @override
  String get close => 'Close';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get reset => 'Reset';

  @override
  String get version => 'Version';

  @override
  String get officeName => 'JAMORE HQ — Floor 14';

  @override
  String get officeAddress => '999/9 Rama I Road, Pathum Wan, Bangkok';

  @override
  String get gpsVerified => 'GPS verified';

  @override
  String get noItems => 'No items';

  @override
  String get attachmentSelected => 'File selected';

  @override
  String get halfDay => 'Half day';

  @override
  String get fullDay => 'Full day';

  @override
  String get profileContact => 'Contact';

  @override
  String get profileEmployment => 'Employment';

  @override
  String get profileSettings => 'Settings';

  @override
  String get profileEmployeeId => 'Employee ID';

  @override
  String get profileDepartment => 'Department';

  @override
  String get profileLevel => 'Level';

  @override
  String get profileTenure => 'Tenure';

  @override
  String get profileLeaveLeft => 'Leave left';

  @override
  String get profileOvertimeThisMonth => 'OT this month';

  @override
  String get profileYearsUnit => 'yr';

  @override
  String get profileMonthsUnit => 'mo';

  @override
  String get profileDaysUnit => 'days';

  @override
  String get profileHoursUnit => 'hrs';

  @override
  String get profileEmail => 'Email';

  @override
  String get profilePhone => 'Phone';

  @override
  String get profileWorkplace => 'Workplace';

  @override
  String get profileStartDate => 'Start date';

  @override
  String get profileEmploymentType => 'Employment type';

  @override
  String get profileReportsTo => 'Reports to';

  @override
  String get profileLanguageHint => 'Choose the app display language';

  @override
  String get profileSecurityPassword => 'Security & password';

  @override
  String get profileHelpContactHr => 'Help & contact HR';

  @override
  String get profileRoleFallback => 'Senior Product Designer';

  @override
  String get profileDesignTeam => 'Design Team';

  @override
  String get profileSeniorLevel => 'P5 · Senior';

  @override
  String get profileOffice => 'JAMORE HQ · Bangkok';

  @override
  String get profileStartDateValue => 'Mar 1, 2022';

  @override
  String get profileFullTime => 'Full-time';

  @override
  String get profileManager => 'Wipha Srisuk';
}
