import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/extensions.dart';
import '../core/theme.dart';
import '../domain/entities/hr_models.dart';
import '../state/app_state.dart';
import 'common.dart';

class DashboardQuickActions extends StatelessWidget {
  const DashboardQuickActions({required this.state, super.key});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final visible = state.quickActions
        .where((item) => item.visible && !item.deleted)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: context.l10n.quickActions,
                  children: context.isThai
                      ? const [
                          TextSpan(
                            text: ' · Quick actions',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ]
                      : const [],
                ),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            TextButton(
              key: const Key('manageQuickActionsButton'),
              onPressed: () => state.navigate('/dashboard/quick-actions'),
              child: Text(context.l10n.manage),
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (visible.isEmpty)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              key: const Key('addQuickActionsButton'),
              onPressed: () => state.navigate('/dashboard/quick-actions'),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(context.l10n.quickActionsAdd),
              style: OutlinedButton.styleFrom(
                foregroundColor: JamoreColors.muted,
                side: const BorderSide(color: Color(0xFFCBD5E1)),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          )
        else
          SingleChildScrollView(
            key: const Key('quickActionsScroll'),
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var index = 0; index < visible.length; index++) ...[
                  if (index > 0) const SizedBox(width: 10),
                  _DashboardActionTile(
                    definition: _definition(context, visible[index].id),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class ManageQuickActionsScreen extends StatelessWidget {
  const ManageQuickActionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final shown = state.quickActions
        .where((item) => item.visible && !item.deleted)
        .toList();
    final active = state.quickActions.where((item) => !item.deleted).toList();
    final removed = state.quickActions.where((item) => item.deleted).toList();

    return PageSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeading(
            title: context.l10n.manageQuickActions,
            subtitle: context.isThai ? 'Manage quick actions' : null,
            backTo: '/dashboard',
          ),
          JamoreCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    text: context.l10n.quickActionsDashboardPreview,
                    children: [
                      TextSpan(
                        text:
                            ' · ${context.l10n.quickActionsShownCount(shown.length)}',
                        style: const TextStyle(
                          color: JamoreColors.muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                if (shown.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Center(
                      child: Text(
                        context.l10n.quickActionsEmpty,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: JamoreColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  )
                else
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: shown
                        .map(
                          (item) => _PreviewActionTile(
                            definition: _definition(context, item.id),
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: context.l10n.quickActionsAll,
                    children: [
                      TextSpan(
                        text: ' · ${context.l10n.quickActionsAllHint}',
                        style: const TextStyle(
                          color: JamoreColors.muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                key: const Key('resetQuickActionsButton'),
                onPressed: state.resetQuickActions,
                child: Text(
                  context.l10n.reset,
                  style: const TextStyle(color: JamoreColors.muted),
                ),
              ),
            ],
          ),
          ...active.map(
            (item) => _ManageActionRow(
              preference: item,
              definition: _definition(context, item.id),
              onVisibilityChanged: (visible) =>
                  state.setQuickActionVisibility(item.id, visible: visible),
              onRemove: () => state.removeQuickAction(item.id),
            ),
          ),
          if (removed.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text.rich(
              TextSpan(
                text: context.l10n.quickActionsRemoved,
                children: [
                  TextSpan(
                    text: ' · ${removed.length}',
                    style: const TextStyle(
                      color: JamoreColors.muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            ...removed.map(
              (item) => _RemovedActionRow(
                definition: _definition(context, item.id),
                onRestore: () => state.restoreQuickAction(item.id),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DashboardActionTile extends StatelessWidget {
  const _DashboardActionTile({required this.definition});

  final _QuickActionDefinition definition;

  @override
  Widget build(BuildContext context) => SizedBox(
    key: Key('quickActionTile_${definition.id.name}'),
    width: 82,
    height: 82,
    child: Material(
      color: definition.background,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: definition.route == null
            ? null
            : () => context.read<AppState>().navigate(definition.route!),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 10, 6, 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(definition.icon, color: definition.foreground),
              ),
              const SizedBox(height: 5),
              Text(
                definition.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: definition.foreground,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _PreviewActionTile extends StatelessWidget {
  const _PreviewActionTile({required this.definition});

  final _QuickActionDefinition definition;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 56,
    child: Column(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: definition.background,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(definition.icon, color: definition.foreground, size: 22),
        ),
        const SizedBox(height: 6),
        Text(
          definition.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: JamoreColors.muted,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

class _ManageActionRow extends StatelessWidget {
  const _ManageActionRow({
    required this.preference,
    required this.definition,
    required this.onVisibilityChanged,
    required this.onRemove,
  });

  final QuickActionPreference preference;
  final _QuickActionDefinition definition;
  final ValueChanged<bool> onVisibilityChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: JamoreColors.line),
      ),
      child: Row(
        children: [
          const Icon(Icons.drag_indicator_rounded, color: Color(0xFFCBD5E1)),
          const SizedBox(width: 10),
          _ActionIcon(definition: definition),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  definition.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  definition.route == null
                      ? '${definition.englishLabel} · ${context.l10n.comingSoon}'
                      : definition.englishLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: JamoreColors.muted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            key: Key('removeQuickAction_${definition.id.name}'),
            tooltip: context.l10n.remove,
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            color: const Color(0xFFDC2626),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFFEF2F2),
              fixedSize: const Size.square(34),
              minimumSize: const Size.square(34),
              padding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(width: 8),
          _VisibilitySwitch(
            key: Key('quickActionVisibility_${definition.id.name}'),
            value: preference.visible,
            onChanged: onVisibilityChanged,
          ),
        ],
      ),
    ),
  );
}

class _RemovedActionRow extends StatelessWidget {
  const _RemovedActionRow({required this.definition, required this.onRestore});

  final _QuickActionDefinition definition;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Opacity(
      opacity: .85,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: JamoreColors.line),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(definition.icon, color: JamoreColors.muted, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                definition.label,
                style: const TextStyle(
                  color: JamoreColors.muted,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ),
            TextButton.icon(
              key: Key('restoreQuickAction_${definition.id.name}'),
              onPressed: onRestore,
              icon: const Icon(Icons.add_rounded, size: 15),
              label: Text(context.l10n.restore),
              style: TextButton.styleFrom(
                backgroundColor: JamoreColors.primary.withValues(alpha: .08),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({required this.definition});

  final _QuickActionDefinition definition;

  @override
  Widget build(BuildContext context) => Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: definition.background,
      borderRadius: BorderRadius.circular(11),
    ),
    child: Icon(definition.icon, color: definition.foreground, size: 20),
  );
}

class _VisibilitySwitch extends StatelessWidget {
  const _VisibilitySwitch({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Semantics(
    toggled: value,
    button: true,
    onTap: () => onChanged(!value),
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 46,
        height: 28,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? JamoreColors.primary : const Color(0xFFCBD5E1),
          borderRadius: BorderRadius.circular(99),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 180),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Color(0x33000000), blurRadius: 3)],
            ),
            child: Icon(
              value ? Icons.visibility_rounded : Icons.visibility_off_rounded,
              size: 13,
              color: value ? JamoreColors.primary : const Color(0xFF94A3B8),
            ),
          ),
        ),
      ),
    ),
  );
}

class _QuickActionDefinition {
  const _QuickActionDefinition({
    required this.id,
    required this.label,
    required this.englishLabel,
    required this.icon,
    required this.background,
    required this.foreground,
    this.route,
  });

  final QuickActionId id;
  final String label;
  final String englishLabel;
  final IconData icon;
  final Color background;
  final Color foreground;
  final String? route;
}

_QuickActionDefinition _definition(BuildContext context, QuickActionId id) =>
    switch (id) {
      QuickActionId.leave => _QuickActionDefinition(
        id: id,
        label: context.l10n.quickActionLeave,
        englishLabel: 'Leave',
        icon: Icons.event_available_rounded,
        background: const Color(0xFFDBEAFE),
        foreground: const Color(0xFF1D4ED8),
        route: '/leave/request',
      ),
      QuickActionId.overtime => _QuickActionDefinition(
        id: id,
        label: context.l10n.quickActionOvertime,
        englishLabel: 'Overtime',
        icon: Icons.more_time_rounded,
        background: const Color(0xFFFEF3C7),
        foreground: const Color(0xFFB45309),
        route: '/overtime/request',
      ),
      QuickActionId.shift => _QuickActionDefinition(
        id: id,
        label: context.l10n.quickActionShift,
        englishLabel: 'Shift',
        icon: Icons.schedule_rounded,
        background: const Color(0xFFDCFCE7),
        foreground: const Color(0xFF15803D),
        route: '/worktime',
      ),
      QuickActionId.payslip => _QuickActionDefinition(
        id: id,
        label: context.l10n.quickActionPayslip,
        englishLabel: 'Payslip',
        icon: Icons.account_balance_wallet_rounded,
        background: const Color(0xFFFCE7F3),
        foreground: const Color(0xFFBE185D),
      ),
      QuickActionId.teamCalendar => _QuickActionDefinition(
        id: id,
        label: context.l10n.quickActionTeam,
        englishLabel: 'Team',
        icon: Icons.group_rounded,
        background: const Color(0xFFEDE9FE),
        foreground: const Color(0xFF6D28D9),
        route: '/leave/calendar',
      ),
      QuickActionId.holidays => _QuickActionDefinition(
        id: id,
        label: context.l10n.quickActionHolidays,
        englishLabel: 'Holidays',
        icon: Icons.wb_sunny_rounded,
        background: const Color(0xFFFFE4E6),
        foreground: const Color(0xFFBE123C),
      ),
      QuickActionId.expense => _QuickActionDefinition(
        id: id,
        label: context.l10n.quickActionExpense,
        englishLabel: 'Expense',
        icon: Icons.payments_rounded,
        background: const Color(0xFFCCFBF1),
        foreground: const Color(0xFF0F766E),
      ),
      QuickActionId.announcements => _QuickActionDefinition(
        id: id,
        label: context.l10n.quickActionNews,
        englishLabel: 'News',
        icon: Icons.campaign_rounded,
        background: const Color(0xFFFEF9C3),
        foreground: const Color(0xFFA16207),
      ),
    };
