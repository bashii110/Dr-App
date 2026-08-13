import 'dart:async';
import 'package:doctor_app/auth/reset_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart';
import '../provider/auth_provider.dart';

const _bg = Color(0xFF0A0E1A);
const _card = Color(0xFF141829);
const _accent = Color(0xFF1A73E8);
const _accentTeal = Color(0xFF00CEC9);

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.email, this.purpose = 'verification',});
  final String email;
  final String purpose;
  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> with SingleTickerProviderStateMixin {
  final _otpCtrl = TextEditingController();
  int _secondsLeft = 60;
  Timer? _timer;
  late AnimationController _blobCtrl;
  late Animation<double> _blobAnim;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _blobCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) _blobCtrl.reverse();
        if (s == AnimationStatus.dismissed) _blobCtrl.forward();
      })
      ..forward();
    _blobAnim = Tween<double>(begin: -12, end: 12)
        .animate(CurvedAnimation(parent: _blobCtrl, curve: Curves.easeInOut));
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft == 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpCtrl.dispose();
    _blobCtrl.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_otpCtrl.text.length < 6) {
      _snack(
        'Please enter the 6-digit code.',
        error: true,
      );
      return;
    }

    final auth = context.read<AuthProvider>();

    final ok = await auth.verifyOtp(
      email: widget.email,
      otp: _otpCtrl.text,
    );

    if (!mounted) return;

    if (!ok) {
      _snack(
        'Invalid or expired verification code.',
        error: true,
      );

      // Clear incorrect OTP
      _otpCtrl.clear();

      return;
    }

    // Keep your existing successful verification flow
    _snack(
      'Email verified! Please log in.',
      success: true,
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
          (_) => false,
    );
  }

  Future<void> _resend() async {
    final ok = await context.read<AuthProvider>().resendOtp(widget.email);
    if (!mounted) return;
    if (ok) {
      _startTimer();
      _snack('New code sent.');
    } else {
      _snack('Failed to resend. Try again.', error: true);
    }
  }

  void _snack(String msg, {bool error = false, bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white)),
      backgroundColor: error
          ? const Color(0xFFD32F2F)
          : success
          ? const Color(0xFF34A853)
          : _card,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _blobAnim,
            builder: (_, __) => Stack(children: [
              Positioned(
                  top: -80 + _blobAnim.value,
                  left: -100,
                  child: _blob(280, _accent.withOpacity(0.12))),
              Positioned(
                  bottom: 100 - _blobAnim.value,
                  right: -60,
                  child: _blob(220, _accentTeal.withOpacity(0.08))),
              Positioned(
                  top: 200 + _blobAnim.value * 0.5,
                  right: -40,
                  child: _blob(160, const Color(0xFF6C5CE7).withOpacity(0.07))),
            ]),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 20, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [_accent, _accentTeal],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.mark_email_read_outlined,
                        size: 32, color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  const Text('Verify your email',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.white.withOpacity(0.5),
                          height: 1.6),
                      children: [
                        const TextSpan(text: 'We sent a 6-digit code to\n'),
                        TextSpan(
                          text: widget.email,
                          style: const TextStyle(
                              color: _accentTeal, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
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

                      // DARK BACKGROUND
                      inactiveFillColor: const Color(0xFF141829),
                      activeFillColor: const Color(0xFF141829),
                      selectedFillColor: const Color(0xFF18243D),

                      // BORDERS
                      inactiveColor: Colors.white.withOpacity(0.12),
                      activeColor: _accent,
                      selectedColor: _accentTeal,

                      borderWidth: 1.5,
                    ),

                    onCompleted: (_) => _verify(),

                    onChanged: (_) {},
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: auth.loading ? null : _verify,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accent,
                        disabledBackgroundColor: _accent.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: auth.loading
                          ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                          : const Text('Verify Email',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: _secondsLeft > 0
                        ? RichText(
                      text: TextSpan(
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.4), fontSize: 14),
                        children: [
                          const TextSpan(text: 'Resend code in '),
                          TextSpan(
                            text: '$_secondsLeft s',
                            style: const TextStyle(
                                color: _accentTeal, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    )
                        : TextButton(
                      onPressed: _resend,
                      child: const Text('Resend code',
                          style: TextStyle(
                              color: _accentTeal,
                              fontWeight: FontWeight.w700,
                              fontSize: 14)),
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

  Widget _blob(double size, Color color) =>
      Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: color));
}