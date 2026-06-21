import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_metadata.dart';
import '../core/extensions.dart';
import '../core/theme.dart';
import '../domain/entities/hr_models.dart';
import '../state/app_state.dart';
import 'common.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({required this.location, super.key});

  final String location;

  @override
  Widget build(BuildContext context) {
    if (location.startsWith('/soon/')) {
      return _ComingSoon(feature: location.split('/').last);
    }

    final state = context.watch<AppState>();
    final isThai = context.isThai;
    final name = state.employeeDisplayName(isThai: isThai);
    final secondaryName = state.employeeDisplayName(isThai: !isThai);
    final position = state.employeePositionName(isThai: isThai);
    final annualLeave = state.balanceFor(LeaveKind.annual).remaining;
    final overtimeHours = state.data.overtimeRequests.fold<double>(
      0,
      (total, request) => total + request.hours,
    );

    return PageSurface(
      maxWidth: 720,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ProfileHeader(
            name: name,
            secondaryName: secondaryName == name ? '' : secondaryName,
            initials: initialsFromName(
              state.employeeDisplayName(isThai: false),
              fallback: name,
            ),
            role: position ?? context.l10n.profileRoleFallback,
            employeeId: state.currentEmployee?.employeeId ?? 'EMP-XXX-XXX',
            department:
                state.currentEmployee?.departmentId ??
                context.l10n.profileDesignTeam,
            level: context.l10n.profileSeniorLevel,
            onEdit: () => state.navigate('/soon/personal-info'),
            onQrCode: () => _showUnavailable(context),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  icon: Icons.business_center_outlined,
                  value: '4',
                  unit: context.l10n.profileYearsUnit,
                  label: context.l10n.profileTenure,
                  color: JamoreColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatTile(
                  icon: Icons.wb_sunny_outlined,
                  value: _number(annualLeave),
                  unit: context.l10n.profileDaysUnit,
                  label: context.l10n.profileLeaveLeft,
                  color: const Color(0xFF3B82F6),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatTile(
                  icon: Icons.more_time_rounded,
                  value: _number(overtimeHours),
                  unit: context.l10n.profileHoursUnit,
                  label: context.l10n.profileOvertimeThisMonth,
                  color: JamoreColors.warning,
                ),
              ),
            ],
          ),
          _ProfileSection(
            title: context.l10n.language,
            showTitle: false,
            child: _LanguageSelector(state: state),
          ),
          _ProfileSection(
            title: context.l10n.profileContact,
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.mail_outline_rounded,
                  label: context.l10n.profileEmail,
                  value:
                      state.currentEmployee?.emailCompany ??
                      state.currentUser?.email ??
                      'nattawut.c@jamore.co.th',
                ),
                _InfoRow(
                  icon: Icons.phone_outlined,
                  label: context.l10n.profilePhone,
                  value: '081-234-5678',
                ),
                _InfoRow(
                  icon: Icons.location_on_outlined,
                  label: context.l10n.profileWorkplace,
                  value: context.l10n.profileOffice,
                  last: true,
                ),
              ],
            ),
          ),
          _ProfileSection(
            title: context.l10n.profileEmployment,
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.calendar_today_outlined,
                  label: context.l10n.profileStartDate,
                  value: context.l10n.profileStartDateValue,
                ),
                _InfoRow(
                  icon: Icons.shield_outlined,
                  label: context.l10n.profileEmploymentType,
                  value: context.l10n.profileFullTime,
                ),
                _InfoRow(
                  icon: Icons.person_outline_rounded,
                  label: context.l10n.profileReportsTo,
                  value: context.l10n.profileManager,
                  last: true,
                ),
              ],
            ),
          ),
          _ProfileSection(
            title: context.l10n.profileSettings,
            edgePadding: const EdgeInsets.all(4),
            child: Column(
              children: [
                _MenuRow(
                  icon: Icons.account_balance_wallet_outlined,
                  label: context.l10n.documentsPayslips,
                  onTap: () => state.navigate('/soon/documents'),
                ),
                _MenuRow(
                  icon: Icons.notifications_none_rounded,
                  label: context.l10n.notifications,
                  badge: '3',
                  onTap: () => state.navigate('/soon/notifications'),
                ),
                _MenuRow(
                  icon: Icons.lock_outline_rounded,
                  label: context.l10n.profileSecurityPassword,
                  onTap: () => state.navigate('/soon/security'),
                ),
                _MenuRow(
                  icon: Icons.help_outline_rounded,
                  label: context.l10n.profileHelpContactHr,
                  onTap: () => state.navigate('/soon/help'),
                  last: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              key: const Key('signOutButton'),
              onPressed: state.logout,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFDC2626),
                backgroundColor: Colors.white,
                side: const BorderSide(color: JamoreColors.line),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.logout_rounded, size: 19),
              label: Text(
                context.l10n.signOut,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'JAMORE HRM v',
                  style: TextStyle(fontSize: 11, color: JamoreColors.muted),
                ),
                const AppVersionText(
                  style: TextStyle(fontSize: 11, color: JamoreColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _number(double value) => value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(1);

  static void _showUnavailable(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.featureNotDesigned)));
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.name,
    required this.secondaryName,
    required this.initials,
    required this.role,
    required this.employeeId,
    required this.department,
    required this.level,
    required this.onEdit,
    required this.onQrCode,
  });

  final String name;
  final String secondaryName;
  final String initials;
  final String role;
  final String employeeId;
  final String department;
  final String level;
  final VoidCallback onEdit;
  final VoidCallback onQrCode;

  @override
  Widget build(BuildContext context) => Container(
    key: const Key('profileHeader'),
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(26),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [JamoreColors.primary, Color(0xFF00789F)],
      ),
      boxShadow: const [
        BoxShadow(
          color: Color(0x500099CC),
          blurRadius: 28,
          offset: Offset(0, 14),
        ),
      ],
    ),
    child: Stack(
      children: [
        const Positioned(
          width: 190,
          height: 190,
          right: -76,
          top: -92,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.fromBorderSide(
                BorderSide(color: Color(0x24FFFFFF), width: 24),
              ),
            ),
          ),
        ),
        const Positioned(
          width: 100,
          height: 100,
          left: -42,
          bottom: -48,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.fromBorderSide(
                BorderSide(color: Color(0x18FFFFFF), width: 18),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _HeaderIconButton(
                    tooltip: context.l10n.personalInfo,
                    icon: Icons.edit_outlined,
                    onPressed: onEdit,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: JamoreColors.primarySoft,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x40000000),
                          blurRadius: 18,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: JamoreColors.primaryDark,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            height: 1.15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -.3,
                          ),
                        ),
                        if (secondaryName.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            secondaryName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xD9FFFFFF),
                              fontSize: 12,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0x2EFFFFFF),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Color(0xFF4ADE80),
                                  shape: BoxShape.circle,
                                ),
                                child: SizedBox.square(dimension: 6),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  role,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0x24FFFFFF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _HeaderStat(
                        label: context.l10n.profileEmployeeId,
                        value: employeeId,
                      ),
                    ),
                    const _HeaderDivider(),
                    Expanded(
                      child: _HeaderStat(
                        label: context.l10n.profileDepartment,
                        value: department,
                      ),
                    ),
                    const _HeaderDivider(),
                    Expanded(
                      child: _HeaderStat(
                        label: context.l10n.profileLevel,
                        value: level,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: 36,
    child: IconButton(
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      style: IconButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0x2EFFFFFF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
    ),
  );
}

