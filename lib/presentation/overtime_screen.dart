import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/extensions.dart';
import '../core/theme.dart';
import '../domain/entities/hr_models.dart';
import '../state/app_state.dart';
import 'common.dart';

class OvertimeScreen extends StatelessWidget {
  const OvertimeScreen({required this.location, super.key});
  final String location;

  @override
  Widget build(BuildContext context) {
    if (location == '/overtime/request') return const _OtRequestScreen();
    if (location.startsWith('/overtime/') && location.split('/').length > 2) {
      return _OtDetailScreen(id: location.split('/').last);
    }
    return const _OtMain();
  }
}

class _OtMain extends StatefulWidget {
  const _OtMain();
  @override
  State<_OtMain> createState() => _OtMainState();
}

class _OtMainState extends State<_OtMain> {
  RequestStatus? filter;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final items = state.data.overtimeRequests
        .where((item) => filter == null || item.status == filter)
        .toList();
    final approved = state.data.overtimeRequests.where(
      (item) => item.status == RequestStatus.approved,
    );
    final hours = approved.fold<double>(0, (sum, item) => sum + item.hours);
    final amount = approved.fold<int>(0, (sum, item) => sum + item.amount);
    return PageSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeading(
            title: context.isThai ? 'ทำงานล่วงเวลา' : 'Overtime',
            subtitle: 'Overtime · OT',
          ),
          _OtSummaryHero(hours: hours, amount: amount),
          const SizedBox(height: 14),
          _OtNewRequestButton(
            onPressed: () => state.navigate('/overtime/request'),
          ),
          const SizedBox(height: 20),
          Text(
            context.isThai ? 'อัตราคำนวณ OT' : 'OT rates',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _OtRateCard(
                  rate: '×1.5',
                  label: context.l10n.weekday,
                  subtitle: context.isThai ? 'หลังเลิกงาน' : 'After work',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _OtRateCard(
                  rate: '×2',
                  label: context.l10n.dayOff,
                  subtitle: context.isThai ? 'เสาร์-อาทิตย์' : 'Weekend',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _OtRateCard(
                  rate: '×3',
                  label: context.l10n.publicHoliday,
                  subtitle: context.isThai
                      ? 'วันหยุดประจำชาติ'
                      : 'National holiday',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          RequestStatusFilter(
            value: filter,
            onChanged: (value) => setState(() => filter = value),
          ),
          const SizedBox(height: 14),
          if (items.isEmpty)
            const JamoreCard(child: EmptyMessage())
          else
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _OtRow(item),
              ),
            ),
        ],
      ),
    );
  }
}

class _OtSummaryHero extends StatelessWidget {
  const _OtSummaryHero({required this.hours, required this.amount});

  final double hours;
  final int amount;

  @override
  Widget build(BuildContext context) => Container(
    key: const Key('otSummaryHero'),
    width: double.infinity,
    padding: const EdgeInsets.all(22),
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
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
    child: Stack(
      children: [
        const Positioned(right: -72, top: -72, child: _OtDecorativeRing()),
        const Positioned(
          right: -42,
          bottom: -82,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0x0FFFFFFF),
              shape: BoxShape.circle,
            ),
            child: SizedBox.square(dimension: 130),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${DateFormat.yMMMM(context.isThai ? 'th' : 'en').format(DateTime.now())} · ${context.isThai ? 'ยอดสะสม' : 'Accumulated'}',
              style: const TextStyle(
                color: Color(0xD9FFFFFF),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          text: _compact(hours),
                          children: [
                            TextSpan(
                              text: ' ${context.l10n.hours}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xD9FFFFFF),
                                letterSpacing: 0,
                              ),
                            ),
                          ],
                        ),
                        style: const TextStyle(
                          height: 1,
                          color: Colors.white,
                          fontSize: 46,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.isThai ? 'จาก 36 ชม./เดือน' : 'of 36 hrs/month',
                        style: const TextStyle(
                          color: Color(0xB3FFFFFF),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      context.l10n.estimatedOt,
                      style: const TextStyle(
                        color: Color(0xCCFFFFFF),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '฿${NumberFormat('#,##0').format(amount)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),
            const _OtBarChart(),
          ],
        ),
      ],
    ),
  );

  static String _compact(double value) =>
      value.toStringAsFixed(value % 1 == 0 ? 0 : 1);
}

class _OtDecorativeRing extends StatelessWidget {
  const _OtDecorativeRing();

  @override
  Widget build(BuildContext context) => Container(
    width: 180,
    height: 180,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: const Color(0x14FFFFFF), width: 24),
    ),
  );
}

