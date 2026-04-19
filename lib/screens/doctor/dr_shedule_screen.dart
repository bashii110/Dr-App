import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/auth_provider.dart';
import '../../service/api_service.dart';

const _bg = Color(0xFF0A0E1A);
const _card = Color(0xFF141829);
const _accent = Color(0xFF1A73E8);
const _accentTeal = Color(0xFF00CEC9);

class DoctorScheduleScreen extends StatefulWidget {
  const DoctorScheduleScreen({super.key});
  @override
  State<DoctorScheduleScreen> createState() => _DoctorScheduleScreenState();
}

class _DoctorScheduleScreenState extends State<DoctorScheduleScreen> {
  final Map<String, bool> _workDays = {
    'Mon': true, 'Tue': true, 'Wed': true, 'Thu': true,
    'Fri': true, 'Sat': false, 'Sun': false,
  };
  TimeOfDay _slotFrom = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _slotTo = const TimeOfDay(hour: 17, minute: 0);
  int _slotDuration = 30;
  String _status = 'available';
  bool _saving = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadFromProfile();
  }

  void _loadFromProfile() {
    final profile = context.read<AuthProvider>().user?.profile;
    if (profile != null) {
      _status = profile['status'] as String? ?? 'available';
      final from = profile['available_from'] as String?;
      final to = profile['available_to'] as String?;
      if (from != null) {
        final p = from.split(':');
        _slotFrom = TimeOfDay(hour: int.parse(p[0]), minute: int.parse(p[1]));
      }
      if (to != null) {
        final p = to.split(':');
        _slotTo = TimeOfDay(hour: int.parse(p[0]), minute: int.parse(p[1]));
      }
    }
    setState(() => _loaded = true);
  }

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickTime(bool isFrom) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isFrom ? _slotFrom : _slotTo,
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(primary: _accent, onSurface: Colors.white)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => isFrom ? _slotFrom = picked : _slotTo = picked);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final res = await ApiService.updateDoctorProfile({
        'available_from': _fmt(_slotFrom),
        'available_to': _fmt(_slotTo),
        'status': _status,
      });
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(res['status'] == 200 ? 'Schedule saved.' : 'Failed to save.',
            style: const TextStyle(color: Colors.white)),
        backgroundColor: res['status'] == 200 ? const Color(0xFF34A853) : const Color(0xFFD32F2F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    } catch (_) {
      setState(() => _saving = false);
    }
  }

  List<String> get _slotPreviews {
    final fromMins = _slotFrom.hour * 60 + _slotFrom.minute;
    final toMins = _slotTo.hour * 60 + _slotTo.minute;
    final slots = <String>[];
    for (var m = fromMins; m + _slotDuration <= toMins; m += _slotDuration) {
      slots.add('${_fmtTime(m ~/ 60, m % 60)} – ${_fmtTime((m + _slotDuration) ~/ 60, (m + _slotDuration) % 60)}');
    }
    return slots;
  }

  String _fmtTime(int h, int m) {
    final suffix = h < 12 ? 'AM' : 'PM';
    final d = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$d:${m.toString().padLeft(2, '0')} $suffix';
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const Scaffold(backgroundColor: _bg, body: Center(child: CircularProgressIndicator(color: _accent)));
    final previews = _slotPreviews;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _card,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('My Schedule', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: _accent))
                : const Text('Save', style: TextStyle(color: _accentTeal, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Current Status'),
            const SizedBox(height: 10),
            Row(
              children: ['available', 'busy', 'offline'].map((s) {
                final sel = _status == s;
                final color = s == 'available' ? const Color(0xFF34A853) : s == 'busy' ? const Color(0xFFFFA000) : Colors.white38;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _status = s),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: sel ? color.withOpacity(0.12) : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: sel ? color : Colors.white.withOpacity(0.1), width: sel ? 1.5 : 1),
                      ),
                      child: Column(
                        children: [
                          Icon(
                              s == 'available' ? Icons.check_circle_outline : s == 'busy' ? Icons.do_not_disturb_on_outlined : Icons.offline_bolt_outlined,
                              size: 22, color: sel ? color : Colors.white24),
                          const SizedBox(height: 4),
                          Text(s[0].toUpperCase() + s.substring(1),
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: sel ? color : Colors.white38)),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            _label('Working Days'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _workDays.entries.map((e) {
                  final active = e.value;
                  return GestureDetector(
                    onTap: () => setState(() => _workDays[e.key] = !e.value),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 40,
                      height: 48,
                      decoration: BoxDecoration(
                        color: active ? _accent : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(e.key,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: active ? Colors.white : Colors.white24)),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            _label('Consultation Hours'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _timeTile('Start', Icons.wb_sunny_outlined, _slotFrom, () => _pickTime(true))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Container(width: 18, height: 1.5, color: Colors.white.withOpacity(0.15)),
                ),
                Expanded(child: _timeTile('End', Icons.nights_stay_outlined, _slotTo, () => _pickTime(false))),
              ],
            ),
            const SizedBox(height: 24),
            _label('Appointment Duration'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 18, color: _accent),
                      const SizedBox(width: 10),
                      Text('$_slotDuration minutes per slot',
                          style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
                    ],
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: _accent,
                      inactiveTrackColor: Colors.white12,
                      thumbColor: _accentTeal,
                      overlayColor: _accent.withOpacity(0.15),
                      valueIndicatorColor: _accent,
                    ),
                    child: Slider(
                      value: _slotDuration.toDouble(),
                      min: 15, max: 60, divisions: 3,
                      label: '$_slotDuration min',
                      onChanged: (v) => setState(() => _slotDuration = v.toInt()),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: ['15', '30', '45', '60']
                        .map((v) => Text('${v}m', style: const TextStyle(fontSize: 11, color: Colors.white38)))
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _label('Slot Preview'),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                      color: _accent.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                  child: Text('${previews.length} slots',
                      style: const TextStyle(fontSize: 11, color: _accent, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            previews.isEmpty
                ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.07))),
              child: const Text('No slots available with current settings.',
                  style: TextStyle(color: Colors.white38, fontSize: 13)),
            )
                : GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, childAspectRatio: 2.4, crossAxisSpacing: 8, mainAxisSpacing: 8),
              itemCount: previews.length > 12 ? 12 : previews.length,
              itemBuilder: (_, i) {
                final isLast = i == 11 && previews.length > 12;
                return Container(
                  decoration: BoxDecoration(
                    color: isLast ? _accent.withOpacity(0.08) : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    isLast ? '+${previews.length - 11} more' : previews[i].split(' – ').first,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isLast ? _accent : Colors.white60),
                  ),
                );
              },
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
                    elevation: 0),
                child: _saving
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : const Text('Save Schedule',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white));

  Widget _timeTile(String label, IconData icon, TimeOfDay time, VoidCallback onTap) =>
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: _accent.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 16, color: _accent),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 11, color: Colors.white38)),
                  Text(time.format(context),
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.white)),
                ],
              ),
            ],
          ),
        ),
      );
}