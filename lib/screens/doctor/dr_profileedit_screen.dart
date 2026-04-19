import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/auth_provider.dart';
import '../../service/api_service.dart';
import '../../utils/config.dart';

const _bg = Color(0xFF0A0E1A);
const _card = Color(0xFF141829);
const _accent = Color(0xFF1A73E8);
const _accentTeal = Color(0xFF00CEC9);
const _border = Color(0x1AFFFFFF);

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
  TimeOfDay _availFrom = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _availTo = const TimeOfDay(hour: 17, minute: 0);
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
    final profile = context.read<AuthProvider>().user?.profile;
    if (profile != null) {
      _category = profile['category'] as String?;
      _status = profile['status'] as String? ?? 'available';
      _bioCtrl.text = profile['bio_data'] as String? ?? '';
      _feeCtrl.text = (profile['consultation_fee'] ?? '').toString();
      _expCtrl.text = (profile['experience'] ?? '').toString();
      final from = profile['available_from'] as String?;
      final to = profile['available_to'] as String?;
      if (from != null) {
        final p = from.split(':');
        _availFrom = TimeOfDay(hour: int.parse(p[0]), minute: int.parse(p[1]));
      }
      if (to != null) {
        final p = to.split(':');
        _availTo = TimeOfDay(hour: int.parse(p[0]), minute: int.parse(p[1]));
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
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickTime(bool isFrom) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isFrom ? _availFrom : _availTo,
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: _accent, onSurface: Colors.white),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => isFrom ? _availFrom = picked : _availTo = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final res = await ApiService.updateDoctorProfile({
        if (_category != null) 'category': _category,
        'bio_data': _bioCtrl.text.trim(),
        'consultation_fee': double.tryParse(_feeCtrl.text) ?? 0,
        'experience': int.tryParse(_expCtrl.text) ?? 0,
        'status': _status,
        'available_from': _fmt(_availFrom),
        'available_to': _fmt(_availTo),
      });
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            res['status'] == 200 ? 'Profile updated successfully.' : (res['message']?.toString() ?? 'Update failed'),
            style: const TextStyle(color: Colors.white)),
        backgroundColor: res['status'] == 200 ? const Color(0xFF34A853) : const Color(0xFFD32F2F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      if (res['status'] == 200) Navigator.pop(context);
    } catch (_) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Connection error.')));
    }
  }

  InputDecoration _inputDec({String? label, String? hint, Widget? prefix, String? suffix}) =>
      InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: suffix,
        prefixIcon: prefix,
        filled: true,
        fillColor: Colors.white.withOpacity(0.06),
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _accent, width: 1.5)),
      );

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(
          backgroundColor: _bg,
          body: Center(child: CircularProgressIndicator(color: _accent)));
    }
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _card,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Edit Profile',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel('Specialisation'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),

                child: DropdownButtonFormField<String>(
                  value: _category,
                  dropdownColor: const Color(0xFF1C2333),
                  hint: Text('Select specialisation',
                      style: TextStyle(color: Colors.grey.withOpacity(0.7))),
                  style: const TextStyle(color: Colors.grey),
                  decoration: const InputDecoration(border: InputBorder.none),
                  items: _categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _category = v),
                ),
              ),
              const SizedBox(height: 16),
              _sectionLabel('Years of experience'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _expCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDec(
                    suffix: 'years',
                    prefix: const Icon(Icons.work_outline, color: _accent, size: 20)),
              ),
              const SizedBox(height: 16),
              _sectionLabel('Consultation fee (Rs)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _feeCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDec(
                    prefix: const Icon(Icons.payments_outlined, color: _accent, size: 20)),
              ),
              const SizedBox(height: 16),
              _sectionLabel('Current status'),
              const SizedBox(height: 8),
              Row(
                children: ['available', 'busy', 'offline'].map((s) {
                  final sel = _status == s;
                  final color = s == 'available'
                      ? const Color(0xFF34A853)
                      : s == 'busy'
                      ? const Color(0xFFFFA000)
                      : Colors.white38;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _status = s),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: sel ? color.withOpacity(0.15) : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: sel ? color : Colors.white.withOpacity(0.1),
                              width: sel ? 1.5 : 1),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          s[0].toUpperCase() + s.substring(1),
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: sel ? color : Colors.white38),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              _sectionLabel('Available hours'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _timePicker('From', _availFrom, () => _pickTime(true))),
                  const SizedBox(width: 12),
                  Expanded(child: _timePicker('To', _availTo, () => _pickTime(false))),
                ],
              ),
              const SizedBox(height: 16),
              _sectionLabel('Professional biography'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _bioCtrl,
                maxLines: 5,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDec(hint: 'Describe your qualifications and experience…'),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    disabledBackgroundColor: _accent.withOpacity(0.4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _saving
                      ? const SizedBox(
                      width: 22, height: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : const Text('Save Changes',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white60));

  Widget _timePicker(String label, TimeOfDay time, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              const Icon(Icons.access_time_outlined, size: 18, color: _accent),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 11, color: Colors.white38)),
                  Text(time.format(context),
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, color: Colors.white, fontSize: 15)),
                ],
              ),
            ],
          ),
        ),
      );
}