class _OtBarChart extends StatelessWidget {
  const _OtBarChart();

  static const values = <double>[
    2,
    3,
    4,
    2.5,
    1.5,
    0,
    0,
    3,
    2,
    4,
    2.5,
    5,
    1,
    0,
  ];

  @override
  Widget build(BuildContext context) => Column(
    children: [
      SizedBox(
        height: 50,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: values
              .map(
                (value) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: FractionallySizedBox(
                      heightFactor: value == 0 ? .06 : value / 5,
                      alignment: Alignment.bottomCenter,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: value == 0
                              ? const Color(0x26FFFFFF)
                              : const Color(0xD9FFFFFF),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
      const SizedBox(height: 6),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            context.isThai ? 'สัปดาห์ที่แล้ว' : 'Last week',
            style: const TextStyle(color: Color(0xB3FFFFFF), fontSize: 10),
          ),
          Text(
            context.l10n.thisWeek,
            style: const TextStyle(color: Color(0xB3FFFFFF), fontSize: 10),
          ),
        ],
      ),
    ],
  );
}

class _OtNewRequestButton extends StatelessWidget {
  const _OtNewRequestButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 52,
    child: OutlinedButton.icon(
      key: const Key('newOtButton'),
      onPressed: onPressed,
      icon: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: JamoreColors.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 16),
      ),
      label: Text(
        context.isThai ? 'ขอ OT ล่วงหน้า · New request' : 'New OT request',
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: JamoreColors.ink,
        side: const BorderSide(color: JamoreColors.line),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
  );
}

class _OtRateCard extends StatelessWidget {
  const _OtRateCard({
    required this.rate,
    required this.label,
    required this.subtitle,
  });

  final String rate;
  final String label;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: JamoreColors.line),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          rate,
          style: const TextStyle(
            color: JamoreColors.primary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF334155),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
        ),
      ],
    ),
  );
}

