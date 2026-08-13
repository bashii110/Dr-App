import 'dart:async';

import 'package:doctor_app/auth/reset_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

import '../provider/auth_provider.dart';

const _bg = Color(0xFF0A0E1A);
const _card = Color(0xFF141829);
const _accent = Color(0xFF1A73E8);
const _accentTeal = Color(0xFF00CEC9);

class ResetOtpScreen extends StatefulWidget {
  const ResetOtpScreen({
    super.key,
    required this.email,
  });

  final String email;

  @override
  State<ResetOtpScreen> createState() => _ResetOtpScreenState();
}

class _ResetOtpScreenState extends State<ResetOtpScreen>
    with SingleTickerProviderStateMixin {
  final _otpCtrl = TextEditingController();

  int _secondsLeft = 60;
  Timer? _timer;

  late AnimationController _blobCtrl;
  late Animation<double> _blobAnim;

  @override
  void initState() {
    super.initState();

    _startTimer();

    _blobCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _blobCtrl.reverse();
        }

        if (status == AnimationStatus.dismissed) {
          _blobCtrl.forward();
        }
      })
      ..forward();

    _blobAnim = Tween<double>(
      begin: -12,
      end: 12,
    ).animate(
      CurvedAnimation(
        parent: _blobCtrl,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _startTimer() {
    _timer?.cancel();

    _secondsLeft = 60;

    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (_secondsLeft == 0) {
          timer.cancel();
        } else {
          setState(() {
            _secondsLeft--;
          });
        }
      },
    );

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpCtrl.dispose();
    _blobCtrl.dispose();

    super.dispose();
  }

  // ============================================================
  // VERIFY RESET OTP
  // ============================================================

  Future<void> _verify() async {
    final otp = _otpCtrl.text.trim();

    if (otp.length != 6) {
      _snack(
        'Please enter the 6-digit code.',
        error: true,
      );
      return;
    }

    final auth = context.read<AuthProvider>();

    final resetToken = await auth.verifyResetOtp(
      email: widget.email,
      otp: otp,
    );

    if (!mounted) return;

    if (resetToken == null || resetToken.isEmpty) {
      _snack(
        'Invalid or expired reset code.',
        error: true,
      );

      _otpCtrl.clear();
      return;
    }

    _snack(
      'Code verified successfully.',
      success: true,
    );

    await Future.delayed(
      const Duration(milliseconds: 400),
    );

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResetPasswordScreen(
          resetToken: resetToken,
        ),
      ),
    );
  }

  // ============================================================
  // RESEND RESET OTP
  // ============================================================

  Future<void> _resend() async {
    if (_secondsLeft > 0) return;

    final auth = context.read<AuthProvider>();

    final ok = await auth.resendResetOtp(
      widget.email,
    );

    if (!mounted) return;

    if (ok) {
      _otpCtrl.clear();

      _startTimer();

      _snack(
        'New reset code sent.',
        success: true,
      );
    } else {
      _snack(
        'Failed to resend reset code. Try again.',
        error: true,
      );
    }
  }

  // ============================================================
  // SNACKBAR
  // ============================================================

  void _snack(
      String msg, {
        bool error = false,
        bool success = false,
      }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: error
            ? const Color(0xFFD32F2F)
            : success
            ? const Color(0xFF34A853)
            : _card,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // ======================================================
          // ANIMATED BACKGROUND BLOBS
          // ======================================================

          AnimatedBuilder(
            animation: _blobAnim,
            builder: (_, __) {
              return Stack(
                children: [
                  Positioned(
                    top: -80 + _blobAnim.value,
                    left: -100,
                    child: _blob(
                      280,
                      _accent.withOpacity(0.12),
                    ),
                  ),

                  Positioned(
                    bottom: 100 - _blobAnim.value,
                    right: -60,
                    child: _blob(
                      220,
                      _accentTeal.withOpacity(0.08),
                    ),
                  ),

                  Positioned(
                    top: 200 + (_blobAnim.value * 0.5),
                    right: -40,
                    child: _blob(
                      160,
                      const Color(0xFF6C5CE7).withOpacity(0.07),
                    ),
                  ),
                ],
              );
            },
          ),

          // ======================================================
          // CONTENT
          // ======================================================

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==================================================
                  // BACK BUTTON
                  // ==================================================

                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                    onPressed: auth.loading
                        ? null
                        : () => Navigator.pop(context),
                  ),

                  const SizedBox(height: 24),

                  // ==================================================
                  // ICON
                  // ==================================================

                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          _accent,
                          _accentTeal,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.lock_reset_rounded,
                      size: 34,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ==================================================
                  // TITLE
                  // ==================================================

                  const Text(
                    'Reset your password',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ==================================================
                  // DESCRIPTION
                  // ==================================================

                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white.withOpacity(0.5),
                        height: 1.6,
                      ),
                      children: [
                        const TextSpan(
                          text: 'We sent a 6-digit reset code to\n',
                        ),
                        TextSpan(
                          text: widget.email,
                          style: const TextStyle(
                            color: _accentTeal,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Enter the code to continue resetting your password.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.4),
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ==================================================
                  // OTP FIELD
                  // ==================================================

                  PinCodeTextField(
                    appContext: context,
                    length: 6,
                    controller: _otpCtrl,

                    keyboardType: TextInputType.number,

                    animationType: AnimationType.scale,

                    enableActiveFill: true,

                    backgroundColor: Colors.transparent,

                    cursorColor: _accentTeal,

                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),

                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(14),

                      fieldHeight: 58,
                      fieldWidth: 48,

                      inactiveFillColor: _card,
                      activeFillColor: _card,
                      selectedFillColor: const Color(0xFF18243D),

                      inactiveColor: Colors.white.withOpacity(0.12),
                      activeColor: _accent,
                      selectedColor: _accentTeal,

                      borderWidth: 1.5,
                    ),

                    onCompleted: (_) {
                      if (!auth.loading) {
                        _verify();
                      }
                    },

                    onChanged: (_) {},
                  ),

                  const SizedBox(height: 32),

                  // ==================================================
                  // VERIFY BUTTON
                  // ==================================================

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: auth.loading ? null : _verify,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accent,
                        disabledBackgroundColor:
                        _accent.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: auth.loading
                          ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                          : const Text(
                        'Verify Code',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ==================================================
                  // RESEND
                  // ==================================================

                  Center(
                    child: _secondsLeft > 0
                        ? RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 14,
                        ),
                        children: [
                          const TextSpan(
                            text: 'Resend code in ',
                          ),
                          TextSpan(
                            text: '$_secondsLeft s',
                            style: const TextStyle(
                              color: _accentTeal,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    )
                        : TextButton(
                      onPressed:
                      auth.loading ? null : _resend,
                      child: const Text(
                        'Resend code',
                        style: TextStyle(
                          color: _accentTeal,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ==================================================
                  // SECURITY NOTE
                  // ==================================================

                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.security_rounded,
                          size: 15,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'This code expires shortly',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // BACKGROUND BLOB
  // ==============================================================

  Widget _blob(
      double size,
      Color color,
      ) {
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