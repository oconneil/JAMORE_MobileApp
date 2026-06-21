import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../application/ports/attachment_picker.dart';
import '../core/extensions.dart';
import '../core/theme.dart';
import '../domain/entities/hr_models.dart';
import '../state/app_state.dart';
import 'common.dart';

class LeaveScreen extends StatelessWidget {
  const LeaveScreen({required this.location, super.key});
  final String location;

  @override
  Widget build(BuildContext context) {
    if (location == '/leave/request') return const _LeaveRequestScreen();
    if (location == '/leave/calendar') return const _TeamCalendarScreen();
    if (location == '/leave/approvals') return const _ApprovalScreen();
    if (location.startsWith('/leave/') && location.split('/').length > 2) {
      return _LeaveDetailScreen(id: location.split('/').last);
    }
    return const _LeaveMain();
  }
}

class _LeaveMain extends StatefulWidget {
  const _LeaveMain();
  @override
  State<_LeaveMain> createState() => _LeaveMainState();
}

class _LeaveMainState extends State<_LeaveMain> {
  RequestStatus? filter;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final items = state.data.leaveRequests
        .where((item) => filter == null || item.status == filter)
        .toList();
    return PageSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeading(title: context.l10n.leave, subtitle: 'Leave management'),
          Container(
            key: const Key('leaveBalanceCard'),
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: JamoreColors.line),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${context.l10n.leaveBalance} · ${DateTime.now().year}',
                        style: const TextStyle(
                          color: JamoreColors.muted,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    TextButton(
                      key: const Key('leaveTeamCalendarButton'),
                      onPressed: () => state.navigate('/leave/calendar'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text('${context.l10n.teamCalendar} →'),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: state.data.leaveBalances
                      .map((balance) => Expanded(child: _BalanceTile(balance)))
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  key: const Key('newLeaveButton'),
                  onPressed: () => state.navigate('/leave/request'),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text(context.l10n.newLeaveRequest),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Badge(
                  alignment: const Alignment(.82, -.82),
                  label: Text(
                    '${state.data.teamApprovals.where((item) => item.status == RequestStatus.pending).length}',
                  ),
                  child: OutlinedButton(
                    key: const Key('leaveApprovalsButton'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      foregroundColor: JamoreColors.ink,
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: JamoreColors.line),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => state.navigate('/leave/approvals'),
                    child: Text(context.l10n.approve),
                  ),
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
                child: _LeaveRow(item),
              ),
            ),
        ],
      ),
    );
  }
}

class _BalanceTile extends StatelessWidget {
  const _BalanceTile(this.item);
  final LeaveBalance item;

