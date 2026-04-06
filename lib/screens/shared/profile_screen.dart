import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../components/custom_widget.dart';
import '../../provider/auth_provider.dart';

import '../../service/api_service.dart';
import '../../utils/config.dart';

import '../doctor/dr_profileedit_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: Config.bgColor,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (user.isDoctor)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const DoctorProfileEditScreen()),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── Avatar ─────────────────────────────────────────────────
            CircleAvatar(
              radius: 50,
              backgroundColor: Config.primaryColor.withOpacity(0.1),
              child: Text(
                user.name[0].toUpperCase(),
                style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: Config.primaryColor),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              user.isDoctor ? 'Dr ${user.name}' : user.name,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Config.textDark),
            ),
            const SizedBox(height: 4),
            Text(user.email,
                style: const TextStyle(color: Config.textMid, fontSize: 14)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: user.isDoctor
                    ? Config.primaryColor.withOpacity(0.1)
                    : Config.secondaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                user.isDoctor ? 'Doctor' : 'Patient',
                style: TextStyle(
                    color: user.isDoctor
                        ? Config.primaryColor
                        : Config.secondaryColor,
                    fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 24),

            // ── Doctor profile info ────────────────────────────────────
            if (user.isDoctor && user.profile != null) ...[
              _InfoCard(items: [
                _InfoRow(Icons.medical_services_outlined, 'Specialisation',
                    user.profile!['category'] as String? ?? 'Not set'),
                _InfoRow(Icons.work_outline, 'Experience',
                    '${user.profile!['experience'] ?? 0} years'),
                _InfoRow(Icons.payments_outlined, 'Consultation fee',
                    'Rs ${(user.profile!['consultation_fee'] ?? 0).toInt()}'),
                _InfoRow(Icons.access_time_outlined, 'Available',
                    '${user.profile!['available_from'] ?? '--'} – ${user.profile!['available_to'] ?? '--'}'),
              ]),
              const SizedBox(height: 16),
              if (user.profile!['bio_data'] != null &&
                  (user.profile!['bio_data'] as String).isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Config.dividerColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Biography',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Config.textDark)),
                      const SizedBox(height: 8),
                      Text(user.profile!['bio_data'] as String,
                          style: const TextStyle(
                              color: Config.textMid, height: 1.6)),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
            ],

            // ── Account section ────────────────────────────────────────
            _InfoCard(items: [
              _InfoRow(Icons.email_outlined, 'Email', user.email),
              _InfoRow(Icons.shield_outlined, 'Account type',
                  user.isDoctor ? 'Doctor' : 'Patient'),
            ]),
            const SizedBox(height: 16),

            // ── Actions ────────────────────────────────────────────────
            _ActionTile(
              icon: Icons.lock_outline,
              label: 'Change password',
              onTap: () => _showChangePassword(context),
            ),
            const SizedBox(height: 8),
            _ActionTile(
              icon: Icons.logout_rounded,
              label: 'Sign out',
              color: Config.errorColor,
              onTap: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Sign out'),
                    content: const Text('Are you sure you want to sign out?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel')),
                      TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Sign out',
                              style: TextStyle(color: Config.errorColor))),
                    ],
                  ),
                );
                if (ok == true && context.mounted) {
                  context.read<AuthProvider>().logout();
                }
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showChangePassword(BuildContext context) {
    final currCtrl = TextEditingController();
    final newCtrl  = TextEditingController();
    final formKey  = GlobalKey<FormState>();
    bool loading   = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.fromLTRB(
              24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Change password',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Config.textDark)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: currCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Current password'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: newCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'New password'),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (v.length < 6) return 'Minimum 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: 'Update Password',
                  loading: loading,
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    setS(() => loading = true);
                    final res = await ApiService.changePassword(
                      current: currCtrl.text,
                      newPass: newCtrl.text,
                    );
                    if (!ctx.mounted) return;
                    setS(() => loading = false);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(res['message'] as String? ?? 'Done.'),
                      backgroundColor:
                      res['status'] == 200 ? Config.secondaryColor : Config.errorColor,
                    ));
                    if (res['status'] == 200 && context.mounted) {
                      context.read<AuthProvider>().logout();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.items});
  final List<Widget> items;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Config.dividerColor),
    ),
    child: Column(children: items),
  );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.icon, this.label, this.value);
  final IconData icon;
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, size: 20, color: Config.primaryColor),
    title: Text(label,
        style: const TextStyle(fontSize: 12, color: Config.textMid)),
    subtitle: Text(value,
        style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Config.textDark)),
    dense: true,
  );
}

class _ActionTile extends StatelessWidget {
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
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Config.dividerColor),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color ?? Config.textMid),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: color ?? Config.textDark)),
          ),
          Icon(Icons.chevron_right_rounded,
              color: color ?? Config.textLight),
        ],
      ),
    ),
  );
}