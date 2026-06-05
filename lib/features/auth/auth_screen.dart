import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';

enum _AuthMode { landing, emailSignIn, register }

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _snowController;
  late final List<_SnowFlake> _flakes;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  _AuthMode _mode = _AuthMode.landing;

  @override
  void initState() {
    super.initState();
    final random = math.Random(38);
    _flakes = List.generate(
      46,
      (_) => _SnowFlake(
        x: random.nextDouble(),
        y: random.nextDouble(),
        radius: 1.6 + random.nextDouble() * 3.3,
        speed: 0.035 + random.nextDouble() * 0.065,
        drift: -0.018 + random.nextDouble() * 0.036,
        opacity: 0.26 + random.nextDouble() * 0.46,
      ),
    );
    _snowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _snowController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authAction = ref.watch(authControllerProvider);
    final isLoading = authAction.isLoading;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          const _AuthGradientBackground(),
          Positioned.fill(
            child: CustomPaint(
              painter: _SnowfallPainter(
                flakes: _flakes,
                animation: _snowController,
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact =
                    constraints.maxHeight < 880 || constraints.maxWidth < 430;
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.fromLTRB(
                        24,
                        compact ? 18 : 38,
                        24,
                        compact ? 18 : 32,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _BrandHeader(compact: compact),
                          SizedBox(height: compact ? 24 : 32),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            child: switch (_mode) {
                              _AuthMode.landing => _LandingActions(
                                key: const ValueKey('landing'),
                                isLoading: isLoading,
                                onGooglePressed: _signInWithGoogle,
                                onEmailPressed: () =>
                                    _setMode(_AuthMode.emailSignIn),
                                onRegisterPressed: () =>
                                    _setMode(_AuthMode.register),
                              ),
                              _AuthMode.emailSignIn => _EmailAuthForm(
                                key: const ValueKey('emailSignIn'),
                                formKey: _formKey,
                                emailController: _emailController,
                                passwordController: _passwordController,
                                isLoading: isLoading,
                                isRegister: false,
                                onSubmit: _submitEmailSignIn,
                                onBack: () => _setMode(_AuthMode.landing),
                                onToggleMode: () =>
                                    _setMode(_AuthMode.register),
                              ),
                              _AuthMode.register => _EmailAuthForm(
                                key: const ValueKey('register'),
                                formKey: _formKey,
                                nameController: _nameController,
                                emailController: _emailController,
                                passwordController: _passwordController,
                                confirmPasswordController:
                                    _confirmPasswordController,
                                isLoading: isLoading,
                                isRegister: true,
                                onSubmit: _submitRegister,
                                onBack: () => _setMode(_AuthMode.landing),
                                onToggleMode: () =>
                                    _setMode(_AuthMode.emailSignIn),
                              ),
                            },
                          ),
                          SizedBox(height: compact ? 36 : 86),
                          const _LoginIllustrationPanel(),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _setMode(_AuthMode mode) {
    _formKey.currentState?.reset();
    setState(() => _mode = mode);
  }

  Future<void> _signInWithGoogle() async {
    try {
      await ref.read(authControllerProvider.notifier).signInWithGoogle();
    } on Object catch (error) {
      _showAuthError(error);
    }
  }

  Future<void> _submitEmailSignIn() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    try {
      await ref
          .read(authControllerProvider.notifier)
          .signInWithEmail(
            email: _emailController.text,
            password: _passwordController.text,
          );
    } on Object catch (error) {
      _showAuthError(error);
    }
  }

  Future<void> _submitRegister() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    try {
      await ref
          .read(authControllerProvider.notifier)
          .registerWithEmail(
            displayName: _nameController.text,
            email: _emailController.text,
            password: _passwordController.text,
          );
    } on Object catch (error) {
      _showAuthError(error);
    }
  }

  void _showAuthError(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.toString()),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _AuthGradientBackground extends StatelessWidget {
  const _AuthGradientBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF5FCED),
            Color(0xFFC8F7C0),
            Color(0xFF88D982),
            Color(0xFF2E7D32),
          ],
          stops: [0, 0.38, 0.72, 1],
        ),
      ),
      child: SizedBox.expand(),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final titleSize = compact ? 50.0 : 56.0;
    return Column(
      children: [
        Container(
          width: compact ? 116 : 138,
          height: compact ? 116 : 138,
          decoration: BoxDecoration(
            color: const Color(0xFFD0FFC7).withValues(alpha: 0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withValues(alpha: 0.18),
                blurRadius: 28,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Icon(
            Icons.recycling,
            color: AppColors.primary,
            size: compact ? 64 : 76,
          ),
        ),
        SizedBox(height: compact ? 20 : 34),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'AtıkAvı\nErzurum',
            textAlign: TextAlign.center,
            style: AppTextStyles.display.copyWith(
              color: AppColors.primary,
              fontSize: titleSize,
              fontWeight: FontWeight.w900,
              height: 1.08,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Atığını dönüştür, puanını\nkazan, Erzurum’u temizle.',
          textAlign: TextAlign.center,
          style: AppTextStyles.subtitle.copyWith(
            color: AppColors.textSecondary,
            fontSize: compact ? 24 : 27,
            fontWeight: FontWeight.w800,
            height: 1.38,
          ),
        ),
      ],
    );
  }
}

