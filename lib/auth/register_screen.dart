import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/custom_widget.dart';
import '../provider/auth_provider.dart';
import '../utils/config.dart';

import 'otp_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});
  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey     = GlobalKey<FormState>();
  final _nameCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _passCtrl    = TextEditingController();
  final _confirmCtrl = TextEditingController();
  String _userType = 'patient';
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final auth = context.read<AuthProvider>();
    final ok   = await auth.register(
      name:     _nameCtrl.text.trim(),
      email:    _emailCtrl.text.trim(),
      password: _passCtrl.text,
      type:     _userType,
    );

    if (!mounted) return;
    if (ok) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpScreen(email: _emailCtrl.text.trim()),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Registration failed.'),
          backgroundColor: Config.errorColor,
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
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Create account',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Config.textDark)),
                const SizedBox(height: 6),
                const Text('Fill in your details to get started.',
                    style: TextStyle(fontSize: 15, color: Config.textMid)),
                const SizedBox(height: 28),

                // ── Role selector ──────────────────────────────────────────
                const Text('I am a…',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Config.textDark)),
                const SizedBox(height: 10),
                Row(children: [
                  _RoleCard(
                    selected:  _userType == 'patient',
                    label:     'Patient',
                    icon:      Icons.person_outline_rounded,
                    subtitle:  'Book appointments',
                    onTap: () => setState(() => _userType = 'patient'),
                  ),
                  const SizedBox(width: 12),
                  _RoleCard(
                    selected:  _userType == 'doctor',
                    label:     'Doctor',
                    icon:      Icons.medical_services_outlined,
                    subtitle:  'Manage your practice',
                    onTap: () => setState(() => _userType = 'doctor'),
                  ),
                ]),
                const SizedBox(height: 24),

                // ── Form ───────────────────────────────────────────────────
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameCtrl,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: _userType == 'doctor'
                              ? 'Full name (as registered)'
                              : 'Full name',
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                        validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Name is required' : null,
                      ),
                      Config.spaceSmall,
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Email is required';
                          if (!v.contains('@')) return 'Enter a valid email';
                          return null;
                        },
                      ),
                      Config.spaceSmall,
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: _obscure,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscure
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Password is required';
                          if (v.length < 6) return 'Minimum 6 characters';
                          return null;
                        },
                      ),
                      Config.spaceSmall,
                      TextFormField(
                        controller: _confirmCtrl,
                        obscureText: _obscure,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                        decoration: const InputDecoration(
                          labelText: 'Confirm password',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        validator: (v) {
                          if (v != _passCtrl.text) return 'Passwords do not match';
                          return null;
                        },
                      ),

                      // Doctor-specific hint
                      if (_userType == 'doctor') ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Config.primaryColor.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.info_outline,
                                  size: 18, color: Config.primaryColor),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'After registration you will be able to fill in your specialisation, availability, and consultation fee.',
                                  style: TextStyle(
                                      fontSize: 12, color: Config.primaryColor),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      Config.spaceMedium,
                      PrimaryButton(
                        label: 'Create Account',
                        loading: auth.loading,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account? ',
                        style: TextStyle(color: Config.textMid)),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text('Sign In',
                          style: TextStyle(
                              color: Config.primaryColor,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Role selector card ────────────────────────────────────────────────────

class _RoleCard extends StatelessWidget {
  const _RoleCard({
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
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
          decoration: BoxDecoration(
            color: selected
                ? Config.primaryColor.withOpacity(0.08)
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? Config.primaryColor : Config.dividerColor,
              width: selected ? 2 : 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  size: 32,
                  color: selected ? Config.primaryColor : Config.textMid),
              const SizedBox(height: 8),
              Text(label,
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: selected ? Config.primaryColor : Config.textDark)),
              const SizedBox(height: 4),
              Text(subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, color: Config.textMid)),
            ],
          ),
        ),
      ),
    );
  }
}