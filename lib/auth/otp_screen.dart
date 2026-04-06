import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart';
import '../components/custom_widget.dart';
import '../provider/auth_provider.dart';
import '../utils/config.dart';


class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.email});
  final String email;
  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpCtrl = TextEditingController();
  int _secondsLeft = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
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
    super.dispose();
  }

  Future<void> _verify() async {
    if (_otpCtrl.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the 6-digit code.')),
      );
      return;
    }
    final auth = context.read<AuthProvider>();
    final ok   = await auth.verifyOtp(
      email: widget.email,
      otp:   _otpCtrl.text,
    );
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email verified! Please log in.'),
          backgroundColor: Config.secondaryColor,
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (_) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Invalid code.'),
          backgroundColor: Config.errorColor,
        ),
      );
    }
  }

  Future<void> _resend() async {
    final ok = await context.read<AuthProvider>().resendOtp(widget.email);
    if (!mounted) return;
    if (ok) {
      _startTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New code sent.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to resend. Try again.'),
          backgroundColor: Config.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Config.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.mark_email_read_outlined,
                    size: 34, color: Config.primaryColor),
              ),
              const SizedBox(height: 20),
              const Text('Verify your email',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Config.textDark)),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 14, color: Config.textMid, height: 1.5),
                  children: [
                    const TextSpan(text: 'We sent a 6-digit code to\n'),
                    TextSpan(
                      text: widget.email,
                      style: const TextStyle(
                          color: Config.textDark, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // PIN field
              PinCodeTextField(
                appContext: context,
                length: 6,
                controller: _otpCtrl,
                keyboardType: TextInputType.number,
                animationType: AnimationType.scale,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(10),
                  fieldHeight: 54,
                  fieldWidth: 46,
                  activeFillColor: Colors.white,
                  selectedFillColor: Config.primaryColor.withOpacity(0.05),
                  inactiveFillColor: Colors.white,
                  activeColor: Config.primaryColor,
                  selectedColor: Config.primaryColor,
                  inactiveColor: Config.dividerColor,
                ),
                enableActiveFill: true,
                onCompleted: (_) => _verify(),
                onChanged: (_) {},
              ),
              const SizedBox(height: 28),

              // Verify button
              PrimaryButton(
                label: 'Verify Email',
                loading: auth.loading,
                onPressed: _verify,
              ),
              const SizedBox(height: 20),

              // Resend row
              Center(
                child: _secondsLeft > 0
                    ? Text(
                  'Resend code in $_secondsLeft s',
                  style: const TextStyle(color: Config.textMid, fontSize: 14),
                )
                    : TextButton(
                  onPressed: _resend,
                  child: const Text(
                    'Resend code',
                    style: TextStyle(
                        color: Config.primaryColor,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}