class _OtRow extends StatelessWidget {
  const _OtRow(this.item);
  final OvertimeRequest item;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: const BorderSide(color: JamoreColors.line),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: () => context.read<AppState>().navigate('/overtime/${item.id}'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: JamoreColors.primary.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _compact(item.hours),
                    style: const TextStyle(
                      height: 1,
                      color: JamoreColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    context.l10n.hours,
                    style: const TextStyle(
                      color: JamoreColors.primary,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          context.date(item.date),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: JamoreColors.primary.withValues(alpha: .08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '×${_compact(item.rate)}',
                          style: const TextStyle(
                            color: JamoreColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.reason,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: JamoreColors.muted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  StatusBadge(item.status),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '฿${NumberFormat('#,##0').format(item.amount)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFCBD5E1),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  static String _compact(double value) =>
      value.toStringAsFixed(value % 1 == 0 ? 0 : 1);
}

class _OtRequestScreen extends StatefulWidget {
  const _OtRequestScreen();
  @override
  State<_OtRequestScreen> createState() => _OtRequestScreenState();
}

class _OtRequestScreenState extends State<_OtRequestScreen> {
  final formKey = GlobalKey<FormState>();
  final reason = TextEditingController();
  late DateTime date = DateTime.now().add(const Duration(days: 1));
  TimeOfDay start = const TimeOfDay(hour: 18, minute: 30);
  TimeOfDay end = const TimeOfDay(hour: 21, minute: 30);
  double rate = 1.5;
  bool submitted = false;
  bool busy = false;

  int get startMinutes => start.hour * 60 + start.minute;
  int get endMinutes => end.hour * 60 + end.minute;
  double get hours => (endMinutes - startMinutes) / 60;
  int get amount => (hours * 250 * rate).round();

  @override
  void dispose() {
    reason.dispose();
    super.dispose();
  }

  Future<void> _date() async {
    final value = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (value != null) setState(() => date = value);
  }

  Future<void> _time(bool isStart) async {
    final value = await showTimePicker(
      context: context,
      initialTime: isStart ? start : end,
    );
    if (value == null) return;
    final total = value.hour * 60 + value.minute;
    final roundedTotal = ((total + 15) ~/ 30 * 30) % (24 * 60);
    final rounded = TimeOfDay(
      hour: roundedTotal ~/ 60,
      minute: roundedTotal % 60,
    );
    setState(() => isStart ? start = rounded : end = rounded);
  }

  Future<void> _submit() async {
    if (!formKey.currentState!.validate()) return;
    if (hours <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.invalidTimeRange)));
      return;
    }
    setState(() => busy = true);
    await context.read<AppState>().submitOvertime(
      date: date,
      startMinutes: startMinutes,
      endMinutes: endMinutes,
      rate: rate,
      reason: reason.text,
    );
    if (mounted) {
      setState(() {
        busy = false;
        submitted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (submitted) return _OtSuccess(backTo: '/overtime');
    return PageSurface(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeading(
              title: context.l10n.requestOt,
              subtitle: context.isThai ? 'New overtime request' : null,
              backTo: '/overtime',
            ),
            _OtFormCard(
              title: context.l10n.otDate,
              subtitle: context.isThai ? 'Date' : null,
              child: _PickerButton(
                value: context.date(date),
                icon: Icons.calendar_month_rounded,
                onTap: _date,
              ),
            ),
            const SizedBox(height: 12),
            _OtFormCard(
              title: context.l10n.timeRange,
              subtitle: context.isThai ? 'Time range' : null,
              child: Row(
                children: [
                  Expanded(
                    child: _PickerButton(
                      value: start.format(context),
                      icon: Icons.schedule_rounded,
                      onTap: () => _time(true),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: JamoreColors.muted,
                    ),
                  ),
                  Expanded(
                    child: _PickerButton(
                      value: end.format(context),
                      icon: Icons.schedule_rounded,
                      onTap: () => _time(false),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _OtFormCard(
              title: context.l10n.otHours,
              subtitle: context.isThai ? 'Hours' : null,
              child: Center(
                child: Text(
                  hours > 0
                      ? '${hours.toStringAsFixed(1)} ${context.l10n.hours}'
                      : '—',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _OtFormCard(
              title: context.l10n.otRate,
              subtitle: context.isThai ? 'Rate' : null,
              child: SegmentedButton<double>(
                segments: [
                  ButtonSegment(
                    value: 1.5,
                    label: Text(
                      '×1.5\n${context.l10n.weekday}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  ButtonSegment(
                    value: 2.0,
                    label: Text(
                      '×2\n${context.l10n.dayOff}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  ButtonSegment(
                    value: 3.0,
                    label: Text(
                      '×3\n${context.l10n.publicHoliday}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                selected: {rate},
                onSelectionChanged: (value) =>
                    setState(() => rate = value.first),
                showSelectedIcon: false,
              ),
            ),
            const SizedBox(height: 12),
            _OtFormCard(
              title: context.l10n.reason,
              subtitle: context.isThai ? 'Reason' : null,
              child: TextFormField(
                controller: reason,
                minLines: 3,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: context.l10n.otReasonHint,
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? context.l10n.requiredField
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0x140099CC),
                border: Border.all(color: const Color(0x300099CC)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.estimatedOt,
                    style: const TextStyle(
                      color: JamoreColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    hours > 0 ? '฿$amount' : '—',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    '${hours > 0 ? hours.toStringAsFixed(1) : 0} × ฿250 × $rate',
                    style: const TextStyle(
                      fontSize: 11,
                      color: JamoreColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            PrimaryButton(
              label: context.isThai
                  ? '${context.l10n.submitRequest} · Submit'
                  : context.l10n.submitRequest,
              onPressed: _submit,
              busy: busy,
            ),
          ],
        ),
      ),
    );
  }
}

class _OtDetailScreen extends StatelessWidget {
  const _OtDetailScreen({required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    OvertimeRequest? item;
    for (final value in state.data.overtimeRequests) {
      if (value.id == id) item = value;
    }
    if (item == null) {
      return PageSurface(
        child: PageHeading(title: context.l10n.noItems, backTo: '/overtime'),
      );
    }
    final value = item;
    return PageSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeading(
            title: context.l10n.otDetail,
            subtitle: value.id,
            backTo: '/overtime',
          ),
          JamoreCard(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    StatusBadge(value.status),
                    const Spacer(),
                    Text(
                      context.date(value.date),
                      style: const TextStyle(color: JamoreColors.muted),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  context.isThai ? 'เงิน OT' : 'OT pay',
                  style: const TextStyle(
                    color: JamoreColors.muted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '฿${NumberFormat('#,##0').format(value.amount)}',
                  style: const TextStyle(
                    height: 1,
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _OtDetailMetric(
                          label: context.l10n.otHours,
                          value:
                              '${_compact(value.hours)} ${context.l10n.hours}',
                        ),
                      ),
                      Expanded(
                        child: _OtDetailMetric(
                          label: context.l10n.otRate,
                          value: '×${_compact(value.rate)}',
                        ),
                      ),
                      Expanded(
                        child: _OtDetailMetric(
                          label: context.isThai ? 'ค่าจ้าง/ชม.' : 'Hourly wage',
                          value:
                              '฿${NumberFormat('#,##0').format(value.hourlyWage)}',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.reason,
                        style: const TextStyle(
                          color: JamoreColors.muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(value.reason),
                      const SizedBox(height: 6),
                      Text(
                        '${_formatMinutes(value.startMinutes)} — ${_formatMinutes(value.endMinutes)}',
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
          ),
          const SizedBox(height: 14),
          JamoreCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.approvalTimeline,
                  style: const TextStyle(
                    color: JamoreColors.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: .4,
                  ),
                ),
                const SizedBox(height: 12),
                _OtTimelineRow(
                  done: true,
                  label: context.l10n.submitted,
                  detail: context.time(value.submittedAt),
                ),
                _OtTimelineRow(
                  done: value.status != RequestStatus.pending,
                  label: context.l10n.managerReview,
                  detail: value.status == RequestStatus.pending
                      ? context.l10n.pending
                      : context.status(value.status),
                ),
                _OtTimelineRow(
                  done: value.status == RequestStatus.approved,
                  label: value.status == RequestStatus.rejected
                      ? context.l10n.rejected
                      : context.l10n.hrApproval,
                  detail: value.status == RequestStatus.pending
                      ? context.l10n.pending
                      : context.status(value.status),
                  last: true,
                ),
              ],
            ),
          ),
          if (value.status == RequestStatus.pending) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: JamoreColors.danger,
                ),
                onPressed: () async {
                  if (await confirmDialog(
                        context,
                        context.l10n.confirmCancel,
                        danger: true,
                      ) &&
                      context.mounted) {
                    await state.cancelOvertime(value.id);
                  }
                },
                icon: const Icon(Icons.cancel_outlined),
                label: Text(context.l10n.cancelRequest),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _formatMinutes(int value) =>
      '${(value ~/ 60).toString().padLeft(2, '0')}:${(value % 60).toString().padLeft(2, '0')}';

  static String _compact(double value) =>
      value.toStringAsFixed(value % 1 == 0 ? 0 : 1);
}

class _OtDetailMetric extends StatelessWidget {
  const _OtDetailMetric({required this.label, required this.value});

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
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
    ],
  );
}

class _OtTimelineRow extends StatelessWidget {
  const _OtTimelineRow({
    required this.done,
    required this.label,
    required this.detail,
    this.last = false,
  });

  final bool done;
  final String label;
  final String detail;
  final bool last;

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 20,
          child: Column(
            children: [
              Icon(
                done
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: done ? JamoreColors.success : const Color(0xFFCBD5E1),
                size: 20,
              ),
              if (!last)
                Expanded(
                  child: Container(width: 2, color: const Color(0xFFE2E8F0)),
                ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: last ? 0 : 16),
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        Text(
          detail,
          style: const TextStyle(color: JamoreColors.muted, fontSize: 11),
        ),
      ],
    ),
  );
}

class _OtFormCard extends StatelessWidget {
  const _OtFormCard({required this.title, required this.child, this.subtitle});
  final String title;
  final Widget child;
  final String? subtitle;
  @override
  Widget build(BuildContext context) => JamoreCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: title,
            children: subtitle == null
                ? const []
                : [
                    TextSpan(
                      text: ' · $subtitle',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
          ),
          style: const TextStyle(
            fontSize: 12,
            color: JamoreColors.muted,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        child,
      ],
    ),
  );
}

class _PickerButton extends StatelessWidget {
  const _PickerButton({
    required this.value,
    required this.icon,
    required this.onTap,
  });
  final String value;
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(value),
    ),
  );
}

class _OtSuccess extends StatelessWidget {
  const _OtSuccess({required this.backTo});
  final String backTo;
  @override
  Widget build(BuildContext context) => PageSurface(
    child: Column(
      children: [
        const SizedBox(height: 70),
        Container(
          width: 86,
          height: 86,
          decoration: const BoxDecoration(
            color: Color(0xFFFEF3C7),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            size: 48,
            color: Color(0xFFB45309),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          context.l10n.otSubmitted,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 5),
        Text(
          context.l10n.pending,
          style: const TextStyle(color: JamoreColors.muted),
        ),
        const SizedBox(height: 28),
        PrimaryButton(
          label: context.l10n.back,
          onPressed: () => context.read<AppState>().navigate(backTo),
          icon: Icons.arrow_back_rounded,
        ),
      ],
    ),
  );
}
