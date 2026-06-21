import 'package:flutter/material.dart';
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
            title: context.l10n.overtime,
            subtitle: context.l10n.overtimeSummary,
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
              ),
              borderRadius: BorderRadius.circular(26),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) => Wrap(
                spacing: 36,
                runSpacing: 14,
                children: [
                  _HeroMetric(
                    label: context.l10n.totalHours,
                    value: hours.toStringAsFixed(1),
                    suffix: context.l10n.hours,
                  ),
                  _HeroMetric(
                    label: context.l10n.estimatedOt,
                    value: '฿$amount',
                    suffix: context.l10n.baht,
                  ),
                  _HeroMetric(
                    label: context.l10n.pending,
                    value:
                        '${state.data.overtimeRequests.where((item) => item.status == RequestStatus.pending).length}',
                    suffix: context.l10n.pendingApprovals,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          PrimaryButton(
            label: context.l10n.requestOt,
            onPressed: () => state.navigate('/overtime/request'),
            icon: Icons.add_rounded,
          ),
          const SizedBox(height: 22),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChoiceChip(
                  label: Text(context.l10n.all),
                  selected: filter == null,
                  onSelected: (_) => setState(() => filter = null),
                ),
                const SizedBox(width: 7),
                ...RequestStatus.values.map(
                  (status) => Padding(
                    padding: const EdgeInsets.only(right: 7),
                    child: ChoiceChip(
                      label: Text(context.status(status)),
                      selected: filter == status,
                      onSelected: (_) => setState(() => filter = status),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          JamoreCard(
            padding: const EdgeInsets.all(4),
            child: items.isEmpty
                ? const EmptyMessage()
                : Column(children: items.map((item) => _OtRow(item)).toList()),
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({
    required this.label,
    required this.value,
    required this.suffix,
  });
  final String label;
  final String value;
  final String suffix;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 150,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          suffix,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
      ],
    ),
  );
}

class _OtRow extends StatelessWidget {
  const _OtRow(this.item);
  final OvertimeRequest item;
  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(18),
    onTap: () => context.read<AppState>().navigate('/overtime/${item.id}'),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.more_time_rounded,
              color: Color(0xFFB45309),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.hours.toStringAsFixed(1)} ${context.l10n.hours} · ×${item.rate}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                Text(
                  '${context.date(item.date)} · ฿${item.amount}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: JamoreColors.muted,
                  ),
                ),
              ],
            ),
          ),
          StatusBadge(item.status),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1)),
        ],
      ),
    ),
  );
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
            PageHeading(title: context.l10n.newOtRequest, backTo: '/overtime'),
            _OtFormCard(
              title: context.l10n.otDate,
              child: _PickerButton(
                value: context.date(date),
                icon: Icons.calendar_month_rounded,
                onTap: _date,
              ),
            ),
            const SizedBox(height: 12),
            _OtFormCard(
              title: context.l10n.timeRange,
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
              label: context.l10n.submitRequest,
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
                const SizedBox(height: 18),
                Text(
                  '${value.hours.toStringAsFixed(1)} ${context.l10n.hours}',
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '${_formatMinutes(value.startMinutes)} — ${_formatMinutes(value.endMinutes)} · ×${value.rate}',
                  style: const TextStyle(color: JamoreColors.muted),
                ),
                const Divider(height: 30),
                Text(
                  context.l10n.reason,
                  style: const TextStyle(
                    fontSize: 11,
                    color: JamoreColors.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(value.reason),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0x140099CC),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: Text(context.l10n.estimatedOt)),
                      Text(
                        '฿${value.amount}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: JamoreColors.primary,
                        ),
                      ),
                    ],
                  ),
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
}

class _OtFormCard extends StatelessWidget {
  const _OtFormCard({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => JamoreCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
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
