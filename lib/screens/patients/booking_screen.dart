import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../models/app_models.dart';
import '../../../service/api_service.dart';

// ── Animated floating blob ─────────────────────────────────────────────────

class _AnimatedBlob extends StatefulWidget {
  const _AnimatedBlob({
    required this.color,
    required this.size,
    required this.duration,
    required this.delay,
    required this.offsetX,
    required this.offsetY,
  });
  final Color color;
  final double size;
  final Duration duration;
  final Duration delay;
  final double offsetX;
  final double offsetY;

  @override
  State<_AnimatedBlob> createState() => _AnimatedBlobState();
}

class _AnimatedBlobState extends State<_AnimatedBlob>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();
    _controller =
    AnimationController(vsync: this, duration: widget.duration)
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) _controller.reverse();
        if (s == AnimationStatus.dismissed) _controller.forward();
      });
    _floatAnim = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatAnim,
      builder: (_, __) => Transform.translate(
        offset:
        Offset(widget.offsetX, widget.offsetY + _floatAnim.value),
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration:
          BoxDecoration(shape: BoxShape.circle, color: widget.color),
        ),
      ),
    );
  }
}

// ── Fade + Slide in ────────────────────────────────────────────────────────

class _FadeSlideIn extends StatefulWidget {
  const _FadeSlideIn({
    required this.child,
    required this.delay,
    this.direction = const Offset(0, 0.25),
  });
  final Widget child;
  final Duration delay;
  final Offset direction;

  @override
  State<_FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<_FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: widget.direction, end: Offset.zero)
        .animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child));
}

