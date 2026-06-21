import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/extensions.dart';
import '../core/theme.dart';
import '../domain/entities/hr_models.dart';
import '../state/app_state.dart';
import 'common.dart';

class WorktimeScreen extends StatelessWidget {
  const WorktimeScreen({required this.location, super.key});
  final String location;

  @override
  Widget build(BuildContext context) {
    if (location == '/worktime/check-in') return const _TimeFlow();
    if (location == '/worktime/history') return const _WorkHistory();
    return const _WorktimeMain();
  }
}

class _WorktimeMain extends StatelessWidget {
  const _WorktimeMain();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final today = state.todayLog;
    final working = today?.isWorking ?? false;
    final finished = today?.clockOut != null;
    final logs = state.data.workLogs.take(5).toList();
    final total = state.data.workLogs
        .take(7)
        .fold<Duration>(Duration.zero, (sum, log) => sum + log.duration);
    final lateCount = state.data.workLogs.take(7).where(_isLate).length;
    final overtimeHours = state.data.overtimeRequests
        .where((item) => item.status == RequestStatus.approved)
        .fold<double>(0, (sum, item) => sum + item.hours);
    return PageSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeading(
            title: context.l10n.worktimeTitle,
            subtitle: context.l10n.worktimeTracker,
          ),
          Container(
            key: const Key('worktimeTodayCard'),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: JamoreColors.line),
            ),
            child: Column(
              children: [
                const SizedBox(height: 130, child: _MiniMap()),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: const Icon(
                              Icons.location_on_rounded,
                              color: JamoreColors.success,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.l10n.officeName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  '${context.l10n.gpsVerified} · ${context.l10n.locationVerified}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: JamoreColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _TimeTile(
                              key: const Key('worktimeClockInSummary'),
                              label: context.l10n.checkInTime,
                              time: today?.clockIn == null
                                  ? '—'
                                  : context.time(today!.clockIn!),
                              color: JamoreColors.success,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _TimeTile(
                              key: const Key('worktimeClockOutSummary'),
                              label: context.l10n.checkOutTime,
                              time: today?.clockOut == null
                                  ? '—'
                                  : context.time(today!.clockOut!),
                              color: today?.clockOut == null
                                  ? const Color(0xFFCBD5E1)
                                  : JamoreColors.primary,
                            ),
                          ),
                        ],
                      ),
                      if (!finished) ...[
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: FilledButton.icon(
                            key: const Key('worktimeRecordButton'),
                            onPressed: () =>
                                state.navigate('/worktime/check-in'),
                            icon: const Icon(Icons.schedule_rounded, size: 18),
                            label: Text(
                              context.isThai
                                  ? '${working ? context.l10n.clockOut : context.l10n.clockIn} · ${working ? 'Clock out' : 'Clock in'}'
                                  : working
                                  ? context.l10n.clockOut
                                  : context.l10n.clockIn,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          SectionHeading(
            title: context.l10n.thisWeek,
            subtitle: context.isThai ? 'This week' : null,
            onSeeAll: () => state.navigate('/worktime/history'),
          ),
          const SizedBox(height: 10),
          JamoreCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _WeeklyMetric(
                        label: context.l10n.totalHours,
                        value: (total.inMinutes / 60).toStringAsFixed(1),
                        suffix: '/ 40 ${context.l10n.hours}',
                      ),
                    ),
                    Expanded(
                      child: _WeeklyMetric(
                        label: context.l10n.late,
                        value: '$lateCount',
                        color: JamoreColors.warning,
                      ),
                    ),
                    Expanded(
                      child: _WeeklyMetric(
                        label: 'OT',
                        value: _compact(overtimeHours),
                        color: JamoreColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 100,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(7, (index) {
                      final day = DateTime.now().subtract(
                        Duration(days: 6 - index),
                      );
                      WorkLog? log;
                      for (final value in state.data.workLogs) {
                        if (DateUtils.isSameDay(value.date, day)) log = value;
                      }
                      final hours = log == null
                          ? 0.0
                          : log.duration.inMinutes / 60;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: FractionallySizedBox(
                                    heightFactor: (hours / 12).clamp(.05, 1),
                                    widthFactor: 1,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: log == null || hours == 0
                                            ? const Color(0xFFF1F5F9)
                                            : _isLate(log)
                                            ? JamoreColors.warning
                                            : hours > 10
                                            ? JamoreColors.primary
                                            : JamoreColors.success,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                context.isThai
                                    ? const [
                                        'จ',
                                        'อ',
                                        'พ',
                                        'พฤ',
                                        'ศ',
                                        'ส',
                                        'อา',
                                      ][day.weekday - 1]
                                    : const [
                                        'M',
                                        'T',
                                        'W',
                                        'T',
                                        'F',
                                        'S',
                                        'S',
                                      ][day.weekday - 1],
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: JamoreColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 14,
                  runSpacing: 6,
                  children: [
                    _WorkLegend(
                      color: JamoreColors.success,
                      label: context.isThai ? 'ปกติ' : 'Normal',
                    ),
                    _WorkLegend(
                      color: JamoreColors.warning,
                      label: context.l10n.late,
                    ),
                    const _WorkLegend(color: JamoreColors.primary, label: 'OT'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          SectionHeading(
            title: context.l10n.recentHistory,
            subtitle: context.isThai ? 'Recent days' : null,
            onSeeAll: () => state.navigate('/worktime/history'),
          ),
          const SizedBox(height: 10),
          JamoreCard(
            padding: const EdgeInsets.all(4),
            child: logs.isEmpty
                ? const EmptyMessage()
                : Column(children: logs.map((log) => _WorkRow(log)).toList()),
          ),
        ],
      ),
    );
  }

  static bool _isLate(WorkLog log) =>
      log.clockIn != null &&
      (log.clockIn!.hour > 9 ||
          log.clockIn!.hour == 9 && log.clockIn!.minute > 0);

  static String _compact(double value) =>
      value.toStringAsFixed(value % 1 == 0 ? 0 : 1);
}

class _WeeklyMetric extends StatelessWidget {
  const _WeeklyMetric({
    required this.label,
    required this.value,
    this.suffix,
    this.color = JamoreColors.ink,
  });

  final String label;
  final String value;
  final String? suffix;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: JamoreColors.muted,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 2),
      Text.rich(
        TextSpan(
          text: value,
          children: suffix == null
              ? const []
              : [
                  TextSpan(
                    text: ' $suffix',
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0,
                    ),
                  ),
                ],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 24,
          fontWeight: FontWeight.w800,
          letterSpacing: -.5,
        ),
      ),
    ],
  );
}

