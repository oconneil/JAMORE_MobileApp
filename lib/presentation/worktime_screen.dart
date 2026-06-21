import 'dart:async';

import 'package:flutter/material.dart';
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
    return PageSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeading(
            title: context.l10n.worktimeTitle,
            subtitle: context.l10n.worktimeTracker,
          ),
          JamoreCard(
            padding: EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Column(
                children: [
                  const SizedBox(height: 150, child: _MiniMap()),
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
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
                                    context.l10n.gpsVerified,
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
                          PrimaryButton(
                            label: working
                                ? context.l10n.clockOut
                                : context.l10n.clockIn,
                            onPressed: () =>
                                state.navigate('/worktime/check-in'),
                            icon: working
                                ? Icons.logout_rounded
                                : Icons.login_rounded,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          SectionHeading(
            title: context.l10n.thisWeek,
            onSeeAll: () => state.navigate('/worktime/history'),
          ),
          const SizedBox(height: 10),
          JamoreCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.totalHours,
                  style: const TextStyle(
                    fontSize: 11,
                    color: JamoreColors.muted,
                  ),
                ),
                Text(
                  '${(total.inMinutes / 60).toStringAsFixed(1)} / 40 ${context.l10n.hours}',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
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
                                        color: hours > 10
                                            ? JamoreColors.primary
                                            : hours > 0
                                            ? JamoreColors.success
                                            : const Color(0xFFF1F5F9),
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
              ],
            ),
          ),
          const SizedBox(height: 22),
          SectionHeading(
            title: context.l10n.recentHistory,
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
}

class _TimeTile extends StatelessWidget {
  const _TimeTile({
    required this.label,
    required this.time,
    required this.color,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: late ? const Color(0xFFFEF3C7) : const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(11),
            ),
            alignment: Alignment.center,
            child: Text(
              '${log.date.day}',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: late ? const Color(0xFFB45309) : const Color(0xFF15803D),
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Wrap(
              spacing: 18,
              runSpacing: 3,
              children: [
                Text(
                  '${context.l10n.checkInTime} ${log.clockIn == null ? '—' : context.time(log.clockIn!)}',
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  '${context.l10n.checkOutTime} ${log.clockOut == null ? '—' : context.time(log.clockOut!)}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '${hours.toStringAsFixed(1)} ${context.l10n.hours}',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _WorkHistory extends StatelessWidget {
  const _WorkHistory();
  @override
  Widget build(BuildContext context) {
    final logs = context.watch<AppState>().data.workLogs;
    final total = logs.fold<Duration>(
      Duration.zero,
      (sum, log) => sum + log.duration,
    );
    final late = logs
        .where((log) => log.clockIn != null && log.clockIn!.hour >= 9)
        .length;
    return PageSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeading(title: context.l10n.workHistory, backTo: '/worktime'),
          JamoreCard(
            child: Row(
              children: [
                Expanded(
                  child: _HistoryMetric(
                    label: context.l10n.totalHours,
                    value: (total.inMinutes / 60).toStringAsFixed(1),
                    color: JamoreColors.primary,
                  ),
                ),
                Expanded(
                  child: _HistoryMetric(
                    label: context.l10n.late,
                    value: '$late',
                    color: JamoreColors.warning,
                  ),
                ),
                Expanded(
                  child: _HistoryMetric(
                    label: context.l10n.days,
                    value: '${logs.length}',
                    color: JamoreColors.success,
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
  });
  final String label;
  final String value;
  final Color color;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 10, color: JamoreColors.muted),
      ),
      Text(
        value,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w900,
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
            title: action,
            subtitle:
                '${step + 1}/2 · ${step == 0 ? context.l10n.verifyLocation : context.l10n.selfie}',
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
                    const SizedBox(height: 240, child: _MiniMap()),
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
                  ? '${context.l10n.confirm} $action'
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
