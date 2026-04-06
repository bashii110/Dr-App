import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../models/app_models.dart';
import '../../../service/api_service.dart';
import '../../../utils/config.dart';
import '../../components/custom_widget.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key, required this.doctor});
  final DoctorModel doctor;
  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime _focusedDay  = DateTime.now();
  DateTime? _selectedDay;
  int? _selectedSlot;
  final _notesCtrl = TextEditingController();
  bool _loading = false;

  // Generate slots from doctor's availability, fallback to 9-17
  List<String> get _slots {
    final from = _parseHour(widget.doctor.availableFrom) ?? 9;
    final to   = _parseHour(widget.doctor.availableTo)   ?? 17;
    return List.generate(to - from, (i) {
      final h = from + i;
      final suffix = h < 12 ? 'AM' : 'PM';
      final display = h > 12 ? h - 12 : h;
      return '$display:00 $suffix';
    });
  }

  int? _parseHour(String? t) {
    if (t == null) return null;
    return int.tryParse(t.split(':').first);
  }

  String _slotToTime(String slot) {
    // Convert "9:00 AM" → "09:00" for API
    final parts = slot.split(' ');
    final hm    = parts[0].split(':');
    int h       = int.parse(hm[0]);
    if (parts[1] == 'PM' && h != 12) h += 12;
    if (parts[1] == 'AM' && h == 12) h  = 0;
    return '${h.toString().padLeft(2, '0')}:${hm[1]}';
  }

  bool _isWeekend(DateTime d) => d.weekday == 6 || d.weekday == 7;

  Future<void> _book() async {
    if (_selectedDay == null) {
      _snack('Please select a date.');
      return;
    }
    if (_selectedSlot == null) {
      _snack('Please select a time slot.');
      return;
    }
    setState(() => _loading = true);
    try {
      final res = await ApiService.bookAppointment(
        doctorId: widget.doctor.id,
        date:     DateFormat('yyyy-MM-dd').format(_selectedDay!),
        time:     _slotToTime(_slots[_selectedSlot!]),
        notes:    _notesCtrl.text.trim(),
      );
      if (!mounted) return;
      setState(() => _loading = false);
      if (res['status'] == 201) {
        _showSuccess();
      } else {
        _snack(res['message'] as String? ?? 'Booking failed.', error: true);
      }
    } catch (_) {
      setState(() => _loading = false);
      _snack('Connection error. Please try again.', error: true);
    }
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? Config.errorColor : null,
    ));
  }

  void _showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Config.secondaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_outline,
                    size: 40, color: Config.secondaryColor),
              ),
              const SizedBox(height: 16),
              const Text('Appointment Booked!',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Config.textDark)),
              const SizedBox(height: 8),
              Text(
                'Your appointment with Dr ${widget.doctor.name} on '
                    '${DateFormat('MMM d, yyyy').format(_selectedDay!)} '
                    'at ${_slots[_selectedSlot!]} has been submitted.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Config.textMid, height: 1.5),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Done',
                onPressed: () {
                  Navigator.pop(context); // close dialog
                  Navigator.pop(context); // back to detail
                  Navigator.pop(context); // back to home
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.doctor;
    final catColors = Config.categoryColor(d.category);

    return Scaffold(
      backgroundColor: Config.bgColor,
      appBar: AppBar(
        title: const Text('Book Appointment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor mini card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Config.dividerColor),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Config.primaryColor.withOpacity(0.1),
                    child: Text(
                      (d.name ?? 'D')[0].toUpperCase(),
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                          color: Config.primaryColor),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dr ${d.name ?? 'Unknown'}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: Config.textDark)),
                        if (d.category != null)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: catColors[0],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(d.category!,
                                style: TextStyle(
                                    fontSize: 11,
                                    color: catColors[1],
                                    fontWeight: FontWeight.w600)),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Rs ${d.consultationFee.toInt()}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Config.primaryColor)),
                      const Text('per visit',
                          style:
                          TextStyle(fontSize: 11, color: Config.textMid)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Calendar ──────────────────────────────────────────────
            const Text('Select Date',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Config.textDark)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Config.dividerColor),
              ),
              child: TableCalendar(
                firstDay: DateTime.now(),
                lastDay: DateTime.now().add(const Duration(days: 90)),
                focusedDay: _focusedDay,
                selectedDayPredicate: (d) =>
                _selectedDay != null && isSameDay(d, _selectedDay),
                enabledDayPredicate: (d) => !_isWeekend(d),
                calendarFormat: CalendarFormat.month,
                availableCalendarFormats: const {CalendarFormat.month: 'Month'},
                rowHeight: 44,
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Config.primaryColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: const TextStyle(
                      color: Config.primaryColor, fontWeight: FontWeight.w700),
                  selectedDecoration: const BoxDecoration(
                    color: Config.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  weekendTextStyle:
                  const TextStyle(color: Config.textLight),
                  disabledTextStyle:
                  const TextStyle(color: Config.textLight),
                ),
                headerStyle: const HeaderStyle(
                  titleCentered: true,
                  formatButtonVisible: false,
                  titleTextStyle: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15),
                ),
                onDaySelected: (selected, focused) {
                  if (!_isWeekend(selected)) {
                    setState(() {
                      _selectedDay  = selected;
                      _focusedDay   = focused;
                      _selectedSlot = null;
                    });
                  }
                },
                onPageChanged: (f) => setState(() => _focusedDay = f),
              ),
            ),
            const SizedBox(height: 20),

            // ── Time slots ────────────────────────────────────────────
            const Text('Select Time',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Config.textDark)),
            const SizedBox(height: 10),
            if (_selectedDay == null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Config.dividerColor),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Config.textMid, size: 18),
                    SizedBox(width: 10),
                    Text('Select a date first',
                        style: TextStyle(color: Config.textMid)),
                  ],
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:  4,
                  childAspectRatio: 1.8,
                  crossAxisSpacing: 10,
                  mainAxisSpacing:  10,
                ),
                itemCount: _slots.length,
                itemBuilder: (_, i) {
                  final sel = _selectedSlot == i;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedSlot = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      decoration: BoxDecoration(
                        color: sel
                            ? Config.primaryColor
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: sel
                              ? Config.primaryColor
                              : Config.dividerColor,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _slots[i],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: sel ? Colors.white : Config.textDark,
                        ),
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 20),

            // ── Notes ─────────────────────────────────────────────────
            const Text('Notes (optional)',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Config.textDark)),
            const SizedBox(height: 10),
            TextFormField(
              controller: _notesCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Describe your symptoms or reason for visit…',
              ),
            ),
            const SizedBox(height: 28),

            // ── Booking summary ───────────────────────────────────────
            if (_selectedDay != null && _selectedSlot != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Config.primaryColor.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.event_available_outlined,
                        color: Config.primaryColor, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('EEEE, MMM d yyyy').format(_selectedDay!),
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Config.primaryColor),
                          ),
                          Text(
                            _slots[_selectedSlot!],
                            style: const TextStyle(
                                color: Config.primaryColor, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Rs ${d.consultationFee.toInt()}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Config.primaryColor,
                          fontSize: 16),
                    ),
                  ],
                ),
              ),

            PrimaryButton(
              label: 'Confirm Booking',
              loading: _loading,
              onPressed: _book,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}