class _WorkLegend extends StatelessWidget {
  const _WorkLegend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 4),
      Text(
        label,
        style: const TextStyle(color: JamoreColors.muted, fontSize: 10),
      ),
    ],
  );
}

class _TimeTile extends StatelessWidget {
  const _TimeTile({
    required this.label,
    required this.time,
    required this.color,
    super.key,
  });
  final String label;
  final String time;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 9),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: JamoreColors.muted),
            ),
            Text(
              time,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ],
    ),
  );
}

class _WorkRow extends StatelessWidget {
  const _WorkRow(this.log);
  final WorkLog log;
  @override
  Widget build(BuildContext context) {
    final hours = log.duration.inMinutes / 60;
    final late =
        log.clockIn != null &&
        (log.clockIn!.hour > 9 ||
            log.clockIn!.hour == 9 && log.clockIn!.minute > 0);
    final working = log.isWorking;
    final background = working
        ? JamoreColors.primarySoft
        : late
        ? const Color(0xFFFEF3C7)
        : const Color(0xFFDCFCE7);
    final foreground = working
        ? JamoreColors.primaryDark
        : late
        ? const Color(0xFFB45309)
        : const Color(0xFF15803D);
    final status = working
        ? context.l10n.working
        : late
        ? context.l10n.late
        : context.isThai
        ? 'ปกติ'
        : 'Normal';
    final dayLabel = context.isThai
        ? const ['จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส', 'อา'][log.date.weekday - 1]
        : const ['M', 'T', 'W', 'T', 'F', 'S', 'S'][log.date.weekday - 1];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  dayLabel,
                  style: TextStyle(
                    height: 1,
                    color: foreground,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${log.date.day}',
                  style: TextStyle(
                    height: 1,
                    color: foreground,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _WorkTimeCell(
                    label: context.isThai ? 'เข้า' : 'In',
                    value: log.clockIn == null
                        ? '—'
                        : context.time(log.clockIn!),
                  ),
                ),
                Expanded(
                  child: _WorkTimeCell(
                    label: context.isThai ? 'ออก' : 'Out',
                    value: log.clockOut == null
                        ? '—'
                        : context.time(log.clockOut!),
                  ),
                ),
                Expanded(
                  child: _WorkTimeCell(
                    label: context.isThai ? 'รวม' : 'Total',
                    value: working
                        ? '—'
                        : '${hours.toStringAsFixed(1)} ${context.l10n.hours}',
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: foreground,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkTimeCell extends StatelessWidget {
  const _WorkTimeCell({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
      ),
      const SizedBox(height: 1),
      Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    ],
  );
}

class _WorkHistory extends StatelessWidget {
  const _WorkHistory();
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final logs = state.data.workLogs;
    final total = logs.fold<Duration>(
      Duration.zero,
      (sum, log) => sum + log.duration,
    );
    final late = logs
        .where((log) => log.clockIn != null && log.clockIn!.hour >= 9)
        .length;
    final overtimeHours = state.data.overtimeRequests
        .where((item) => item.status == RequestStatus.approved)
        .fold<double>(0, (sum, item) => sum + item.hours);
    return PageSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeading(
            title: context.l10n.workHistory,
            subtitle: DateFormat.yMMMM(
              context.isThai ? 'th' : 'en',
            ).format(DateTime.now()),
            backTo: '/worktime',
          ),
          JamoreCard(
            child: Row(
              children: [
                Expanded(
                  child: _HistoryMetric(
                    label: context.isThai ? 'วันทำงาน' : 'Work days',
                    value: '${logs.length}',
                    suffix: context.l10n.days,
                    color: JamoreColors.ink,
                  ),
                ),
                Expanded(
                  child: _HistoryMetric(
                    label: context.l10n.totalHours,
                    value: (total.inMinutes / 60).toStringAsFixed(1),
                    suffix: context.l10n.hours,
                    color: JamoreColors.ink,
                  ),
                ),
                Expanded(
                  child: _HistoryMetric(
                    label: context.l10n.late,
                    value: '$late',
                    suffix: context.l10n.days,
                    color: JamoreColors.warning,
                  ),
                ),
                Expanded(
                  child: _HistoryMetric(
                    label: 'OT',
                    value: overtimeHours.toStringAsFixed(
                      overtimeHours % 1 == 0 ? 0 : 1,
                    ),
                    suffix: context.l10n.hours,
                    color: JamoreColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          JamoreCard(
            padding: const EdgeInsets.all(4),
            child: logs.isEmpty
                ? const EmptyMessage()
                : Column(children: logs.map((log) => _WorkRow(log)).toList()),
          ),
        ],
      ),
    );
  }
}

class _HistoryMetric extends StatelessWidget {
  const _HistoryMetric({
    required this.label,
    required this.value,
    required this.color,
    this.suffix,
  });
  final String label;
  final String value;
  final Color color;
  final String? suffix;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 10, color: JamoreColors.muted),
      ),
      Text.rich(
        TextSpan(
          text: value,
          children: suffix == null
              ? const []
              : [
                  TextSpan(
                    text: ' $suffix',
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
        ),
        maxLines: 1,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    ],
  );
}

class _TimeFlow extends StatefulWidget {
  const _TimeFlow();
  @override
  State<_TimeFlow> createState() => _TimeFlowState();
}

class _TimeFlowState extends State<_TimeFlow> {
  int step = 0;
  bool ready = false;
  bool done = false;
  Timer? timer;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _selfie() {
    setState(() => step = 1);
    if (MediaQuery.disableAnimationsOf(context)) {
      setState(() => ready = true);
    } else {
      timer = Timer(const Duration(milliseconds: 1400), () {
        if (mounted) setState(() => ready = true);
      });
    }
  }

  Future<void> _record() async {
    await context.read<AppState>().recordTime();
    if (mounted) setState(() => done = true);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final action = (state.todayLog?.isWorking ?? false)
        ? context.l10n.clockOut
        : context.l10n.clockIn;
    if (done) {
      return PageSurface(
        child: Column(
          children: [
            const SizedBox(height: 70),
            Container(
              width: 92,
              height: 92,
              decoration: const BoxDecoration(
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: JamoreColors.success,
                size: 54,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              context.l10n.timeRecorded,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            Text(
              '$action · ${context.time(DateTime.now())}\n${context.l10n.officeName}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: JamoreColors.muted),
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              label: context.l10n.back,
              icon: Icons.arrow_back_rounded,
              onPressed: () => state.navigate('/worktime'),
            ),
          ],
        ),
      );
    }
    return PageSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeading(
            title: context.isThai ? 'ลงเวลา' : 'Record time',
            subtitle: step == 0 ? '1/2 · GPS verify' : '2/2 · Selfie',
            backTo: '/worktime',
          ),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: 1,
                  minHeight: 5,
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: LinearProgressIndicator(
                  value: step == 1 ? 1 : 0,
                  minHeight: 5,
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (step == 0) ...[
            JamoreCard(
              padding: EdgeInsets.zero,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 220, child: _MiniMap()),
                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              '✓ ${context.l10n.insideOffice}',
                              style: const TextStyle(
                                color: Color(0xFF15803D),
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            context.l10n.officeName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            context.l10n.officeAddress,
                            style: const TextStyle(color: JamoreColors.muted),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _LocationMetric(
                                    label: context.isThai
                                        ? 'ระยะห่าง'
                                        : 'Distance',
                                    value: context.isThai ? '8 ม.' : '8 m',
                                  ),
                                ),
                                Expanded(
                                  child: _LocationMetric(
                                    label: context.isThai
                                        ? 'ความแม่นยำ'
                                        : 'Accuracy',
                                    value: context.isThai ? '3 ม.' : '3 m',
                                  ),
                                ),
                                const Expanded(
                                  child: _LocationMetric(
                                    label: 'GPS',
                                    value: '✓ Strong',
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
              ),
            ),
            const SizedBox(height: 14),
            PrimaryButton(
              label: context.l10n.nextSelfie,
              onPressed: _selfie,
              icon: Icons.camera_alt_rounded,
            ),
          ] else ...[
            AspectRatio(
              aspectRatio: 3 / 4,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                  ),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white38, width: 3),
                      ),
                    ),
                    Container(
                      width: 138,
                      height: 138,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .1),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white54,
                        size: 82,
                      ),
                    ),
                    Positioned(
                      bottom: 25,
                      child: AnimatedContainer(
                        duration: MediaQuery.disableAnimationsOf(context)
                            ? Duration.zero
                            : const Duration(milliseconds: 220),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: ready
                              ? JamoreColors.success
                              : Colors.white.withValues(alpha: .15),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              ready
                                  ? Icons.check_rounded
                                  : Icons.center_focus_strong_rounded,
                              color: Colors.white,
                              size: 17,
                            ),
                            const SizedBox(width: 7),
                            Text(
                              ready
                                  ? context.l10n.faceVerified
                                  : context.l10n.placeFace,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            PrimaryButton(
              label: ready
                  ? context.isThai
                        ? 'ยืนยันลงเวลา · Confirm'
                        : 'Confirm time record'
                  : context.l10n.checking,
              onPressed: ready ? _record : null,
              busy: !ready,
            ),
          ],
        ],
      ),
    );
  }
}

class _LocationMetric extends StatelessWidget {
  const _LocationMetric({required this.label, required this.value});

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
        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
      ),
      const SizedBox(height: 2),
      Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      ),
    ],
  );
}

class _MiniMap extends StatelessWidget {
  const _MiniMap();
  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _MapPainter(),
    child: const Center(
      child: Icon(Icons.location_pin, color: JamoreColors.primary, size: 48),
    ),
  );
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFE8EEF5),
    );
    final road = Paint()
      ..color = Colors.white
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(-20, size.height * .7),
      Offset(size.width + 20, size.height * .35),
      road,
    );
    canvas.drawLine(
      Offset(size.width * .2, -20),
      Offset(size.width * .6, size.height + 20),
      road..strokeWidth = 11,
    );
    canvas.drawLine(
      Offset(size.width * .85, -20),
      Offset(size.width * .68, size.height + 20),
      road..strokeWidth = 8,
    );
    final building = Paint()..color = const Color(0xFFCBD5E1);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * .1, 18, 50, 34),
        const Radius.circular(4),
      ),
      building,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * .7, size.height * .62, 56, 40),
        const Radius.circular(4),
      ),
      building,
    );
  }

  @override
  bool shouldRepaint(covariant _MapPainter oldDelegate) => false;
}
