import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../components/custom_widget.dart';
import '../../provider/auth_provider.dart';

import '../../service/api_service.dart';
import '../../utils/config.dart';


class DoctorScheduleScreen extends StatefulWidget {
  const DoctorScheduleScreen({super.key});
  @override
  State<DoctorScheduleScreen> createState() => _DoctorScheduleScreenState();
}

class _DoctorScheduleScreenState extends State<DoctorScheduleScreen> {
  // Working days — defaults, loaded from profile
  final Map<String, bool> _workDays = {
    'Mon': true,
    'Tue': true,
    'Wed': true,
    'Thu': true,
    'Fri': true,
    'Sat': false,
    'Sun': false,
  };

  TimeOfDay _slotFrom     = const TimeOfDay(hour: 9,  minute: 0);
  TimeOfDay _slotTo       = const TimeOfDay(hour: 17, minute: 0);
  int       _slotDuration = 30; // minutes
  String    _status       = 'available';
  bool      _saving       = false;
  bool      _loaded       = false;

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
      final to   = profile['available_to'] as String?;
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
    );
    if (picked != null) setState(() => isFrom ? _slotFrom = picked : _slotTo = picked);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final res = await ApiService.updateDoctorProfile({
        'available_from': _fmt(_slotFrom),
        'available_to':   _fmt(_slotTo),
        'status':         _status,
      });
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['status'] == 200
              ? 'Schedule saved.'
              : 'Failed to save. Try again.'),
          backgroundColor:
          res['status'] == 200 ? Config.secondaryColor : Config.errorColor,
        ),
      );
    } catch (_) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Connection error.')));
    }
  }

  // ── Slot preview ──────────────────────────────────────────────────────────

  List<String> get _slotPreviews {
    final fromMins = _slotFrom.hour * 60 + _slotFrom.minute;
    final toMins   = _slotTo.hour * 60 + _slotTo.minute;
    final slots    = <String>[];
    for (var m = fromMins; m + _slotDuration <= toMins; m += _slotDuration) {
      final h  = m ~/ 60;
      final mi = m % 60;
      final h2  = (m + _slotDuration) ~/ 60;
      final mi2 = (m + _slotDuration) % 60;
      slots.add(
          '${_fmtTime(h, mi)} – ${_fmtTime(h2, mi2)}');
    }
    return slots;
  }

  String _fmtTime(int h, int m) {
    final suffix  = h < 12 ? 'AM' : 'PM';
    final display = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$display:${m.toString().padLeft(2, '0')} $suffix';
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final previews = _slotPreviews;

    return Scaffold(
      backgroundColor: Config.bgColor,
      appBar: AppBar(
        title: const Text('My Schedule'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Config.primaryColor))
                : const Text('Save',
                style: TextStyle(
                    color: Config.primaryColor,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Current status ─────────────────────────────────────────
            _SectionTitle('Current Status'),
            const SizedBox(height: 10),
            Row(
              children: ['available', 'busy', 'offline'].map((s) {
                final sel = _status == s;
                final color = s == 'available'
                    ? Config.secondaryColor
                    : s == 'busy'
                    ? Config.accentColor
                    : Config.textMid;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _status = s),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: sel ? color.withOpacity(0.12) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: sel ? color : Config.dividerColor,
                          width: sel ? 2 : 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            s == 'available'
                                ? Icons.check_circle_outline
                                : s == 'busy'
                                ? Icons.do_not_disturb_on_outlined
                                : Icons.offline_bolt_outlined,
                            size: 22,
                            color: sel ? color : Config.textLight,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            s[0].toUpperCase() + s.substring(1),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: sel ? color : Config.textMid,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // ── Working days ───────────────────────────────────────────
            _SectionTitle('Working Days'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Config.dividerColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _workDays.entries.map((e) {
                  final active = e.value;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _workDays[e.key] = !_workDays[e.key]!),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 40,
                      height: 48,
                      decoration: BoxDecoration(
                        color: active
                            ? Config.primaryColor
                            : Config.bgColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        e.key,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: active ? Colors.white : Config.textMid,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // ── Consultation hours ─────────────────────────────────────
            _SectionTitle('Consultation Hours'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _TimeTile(
                    label: 'Start',
                    icon: Icons.wb_sunny_outlined,
                    time: _slotFrom,
                    onTap: () => _pickTime(true),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                    width: 32,
                    height: 2,
                    color: Config.dividerColor,
                  ),
                ),
                Expanded(
                  child: _TimeTile(
                    label: 'End',
                    icon: Icons.nights_stay_outlined,
                    time: _slotTo,
                    onTap: () => _pickTime(false),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Slot duration ──────────────────────────────────────────
            _SectionTitle('Appointment Duration'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Config.dividerColor),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined,
                          size: 18, color: Config.primaryColor),
                      const SizedBox(width: 10),
                      Text('$_slotDuration minutes per slot',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Config.textDark)),
                    ],
                  ),
                  Slider(
                    value: _slotDuration.toDouble(),
                    min: 15,
                    max: 60,
                    divisions: 3,
                    label: '$_slotDuration min',
                    activeColor: Config.primaryColor,
                    onChanged: (v) =>
                        setState(() => _slotDuration = v.toInt()),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: ['15', '30', '45', '60']
                        .map((v) => Text('${v}m',
                        style: const TextStyle(
                            fontSize: 11, color: Config.textMid)))
                        .toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Slot preview ───────────────────────────────────────────
            Row(
              children: [
                _SectionTitle('Slot Preview'),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Config.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('${previews.length} slots',
                      style: const TextStyle(
                          fontSize: 11,
                          color: Config.primaryColor,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            previews.isEmpty
                ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Config.dividerColor),
              ),
              child: const Text(
                'No slots available with current settings.',
                style:
                TextStyle(color: Config.textMid, fontSize: 13),
              ),
            )
                : GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2.4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: previews.length > 12 ? 12 : previews.length,
              itemBuilder: (_, i) {
                final isLast = i == 11 && previews.length > 12;
                return Container(
                  decoration: BoxDecoration(
                    color: isLast
                        ? Config.primaryColor.withOpacity(0.06)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Config.dividerColor),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    isLast
                        ? '+${previews.length - 11} more'
                        : previews[i].split(' – ').first,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isLast
                          ? Config.primaryColor
                          : Config.textDark,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),
            PrimaryButton(
              label: 'Save Schedule',
              loading: _saving,
              onPressed: _save,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Config.textDark));
}

class _TimeTile extends StatelessWidget {
  const _TimeTile({
    required this.label,
    required this.icon,
    required this.time,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final TimeOfDay time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Config.dividerColor, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Config.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: Config.primaryColor),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: Config.textMid)),
              Text(time.format(context),
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Config.textDark)),
            ],
          ),
        ],
      ),
    ),
  );
}