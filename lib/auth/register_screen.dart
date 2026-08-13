import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/auth_provider.dart';
import '../utils/config.dart';
import 'otp_screen.dart';

// ── Animated floating blob ───────────────────────────────────────────────

class _AnimatedBlob extends StatefulWidget {
  const _AnimatedBlob({
    required this.color,
    required this.size,
    required this.duration,
    required this.delay,
    required this.offsetX,
    required this.offsetY,
  });

  final Color color;
  final double size;
  final Duration duration;
  final Duration delay;
  final double offsetX;
  final double offsetY;

  @override
  State<_AnimatedBlob> createState() => _AnimatedBlobState();
}

class _AnimatedBlobState extends State<_AnimatedBlob>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      }

      if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });

    _floatAnim = Tween<double>(
      begin: -8,
      end: 8,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatAnim,
      builder: (_, __) {
        return Transform.translate(
          offset: Offset(
            widget.offsetX,
            widget.offsetY + _floatAnim.value,
          ),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color,
            ),
          ),
        );
      },
    );
  }
}

// ── Dark text field ──────────────────────────────────────────────────────

class _DarkTextField extends StatelessWidget {
  const _DarkTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final bool obscureText;
  final Widget? suffixIcon;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      obscureText: obscureText,
      onFieldSubmitted: onFieldSubmitted,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.25),
        ),
        labelStyle: TextStyle(
          color: Colors.white.withOpacity(0.5),
        ),
        prefixIcon: Icon(
          icon,
          color: Colors.white.withOpacity(0.4),
          size: 20,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
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
      validator: validator,
    );
  }
}

// ── Gradient button ──────────────────────────────────────────────────────

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

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
                  Config.primaryColor.withOpacity(0.7),
                  Config.primaryColor.withOpacity(0.5),
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
                  color: Config.primaryColor.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: loading
                  ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
                  : Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Role card ────────────────────────────────────────────────────────────

class _DarkRoleCard extends StatelessWidget {
  const _DarkRoleCard({
    required this.selected,
    required this.label,
    required this.icon,
    required this.subtitle,
    required this.onTap,
  });

