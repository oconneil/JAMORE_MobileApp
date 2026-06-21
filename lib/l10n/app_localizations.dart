import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_th.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('th'),
  ];

  /// No description provided for @appName.
  ///
  /// In th, this message translates to:
  /// **'Jamore'**
  String get appName;

  /// No description provided for @hrm.
  ///
  /// In th, this message translates to:
  /// **'HRM'**
  String get hrm;

  /// No description provided for @welcome.
  ///
  /// In th, this message translates to:
  /// **'สวัสดี'**
  String get welcome;

  /// No description provided for @welcomeBack.
  ///
  /// In th, this message translates to:
  /// **'ยินดีต้อนรับกลับ'**
  String get welcomeBack;

  /// No description provided for @signInContinue.
  ///
  /// In th, this message translates to:
  /// **'เข้าสู่ระบบเพื่อดำเนินการต่อ'**
  String get signInContinue;

  /// No description provided for @username.
  ///
  /// In th, this message translates to:
  /// **'ชื่อผู้ใช้'**
  String get username;

  /// No description provided for @password.
  ///
  /// In th, this message translates to:
  /// **'รหัสผ่าน'**
  String get password;

  /// No description provided for @companyId.
  ///
  /// In th, this message translates to:
  /// **'รหัสบริษัท'**
  String get companyId;

  /// No description provided for @companyFound.
  ///
  /// In th, this message translates to:
  /// **'พบบริษัท'**
  String get companyFound;

  /// No description provided for @rememberMe.
  ///
  /// In th, this message translates to:
  /// **'จดจำการเข้าสู่ระบบ'**
  String get rememberMe;

  /// No description provided for @forgotPassword.
  ///
  /// In th, this message translates to:
  /// **'ลืมรหัสผ่าน?'**
  String get forgotPassword;

  /// No description provided for @signIn.
  ///
  /// In th, this message translates to:
  /// **'เข้าสู่ระบบ'**
  String get signIn;

  /// No description provided for @or.
  ///
  /// In th, this message translates to:
  /// **'หรือ'**
  String get or;

  /// No description provided for @useFaceId.
  ///
  /// In th, this message translates to:
  /// **'ใช้ Face ID'**
  String get useFaceId;

  /// No description provided for @show.
  ///
  /// In th, this message translates to:
  /// **'แสดง'**
  String get show;

  /// No description provided for @hide.
  ///
  /// In th, this message translates to:
  /// **'ซ่อน'**
  String get hide;

  /// No description provided for @invalidCredentials.
  ///
  /// In th, this message translates to:
  /// **'ข้อมูลเข้าสู่ระบบไม่ถูกต้อง'**
  String get invalidCredentials;

  /// No description provided for @loginFailed.
  ///
  /// In th, this message translates to:
  /// **'เข้าสู่ระบบไม่สำเร็จ'**
  String get loginFailed;

  /// No description provided for @tryAgain.
  ///
  /// In th, this message translates to:
  /// **'ลองอีกครั้ง'**
  String get tryAgain;

  /// No description provided for @biometricUnavailable.
  ///
  /// In th, this message translates to:
  /// **'กรุณาเข้าสู่ระบบด้วยรหัสผ่านอย่างน้อยหนึ่งครั้ง'**
  String get biometricUnavailable;

  /// No description provided for @dashboard.
  ///
  /// In th, this message translates to:
  /// **'หน้าหลัก'**
  String get dashboard;

  /// No description provided for @leave.
  ///
  /// In th, this message translates to:
  /// **'การลา'**
  String get leave;

  /// No description provided for @worktime.
  ///
  /// In th, this message translates to:
  /// **'เวลา'**
  String get worktime;

  /// No description provided for @overtime.
  ///
  /// In th, this message translates to:
  /// **'OT'**
  String get overtime;

  /// No description provided for @profile.
  ///
  /// In th, this message translates to:
  /// **'โปรไฟล์'**
  String get profile;

  /// No description provided for @goodMorning.
  ///
  /// In th, this message translates to:
  /// **'สวัสดีตอนเช้า'**
  String get goodMorning;

  /// No description provided for @workingToday.
  ///
  /// In th, this message translates to:
  /// **'กำลังทำงานวันนี้'**
  String get workingToday;

  /// No description provided for @clockIn.
  ///
  /// In th, this message translates to:
  /// **'ลงเวลาเข้างาน'**
  String get clockIn;

  /// No description provided for @clockOut.
  ///
  /// In th, this message translates to:
  /// **'ลงเวลาออกงาน'**
  String get clockOut;

  /// No description provided for @quickActions.
  ///
  /// In th, this message translates to:
  /// **'ทางลัด'**
  String get quickActions;

  /// No description provided for @requestLeave.
  ///
  /// In th, this message translates to:
  /// **'ขอลา'**
  String get requestLeave;

  /// No description provided for @requestOt.
  ///
  /// In th, this message translates to:
  /// **'ขอ OT'**
  String get requestOt;

  /// No description provided for @shift.
  ///
  /// In th, this message translates to:
  /// **'กะงาน'**
  String get shift;

  /// No description provided for @leaveBalance.
  ///
  /// In th, this message translates to:
  /// **'วันลาคงเหลือ'**
  String get leaveBalance;

  /// No description provided for @otThisMonth.
  ///
  /// In th, this message translates to:
  /// **'OT เดือนนี้'**
  String get otThisMonth;

  /// No description provided for @scheduleToday.
  ///
  /// In th, this message translates to:
  /// **'ตารางวันนี้'**
  String get scheduleToday;

  /// No description provided for @announcements.
  ///
  /// In th, this message translates to:
  /// **'ประกาศ'**
  String get announcements;

  /// No description provided for @holidays.
  ///
  /// In th, this message translates to:
  /// **'วันหยุดถัดไป'**
  String get holidays;

  /// No description provided for @birthdays.
  ///
  /// In th, this message translates to:
  /// **'วันเกิดเพื่อนร่วมงาน'**
  String get birthdays;

  /// No description provided for @seeAll.
  ///
  /// In th, this message translates to:
  /// **'ดูทั้งหมด'**
  String get seeAll;

  /// No description provided for @days.
  ///
  /// In th, this message translates to:
  /// **'วัน'**
  String get days;

  /// No description provided for @hours.
  ///
  /// In th, this message translates to:
  /// **'ชม.'**
  String get hours;

  /// No description provided for @baht.
  ///
  /// In th, this message translates to:
  /// **'บาท'**
  String get baht;

  /// No description provided for @annualLeave.
  ///
  /// In th, this message translates to:
  /// **'ลาพักร้อน'**
  String get annualLeave;

  /// No description provided for @sickLeave.
  ///
  /// In th, this message translates to:
  /// **'ลาป่วย'**
  String get sickLeave;

  /// No description provided for @personalLeave.
  ///
  /// In th, this message translates to:
  /// **'ลากิจ'**
  String get personalLeave;

  /// No description provided for @maternityLeave.
  ///
  /// In th, this message translates to:
  /// **'ลาคลอด'**
  String get maternityLeave;

  /// No description provided for @leaveHistory.
  ///
  /// In th, this message translates to:
  /// **'ประวัติการลา'**
  String get leaveHistory;

  /// No description provided for @teamCalendar.
  ///
  /// In th, this message translates to:
  /// **'ปฏิทินทีม'**
  String get teamCalendar;

  /// No description provided for @pendingApprovals.
  ///
  /// In th, this message translates to:
  /// **'รออนุมัติ'**
  String get pendingApprovals;

  /// No description provided for @all.
  ///
  /// In th, this message translates to:
  /// **'ทั้งหมด'**
  String get all;

  /// No description provided for @approved.
  ///
  /// In th, this message translates to:
  /// **'อนุมัติ'**
  String get approved;

  /// No description provided for @pending.
  ///
  /// In th, this message translates to:
  /// **'รออนุมัติ'**
  String get pending;

  /// No description provided for @rejected.
  ///
  /// In th, this message translates to:
  /// **'ไม่อนุมัติ'**
  String get rejected;

  /// No description provided for @cancelled.
  ///
  /// In th, this message translates to:
  /// **'ยกเลิกแล้ว'**
  String get cancelled;

  /// No description provided for @newLeaveRequest.
  ///
  /// In th, this message translates to:
  /// **'คำขอลาใหม่'**
  String get newLeaveRequest;

  /// No description provided for @leaveType.
  ///
  /// In th, this message translates to:
  /// **'ประเภทการลา'**
  String get leaveType;

  /// No description provided for @dateRange.
  ///
  /// In th, this message translates to:
  /// **'ช่วงวันที่'**
  String get dateRange;

  /// No description provided for @fromDate.
  ///
  /// In th, this message translates to:
  /// **'จากวันที่'**
  String get fromDate;

  /// No description provided for @toDate.
  ///
  /// In th, this message translates to:
  /// **'ถึงวันที่'**
  String get toDate;

  /// No description provided for @leaveDays.
  ///
  /// In th, this message translates to:
  /// **'จำนวนวันลา'**
  String get leaveDays;

  /// No description provided for @reason.
  ///
  /// In th, this message translates to:
  /// **'เหตุผล'**
  String get reason;

  /// No description provided for @reasonHint.
  ///
  /// In th, this message translates to:
  /// **'ระบุเหตุผล...'**
  String get reasonHint;

  /// No description provided for @attachmentOptional.
  ///
  /// In th, this message translates to:
  /// **'แนบไฟล์ (ไม่บังคับ)'**
  String get attachmentOptional;

  /// No description provided for @chooseFile.
  ///
  /// In th, this message translates to:
  /// **'เลือกไฟล์ใบรับรอง / อื่นๆ'**
  String get chooseFile;

  /// No description provided for @submitRequest.
  ///
  /// In th, this message translates to:
  /// **'ส่งคำขอ'**
  String get submitRequest;

  /// No description provided for @leaveSubmitted.
  ///
  /// In th, this message translates to:
  /// **'ส่งคำขอลาแล้ว'**
  String get leaveSubmitted;

  /// No description provided for @waitingManager.
  ///
  /// In th, this message translates to:
  /// **'รออนุมัติจากผู้จัดการ'**
  String get waitingManager;

  /// No description provided for @leaveDetail.
  ///
  /// In th, this message translates to:
  /// **'รายละเอียดการลา'**
  String get leaveDetail;

  /// No description provided for @approvalTimeline.
  ///
  /// In th, this message translates to:
  /// **'ไทม์ไลน์การอนุมัติ'**
  String get approvalTimeline;

  /// No description provided for @submitted.
  ///
  /// In th, this message translates to:
  /// **'ส่งคำขอ'**
  String get submitted;

  /// No description provided for @managerReview.
  ///
  /// In th, this message translates to:
  /// **'หัวหน้าทีมพิจารณา'**
  String get managerReview;

  /// No description provided for @hrApproval.
  ///
  /// In th, this message translates to:
  /// **'HR อนุมัติ'**
  String get hrApproval;

  /// No description provided for @cancelRequest.
  ///
  /// In th, this message translates to:
  /// **'ยกเลิกคำขอ'**
  String get cancelRequest;

  /// No description provided for @confirmCancel.
  ///
  /// In th, this message translates to:
  /// **'ยืนยันยกเลิกคำขอนี้หรือไม่?'**
  String get confirmCancel;

  /// No description provided for @teamPending.
  ///
  /// In th, this message translates to:
  /// **'คำขอลาที่รออนุมัติ'**
  String get teamPending;

  /// No description provided for @approve.
  ///
  /// In th, this message translates to:
  /// **'อนุมัติ'**
  String get approve;

  /// No description provided for @reject.
  ///
  /// In th, this message translates to:
  /// **'ไม่อนุมัติ'**
  String get reject;

  /// No description provided for @confirmApprove.
  ///
  /// In th, this message translates to:
  /// **'ยืนยันอนุมัติคำขอนี้หรือไม่?'**
  String get confirmApprove;

  /// No description provided for @rejectionReason.
  ///
  /// In th, this message translates to:
  /// **'เหตุผลที่ไม่อนุมัติ'**
  String get rejectionReason;

  /// No description provided for @requiredField.
  ///
  /// In th, this message translates to:
  /// **'กรุณากรอกข้อมูลนี้'**
  String get requiredField;

  /// No description provided for @invalidDateRange.
  ///
  /// In th, this message translates to:
  /// **'วันสิ้นสุดต้องไม่ก่อนวันเริ่ม'**
  String get invalidDateRange;

  /// No description provided for @insufficientBalance.
  ///
  /// In th, this message translates to:
  /// **'จำนวนวันลาเกินสิทธิ์คงเหลือ'**
  String get insufficientBalance;

  /// No description provided for @noWorkingDays.
  ///
  /// In th, this message translates to:
  /// **'ช่วงวันที่เลือกไม่มีวันทำงาน'**
  String get noWorkingDays;

  /// No description provided for @filePickerUnavailable.
  ///
  /// In th, this message translates to:
  /// **'ตัวเลือกไฟล์จริงจะพร้อมเมื่อเพิ่ม platform adapter'**
  String get filePickerUnavailable;

  /// No description provided for @fileRules.
  ///
  /// In th, this message translates to:
  /// **'รองรับ PDF, JPG, PNG ไม่เกิน 5 MB'**
  String get fileRules;

  /// No description provided for @overtimeSummary.
  ///
  /// In th, this message translates to:
  /// **'สรุป OT'**
  String get overtimeSummary;

  /// No description provided for @newOtRequest.
  ///
  /// In th, this message translates to:
  /// **'คำขอ OT ใหม่'**
  String get newOtRequest;

  /// No description provided for @otDate.
  ///
  /// In th, this message translates to:
  /// **'วันที่ทำ OT'**
  String get otDate;

  /// No description provided for @timeRange.
  ///
  /// In th, this message translates to:
  /// **'ช่วงเวลา'**
  String get timeRange;

  /// No description provided for @start.
  ///
  /// In th, this message translates to:
  /// **'เริ่ม'**
  String get start;

  /// No description provided for @end.
  ///
  /// In th, this message translates to:
  /// **'สิ้นสุด'**
  String get end;

  /// No description provided for @otHours.
  ///
  /// In th, this message translates to:
  /// **'จำนวนชั่วโมง'**
  String get otHours;

  /// No description provided for @otRate.
  ///
  /// In th, this message translates to:
  /// **'อัตรา OT'**
  String get otRate;

  /// No description provided for @weekday.
  ///
  /// In th, this message translates to:
  /// **'วันธรรมดา'**
  String get weekday;

  /// No description provided for @dayOff.
  ///
  /// In th, this message translates to:
  /// **'วันหยุด'**
  String get dayOff;

  /// No description provided for @publicHoliday.
  ///
  /// In th, this message translates to:
  /// **'นักขัตฤกษ์'**
  String get publicHoliday;

  /// No description provided for @otReasonHint.
  ///
  /// In th, this message translates to:
  /// **'ระบุงานที่ต้องทำ...'**
  String get otReasonHint;

  /// No description provided for @estimatedOt.
  ///
  /// In th, this message translates to:
  /// **'คำนวณเงิน OT'**
  String get estimatedOt;

  /// No description provided for @otSubmitted.
  ///
  /// In th, this message translates to:
  /// **'ส่งคำขอ OT แล้ว'**
  String get otSubmitted;

  /// No description provided for @otDetail.
  ///
  /// In th, this message translates to:
  /// **'รายละเอียด OT'**
  String get otDetail;

  /// No description provided for @invalidTimeRange.
  ///
  /// In th, this message translates to:
  /// **'เวลาสิ้นสุดต้องหลังเวลาเริ่ม'**
  String get invalidTimeRange;

  /// No description provided for @worktimeTitle.
  ///
  /// In th, this message translates to:
  /// **'เวลาทำงาน'**
  String get worktimeTitle;

  /// No description provided for @worktimeTracker.
  ///
  /// In th, this message translates to:
  /// **'ติดตามเวลาทำงาน'**
  String get worktimeTracker;

  /// No description provided for @today.
  ///
  /// In th, this message translates to:
  /// **'วันนี้'**
  String get today;

  /// No description provided for @locationVerified.
  ///
  /// In th, this message translates to:
  /// **'ยืนยันตำแหน่งแล้ว'**
  String get locationVerified;

  /// No description provided for @checkInTime.
  ///
  /// In th, this message translates to:
  /// **'เข้างาน'**
  String get checkInTime;

  /// No description provided for @checkOutTime.
  ///
  /// In th, this message translates to:
  /// **'ออกงาน'**
  String get checkOutTime;

  /// No description provided for @notClockedIn.
  ///
  /// In th, this message translates to:
  /// **'ยังไม่ได้ลงเวลาเข้างาน'**
  String get notClockedIn;

  /// No description provided for @working.
  ///
  /// In th, this message translates to:
  /// **'กำลังทำงาน'**
  String get working;

  /// No description provided for @finished.
  ///
  /// In th, this message translates to:
  /// **'ออกงานแล้ว'**
  String get finished;

  /// No description provided for @thisWeek.
  ///
  /// In th, this message translates to:
  /// **'สัปดาห์นี้'**
  String get thisWeek;

  /// No description provided for @totalHours.
  ///
  /// In th, this message translates to:
  /// **'ชั่วโมงรวม'**
  String get totalHours;

  /// No description provided for @late.
  ///
  /// In th, this message translates to:
  /// **'มาสาย'**
  String get late;

  /// No description provided for @recentHistory.
  ///
  /// In th, this message translates to:
  /// **'ประวัติล่าสุด'**
  String get recentHistory;

  /// No description provided for @workHistory.
  ///
  /// In th, this message translates to:
  /// **'ประวัติเข้างาน'**
  String get workHistory;

  /// No description provided for @verifyLocation.
  ///
  /// In th, this message translates to:
  /// **'ยืนยันตำแหน่ง'**
  String get verifyLocation;

  /// No description provided for @insideOffice.
  ///
  /// In th, this message translates to:
  /// **'อยู่ในพื้นที่ออฟฟิศ'**
  String get insideOffice;

  /// No description provided for @nextSelfie.
  ///
  /// In th, this message translates to:
  /// **'ถัดไป — ถ่ายเซลฟี่'**
  String get nextSelfie;

  /// No description provided for @selfie.
  ///
  /// In th, this message translates to:
  /// **'เซลฟี่'**
  String get selfie;

  /// No description provided for @placeFace.
  ///
  /// In th, this message translates to:
  /// **'วางใบหน้าให้อยู่ในกรอบ'**
  String get placeFace;

  /// No description provided for @faceVerified.
  ///
  /// In th, this message translates to:
  /// **'ตรวจสอบใบหน้าสำเร็จ'**
  String get faceVerified;

  /// No description provided for @checking.
  ///
  /// In th, this message translates to:
  /// **'กำลังตรวจสอบ...'**
  String get checking;

  /// No description provided for @confirm.
  ///
  /// In th, this message translates to:
  /// **'ยืนยัน'**
  String get confirm;

  /// No description provided for @timeRecorded.
  ///
  /// In th, this message translates to:
  /// **'ลงเวลาเรียบร้อย'**
  String get timeRecorded;

  /// No description provided for @personalInfo.
  ///
  /// In th, this message translates to:
  /// **'ข้อมูลส่วนตัว'**
  String get personalInfo;

  /// No description provided for @positionTeam.
  ///
  /// In th, this message translates to:
  /// **'ตำแหน่งและทีม'**
  String get positionTeam;

  /// No description provided for @documentsPayslips.
  ///
  /// In th, this message translates to:
  /// **'เอกสารและสลิป'**
  String get documentsPayslips;

  /// No description provided for @notifications.
  ///
  /// In th, this message translates to:
  /// **'การแจ้งเตือน'**
  String get notifications;

  /// No description provided for @language.
  ///
  /// In th, this message translates to:
  /// **'ภาษา'**
  String get language;

  /// No description provided for @thai.
  ///
  /// In th, this message translates to:
  /// **'ไทย'**
  String get thai;

  /// No description provided for @english.
  ///
  /// In th, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @resetDemoData.
  ///
  /// In th, this message translates to:
  /// **'รีเซ็ตข้อมูลตัวอย่าง'**
  String get resetDemoData;

  /// No description provided for @resetConfirm.
  ///
  /// In th, this message translates to:
  /// **'ข้อมูลที่แก้ไขทั้งหมดจะถูกลบ ต้องการดำเนินการต่อหรือไม่?'**
  String get resetConfirm;

  /// No description provided for @signOut.
  ///
  /// In th, this message translates to:
  /// **'ออกจากระบบ'**
  String get signOut;

  /// No description provided for @comingSoon.
  ///
  /// In th, this message translates to:
  /// **'เร็ว ๆ นี้'**
  String get comingSoon;

  /// No description provided for @featureNotDesigned.
  ///
  /// In th, this message translates to:
  /// **'ส่วนนี้ยังไม่มีรายละเอียดในดีไซน์ต้นฉบับ'**
  String get featureNotDesigned;

  /// No description provided for @back.
  ///
  /// In th, this message translates to:
  /// **'กลับ'**
  String get back;

  /// No description provided for @close.
  ///
  /// In th, this message translates to:
  /// **'ปิด'**
  String get close;

  /// No description provided for @cancel.
  ///
  /// In th, this message translates to:
  /// **'ยกเลิก'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In th, this message translates to:
  /// **'บันทึก'**
  String get save;

  /// No description provided for @reset.
  ///
  /// In th, this message translates to:
  /// **'รีเซ็ต'**
  String get reset;

  /// No description provided for @version.
  ///
  /// In th, this message translates to:
  /// **'เวอร์ชัน'**
  String get version;

  /// No description provided for @officeName.
  ///
  /// In th, this message translates to:
  /// **'JAMORE HQ — ชั้น 14'**
  String get officeName;

  /// No description provided for @officeAddress.
  ///
  /// In th, this message translates to:
  /// **'999/9 ถนนพระราม 1 ปทุมวัน กรุงเทพฯ'**
  String get officeAddress;

  /// No description provided for @gpsVerified.
  ///
  /// In th, this message translates to:
  /// **'GPS verified'**
  String get gpsVerified;

  /// No description provided for @noItems.
  ///
  /// In th, this message translates to:
  /// **'ไม่มีรายการ'**
  String get noItems;

  /// No description provided for @attachmentSelected.
  ///
  /// In th, this message translates to:
  /// **'เลือกไฟล์แล้ว'**
  String get attachmentSelected;

  /// No description provided for @halfDay.
  ///
  /// In th, this message translates to:
  /// **'ครึ่งวัน'**
  String get halfDay;

  /// No description provided for @fullDay.
  ///
  /// In th, this message translates to:
  /// **'เต็มวัน'**
  String get fullDay;

  /// No description provided for @profileContact.
  ///
  /// In th, this message translates to:
  /// **'ข้อมูลติดต่อ'**
  String get profileContact;

  /// No description provided for @profileEmployment.
  ///
  /// In th, this message translates to:
  /// **'ข้อมูลการจ้างงาน'**
  String get profileEmployment;

  /// No description provided for @profileSettings.
  ///
  /// In th, this message translates to:
  /// **'การตั้งค่า'**
  String get profileSettings;

  /// No description provided for @profileEmployeeId.
  ///
  /// In th, this message translates to:
  /// **'รหัสพนักงาน'**
  String get profileEmployeeId;

  /// No description provided for @profileDepartment.
  ///
  /// In th, this message translates to:
  /// **'แผนก'**
  String get profileDepartment;

  /// No description provided for @profileLevel.
  ///
  /// In th, this message translates to:
  /// **'ระดับ'**
  String get profileLevel;

  /// No description provided for @profileTenure.
  ///
  /// In th, this message translates to:
  /// **'อายุงาน'**
  String get profileTenure;

  /// No description provided for @profileLeaveLeft.
  ///
  /// In th, this message translates to:
  /// **'ลาคงเหลือ'**
  String get profileLeaveLeft;

  /// No description provided for @profileOvertimeThisMonth.
  ///
  /// In th, this message translates to:
  /// **'OT เดือนนี้'**
  String get profileOvertimeThisMonth;

  /// No description provided for @profileYearsUnit.
  ///
  /// In th, this message translates to:
  /// **'ปี'**
  String get profileYearsUnit;

  /// No description provided for @profileDaysUnit.
  ///
  /// In th, this message translates to:
  /// **'วัน'**
  String get profileDaysUnit;

  /// No description provided for @profileHoursUnit.
  ///
  /// In th, this message translates to:
  /// **'ชม.'**
  String get profileHoursUnit;

  /// No description provided for @profileEmail.
  ///
  /// In th, this message translates to:
  /// **'อีเมล'**
  String get profileEmail;

  /// No description provided for @profilePhone.
  ///
  /// In th, this message translates to:
  /// **'เบอร์โทร'**
  String get profilePhone;

  /// No description provided for @profileWorkplace.
  ///
  /// In th, this message translates to:
  /// **'สถานที่ทำงาน'**
  String get profileWorkplace;

  /// No description provided for @profileStartDate.
  ///
  /// In th, this message translates to:
  /// **'วันเริ่มงาน'**
  String get profileStartDate;

  /// No description provided for @profileEmploymentType.
  ///
  /// In th, this message translates to:
  /// **'ประเภทพนักงาน'**
  String get profileEmploymentType;

  /// No description provided for @profileReportsTo.
  ///
  /// In th, this message translates to:
  /// **'ผู้บังคับบัญชา'**
  String get profileReportsTo;

  /// No description provided for @profileLanguageHint.
  ///
  /// In th, this message translates to:
  /// **'เลือกภาษาที่แสดงในแอป'**
  String get profileLanguageHint;

  /// No description provided for @profileSecurityPassword.
  ///
  /// In th, this message translates to:
  /// **'ความปลอดภัยและรหัสผ่าน'**
  String get profileSecurityPassword;

  /// No description provided for @profileHelpContactHr.
  ///
  /// In th, this message translates to:
  /// **'ช่วยเหลือและติดต่อ HR'**
  String get profileHelpContactHr;

  /// No description provided for @profileRoleFallback.
  ///
  /// In th, this message translates to:
  /// **'นักออกแบบผลิตภัณฑ์อาวุโส'**
  String get profileRoleFallback;

  /// No description provided for @profileDesignTeam.
  ///
  /// In th, this message translates to:
  /// **'ทีมดีไซน์'**
  String get profileDesignTeam;

  /// No description provided for @profileSeniorLevel.
  ///
  /// In th, this message translates to:
  /// **'P5 · อาวุโส'**
  String get profileSeniorLevel;

  /// No description provided for @profileOffice.
  ///
  /// In th, this message translates to:
  /// **'JAMORE HQ · กรุงเทพฯ'**
  String get profileOffice;

  /// No description provided for @profileStartDateValue.
  ///
  /// In th, this message translates to:
  /// **'1 มี.ค. 2022'**
  String get profileStartDateValue;

  /// No description provided for @profileFullTime.
  ///
  /// In th, this message translates to:
  /// **'พนักงานประจำ'**
  String get profileFullTime;

  /// No description provided for @profileManager.
  ///
  /// In th, this message translates to:
  /// **'วิภา ศรีสุข'**
  String get profileManager;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'th'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'th':
      return AppLocalizationsTh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
