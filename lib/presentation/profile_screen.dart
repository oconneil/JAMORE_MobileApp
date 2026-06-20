import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_metadata.dart';
import '../core/extensions.dart';
import '../core/theme.dart';
import '../state/app_state.dart';
import 'common.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({required this.location, super.key});
  final String location;

  @override
  Widget build(BuildContext context) {
    if (location.startsWith('/soon/')) {
      final feature = location.split('/').last;
      return _ComingSoon(feature: feature);
    }
    final state = context.watch<AppState>();
    return PageSurface(
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 92,
            height: 92,
            decoration: const BoxDecoration(
              color: JamoreColors.primarySoft,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Text(
              'NJ',
              style: TextStyle(
                color: JamoreColors.primaryDark,
                fontSize: 31,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            state.employeeDisplayName(isThai: context.isThai),
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
          ),
          Text(
            'Senior Product Designer · Design Team',
            style: const TextStyle(color: JamoreColors.muted, fontSize: 12),
          ),
          const SizedBox(height: 7),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: JamoreColors.line),
              borderRadius: BorderRadius.circular(99),
            ),
            child: const Text(
              'EMP-2024-0142',
              style: TextStyle(
                fontSize: 11,
                color: JamoreColors.muted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 24),
          JamoreCard(
            padding: const EdgeInsets.all(4),
            child: Column(
              children: [
                _ProfileTile(
                  icon: Icons.person_outline_rounded,
                  label: context.l10n.personalInfo,
                  onTap: () => state.navigate('/soon/personal-info'),
                ),
                _ProfileTile(
                  icon: Icons.work_outline_rounded,
                  label: context.l10n.positionTeam,
                  onTap: () => state.navigate('/soon/position-team'),
                ),
                _ProfileTile(
                  icon: Icons.receipt_long_outlined,
                  label: context.l10n.documentsPayslips,
                  onTap: () => state.navigate('/soon/documents'),
                ),
                _ProfileTile(
                  icon: Icons.notifications_none_rounded,
                  label: context.l10n.notifications,
                  onTap: () => state.navigate('/soon/notifications'),
                  last: true,
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
                  context.l10n.language,
                  style: const TextStyle(
                    fontSize: 12,
                    color: JamoreColors.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<String>(
                    key: const Key('languageSelector'),
                    segments: [
                      ButtonSegment(
                        value: 'th',
                        label: Text(context.l10n.thai),
                      ),
                      ButtonSegment(
                        value: 'en',
                        label: Text(context.l10n.english),
                      ),
                    ],
                    selected: {state.data.localeCode},
                    onSelectionChanged: (value) => state.setLocale(value.first),
                    showSelectedIcon: false,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          JamoreCard(
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.restart_alt_rounded,
                    color: JamoreColors.warning,
                  ),
                  title: Text(context.l10n.resetDemoData),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () async {
                    if (await confirmDialog(
                          context,
                          context.l10n.resetConfirm,
                          danger: true,
                        ) &&
                        context.mounted) {
                      await state.resetDemoData();
                    }
                  },
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.info_outline_rounded,
                    color: JamoreColors.muted,
                  ),
                  title: Text(context.l10n.version),
                  trailing: const AppVersionText(
                    style: TextStyle(color: JamoreColors.muted),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              key: const Key('signOutButton'),
              style: OutlinedButton.styleFrom(
                foregroundColor: JamoreColors.danger,
                backgroundColor: Colors.white,
              ),
              onPressed: state.logout,
              icon: const Icon(Icons.logout_rounded),
              label: Text(context.l10n.signOut),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.last = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool last;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      ListTile(
        minTileHeight: 58,
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0x140099CC),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: JamoreColors.primary, size: 19),
        ),
        title: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: Color(0xFFCBD5E1),
        ),
        onTap: onTap,
      ),
      if (!last) const Divider(height: 1, indent: 58),
    ],
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
            decoration: const BoxDecoration(
              color: Color(0x140099CC),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.construction_rounded,
              color: JamoreColors.primary,
              size: 46,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            context.l10n.comingSoon,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
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
