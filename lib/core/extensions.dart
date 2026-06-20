import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/models.dart';
import '../l10n/app_localizations.dart';

extension BuildContextX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  bool get isThai => Localizations.localeOf(this).languageCode == 'th';

  String date(DateTime value, {bool year = true}) {
    final pattern = year
        ? (isThai ? 'd MMM yyyy' : 'MMM d, yyyy')
        : (isThai ? 'd MMM' : 'MMM d');
    return DateFormat(pattern, isThai ? 'th' : 'en').format(value);
  }

  String time(DateTime value) => DateFormat('HH:mm').format(value);

  String leaveKind(LeaveKind value) => switch (value) {
    LeaveKind.annual => l10n.annualLeave,
    LeaveKind.sick => l10n.sickLeave,
    LeaveKind.personal => l10n.personalLeave,
    LeaveKind.maternity => l10n.maternityLeave,
  };

  String status(RequestStatus value) => switch (value) {
    RequestStatus.approved => l10n.approved,
    RequestStatus.pending => l10n.pending,
    RequestStatus.rejected => l10n.rejected,
    RequestStatus.cancelled => l10n.cancelled,
  };
}