class _LandingActions extends StatelessWidget {
  const _LandingActions({
    super.key,
    required this.isLoading,
    required this.onGooglePressed,
    required this.onEmailPressed,
    required this.onRegisterPressed,
  });

  final bool isLoading;
  final VoidCallback onGooglePressed;
  final VoidCallback onEmailPressed;
  final VoidCallback onRegisterPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _AuthActionButton(
          label: isLoading ? 'Giriş yapılıyor...' : 'Google ile devam et',
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          onPressed: isLoading ? null : onGooglePressed,
          leading: isLoading
              ? const SizedBox.square(
                  dimension: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.4),
                )
              : const _GoogleMark(),
        ),
        const SizedBox(height: 18),
        _AuthActionButton(
          label: 'E-posta ile Giriş Yap',
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          onPressed: isLoading ? null : onEmailPressed,
        ),
        const SizedBox(height: 30),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          children: [
            Text(
              'Henüz hesabınız yok mu?',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                fontSize: 18,
              ),
            ),
            TextButton(
              onPressed: isLoading ? null : onRegisterPressed,
              child: Text(
                'Kayıt Ol',
                style: AppTextStyles.subtitle.copyWith(
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _EmailAuthForm extends StatelessWidget {
  const _EmailAuthForm({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.isRegister,
    required this.onSubmit,
    required this.onBack,
    required this.onToggleMode,
    this.nameController,
    this.confirmPasswordController,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController? nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController? confirmPasswordController;
  final bool isLoading;
  final bool isRegister;
  final VoidCallback onSubmit;
  final VoidCallback onBack;
  final VoidCallback onToggleMode;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          if (isRegister) ...[
            _AuthTextField(
              controller: nameController!,
              label: 'Ad Soyad',
              icon: Icons.person_outline,
              validator: (value) {
                if ((value ?? '').trim().isEmpty) return 'Ad boş olamaz.';
                return null;
              },
            ),
            const SizedBox(height: 12),
          ],
          _AuthTextField(
            controller: emailController,
            label: 'E-posta',
            icon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
          ),
          const SizedBox(height: 12),
          _AuthTextField(
            controller: passwordController,
            label: 'Şifre',
            icon: Icons.lock_outline,
            obscureText: true,
            validator: _validatePassword,
          ),
          if (isRegister) ...[
            const SizedBox(height: 12),
            _AuthTextField(
              controller: confirmPasswordController!,
              label: 'Şifre tekrar',
              icon: Icons.lock_reset,
              obscureText: true,
              validator: (value) {
                final text = value ?? '';
                if (text != passwordController.text) {
                  return 'Şifreler aynı olmalı.';
                }
                return null;
              },
            ),
          ],
          const SizedBox(height: 18),
          _AuthActionButton(
            label: isRegister ? 'Kayıt Ol' : 'Giriş Yap',
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            onPressed: isLoading ? null : onSubmit,
            leading: isLoading
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.3,
                      color: AppColors.textOnPrimary,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: isLoading ? null : onBack,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Geri'),
              ),
              TextButton(
                onPressed: isLoading ? null : onToggleMode,
                child: Text(isRegister ? 'Giriş Yap' : 'Kayıt Ol'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String? _validateEmail(String? value) {
    final text = (value ?? '').trim();
    final hasValidShape = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text);
    if (!hasValidShape) return 'Geçerli bir e-posta girin.';
    return null;
  }

  String? _validatePassword(String? value) {
    if ((value ?? '').length < 6) return 'Şifre en az 6 karakter olmalı.';
    return null;
  }
}

class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surface.withValues(alpha: 0.92),
        prefixIcon: Icon(icon, color: AppColors.primary),
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(
            color: AppColors.outline.withValues(alpha: 0.7),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(
            color: AppColors.outline.withValues(alpha: 0.7),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

class _AuthActionButton extends StatelessWidget {
  const _AuthActionButton({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
    this.leading,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback? onPressed;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor: backgroundColor.withValues(alpha: 0.68),
          disabledForegroundColor: foregroundColor.withValues(alpha: 0.62),
          elevation: 5,
          shadowColor: AppColors.primaryDark.withValues(alpha: 0.24),
          shape: const StadiumBorder(),
          textStyle: AppTextStyles.subtitle.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 18)],
            Flexible(
              child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'G',
      style: TextStyle(
        color: Color(0xFF4285F4),
        fontSize: 30,
        fontWeight: FontWeight.w800,
        fontFamily: 'Roboto',
      ),
    );
  }
}

class _LoginIllustrationPanel extends StatelessWidget {
  const _LoginIllustrationPanel();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2.08,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(42)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/login.png', fit: BoxFit.cover),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.surface.withValues(alpha: 0.12),
                    AppColors.primaryDark.withValues(alpha: 0.1),
                  ],
                ),
              ),
            ),
            Align(
              alignment: const Alignment(0, 0.66),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  _IllustrationIconCard(
                    icon: Icons.eco,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 24),
                  _IllustrationIconCard(
                    icon: Icons.location_on_outlined,
                    color: AppColors.winterBlue,
                  ),
                  SizedBox(width: 24),
                  _IllustrationIconCard(
                    icon: Icons.volunteer_activism,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IllustrationIconCard extends StatelessWidget {
  const _IllustrationIconCard({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(icon, color: color, size: 31),
    );
  }
}

class _SnowfallPainter extends CustomPainter {
  _SnowfallPainter({required this.flakes, required Animation<double> animation})
    : _animation = animation,
      super(repaint: animation);

  final List<_SnowFlake> flakes;
  final Animation<double> _animation;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final progress = _animation.value;

    for (final flake in flakes) {
      final y = ((flake.y + progress * flake.speed) % 1.0) * size.height;
      final drift = math.sin((progress + flake.y) * math.pi * 2) * 14;
      final x = ((flake.x + progress * flake.drift) % 1.0) * size.width + drift;
      paint.color = AppColors.surface.withValues(alpha: flake.opacity);
      canvas.drawCircle(Offset(x, y), flake.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SnowfallPainter oldDelegate) {
    return oldDelegate.flakes != flakes;
  }
}

class _SnowFlake {
  const _SnowFlake({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.drift,
    required this.opacity,
  });

  final double x;
  final double y;
  final double radius;
  final double speed;
  final double drift;
  final double opacity;
}
