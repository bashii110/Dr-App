import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../components/custom_widget.dart';
import '../../provider/auth_provider.dart';
import '../../service/api_service.dart';
import '../../utils/config.dart';


class DoctorProfileEditScreen extends StatefulWidget {
  const DoctorProfileEditScreen({super.key});
  @override
  State<DoctorProfileEditScreen> createState() => _DoctorProfileEditScreenState();
}

class _DoctorProfileEditScreenState extends State<DoctorProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bioCtrl = TextEditingController();
  final _feeCtrl = TextEditingController();
  final _expCtrl = TextEditingController();

  String? _category;
  String _status = 'available';
  TimeOfDay _availFrom = const TimeOfDay(hour: 9,  minute: 0);
  TimeOfDay _availTo   = const TimeOfDay(hour: 17, minute: 0);
  bool _saving = false;
  bool _loaded = false;

  static const _categories = [
    'General', 'Cardiology', 'Respirations', 'Dermatology',
    'Gynaecology', 'Dental', 'Orthopaedics', 'Neurology',
    'Paediatrics', 'Psychiatry',
  ];

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  void _loadExisting() {
    final user = context.read<AuthProvider>().user;
    final profile = user?.profile;
    if (profile != null) {
      _category = profile['category'] as String?;
      _status   = profile['status'] as String? ?? 'available';
      _bioCtrl.text = profile['bio_data'] as String? ?? '';
      _feeCtrl.text = (profile['consultation_fee'] ?? '').toString();
      _expCtrl.text = (profile['experience'] ?? '').toString();
      final from = profile['available_from'] as String?;
      final to   = profile['available_to'] as String?;
      if (from != null) {
        final parts = from.split(':');
        _availFrom = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
      if (to != null) {
        final parts = to.split(':');
        _availTo = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
    }
    setState(() => _loaded = true);
  }

  @override
  void dispose() {
    _bioCtrl.dispose();
    _feeCtrl.dispose();
    _expCtrl.dispose();
    super.dispose();
  }

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}';

  Future<void> _pickTime(bool isFrom) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isFrom ? _availFrom : _availTo,
    );
    if (picked != null) {
      setState(() {
        if (isFrom) _availFrom = picked;
        else        _availTo   = picked;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final res = await ApiService.updateDoctorProfile({

        if (_category != null) 'category': _category,
        'bio_data':         _bioCtrl.text.trim(),
        'consultation_fee': double.tryParse(_feeCtrl.text) ?? 0,
        'experience':       int.tryParse(_expCtrl.text)    ?? 0,
        'status':           _status,
        'available_from':   _fmt(_availFrom),
        'available_to':     _fmt(_availTo),
      });
      print("UPDATE RESPONSE: $res");
      if (!mounted) return;
      setState(() => _saving = false);
      if (res['status'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully.'),
            backgroundColor: Config.secondaryColor,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message']?.toString() ?? 'Update failed'),
            backgroundColor: Config.errorColor,
          ),
        );
      }
    } catch (_) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connection error.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: Config.bgColor,
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Category ──────────────────────────────────────────────
              _Label('Specialisation'),
              Config.spaceXS,
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(),
                hint: const Text('Select specialisation'),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v),
              ),
              Config.spaceSmall,

              // ── Experience ────────────────────────────────────────────
              _Label('Years of experience'),
              Config.spaceXS,
              TextFormField(
                controller: _expCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.work_outline),
                  suffixText: 'years',
                ),
              ),
              Config.spaceSmall,

              // ── Consultation fee ──────────────────────────────────────
              _Label('Consultation fee (Rs)'),
              Config.spaceXS,
              TextFormField(
                controller: _feeCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.payments_outlined),
                  prefixText: 'Rs ',
                ),
              ),
              Config.spaceSmall,

              // ── Status ────────────────────────────────────────────────
              _Label('Current status'),
              Config.spaceXS,
              Row(
                children: ['available', 'busy', 'offline'].map((s) {
                  final sel = _status == s;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _status = s),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: sel
                              ? Config.primaryColor
                              : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: sel ? Config.primaryColor : Config.dividerColor,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          s[0].toUpperCase() + s.substring(1),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: sel ? Colors.white : Config.textMid,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              Config.spaceSmall,

              // ── Availability ──────────────────────────────────────────
              _Label('Available hours'),
              Config.spaceXS,
              Row(
                children: [
                  Expanded(
                    child: _TimePicker(
                      label: 'From',
                      time: _availFrom,
                      onTap: () => _pickTime(true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TimePicker(
                      label: 'To',
                      time: _availTo,
                      onTap: () => _pickTime(false),
                    ),
                  ),
                ],
              ),
              Config.spaceSmall,

              // ── Bio ───────────────────────────────────────────────────
              _Label('Professional biography'),
              Config.spaceXS,
              TextFormField(
                controller: _bioCtrl,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Describe your qualifications, experience, and specialisation…',
                ),
              ),
              Config.spaceLarge,

              PrimaryButton(
                label: 'Save Changes',
                loading: _saving,
                onPressed: _save,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Config.textDark));
}

class _TimePicker extends StatelessWidget {
  const _TimePicker({required this.label, required this.time, required this.onTap});
  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Config.dividerColor, width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time_outlined,
              size: 18, color: Config.primaryColor),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: Config.textMid)),
              Text(
                time.format(context),
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Config.textDark),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}