import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_metadata.dart';
import '../core/extensions.dart';
import '../core/theme.dart';
import '../state/app_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController(text: 'kotchawan.a');
  final _password = TextEditingController(text: 'P@ssw0rd');
  final _company = TextEditingController(text: 'JCORP');
  bool _remember = true;
  bool _obscure = true;
  bool _busy = false;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _company.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    final state = context.read<AppState>();
    final ok = await state.login(
      username: _username.text,
      password: _password.text,
      companyId: _company.text,
      rememberMe: _remember,
    );
    if (!mounted) return;
    if (!ok) {
      setState(() => _busy = false);
      // Surface a user-friendly, localized reason. The gateway's raw
      // `loginError` is an internal token not meant for display.
      await _showLoginFailed(context.l10n.invalidCredentials);
    }
  }

  Future<void> _showLoginFailed(String message) => showDialog<void>(
    context: context,
    barrierColor: const Color(0x800B1B2B),
    builder: (context) => _LoginFailedDialog(message: message),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      fit: StackFit.expand,
      children: [
        const _AuroraBackground(),
        SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 432),
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 650),
                  curve: Curves.easeOutCubic,
                  tween: Tween(begin: 0, end: 1),
                  builder: (context, t, child) => Opacity(
                    opacity: t.clamp(0, 1),
                    child: Transform.translate(
                      offset: Offset(0, (1 - t) * 28),
                      child: child,
                    ),
                  ),
                  child: _glassCard(),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _glassCard() => ClipRRect(
    borderRadius: BorderRadius.circular(30),
    child: BackdropFilter(
      filter: ui.ImageFilter.blur(sigmaX: 22, sigmaY: 22),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          // Brand gradient lives in the card (echoing the dashboard's blue
          // hero) so the page background can stay the app's light canvas.
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              JamoreColors.primary.withValues(alpha: .94),
              JamoreColors.primaryDark.withValues(alpha: .97),
            ],
          ),
          border: Border.all(color: Colors.white.withValues(alpha: .35)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x400099CC),
              blurRadius: 40,
              offset: Offset(0, 24),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(26, 34, 26, 28),
          child: Form(
            key: _formKey,
            child: AutofillGroup(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _Brand(),
                  const SizedBox(height: 28),
                  _GlassField(
                    fieldKey: const Key('usernameField'),
                    controller: _username,
                    label: context.l10n.username,
                    icon: Icons.person_outline_rounded,
                    autofillHints: const [AutofillHints.username],
                    validator: (value) => value == null || value.trim().isEmpty
                        ? context.l10n.requiredField
                        : null,
                  ),
                  const SizedBox(height: 14),
                  _GlassField(
                    fieldKey: const Key('passwordField'),
                    controller: _password,
                    label: context.l10n.password,
                    icon: Icons.lock_outline_rounded,
                    obscureText: _obscure,
                    autofillHints: const [AutofillHints.password],
                    onSubmitted: (_) => _login(),
                    suffix: IconButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      tooltip: _obscure ? context.l10n.show : context.l10n.hide,
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: JamoreColors.primaryDark,
                      ),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? context.l10n.requiredField
                        : null,
                  ),
                  const SizedBox(height: 14),
                  _GlassField(
                    fieldKey: const Key('companyField'),
                    controller: _company,
                    label: context.l10n.companyId,
                    icon: Icons.apartment_rounded,
                    textCapitalization: TextCapitalization.characters,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? context.l10n.requiredField
                        : null,
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    runSpacing: 4,
                    children: [
                      _RememberToggle(
                        value: _remember,
                        onChanged: (value) => setState(() => _remember = value),
                        label: context.l10n.rememberMe,
                      ),
                      TextButton(
                        onPressed: () =>
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(context.l10n.comingSoon)),
                            ),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                        child: Text(context.l10n.forgotPassword),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 54,
                    child: FilledButton(
                      key: const Key('signInButton'),
                      onPressed: _busy ? null : _login,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: JamoreColors.primaryDark,
                        disabledBackgroundColor: Colors.white.withValues(
                          alpha: .7,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _busy
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(
                                color: JamoreColors.primary,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              context.l10n.signIn,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: .3,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Center(
                    child: DefaultTextStyle(
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: .7),
                        fontSize: 12,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${context.l10n.appName} ${context.l10n.hrm} · ',
                          ),
                          const AppVersionText(
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
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
        ),
      ),
    ),
  );
}

/// Centered JAMORE lockup: logo mark + wordmark + HRM tag.
class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) => Column(
    children: [
      // Blue "Jamore" wordmark needs a white surface to read on the glass.
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF023349).withValues(alpha: .25),
              blurRadius: 26,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Image.asset(
          'assets/branding/app_Logo_Login_blue.png',
          height: 46,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => Text(
            context.l10n.appName,
            style: const TextStyle(
              color: JamoreColors.primary,
              fontSize: 34,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .18),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: Colors.white.withValues(alpha: .35)),
        ),
        child: Text(
          '${context.l10n.hrm} · ${context.l10n.signInContinue}',
          style: TextStyle(
            color: Colors.white.withValues(alpha: .92),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: .3,
          ),
        ),
      ),
    ],
  );
}