class _HeaderStat extends StatelessWidget {
  const _HeaderStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 10),
      ),
      const SizedBox(height: 3),
      Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}

class _HeaderDivider extends StatelessWidget {
  const _HeaderDivider();

  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 34,
    margin: const EdgeInsets.symmetric(horizontal: 10),
    color: const Color(0x40FFFFFF),
  );
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.value,
    required this.unit,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String unit;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: JamoreColors.line),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .09),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                height: 1,
                fontWeight: FontWeight.w800,
                letterSpacing: -.5,
              ),
            ),
            const SizedBox(width: 3),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 1),
                child: Text(
                  unit,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: JamoreColors.muted,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({
    required this.title,
    required this.child,
    this.edgePadding = const EdgeInsets.fromLTRB(16, 4, 16, 10),
    this.showTitle = true,
  });

  final String title;
  final Widget child;
  final EdgeInsets edgePadding;
  final bool showTitle;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 22),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle) ...[
          Text(
            title,
            style: const TextStyle(
              color: JamoreColors.ink,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
        ],
        Container(
          padding: edgePadding,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: JamoreColors.line),
            borderRadius: BorderRadius.circular(22),
          ),
          child: child,
        ),
      ],
    ),
  );
}

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) => Column(
    key: const Key('languageSelector'),
    children: [
      Row(
        children: [
          const _ProfileIcon(icon: Icons.language_rounded),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.language,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  context.l10n.profileLanguageHint,
                  style: const TextStyle(
                    color: JamoreColors.muted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: _LanguageOption(
              flag: '🇹🇭',
              title: context.l10n.thai,
              subtitle: 'Thai',
              selected: state.data.localeCode == 'th',
              onTap: () => state.setLocale('th'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _LanguageOption(
              flag: '🇬🇧',
              title: context.l10n.english,
              subtitle: context.isThai ? 'อังกฤษ' : 'English',
              selected: state.data.localeCode == 'en',
              onTap: () => state.setLocale('en'),
            ),
          ),
        ],
      ),
    ],
  );
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.flag,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String flag;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: selected
        ? JamoreColors.primary.withValues(alpha: .08)
        : const Color(0xFFF8FAFC),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: BorderSide(
        color: selected ? JamoreColors.primary : Colors.transparent,
        width: 1.5,
      ),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 22, height: 1)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: JamoreColors.muted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? JamoreColors.primary : Colors.transparent,
                border: selected
                    ? null
                    : Border.all(color: const Color(0xFFCBD5E1), width: 2),
              ),
              child: selected
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 13,
                    )
                  : null,
            ),
          ],
        ),
      ),
    ),
  );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.last = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(
      border: last
          ? null
          : const Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
    ),
    child: Row(
      children: [
        _ProfileIcon(icon: icon),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            color: JamoreColors.muted,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}

class _ProfileIcon extends StatelessWidget {
  const _ProfileIcon({required this.icon, this.size = 34});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: JamoreColors.primary.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Icon(icon, color: JamoreColors.primary, size: 18),
  );
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge,
    this.last = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? badge;
  final bool last;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: last
              ? null
              : const Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
        ),
        child: Row(
          children: [
            _ProfileIcon(icon: icon, size: 36),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (badge != null) ...[
              Container(
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 7),
            ],
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1)),
          ],
        ),
      ),
    ),
  );
}

class _ComingSoon extends StatelessWidget {
  const _ComingSoon({required this.feature});

  final String feature;

  @override
  Widget build(BuildContext context) {
    final title = switch (feature) {
      'personal-info' => context.l10n.personalInfo,
      'position-team' => context.l10n.positionTeam,
      'documents' => context.l10n.documentsPayslips,
      'notifications' => context.l10n.notifications,
      'security' => context.l10n.profileSecurityPassword,
      'help' => context.l10n.profileHelpContactHr,
      _ => context.l10n.comingSoon,
    };
    return PageSurface(
      child: Column(
        children: [
          PageHeading(title: title, backTo: '/profile'),
          const SizedBox(height: 70),
          Container(
            width: 92,
            height: 92,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: JamoreColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.construction_rounded,
              color: JamoreColors.primary,
              size: 42,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            context.l10n.comingSoon,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            context.l10n.featureNotDesigned,
            textAlign: TextAlign.center,
            style: const TextStyle(color: JamoreColors.muted),
          ),
        ],
      ),
    );
  }
}