// ══════════════════════════════════════════════════════════════════════════════
//  BOOKING SCREEN
// ══════════════════════════════════════════════════════════════════════════════

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key, required this.doctor});
  final DoctorModel doctor;
  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen>
    with SingleTickerProviderStateMixin {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  int? _selectedSlot;
  final _notesCtrl = TextEditingController();
  bool _loading = false;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    Future.delayed(const Duration(milliseconds: 80),
            () => mounted ? _fadeCtrl.forward() : null);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  List<String> get _slots {
    final from = _parseHour(widget.doctor.availableFrom) ?? 9;
    final to = _parseHour(widget.doctor.availableTo) ?? 17;
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
    final parts = slot.split(' ');
    final hm = parts[0].split(':');
    int h = int.parse(hm[0]);
    if (parts[1] == 'PM' && h != 12) h += 12;
    if (parts[1] == 'AM' && h == 12) h = 0;
    return '${h.toString().padLeft(2, '0')}:${hm[1]}';
  }

  bool _isWeekend(DateTime d) =>
      d.weekday == 6 || d.weekday == 7;

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
        date: DateFormat('yyyy-MM-dd').format(_selectedDay!),
        time: _slotToTime(_slots[_selectedSlot!]),
        notes: _notesCtrl.text.trim(),
      );
      if (!mounted) return;
      setState(() => _loading = false);
      if (res['status'] == 201) {
        _showSuccess();
      } else {
        _snack(res['message'] as String? ?? 'Booking failed.',
            error: true);
      }
    } catch (_) {
      setState(() => _loading = false);
      _snack('Connection error. Please try again.', error: true);
    }
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: const TextStyle(color: Colors.white)),
      backgroundColor: error
          ? const Color(0xFFEA4335)
          : const Color(0xFF1A73E8),
      behavior: SnackBarBehavior.floating,
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  void _showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF141829),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
              color: Colors.white.withOpacity(0.12), width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF34A853), Color(0xFF00CEC9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF34A853).withOpacity(0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: const Icon(Icons.check_rounded,
                    size: 42, color: Colors.white),
              ),
              const SizedBox(height: 20),
              const Text(
                'Appointment Booked!',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white),
              ),
              const SizedBox(height: 10),
              Text(
                'Your appointment with Dr ${widget.doctor.name} on '
                    '${DateFormat('MMM d, yyyy').format(_selectedDay!)} '
                    'at ${_slots[_selectedSlot!]} has been submitted.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    height: 1.6,
                    fontSize: 14),
              ),
              const SizedBox(height: 28),
              _PrimaryButton(
                label: 'Done',
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.doctor;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: Stack(
        children: [
          // Blobs
          _AnimatedBlob(
            color: const Color(0xFF1A73E8).withOpacity(0.10),
            size: 280,
            duration: const Duration(seconds: 5),
            delay: Duration.zero,
            offsetX: -80,
            offsetY: -60,
          ),
          _AnimatedBlob(
            color: const Color(0xFF34A853).withOpacity(0.07),
            size: 220,
            duration: const Duration(seconds: 6),
            delay: const Duration(milliseconds: 500),
            offsetX: 200,
            offsetY: 400,
          ),
          _AnimatedBlob(
            color: const Color(0xFF6C5CE7).withOpacity(0.06),
            size: 180,
            duration: const Duration(seconds: 7),
            delay: const Duration(milliseconds: 300),
            offsetX: -30,
            offsetY: 650,
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                children: [
                  // AppBar area
                  _FadeSlideIn(
                    delay: const Duration(milliseconds: 80),
                    direction: const Offset(0, -0.2),
                    child: Padding(
                      padding:
                      const EdgeInsets.fromLTRB(8, 8, 24, 0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 20,
                                color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Expanded(
                            child: Text(
                              'Book Appointment',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Scrollable body
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Doctor mini card
                          _FadeSlideIn(
                            delay: const Duration(milliseconds: 150),
                            child: _buildDoctorCard(d),
                          ),
                          const SizedBox(height: 24),

                          // Calendar
                          _FadeSlideIn(
                            delay: const Duration(milliseconds: 220),
                            child: _buildSectionLabel('Select Date'),
                          ),
                          const SizedBox(height: 10),
                          _FadeSlideIn(
                            delay: const Duration(milliseconds: 260),
                            child: _buildCalendar(),
                          ),
                          const SizedBox(height: 24),

                          // Time slots
                          _FadeSlideIn(
                            delay: const Duration(milliseconds: 330),
                            child: _buildSectionLabel('Select Time'),
                          ),
                          const SizedBox(height: 10),
                          _FadeSlideIn(
                            delay: const Duration(milliseconds: 370),
                            child: _buildTimeSlots(),
                          ),
                          const SizedBox(height: 24),

                          // Notes
                          _FadeSlideIn(
                            delay: const Duration(milliseconds: 420),
                            child: _buildSectionLabel(
                                'Notes (optional)'),
                          ),
                          const SizedBox(height: 10),
                          _FadeSlideIn(
                            delay: const Duration(milliseconds: 450),
                            child: _buildNotesField(),
                          ),
                          const SizedBox(height: 24),

                          // Summary
                          if (_selectedDay != null &&
                              _selectedSlot != null)
                            _FadeSlideIn(
                              delay: const Duration(milliseconds: 480),
                              child: _buildSummary(d),
                            ),

                          // Book button
                          _FadeSlideIn(
                            delay: const Duration(milliseconds: 500),
                            child: _PrimaryButton(
                              label: 'Confirm Booking',
                              loading: _loading,
                              onPressed: _book,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.white),
    );
  }

  Widget _buildDoctorCard(DoctorModel d) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: Colors.white.withOpacity(0.12), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A73E8), Color(0xFF00CEC9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                (d.name ?? 'D')[0].toUpperCase(),
                style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dr ${d.name ?? 'Unknown'}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Colors.white),
                ),
                if (d.category != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A73E8).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: const Color(0xFF1A73E8).withOpacity(0.3)),
                    ),
                    child: Text(
                      d.category!,
                      style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF1A73E8),
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Rs ${d.consultationFee.toInt()}',
                style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF00CEC9),
                    fontSize: 16),
              ),
              Text(
                'per visit',
                style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.4)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: Colors.white.withOpacity(0.12), width: 1.5),
      ),
      child: TableCalendar(
        firstDay: DateTime.now(),
        lastDay: DateTime.now().add(const Duration(days: 90)),
        focusedDay: _focusedDay,
        selectedDayPredicate: (d) =>
        _selectedDay != null && isSameDay(d, _selectedDay),
        enabledDayPredicate: (d) => !_isWeekend(d),
        calendarFormat: CalendarFormat.month,
        availableCalendarFormats: const {
          CalendarFormat.month: 'Month'
        },
        rowHeight: 44,
        calendarStyle: CalendarStyle(
          defaultTextStyle:
          const TextStyle(color: Colors.white, fontSize: 13),
          weekendTextStyle: TextStyle(
              color: Colors.white.withOpacity(0.2), fontSize: 13),
          disabledTextStyle: TextStyle(
              color: Colors.white.withOpacity(0.2), fontSize: 13),
          outsideTextStyle: TextStyle(
              color: Colors.white.withOpacity(0.15), fontSize: 13),
          todayDecoration: BoxDecoration(
            color: const Color(0xFF1A73E8).withOpacity(0.25),
            shape: BoxShape.circle,
          ),
          todayTextStyle: const TextStyle(
              color: Color(0xFF1A73E8),
              fontWeight: FontWeight.w700),
          selectedDecoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A73E8), Color(0xFF00CEC9)],
            ),
            shape: BoxShape.circle,
          ),
          selectedTextStyle: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w800),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
              fontWeight: FontWeight.w600),
          weekendStyle: TextStyle(
              color: Colors.white.withOpacity(0.2),
              fontSize: 12,
              fontWeight: FontWeight.w600),
        ),
        headerStyle: HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
          titleTextStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: Colors.white),
          leftChevronIcon: Icon(Icons.chevron_left,
              color: Colors.white.withOpacity(0.6)),
          rightChevronIcon: Icon(Icons.chevron_right,
              color: Colors.white.withOpacity(0.6)),
        ),
        onDaySelected: (selected, focused) {
          if (!_isWeekend(selected)) {
            setState(() {
              _selectedDay = selected;
              _focusedDay = focused;
              _selectedSlot = null;
            });
          }
        },
        onPageChanged: (f) => setState(() => _focusedDay = f),
      ),
    );
  }

  Widget _buildTimeSlots() {
    if (_selectedDay == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: Colors.white.withOpacity(0.08), width: 1.5),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline,
                color: Colors.white.withOpacity(0.3), size: 18),
            const SizedBox(width: 10),
            Text('Select a date first',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 13)),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.8,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _slots.length,
      itemBuilder: (_, i) {
        final sel = _selectedSlot == i;
        return GestureDetector(
          onTap: () => setState(() => _selectedSlot = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              gradient: sel
                  ? const LinearGradient(
                colors: [Color(0xFF1A73E8), Color(0xFF00CEC9)],
              )
                  : null,
              color: sel ? null : Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: sel
                    ? Colors.transparent
                    : Colors.white.withOpacity(0.12),
                width: 1.5,
              ),
              boxShadow: sel
                  ? [
                BoxShadow(
                  color:
                  const Color(0xFF1A73E8).withOpacity(0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
                  : [],
            ),
            alignment: Alignment.center,
            child: Text(
              _slots[i],
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: sel
                    ? Colors.white
                    : Colors.white.withOpacity(0.6),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotesField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: Colors.white.withOpacity(0.12), width: 1.5),
      ),
      child: TextField(
        controller: _notesCtrl,
        maxLines: 3,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          hintText: 'Describe your symptoms or reason for visit…',
          hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.3), fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildSummary(DoctorModel d) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A73E8).withOpacity(0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: const Color(0xFF1A73E8).withOpacity(0.25), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF1A73E8).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.event_available_outlined,
                color: Color(0xFF1A73E8), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE, MMM d yyyy').format(_selectedDay!),
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontSize: 13),
                ),
                Text(
                  _slots[_selectedSlot!],
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            'Rs ${d.consultationFee.toInt()}',
            style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFF00CEC9),
                fontSize: 16),
          ),
        ],
      ),
    );
  }
}

// ── Primary button ─────────────────────────────────────────────────────────

class _PrimaryButton extends StatefulWidget {
  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    this.loading = false,
  });
  final String label;
  final VoidCallback onPressed;
  final bool loading;

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 100),
        lowerBound: 0.96,
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
    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) {
        _ctrl.forward();
        if (!widget.loading) widget.onPressed();
      },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _ctrl,
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A73E8), Color(0xFF00CEC9)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1A73E8).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Center(
            child: widget.loading
                ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                  strokeWidth: 2.5, color: Colors.white),
            )
                : Text(
              widget.label,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}