  @override
  Widget build(BuildContext context) {
    final color = switch (item.kind) {
      LeaveKind.annual => const Color(0xFF3B82F6),
      LeaveKind.sick => const Color(0xFF10B981),
      LeaveKind.personal => const Color(0xFFF59E0B),
      LeaveKind.maternity => const Color(0xFFEC4899),
    };
    final remaining = item.remaining.toStringAsFixed(
      item.remaining % 1 == 0 ? 0 : 1,
    );
    return Column(
      children: [
        SizedBox.square(
          dimension: 56,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox.square(
                dimension: 56,
                child: CircularProgressIndicator(
                  value: item.total == 0 ? 0 : item.remaining / item.total,
                  strokeWidth: 5,
                  backgroundColor: const Color(0xFFF1F5F9),
                  color: color,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    remaining,
                    style: const TextStyle(
                      height: 1,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '/ ${item.total.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 8,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          context.leaveKind(item.kind),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF475569),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _LeaveRow extends StatelessWidget {
  const _LeaveRow(this.item);
  final LeaveRequest item;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: const BorderSide(color: JamoreColors.line),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: () => context.read<AppState>().navigate('/leave/${item.id}'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.days.toStringAsFixed(item.days % 1 == 0 ? 0 : 1),
                    style: const TextStyle(
                      height: 1,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    context.l10n.days,
                    style: const TextStyle(
                      color: JamoreColors.muted,
                      fontSize: 9,
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
                          context.leaveKind(item.kind),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      StatusBadge(item.status),
                    ],
                  ),
                  Text(
                    '${context.date(item.start, year: false)} → ${context.date(item.end)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: JamoreColors.muted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '“${item.reason}”',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1)),
          ],
        ),
      ),
    ),
  );
}

class _LeaveRequestScreen extends StatefulWidget {
  const _LeaveRequestScreen();
  @override
  State<_LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<_LeaveRequestScreen> {
  final formKey = GlobalKey<FormState>();
  final reason = TextEditingController();
  LeaveKind kind = LeaveKind.annual;
  late DateTime start;
  late DateTime end;
  bool halfDay = false;
  AttachmentMeta? attachment;
  bool submitted = false;
  bool busy = false;

  @override
  void initState() {
    super.initState();
    start = _nextWeekday(DateTime.now().add(const Duration(days: 1)));
    end = start;
  }

  @override
  void dispose() {
    reason.dispose();
    super.dispose();
  }

  Future<void> _date(bool from) async {
    final value = await showDatePicker(
      context: context,
      initialDate: from ? start : end,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (value == null) return;
    setState(() {
      if (from) {
        start = value;
        if (end.isBefore(start)) end = start;
      } else {
        end = value;
      }
      if (start != end) halfDay = false;
    });
  }

  Future<void> _attachment() async {
    final value = await context.read<AttachmentPicker>().pick();
    if (!mounted) return;
    if (value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.filePickerUnavailable)),
      );
    } else {
      setState(() => attachment = value);
    }
  }

  Future<void> _submit() async {
    if (!formKey.currentState!.validate()) return;
    final state = context.read<AppState>();
    final days = state.workingDays(start, end, halfDay: halfDay);
    if (days <= 0) return _message(context.l10n.noWorkingDays);
    if (days > state.balanceFor(kind).remaining) {
      return _message(context.l10n.insufficientBalance);
    }
    setState(() => busy = true);
    await state.submitLeave(
      kind: kind,
      start: start,
      end: end,
      days: days,
      reason: reason.text,
      attachment: attachment,
    );
    if (mounted) {
      setState(() {
        busy = false;
        submitted = true;
      });
    }
  }

  void _message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) {
    if (submitted) {
      return _Success(
        title: context.l10n.leaveSubmitted,
        subtitle: context.l10n.waitingManager,
        backTo: '/leave',
      );
    }
    final state = context.watch<AppState>();
    final days = state.workingDays(start, end, halfDay: halfDay);
    return PageSurface(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeading(
              title: context.l10n.requestLeave,
              subtitle: context.isThai ? 'New leave request' : null,
              backTo: '/leave',
            ),
            _FormSection(
              title: context.l10n.leaveType,
              subtitle: context.isThai ? 'Leave type' : null,
              child: LayoutBuilder(
                builder: (context, constraints) => GridView.count(
                  crossAxisCount: constraints.maxWidth > 520 ? 4 : 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 2.05,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  children: LeaveKind.values
                      .map(
                        (value) => ChoiceChip(
                          selected: kind == value,
                          onSelected: (_) => setState(() => kind = value),
                          label: SizedBox(
                            width: double.infinity,
                            child: Text(
                              '${context.leaveKind(value)}\n${state.balanceFor(value).remaining.toStringAsFixed(0)} ${context.l10n.days}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _FormSection(
              title: context.l10n.dateRange,
              subtitle: context.isThai ? 'Date range' : null,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _DateButton(
                          label: context.l10n.fromDate,
                          value: context.date(start),
                          onTap: () => _date(true),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _DateButton(
                          label: context.l10n.toDate,
                          value: context.date(end),
                          onTap: () => _date(false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        '${context.l10n.leaveDays}:',
                        style: const TextStyle(color: JamoreColors.muted),
                      ),
                      const Spacer(),
                      Text(
                        '$days ${context.l10n.days}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  if (AppState.sameDay(start, end))
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: halfDay,
                      onChanged: (value) => setState(() => halfDay = value),
                      title: Text(context.l10n.halfDay),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _FormSection(
              title: context.l10n.reason,
              subtitle: context.isThai ? 'Reason' : null,
              child: TextFormField(
                controller: reason,
                maxLines: 3,
                decoration: InputDecoration(hintText: context.l10n.reasonHint),
                validator: (value) => value == null || value.trim().isEmpty
                    ? context.l10n.requiredField
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            _FormSection(
              title: context.l10n.attachmentOptional,
              subtitle: context.isThai ? 'Attachment' : null,
              child: OutlinedButton.icon(
                onPressed: _attachment,
                icon: Icon(
                  attachment == null
                      ? Icons.attach_file_rounded
                      : Icons.check_circle_rounded,
                ),
                label: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(attachment?.name ?? context.l10n.chooseFile),
                ),
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

  static DateTime _nextWeekday(DateTime value) {
    var result = DateTime(value.year, value.month, value.day);
    while (result.weekday > DateTime.friday) {
      result = result.add(const Duration(days: 1));
    }
    return result;
  }
}

class _LeaveDetailScreen extends StatelessWidget {
  const _LeaveDetailScreen({required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final item = state.data.leaveRequests.cast<LeaveRequest?>().firstWhere(
      (value) => value?.id == id,
      orElse: () => null,
    );
    if (item == null) {
      return _Success(
        title: context.l10n.noItems,
        subtitle: id,
        backTo: '/leave',
      );
    }
    return PageSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeading(
            title: context.l10n.leaveDetail,
            subtitle: item.id,
            backTo: '/leave',
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [JamoreColors.primary, JamoreColors.primaryDark],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatusBadge(item.status),
                const SizedBox(height: 12),
                Text(
                  context.leaveKind(item.kind),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '${context.date(item.start)} → ${context.date(item.end)}',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 12),
                Text(
                  '${item.days} ${context.l10n.days}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          JamoreCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.reason,
                  style: const TextStyle(
                    color: JamoreColors.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(item.reason),
                if (item.attachment != null) ...[
                  const Divider(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.attach_file_rounded, size: 18),
                      const SizedBox(width: 6),
                      Text(item.attachment!.name),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          JamoreCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.approvalTimeline,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                _TimelineRow(
                  done: true,
                  label: context.l10n.submitted,
                  detail: context.date(item.submittedAt),
                ),
                _TimelineRow(
                  done: item.status != RequestStatus.pending,
                  label: context.l10n.managerReview,
                  detail: item.status == RequestStatus.pending
                      ? context.l10n.pending
                      : context.status(item.status),
                ),
                _TimelineRow(
                  done: item.status == RequestStatus.approved,
                  label: context.l10n.hrApproval,
                  detail: item.decisionReason ?? context.status(item.status),
                ),
              ],
            ),
          ),
          if (item.status == RequestStatus.pending) ...[
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
                    await state.cancelLeave(item.id);
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
}

class _TeamCalendarScreen extends StatefulWidget {
  const _TeamCalendarScreen();
  @override
  State<_TeamCalendarScreen> createState() => _TeamCalendarScreenState();
}

class _TeamCalendarScreenState extends State<_TeamCalendarScreen> {
  late DateTime month = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  Widget build(BuildContext context) {
    final approvals = context.watch<AppState>().data.teamApprovals;
    final firstWeekday = DateTime(month.year, month.month, 1).weekday % 7;
    final count = DateUtils.getDaysInMonth(month.year, month.month);
    final cells = List<int?>.filled(firstWeekday, null, growable: true)
      ..addAll(List.generate(count, (index) => index + 1));
    return PageSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeading(
            title: context.l10n.teamCalendar,
            subtitle: context.isThai ? 'Team leave calendar' : null,
            backTo: '/leave',
          ),
          JamoreCard(
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => setState(
                        () => month = DateTime(month.year, month.month - 1),
                      ),
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Expanded(
                      child: Text(
                        context.date(month),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(
                        () => month = DateTime(month.year, month.month + 1),
                      ),
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                GridView.count(
                  crossAxisCount: 7,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children:
                      (context.isThai
                              ? const ['อา', 'จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส']
                              : const ['S', 'M', 'T', 'W', 'T', 'F', 'S'])
                          .map(
                            (label) => Center(
                              child: Text(
                                label,
                                style: const TextStyle(
                                  color: JamoreColors.muted,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                ),
                GridView.count(
                  crossAxisCount: 7,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: cells.map((number) {
                    if (number == null) return const SizedBox();
                    final date = DateTime(month.year, month.month, number);
                    final marked = approvals.any(
                      (item) =>
                          !date.isBefore(item.start) && !date.isAfter(item.end),
                    );
                    final today = DateUtils.isSameDay(date, DateTime.now());
                    return Semantics(
                      label: context.date(date),
                      child: Container(
                        margin: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: today
                              ? JamoreColors.primary
                              : marked
                              ? const Color(0xFFDBEAFE)
                              : null,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$number',
                          style: TextStyle(
                            color: today ? Colors.white : JamoreColors.ink,
                            fontWeight: marked || today
                                ? FontWeight.w800
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ...approvals.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: JamoreCard(
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: JamoreColors.primarySoft,
                      foregroundColor: JamoreColors.primaryDark,
                      child: Text(
                        (context.isThai ? item.nameTh : item.nameEn)
                            .characters
                            .first,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.isThai ? item.nameTh : item.nameEn,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          Text(
                            '${context.date(item.start)} — ${context.date(item.end)}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: JamoreColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    StatusBadge(item.status),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ApprovalScreen extends StatelessWidget {
  const _ApprovalScreen();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final pending = state.data.teamApprovals
        .where((item) => item.status == RequestStatus.pending)
        .toList();
    return PageSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeading(
            title: context.l10n.teamPending,
            subtitle: context.isThai ? 'Pending approvals' : null,
            backTo: '/leave',
          ),
          if (pending.isEmpty)
            const JamoreCard(child: EmptyMessage())
          else
            ...pending.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: JamoreCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: const Color(0xFFA7F3D0),
                            child: Text(
                              (context.isThai ? item.nameTh : item.nameEn)
                                  .characters
                                  .first,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.isThai ? item.nameTh : item.nameEn,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  item.id,
                                  style: const TextStyle(
                                    color: JamoreColors.muted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          StatusBadge(item.status),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${context.leaveKind(item.kind)} · ${item.days} ${context.l10n.days}',
                            ),
                            Text(
                              '${context.date(item.start)} — ${context.date(item.end)}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: JamoreColors.muted,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              context.isThai ? item.reasonTh : item.reasonEn,
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: JamoreColors.danger,
                              ),
                              onPressed: () => _reject(context, item),
                              icon: const Icon(Icons.close_rounded),
                              label: Text(context.l10n.reject),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: JamoreColors.success,
                              ),
                              onPressed: () async {
                                if (await confirmDialog(
                                      context,
                                      context.l10n.confirmApprove,
                                    ) &&
                                    context.mounted) {
                                  await context.read<AppState>().decideApproval(
                                    item.id,
                                    true,
                                  );
                                }
                              },
                              icon: const Icon(Icons.check_rounded),
                              label: Text(context.l10n.approve),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _reject(BuildContext context, TeamApproval item) async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.rejectionReason),
        content: TextField(
          controller: controller,
          autofocus: true,
          minLines: 2,
          maxLines: 4,
          decoration: InputDecoration(hintText: context.l10n.rejectionReason),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(dialogContext, controller.text.trim());
              }
            },
            child: Text(context.l10n.reject),
          ),
        ],
      ),
    );
    controller.dispose();
    if (reason != null && context.mounted) {
      await context.read<AppState>().decideApproval(
        item.id,
        false,
        reason: reason,
      );
    }
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection({required this.title, required this.child, this.subtitle});
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

class _DateButton extends StatelessWidget {
  const _DateButton({
    required this.label,
    required this.value,
    required this.onTap,
  });
  final String label;
  final String value;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: onTap,
    style: OutlinedButton.styleFrom(
      padding: const EdgeInsets.all(12),
      alignment: Alignment.centerLeft,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: JamoreColors.muted),
        ),
        Text(value, maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    ),
  );
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.done,
    required this.label,
    required this.detail,
  });
  final bool done;
  final String label;
  final String detail;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          done
              ? Icons.check_circle_rounded
              : Icons.radio_button_unchecked_rounded,
          color: done ? JamoreColors.success : const Color(0xFFCBD5E1),
          size: 20,
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        Text(
          detail,
          style: const TextStyle(fontSize: 11, color: JamoreColors.muted),
        ),
      ],
    ),
  );
}

class _Success extends StatelessWidget {
  const _Success({
    required this.title,
    required this.subtitle,
    required this.backTo,
  });
  final String title;
  final String subtitle;
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
            color: Color(0xFFDCFCE7),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            size: 48,
            color: JamoreColors.success,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          textAlign: TextAlign.center,
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