  final bool selected;
  final String label;
  final IconData icon;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 14,
          ),
          decoration: BoxDecoration(
            color: selected
                ? Config.primaryColor.withOpacity(0.20)
                : Colors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? Config.primaryColor.withOpacity(0.8)
                  : Colors.white.withOpacity(0.12),
              width: selected ? 2 : 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: selected
                    ? Config.primaryColor
                    : Colors.white.withOpacity(0.45),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: selected
                      ? Colors.white
                      : Colors.white.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Registration Screen ──────────────────────────────────────────────────

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  String _userType = 'patient';
  bool _obscure = true;

  late AnimationController _fadeCtrl;
  late AnimationController _slideCtrl;

  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnim = CurvedAnimation(
      parent: _fadeCtrl,
      curve: Curves.easeOut,
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _slideCtrl,
        curve: Curves.easeOutCubic,
      ),
    );

    Future.delayed(
      const Duration(milliseconds: 100),
          () {
        if (!mounted) return;

        _fadeCtrl.forward();
        _slideCtrl.forward();
      },
    );
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _slideCtrl.dispose();

    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();

    super.dispose();
  }

  // ── REGISTER ───────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    final auth = context.read<AuthProvider>();

    final email = _emailCtrl.text.trim();

    final success = await auth.register(
      name: _nameCtrl.text.trim(),
      email: email,
      password: _passCtrl.text,
      type: _userType,
    );

    if (!mounted) return;

    if (success) {
      /*
       * IMPORTANT:
       *
       * Registration does NOT log the user in.
       *
       * Backend should:
       * 1. Create user
       * 2. Generate registration OTP
       * 3. Send OTP to email
       *
       * Then Flutter sends the user to OTP screen.
       */

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpScreen(
            email: email,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            auth.error ?? 'Registration failed.',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0E1A),
        body: Stack(
          children: [
            // ── Background blobs ───────────────────────────────────────

            _AnimatedBlob(
              color: Config.primaryColor.withOpacity(0.12),
              size: 280,
              duration: const Duration(seconds: 4),
              delay: Duration.zero,
              offsetX: -60,
              offsetY: -40,
            ),

            _AnimatedBlob(
              color: Config.secondaryColor.withOpacity(0.09),
              size: 220,
              duration: const Duration(seconds: 5),
              delay: const Duration(milliseconds: 600),
              offsetX: 200,
              offsetY: 80,
            ),

            _AnimatedBlob(
              color: const Color(0xFF6C5CE7).withOpacity(0.08),
              size: 180,
              duration: const Duration(seconds: 3),
              delay: const Duration(seconds: 1),
              offsetX: 80,
              offsetY: 480,
            ),

            // ── Back button ────────────────────────────────────────────

            SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: IconButton(
                    icon: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.12),
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),

            // ── Main content ───────────────────────────────────────────

            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      28,
                      60,
                      28,
                      32,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),

                        const Text(
                          'Create\nAccount ✨',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Fill in your details to get started',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white.withOpacity(0.55),
                          ),
                        ),

                        const SizedBox(height: 28),

                        Text(
                          'I am a…',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // ── Role selector ──────────────────────────────

                        Row(
                          children: [
                            _DarkRoleCard(
                              selected: _userType == 'patient',
                              label: 'Patient',
                              icon: Icons.person_outline_rounded,
                              subtitle: 'Book appointments',
                              onTap: () {
                                setState(() {
                                  _userType = 'patient';
                                });
                              },
                            ),

                            const SizedBox(width: 12),

                            _DarkRoleCard(
                              selected: _userType == 'doctor',
                              label: 'Doctor',
                              icon: Icons.medical_services_outlined,
                              subtitle: 'Manage your practice',
                              onTap: () {
                                setState(() {
                                  _userType = 'doctor';
                                });
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // ── Form ────────────────────────────────────────

                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.07),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.12),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 40,
                                offset: const Offset(0, 16),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // Name
                                _DarkTextField(
                                  controller: _nameCtrl,
                                  label: _userType == 'doctor'
                                      ? 'Full name (as registered)'
                                      : 'Full name',
                                  hint: 'Your full name',
                                  icon: Icons.person_outline,
                                  textCapitalization:
                                  TextCapitalization.words,
                                  textInputAction:
                                  TextInputAction.next,
                                  validator: (v) {
                                    if (v == null ||
                                        v.trim().isEmpty) {
                                      return 'Name is required';
                                    }

                                    if (v.trim().length < 2) {
                                      return 'Enter a valid name';
                                    }

                                    return null;
                                  },
                                ),

                                const SizedBox(height: 14),

                                // Email
                                _DarkTextField(
                                  controller: _emailCtrl,
                                  label: 'Email',
                                  hint: 'you@example.com',
                                  icon: Icons.email_outlined,
                                  keyboardType:
                                  TextInputType.emailAddress,
                                  textInputAction:
                                  TextInputAction.next,
                                  validator: (v) {
                                    if (v == null ||
                                        v.trim().isEmpty) {
                                      return 'Email is required';
                                    }

                                    final email =
                                    v.trim();

                                    final emailRegex = RegExp(
                                      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                    );

                                    if (!emailRegex
                                        .hasMatch(email)) {
                                      return 'Enter a valid email';
                                    }

                                    return null;
                                  },
                                ),

                                const SizedBox(height: 14),

                                // Password
                                _DarkTextField(
                                  controller: _passCtrl,
                                  label: 'Password',
                                  hint: '••••••••',
                                  icon: Icons.lock_outline,
                                  obscureText: _obscure,
                                  textInputAction:
                                  TextInputAction.next,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscure
                                          ? Icons
                                          .visibility_off_outlined
                                          : Icons
                                          .visibility_outlined,
                                      color: Colors.white
                                          .withOpacity(0.4),
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscure = !_obscure;
                                      });
                                    },
                                  ),
                                  validator: (v) {
                                    if (v == null ||
                                        v.isEmpty) {
                                      return 'Password is required';
                                    }

                                    if (v.length < 8) {
                                      return 'Minimum 8 characters';
                                    }

                                    return null;
                                  },
                                ),

                                const SizedBox(height: 14),

                                // Confirm password
                                _DarkTextField(
                                  controller: _confirmCtrl,
                                  label: 'Confirm password',
                                  hint: '••••••••',
                                  icon: Icons.lock_outline,
                                  obscureText: _obscure,
                                  textInputAction:
                                  TextInputAction.done,
                                  onFieldSubmitted: (_) =>
                                      _submit(),
                                  validator: (v) {
                                    if (v == null ||
                                        v.isEmpty) {
                                      return 'Please confirm your password';
                                    }

                                    if (v != _passCtrl.text) {
                                      return 'Passwords do not match';
                                    }

                                    return null;
                                  },
                                ),

                                // Doctor hint
                                if (_userType == 'doctor') ...[
                                  const SizedBox(height: 14),

                                  Container(
                                    padding:
                                    const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Config.primaryColor
                                          .withOpacity(0.12),
                                      borderRadius:
                                      BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Config.primaryColor
                                            .withOpacity(0.3),
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          size: 16,
                                          color: Config.primaryColor
                                              .withOpacity(0.9),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            'After email verification you can fill in your specialisation, availability, and consultation fee.',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Config
                                                  .primaryColor
                                                  .withOpacity(0.9),
                                              height: 1.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],

                                const SizedBox(height: 20),

                                // ── Register button ────────────────────

                                _GradientButton(
                                  label: 'Create Account',
                                  loading: auth.loading,
                                  onPressed: _submit,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ── Login ──────────────────────────────────────

                        Center(
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account? ',
                                style: TextStyle(
                                  color: Colors.white
                                      .withOpacity(0.5),
                                ),
                              ),
                              GestureDetector(
                                onTap: () =>
                                    Navigator.pop(context),
                                child: const Text(
                                  'Sign In',
                                  style: TextStyle(
                                    color: Color(0xFF00CEC9),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),
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
}