import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/extensions.dart';
import '../core/theme.dart';
import '../domain/entities/hr_models.dart';
import '../state/app_state.dart';
import 'common.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final positionName = state.employeePositionName(isThai: context.isThai);
    final displayName = state.employeeDisplayName(isThai: context.isThai);
    return PageSurface(
      maxWidth: 980,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: JamoreColors.primarySoft,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x240099CC),
                      blurRadius: 14,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                clipBehavior: Clip.antiAlias,
                child: _DashboardAvatar(
                  imageBytes: state.currentEmployeeImageBytes,
                  initials: initialsFromName(
                    state.employeeDisplayName(isThai: false),
                    fallback: displayName,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (positionName != null)
                      Text(
                        positionName,
                        style: const TextStyle(
                          color: JamoreColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                tooltip: context.l10n.notifications,
                onPressed: () => state.navigate('/soon/notifications'),
                icon: const Badge(
                  label: Text('3'),
                  child: Icon(Icons.notifications_none_rounded),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _WorkHero(state: state),
          const SizedBox(height: 22),
          SectionHeading(title: context.l10n.quickActions),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _QuickAction(
                icon: Icons.event_available_rounded,
                label: context.l10n.requestLeave,
                color: const Color(0xFF1D4ED8),
                background: const Color(0xFFDBEAFE),
                onTap: () => state.navigate('/leave/request'),
              ),
              _QuickAction(
                icon: Icons.more_time_rounded,
                label: context.l10n.requestOt,
                color: const Color(0xFFB45309),
                background: const Color(0xFFFEF3C7),
                onTap: () => state.navigate('/overtime/request'),
              ),
              _QuickAction(
                icon: Icons.schedule_rounded,
                label: context.l10n.shift,
                color: const Color(0xFF15803D),
                background: const Color(0xFFDCFCE7),
                onTap: () => state.navigate('/worktime'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SectionHeading(
            title: context.l10n.leaveBalance,
            onSeeAll: () => state.navigate('/leave'),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 700 ? 4 : 2;
              return GridView.count(
                crossAxisCount: columns,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: columns == 4 ? 1.25 : 1.15,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: state.data.leaveBalances
                    .map((balance) => _BalanceCard(balance))
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 24),
          SectionHeading(
            title: context.l10n.otThisMonth,
            onSeeAll: () => state.navigate('/overtime'),
          ),
          const SizedBox(height: 10),
          _OtSummary(items: state.data.overtimeRequests),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final cards = [
                _InfoCard(
                  icon: Icons.event_note_rounded,
                  title: context.l10n.scheduleToday,
                  children: const [
                    ('09:00', 'Daily Stand-up'),
                    ('11:00', 'Design Review'),
                    ('14:30', '1:1 with Manager'),
                  ],
                ),
                _InfoCard(
                  icon: Icons.campaign_rounded,
                  title: context.l10n.announcements,
                  children: context.isThai
                      ? const [
                          ('HR', 'เปิดรับสมัครกองทุนสำรองเลี้ยงชีพ'),
                          ('ประกาศ', 'วันหยุดบริษัทครั้งถัดไป'),
                          ('กิจกรรม', 'JAMORE Family Day'),
                        ]
                      : const [
                          ('HR', 'Provident fund enrollment'),
                          ('News', 'Next company holiday'),
                          ('Event', 'JAMORE Family Day'),
                        ],
                ),
                _InfoCard(
                  icon: Icons.celebration_rounded,
                  title: context.l10n.birthdays,
                  children: context.isThai
                      ? const [
                          ('วันนี้', 'พิมพ์ลภัส · Engineering'),
                          ('พรุ่งนี้', 'ธนกร · Marketing'),
                        ]
                      : const [
                          ('Today', 'Pimlapas · Engineering'),
                          ('Tomorrow', 'Thanakorn · Marketing'),
                        ],
                ),
              ];
              if (constraints.maxWidth >= 820) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: cards
                      .map(
                        (card) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: card,
                          ),
                        ),
                      )
                      .toList(),
                );
              }
              return Column(
                children: cards
                    .map(
                      (card) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: card,
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DashboardAvatar extends StatelessWidget {
  const _DashboardAvatar({required this.imageBytes, required this.initials});

  final Uint8List? imageBytes;
  final String initials;

  @override
  Widget build(BuildContext context) {
    final bytes = imageBytes;
    if (bytes == null) return _initials();
    return Image.memory(
      bytes,
      key: const Key('dashboardAvatarImage'),
      width: 48,
      height: 48,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => _initials(),
    );
  }

  Widget _initials() => Text(
    initials,
    key: const Key('dashboardAvatarInitials'),
    style: const TextStyle(
      fontWeight: FontWeight.w900,
      color: JamoreColors.primaryDark,
    ),
  );
}

class _WorkHero extends StatelessWidget {
  const _WorkHero({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final log = state.todayLog;
    final working = log?.isWorking ?? false;
    final finished = log?.clockOut != null;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [JamoreColors.primary, JamoreColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x400099CC),
            blurRadius: 28,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final details = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                working
                    ? context.l10n.workingToday
                    : finished
                    ? context.l10n.finished
                    : context.l10n.notClockedIn,
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              const _LiveClock(),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    color: Colors.white70,
                    size: 16,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      context.l10n.officeName,
                      maxLines: 2,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
          final button = SizedBox(
            width: constraints.maxWidth > 520 ? 210 : double.infinity,
            height: 50,
            child: FilledButton.icon(
              onPressed: finished
                  ? null
                  : () => state.navigate('/worktime/check-in'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: JamoreColors.primary,
              ),
              icon: Icon(working ? Icons.logout_rounded : Icons.login_rounded),
              label: Text(
                working ? context.l10n.clockOut : context.l10n.clockIn,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          );
          if (constraints.maxWidth > 520) {
            return Row(
              children: [
                Expanded(child: details),
                const SizedBox(width: 18),
                button,
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [details, const SizedBox(height: 18), button],
          );
        },
      ),
    );
  }
}

class _LiveClock extends StatefulWidget {
  const _LiveClock();
  @override
  State<_LiveClock> createState() => _LiveClockState();
}

class _LiveClockState extends State<_LiveClock> {
  late Timer _timer;
  DateTime now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: false,
    label: context.time(now),
    child: Text(
      context.time(now),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 38,
        fontWeight: FontWeight.w900,
        letterSpacing: -1,
      ),
    ),
  );
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.background,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final Color background;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 150,
    height: 74,
    child: Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard(this.balance);
  final LeaveBalance balance;

  @override
  Widget build(BuildContext context) {
    final colors = switch (balance.kind) {
      LeaveKind.annual => (
        const Color(0xFFDBEAFE),
        const Color(0xFF2563EB),
        Icons.wb_sunny_outlined,
      ),
      LeaveKind.sick => (
        const Color(0xFFDCFCE7),
        const Color(0xFF059669),
        Icons.health_and_safety_outlined,
      ),
      LeaveKind.personal => (
        const Color(0xFFFEF3C7),
        const Color(0xFFD97706),
        Icons.work_outline_rounded,
      ),
      LeaveKind.maternity => (
        const Color(0xFFFCE7F3),
        const Color(0xFFDB2777),
        Icons.child_friendly_rounded,
      ),
    };
    return JamoreCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colors.$1,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(colors.$3, color: colors.$2, size: 20),
          ),
          const Spacer(),
          Text(
            context.leaveKind(balance.kind),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: JamoreColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '${balance.remaining.toStringAsFixed(balance.remaining % 1 == 0 ? 0 : 1)} ${context.l10n.days}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          LinearProgressIndicator(
            value: balance.used / balance.total,
            color: colors.$2,
            backgroundColor: colors.$1,
            borderRadius: BorderRadius.circular(8),
          ),
        ],
      ),
    );
  }
}

class _OtSummary extends StatelessWidget {
  const _OtSummary({required this.items});
  final List<OvertimeRequest> items;

  @override
  Widget build(BuildContext context) {
    final approved = items.where(
      (item) => item.status == RequestStatus.approved,
    );
    final hours = approved.fold<double>(0, (sum, item) => sum + item.hours);
    final amount = approved.fold<int>(0, (sum, item) => sum + item.amount);
    return JamoreCard(
      child: Row(
        children: [
          Expanded(
            child: _Metric(
              label: context.l10n.totalHours,
              value: hours.toStringAsFixed(1),
              suffix: context.l10n.hours,
            ),
          ),
          Container(height: 54, width: 1, color: JamoreColors.line),
          Expanded(
            child: _Metric(
              label: context.l10n.estimatedOt,
              value: '฿${amount.toString()}',
              suffix: context.l10n.baht,
              color: JamoreColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    required this.suffix,
    this.color,
  });
  final String label;
  final String value;
  final String suffix;
  final Color? color;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: JamoreColors.muted),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        Text(
          suffix,
          style: const TextStyle(fontSize: 10, color: JamoreColors.muted),
        ),
      ],
    ),
  );
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.children,
  });
  final IconData icon;
  final String title;
  final List<(String, String)> children;

  @override
  Widget build(BuildContext context) => JamoreCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: JamoreColors.primary, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children.map(
          (item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 62,
                  child: Text(
                    item.$1,
                    style: const TextStyle(
                      fontSize: 11,
                      color: JamoreColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    item.$2,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
