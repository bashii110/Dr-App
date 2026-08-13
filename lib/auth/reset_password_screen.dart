import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/auth_provider.dart';
import '../utils/config.dart';
import 'login_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Theme
// ─────────────────────────────────────────────────────────────────────────────

const _bg = Color(0xFF0A0E1A);
const _card = Color(0xFF141829);
const _accentTeal = Color(0xFF00CEC9);

// ─────────────────────────────────────────────────────────────────────────────
// Reset Password Screen
// ─────────────────────────────────────────────────────────────────────────────

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({
    super.key,
    required this.resetToken,
  });

  final String resetToken;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  late AnimationController _fadeController;
  late AnimationController _slideController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeOutCubic,
      ),
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;

      _fadeController.forward();
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();

    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Reset password
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    final auth = context.read<AuthProvider>();

    final success = await auth.resetPassword(
      resetToken: widget.resetToken,
      password: _passwordController.text,
      passwordConfirmation: _confirmPasswordController.text,
    );

    if (!mounted) return;

    if (!success) {
      _showMessage(
        auth.error ?? 'Unable to reset password.',
        error: true,
      );
      return;
    }

    _showMessage(
      'Password reset successfully.',
      success: true,
    );

    await Future.delayed(
      const Duration(milliseconds: 700),
    );

    if (!mounted) return;

    auth.resetAuthState();

    if (!mounted) return;

    // Navigator.pushAndRemoveUntil(
    //   context,
    //   MaterialPageRoute(
    //     builder: (_) => const LoginScreen(),
    //   ),
    //       (_) => false,
    // );

    Navigator.pop(context);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Message
  // ─────────────────────────────────────────────────────────────────────────

  void _showMessage(
      String message, {
        bool error = false,
        bool success = false,
      }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: error
            ? Colors.redAccent
            : success
            ? const Color(0xFF34A853)
            : _card,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: _bg,
        body: Stack(
          children: [
            // Background glow
            Positioned(
              top: -120,
              left: -100,
              child: _glowBlob(
                300,
                Config.primaryColor.withOpacity(0.13),
              ),
            ),

            Positioned(
              bottom: 80,
              right: -80,
              child: _glowBlob(
                250,
                _accentTeal.withOpacity(0.08),
              ),
            ),

            Positioned(
              top: 280,
              right: -70,
              child: _glowBlob(
                180,
                const Color(0xFF6C5CE7).withOpacity(0.07),
              ),
            ),

            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Back button
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),

                        const SizedBox(height: 36),

                        // Icon
                        Center(
                          child: _buildIcon(),
                        ),

                        const SizedBox(height: 28),

                        // Title
                        const Text(
                          'Create new\npassword 🔐',
                          style: TextStyle(
                            fontSize: 34,
                            height: 1.15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          'Create a strong password for your account.',
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: Colors.white.withOpacity(0.55),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Email
                        Row(
                          children: [
                            Icon(
                              Icons.verified_outlined,
                              size: 16,
                              color: _accentTeal.withOpacity(0.8),
                            ),
                            const SizedBox(width: 7),
                            Expanded(
                              child: Text(
                                'Create a new password',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: _accentTeal,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 36),

                        // Form card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.11),
                              width: 1.3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.28),
                                blurRadius: 35,
                                offset: const Offset(0, 14),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // New password
                                _PasswordField(
                                  controller: _passwordController,
                                  label: 'New password',
                                  hint: 'Enter your new password',
                                  obscureText: _obscurePassword,
                                  onToggle: () {
                                    setState(() {
                                      _obscurePassword =
                                      !_obscurePassword;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Password is required';
                                    }

                                    if (value.length < 8) {
                                      return 'Minimum 8 characters';
                                    }

                                    return null;
                                  },
                                ),

                                const SizedBox(height: 18),

                                // Confirm password
                                _PasswordField(
                                  controller:
                                  _confirmPasswordController,
                                  label: 'Confirm password',
                                  hint: 'Re-enter your new password',
                                  obscureText: _obscureConfirmPassword,
                                  textInputAction: TextInputAction.done,
                                  onToggle: () {
                                    setState(() {
                                      _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please confirm your password';
                                    }

                                    if (value !=
                                        _passwordController.text) {
                                      return 'Passwords do not match';
                                    }

                                    return null;
                                  },
                                ),

                                const SizedBox(height: 14),

                                // Password requirements
                                _buildPasswordHint(),

                                const SizedBox(height: 24),

                                // Reset button
                                _ResetButton(
                                  loading: auth.loading,
                                  onPressed: auth.loading
                                      ? null
                                      : _resetPassword,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        Center(
                          child: Text(
                            'Your password should be unique and difficult to guess.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.35),
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Icon
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildIcon() {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Config.primaryColor,
            _accentTeal,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Config.primaryColor.withOpacity(0.28),
            blurRadius: 26,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Icon(
        Icons.lock_reset_rounded,
        size: 38,
        color: Colors.white,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Password requirement
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildPasswordHint() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.035),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(0.07),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: _accentTeal.withOpacity(0.75),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Use at least 8 characters. A combination of letters, numbers, and symbols is recommended.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.42),
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glowBlob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Password Field
// ─────────────────────────────────────────────────────────────────────────────

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.obscureText,
    required this.onToggle,
    this.validator,
    this.textInputAction,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final bool obscureText;
  final VoidCallback onToggle;
  final FormFieldValidator<String>? validator;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      textInputAction: textInputAction,
      validator: validator,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,

        labelStyle: TextStyle(
          color: Colors.white.withOpacity(0.5),
        ),

        hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.22),
        ),

        prefixIcon: Icon(
          Icons.lock_outline_rounded,
          color: Colors.white.withOpacity(0.4),
          size: 20,
        ),

        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            obscureText
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: Colors.white.withOpacity(0.4),
            size: 20,
          ),
        ),

        filled: true,
        fillColor: Colors.white.withOpacity(0.07),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.12),
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Config.primaryColor.withOpacity(0.8),
            width: 2,
          ),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Colors.redAccent,
          ),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 2,
          ),
        ),

        errorStyle: const TextStyle(
          color: Color(0xFFFF8A80),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reset Button
// ─────────────────────────────────────────────────────────────────────────────

class _ResetButton extends StatelessWidget {
  const _ResetButton({
    required this.loading,
    required this.onPressed,
  });

  final bool loading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: loading ? null : onPressed,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: loading
                  ? LinearGradient(
                colors: [
                  Config.primaryColor.withOpacity(0.55),
                  Config.primaryColor.withOpacity(0.4),
                ],
              )
                  : LinearGradient(
                colors: [
                  Config.primaryColor,
                  Config.primaryColor.withBlue(220),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: loading
                  ? []
                  : [
                BoxShadow(
                  color: Config.primaryColor.withOpacity(0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: loading
                  ? const SizedBox(
                width: 23,
                height: 23,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
                  : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_reset_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 9),
                  Text(
                    'Reset Password',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}