/// Frosted text field tuned to read on top of the glass card.
class _GlassField extends StatelessWidget {
  const _GlassField({
    required this.fieldKey,
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.suffix,
    this.validator,
    this.onSubmitted,
    this.autofillHints,
    this.textCapitalization = TextCapitalization.none,
  });

  final Key fieldKey;
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final Widget? suffix;
  final String? Function(String?)? validator;
  final void Function(String)? onSubmitted;
  final Iterable<String>? autofillHints;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: color, width: width),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 7),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: .2,
            ),
          ),
        ),
        TextFormField(
          key: fieldKey,
          controller: controller,
          obscureText: obscureText,
          autofillHints: autofillHints,
          onFieldSubmitted: onSubmitted,
          textCapitalization: textCapitalization,
          validator: validator,
          style: const TextStyle(
            color: JamoreColors.ink,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            // Label lives above the field (clear on glass); keep the inside
            // free of a floating label that would notch into the border.
            prefixIcon: Icon(icon, color: JamoreColors.primary),
            suffixIcon: suffix,
            filled: true,
            fillColor: Colors.white.withValues(alpha: .92),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: border(Colors.transparent),
            enabledBorder: border(Colors.white.withValues(alpha: .5)),
            focusedBorder: border(Colors.white, 1.8),
            errorStyle: const TextStyle(
              color: Color(0xFFFFE08A),
              fontWeight: FontWeight.w600,
            ),
            errorBorder: border(const Color(0xFFFFC15E), 1.4),
            focusedErrorBorder: border(const Color(0xFFFFC15E), 1.8),
          ),
        ),
      ],
    );
  }
}

/// Compact white "remember me" pill toggle (CheckboxListTile is too heavy here).
class _RememberToggle extends StatelessWidget {
  const _RememberToggle({
    required this.value,
    required this.onChanged,
    required this.label,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => onChanged(!value),
    borderRadius: BorderRadius.circular(8),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: value ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: Colors.white.withValues(alpha: value ? 1 : .6),
                width: 1.6,
              ),
            ),
            child: value
                ? const Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: JamoreColors.primaryDark,
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}

/// App's light canvas (same as every other page) with faint brand-tinted
/// glows so the blue glass card has subtle depth without a full-bleed colour.
class _AuroraBackground extends StatelessWidget {
  const _AuroraBackground();

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(color: JamoreColors.canvas),
    child: Stack(
      children: [
        _blob(-90, -60, 260, JamoreColors.primary.withValues(alpha: .16)),
        _blob(
          null,
          -40,
          240,
          const Color(0xFFFDE68A).withValues(alpha: .22),
          right: -70,
        ),
        _blob(
          null,
          -80,
          320,
          JamoreColors.primary.withValues(alpha: .08),
          bottom: -120,
        ),
      ],
    ),
  );

  Widget _blob(
    double? top,
    double? left,
    double size,
    Color color, {
    double? right,
    double? bottom,
  }) => Positioned(
    top: top,
    left: left,
    right: right,
    bottom: bottom,
    child: ImageFiltered(
      imageFilter: ui.ImageFilter.blur(sigmaX: 70, sigmaY: 70),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    ),
  );
}

/// Center-screen alert shown when sign-in is rejected.
class _LoginFailedDialog extends StatelessWidget {
  const _LoginFailedDialog({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: Colors.white,
    insetPadding: const EdgeInsets.symmetric(horizontal: 36),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Color(0xFFFDECEC),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              color: JamoreColors.danger,
              size: 34,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            context.l10n.loginFailed,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: JamoreColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            key: const Key('loginError'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: JamoreColors.muted,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                context.l10n.tryAgain,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
