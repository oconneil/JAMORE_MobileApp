import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/extensions.dart';
import '../core/theme.dart';
import '../state/app_state.dart';
import 'dashboard_screen.dart';
import 'leave_screen.dart';
import 'overtime_screen.dart';
import 'profile_screen.dart';
import 'worktime_screen.dart';

class AdaptiveShell extends StatelessWidget {
  const AdaptiveShell({required this.location, super.key});
  final String location;

  static const _roots = [
    '/dashboard',
    '/leave',
    '/worktime',
    '/overtime',
    '/profile',
  ];

  int get _selected {
    if (location.startsWith('/soon/')) return _roots.indexOf('/profile');
    final index = _roots.indexWhere((root) => location.startsWith(root));
    return index < 0 ? 0 : index;
  }

  Widget _screen() {
    if (location.startsWith('/leave')) return LeaveScreen(location: location);
    if (location.startsWith('/overtime')) {
      return OvertimeScreen(location: location);
    }
    if (location.startsWith('/worktime')) {
      return WorktimeScreen(location: location);
    }
    if (location.startsWith('/profile') || location.startsWith('/soon/')) {
      return ProfileScreen(location: location);
    }
    return const DashboardScreen();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final useRail = constraints.maxWidth >= 720;
      final extended = constraints.maxWidth >= 1120;
      if (useRail) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: NavigationRail(
                    extended: extended,
                    selectedIndex: _selected,
                    onDestinationSelected: (index) =>
                        context.read<AppState>().navigate(_roots[index]),
                    leading: const _RailBrand(),
                    labelType: extended
                        ? NavigationRailLabelType.none
                        : NavigationRailLabelType.all,
                    groupAlignment: -.6,
                    indicatorShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    destinations: _destinations(context)
                        .map(
                          (item) => NavigationRailDestination(
                            icon: Icon(item.icon),
                            selectedIcon: Icon(item.icon),
                            label: Text(item.label),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              const VerticalDivider(width: 1, color: JamoreColors.line),
              Expanded(child: _screen()),
            ],
          ),
        );
      }
      return Scaffold(
        body: _screen(),
        extendBody: true,
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .96),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: JamoreColors.line),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x180F172A),
                  blurRadius: 26,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: NavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              height: 68,
              selectedIndex: _selected,
              onDestinationSelected: (index) =>
                  context.read<AppState>().navigate(_roots[index]),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: _destinations(context)
                  .map(
                    (item) => NavigationDestination(
                      icon: Icon(item.icon),
                      label: item.label,
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      );
    },
  );

  List<({IconData icon, String label})> _destinations(BuildContext context) => [
    (icon: Icons.home_rounded, label: context.l10n.dashboard),
    (icon: Icons.calendar_month_rounded, label: context.l10n.leave),
    (icon: Icons.schedule_rounded, label: context.l10n.worktime),
    (icon: Icons.more_time_rounded, label: context.l10n.overtime),
    (icon: Icons.person_rounded, label: context.l10n.profile),
  ];
}

class _RailBrand extends StatelessWidget {
  const _RailBrand();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 28),
    child: Semantics(
      label: '${context.l10n.appName} ${context.l10n.hrm}',
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: JamoreColors.primary,
          borderRadius: BorderRadius.circular(13),
        ),
        alignment: Alignment.center,
        child: const Text(
          'J',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
      ),
    ),
  );
}
