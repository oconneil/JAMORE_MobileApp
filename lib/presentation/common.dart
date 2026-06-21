import 'package:flutter/material.dart';

import '../core/extensions.dart';
import '../core/theme.dart';
import '../domain/entities/hr_models.dart';
import '../state/app_state.dart';
import 'package:provider/provider.dart';

String initialsFromName(String value, {required String fallback}) {
  final words = value
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .toList();
  if (words.isEmpty) return fallback.characters.take(2).toString();
  return words
      .take(2)
      .map((word) => word.characters.first)
      .join()
      .toUpperCase();
}

class PageSurface extends StatelessWidget {
  const PageSurface({
    required this.child,
    super.key,
    this.maxWidth = 760,
    this.padding = const EdgeInsets.fromLTRB(16, 20, 16, 120),
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: JamoreColors.canvas,
    child: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: SingleChildScrollView(padding: padding, child: child),
        ),
      ),
    ),
  );
}

class PageHeading extends StatelessWidget {
  const PageHeading({
    required this.title,
    super.key,
    this.subtitle,
    this.backTo,
  });

  final String title;
  final String? subtitle;
  final String? backTo;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Row(
      children: [
        if (backTo != null) ...[
          IconButton.filledTonal(
            tooltip: context.l10n.back,
            onPressed: () => context.read<AppState>().navigate(backTo!),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: JamoreColors.muted),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}

class JamoreCard extends StatelessWidget {
  const JamoreCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(18),
    this.color,
  });
  final Widget child;
  final EdgeInsets padding;
  final Color? color;

  @override
  Widget build(BuildContext context) => Material(
    color: color ?? Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(22),
      side: const BorderSide(color: JamoreColors.line),
    ),
    clipBehavior: Clip.antiAlias,
    child: Padding(padding: padding, child: child),
  );
}

class SectionHeading extends StatelessWidget {
  const SectionHeading({
    required this.title,
    super.key,
    this.subtitle,
    this.onSeeAll,
  });
  final String title;
  final String? subtitle;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: const TextStyle(fontSize: 11, color: JamoreColors.muted),
              ),
          ],
        ),
      ),
      if (onSeeAll != null)
        TextButton(onPressed: onSeeAll, child: Text(context.l10n.seeAll)),
    ],
  );
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.busy = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool busy;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 54,
    child: FilledButton.icon(
      onPressed: busy ? null : onPressed,
      icon: busy
          ? const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Icon(icon ?? Icons.arrow_forward_rounded),
      label: Text(
        label,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
  );
}

class StatusBadge extends StatelessWidget {
  const StatusBadge(this.status, {super.key});
  final RequestStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      RequestStatus.approved => (
        const Color(0xFFDCFCE7),
        const Color(0xFF15803D),
      ),
      RequestStatus.pending => (
        const Color(0xFFFEF3C7),
        const Color(0xFFB45309),
      ),
      RequestStatus.rejected => (const Color(0xFFFEE2E2), JamoreColors.danger),
      RequestStatus.cancelled => (const Color(0xFFF1F5F9), JamoreColors.muted),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        context.status(status),
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class EmptyMessage extends StatelessWidget {
  const EmptyMessage({super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(32),
    child: Center(
      child: Text(
        context.l10n.noItems,
        style: const TextStyle(color: JamoreColors.muted),
      ),
    ),
  );
}

Future<bool> confirmDialog(
  BuildContext context,
  String message, {
  bool danger = false,
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            style: danger
                ? FilledButton.styleFrom(backgroundColor: JamoreColors.danger)
                : null,
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.confirm),
          ),
        ],
      ),
    ) ??
    false;
