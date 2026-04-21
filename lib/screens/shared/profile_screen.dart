import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/auth_provider.dart';
import '../../service/api_service.dart';
import '../doctor/dr_profileedit_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E1A),
        elevation: 0,
        title: const Text('Profile',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700)),
        actions: [
          if (user.isDoctor)
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const DoctorProfileEditScreen()),
              ),
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(10),
                  border:
                  Border.all(color: Colors.white.withOpacity(0.12)),
                ),
                child: Icon(Icons.edit_outlined,
                    color: Colors.white.withOpacity(0.7), size: 18),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── Avatar ─────────────────────────────────────────────────
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A73E8), Color(0xFF00CEC9)],
                ),
              ),
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: const Color(0xFF141829),
                  borderRadius: BorderRadius.circular(27),
                ),
                child: Center(
                  child: Text(
                    user.name[0].toUpperCase(),
                    style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.isDoctor ? 'Dr ${user.name}' : user.name,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(user.email,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.45), fontSize: 14)),
            const SizedBox(height: 12),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: user.isDoctor
                    ? const Color(0xFF1A73E8).withOpacity(0.15)
                    : const Color(0xFF1D9E75).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: user.isDoctor
                      ? const Color(0xFF1A73E8).withOpacity(0.3)
                      : const Color(0xFF1D9E75).withOpacity(0.3),
                ),
              ),
              child: Text(
                user.isDoctor ? 'Doctor' : 'Patient',
                style: TextStyle(
                    color: user.isDoctor
                        ? const Color(0xFF378ADD)
                        : const Color(0xFF1D9E75),
                    fontWeight: FontWeight.w700,
                    fontSize: 13),
              ),
            ),
            const SizedBox(height: 28),

            // ── Doctor profile ─────────────────────────────────────────
            if (user.isDoctor && user.profile != null) ...[
              _DarkCard(
                children: [
                  _InfoRow(
                      Icons.medical_services_outlined,
                      'Specialisation',
                      user.profile!['category'] as String? ?? 'Not set'),
                  _InfoRow(Icons.work_outline, 'Experience',
                      '${user.profile!['experience'] ?? 0} years'),
                  _InfoRow(Icons.payments_outlined, 'Consultation fee',
                      'Rs ${(user.profile!['fee'] ?? 0)}'),
                  _InfoRow(Icons.access_time_outlined, 'Available',
                      '${user.profile!['available_from'] ?? '--'} – ${user.profile!['available_to'] ?? '--'}'),
                ],
              ),
              const SizedBox(height: 14),
              if (user.profile!['bio_data'] != null &&
                  (user.profile!['bio_data'] as String).isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.09)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Biography',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.white.withOpacity(0.55),
                              fontSize: 12,
                              letterSpacing: 0.5)),
                      const SizedBox(height: 8),
                      Text(user.profile!['bio_data'] as String,
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.65),
                              fontSize: 14,
                              height: 1.6)),
                    ],
                  ),
                ),
              const SizedBox(height: 14),
            ],

            // ── Account ────────────────────────────────────────────────
            _DarkCard(
              children: [
                _InfoRow(Icons.email_outlined, 'Email', user.email),
                _InfoRow(Icons.shield_outlined, 'Account type',
                    user.isDoctor ? 'Doctor' : 'Patient'),
              ],
            ),
            const SizedBox(height: 14),

            // ── Actions ────────────────────────────────────────────────
            _ActionTile(
              icon: Icons.lock_outline,
              label: 'Change password',
              onTap: () => _showChangePassword(context),
            ),
            const SizedBox(height: 10),
            _ActionTile(
              icon: Icons.logout_rounded,
              label: 'Sign out',
              color: const Color(0xFFE24B4A),
              onTap: () async {
                final ok = await _confirmDialog(context, 'Sign out',
                    'Are you sure you want to sign out?');
                if (ok == true && context.mounted) {
                  context.read<AuthProvider>().logout();
                }
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Future<bool?> _confirmDialog(
      BuildContext context, String title, String content) {
    return showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF141829),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(content,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.5), fontSize: 14)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, false),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.12)),
                        ),
                        child: Center(
                            child: Text('Cancel',
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontWeight: FontWeight.w600))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, true),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1A73E8), Color(0xFF1565C0)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                            child: Text(title,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700))),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangePassword(BuildContext context) {
    final currCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF141829),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          bool loading = false;
          return Padding(
            padding: EdgeInsets.fromLTRB(
                24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 32),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Change password',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 20),
                  _DarkTextField(
                    controller: currCtrl,
                    label: 'Current password',
                    obscure: true,
                    validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),
                  _DarkTextField(
                    controller: newCtrl,
                    label: 'New password',
                    obscure: true,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (v.length < 6) return 'Minimum 6 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: loading
                        ? null
                        : () async {
                      if (!formKey.currentState!.validate()) return;
                      setS(() => loading = true);
                      final res = await ApiService.changePassword(
                        current: currCtrl.text,
                        newPass: newCtrl.text,
                      );
                      if (!ctx.mounted) return;
                      setS(() => loading = false);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              res['message'] as String? ?? 'Done.'),
                          backgroundColor: const Color(0xFF1C2333),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(12)),
                        ),
                      );
                      if (res['status'] == 200 && context.mounted) {
                        context.read<AuthProvider>().logout();
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1A73E8), Color(0xFF1565C0)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: loading
                            ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                            : const Text('Update Password',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────

class _DarkCard extends StatelessWidget {
  const _DarkCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.09)),
      ),
      child: Column(
        children: children.asMap().entries.map((e) {
          final isLast = e.key == children.length - 1;
          return Column(
            children: [
              e.value,
              if (!isLast)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child:
                  Container(height: 0.5, color: Colors.white.withOpacity(0.07)),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.icon, this.label, this.value);
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF1A73E8).withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child:
            Icon(icon, size: 17, color: const Color(0xFF378ADD)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.4),
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatefulWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  State<_ActionTile> createState() => _ActionTileState();
}

class _ActionTileState extends State<_ActionTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 100),
        lowerBound: 0.97,
        upperBound: 1.0,
        value: 1.0);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Colors.white;
    final isDestructive = widget.color != null;

    return ScaleTransition(
      scale: _ctrl,
      child: GestureDetector(
        onTapDown: (_) => _ctrl.reverse(),
        onTapUp: (_) {
          _ctrl.forward();
          widget.onTap();
        },
        onTapCancel: () => _ctrl.forward(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            color: isDestructive
                ? color.withOpacity(0.06)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDestructive
                  ? color.withOpacity(0.2)
                  : Colors.white.withOpacity(0.09),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(widget.icon, size: 17, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(widget.label,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: color,
                        fontSize: 14)),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: color.withOpacity(0.4), size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _DarkTextField extends StatelessWidget {
  const _DarkTextField({
    required this.controller,
    required this.label,
    this.obscure = false,
    this.validator,
  });
  final TextEditingController controller;
  final String label;
  final bool obscure;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.45)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
          BorderSide(color: Colors.white.withOpacity(0.12)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
          BorderSide(color: Colors.white.withOpacity(0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF1A73E8)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE24B4A)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE24B4A)),
        ),
      ),
    );
  }
}