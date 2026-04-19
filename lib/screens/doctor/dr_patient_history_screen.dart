import 'package:flutter/material.dart';
import '../../models/app_models.dart';
import '../../service/api_service.dart';

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
        offset: Offset(widget.offsetX, widget.offsetY + _floatAnim.value),
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

// ── Shimmer card ───────────────────────────────────────────────────────────

class _ShimmerCard extends StatefulWidget {
  const _ShimmerCard({this.height = 80});
  final double height;

  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        height: widget.height,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Color.lerp(const Color(0xFF1C2333),
              const Color(0xFF232B40), _anim.value),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  DOCTOR PATIENT HISTORY SCREEN
// ══════════════════════════════════════════════════════════════════════════════

class DoctorPatientHistoryScreen extends StatefulWidget {
  const DoctorPatientHistoryScreen({super.key});
  @override
  State<DoctorPatientHistoryScreen> createState() =>
      _DoctorPatientHistoryScreenState();
}

class _DoctorPatientHistoryScreenState
    extends State<DoctorPatientHistoryScreen>
    with SingleTickerProviderStateMixin {
  Map<int, List<AppointmentModel>> _grouped = {};
  Map<int, String> _patientNames = {};
  bool _loading = true;
  String _search = '';

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    Future.delayed(const Duration(milliseconds: 100),
            () => mounted ? _fadeCtrl.forward() : null);
    _load();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ApiService.getDoctorAppointments();
      if (res['status'] == 200) {
        final items = ((res['data'] as Map)['data'] as List)
            .map(
                (e) => AppointmentModel.fromJson(e as Map<String, dynamic>))
            .toList();

        final grouped = <int, List<AppointmentModel>>{};
        final names = <int, String>{};

        for (final a in items) {
          grouped.putIfAbsent(a.patientId, () => []).add(a);
          if (a.patient != null) {
            names[a.patientId] =
                a.patient!['name'] as String? ?? 'Patient';
          }
        }

        setState(() {
          _grouped = grouped;
          _patientNames = names;
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  List<int> get _filteredIds {
    if (_search.isEmpty) return _grouped.keys.toList();
    return _grouped.keys
        .where((id) => (_patientNames[id] ?? '')
        .toLowerCase()
        .contains(_search.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: Stack(
        children: [
          // Blobs
          _AnimatedBlob(
            color: const Color(0xFF1A73E8).withOpacity(0.10),
            size: 300,
            duration: const Duration(seconds: 5),
            delay: Duration.zero,
            offsetX: -80,
            offsetY: -60,
          ),
          _AnimatedBlob(
            color: const Color(0xFF6C5CE7).withOpacity(0.07),
            size: 240,
            duration: const Duration(seconds: 6),
            delay: const Duration(milliseconds: 600),
            offsetX: 200,
            offsetY: 300,
          ),
          _AnimatedBlob(
            color: const Color(0xFF00CEC9).withOpacity(0.06),
            size: 180,
            duration: const Duration(seconds: 7),
            delay: const Duration(milliseconds: 300),
            offsetX: -30,
            offsetY: 550,
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _FadeSlideIn(
                    delay: const Duration(milliseconds: 80),
                    direction: const Offset(0, -0.2),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 24, 0),
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
                              'Patient History',
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Search bar
                  _FadeSlideIn(
                    delay: const Duration(milliseconds: 160),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.12),
                              width: 1.5),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 14),
                            Icon(Icons.search,
                                color: Colors.white.withOpacity(0.4),
                                size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _searchCtrl,
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 14),
                                onChanged: (v) =>
                                    setState(() => _search = v),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Search patients…',
                                  hintStyle: TextStyle(
                                      color: Colors.grey.withOpacity(0.7),
                                      fontSize: 14),
                                ),
                              ),
                            ),
                            if (_search.isNotEmpty)
                              IconButton(
                                icon: Icon(Icons.clear,
                                    color: Colors.white.withOpacity(0.4),
                                    size: 18),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  setState(() => _search = '');
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // List
                  Expanded(
                    child: _loading
                        ? Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: List.generate(
                            6,
                                (_) =>
                            const _ShimmerCard(height: 80)),
                      ),
                    )
                        : _grouped.isEmpty
                        ? Center(
                      child: Column(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline,
                              size: 52,
                              color: Colors.white
                                  .withOpacity(0.2)),
                          const SizedBox(height: 14),
                          Text(
                            'No patient history yet.',
                            style: TextStyle(
                                color: Colors.white
                                    .withOpacity(0.4),
                                fontSize: 15,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    )
                        : RefreshIndicator(
                      onRefresh: _load,
                      color: const Color(0xFF1A73E8),
                      backgroundColor:
                      const Color(0xFF141829),
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                            20, 8, 20, 100),
                        physics:
                        const BouncingScrollPhysics(),
                        itemCount: _filteredIds.length,
                        itemBuilder: (_, i) {
                          final patId = _filteredIds[i];
                          final appts = _grouped[patId]!;
                          final name =
                              _patientNames[patId] ??
                                  'Patient';
                          return _FadeSlideIn(
                            delay: Duration(
                                milliseconds:
                                200 + i * 50),
                            child: _PatientHistoryCard(
                              patientName: name,
                              appointments: appts,
                            ),
                          );
                        },
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
}

// ── Patient history card ───────────────────────────────────────────────────

class _PatientHistoryCard extends StatefulWidget {
  const _PatientHistoryCard({
    required this.patientName,
    required this.appointments,
  });
  final String patientName;
  final List<AppointmentModel> appointments;

  @override
  State<_PatientHistoryCard> createState() => _PatientHistoryCardState();
}

class _PatientHistoryCardState extends State<_PatientHistoryCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _ctrl;
  late Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    _expandAnim =
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _ctrl.forward() : _ctrl.reverse();
  }

  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'confirmed':
        return const Color(0xFF34A853);
      case 'completed':
        return const Color(0xFF00CEC9);
      case 'cancelled':
        return const Color(0xFFEA4335);
      default:
        return const Color(0xFFFFA000);
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.appointments.length;
    final completed =
        widget.appointments.where((a) => a.isCompleted).length;
    final lastVisit = widget.appointments.isNotEmpty
        ? widget.appointments
        .map((a) => a.appointmentDate)
        .reduce((a, b) => a.compareTo(b) > 0 ? a : b)
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: Colors.white.withOpacity(0.10), width: 1.5),
      ),
      child: Column(
        children: [
          // Header row
          GestureDetector(
            onTap: _toggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF6C5CE7),
                          Color(0xFF00CEC9)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        widget.patientName[0].toUpperCase(),
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.patientName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _Pill(
                              text: '$total visits',
                              bg: const Color(0xFF1A73E8)
                                  .withOpacity(0.15),
                              fg: const Color(0xFF1A73E8),
                            ),
                            const SizedBox(width: 6),
                            _Pill(
                              text: '$completed done',
                              bg: const Color(0xFF34A853)
                                  .withOpacity(0.15),
                              fg: const Color(0xFF34A853),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (lastVisit != null)
                        Text(
                          lastVisit,
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.4)),
                        ),
                      const SizedBox(height: 6),
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 250),
                        child: Icon(Icons.keyboard_arrow_down_rounded,
                            color: Colors.white.withOpacity(0.4)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Expanded section
          SizeTransition(
            sizeFactor: _expandAnim,
            child: Column(
              children: [
                Divider(height: 1, color: Colors.white.withOpacity(0.08)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  child: Column(
                    children: widget.appointments.map((a) {
                      final sc = _statusColor(a.status);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.07)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                          Icons.calendar_today_outlined,
                                          size: 11,
                                          color: Colors.white
                                              .withOpacity(0.4)),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${a.appointmentDate}  ·  ${a.appointmentTime}',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  if (a.notes != null &&
                                      a.notes!.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      a.notes!,
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.white
                                              .withOpacity(0.45),
                                          fontStyle: FontStyle.italic),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: sc.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: sc.withOpacity(0.3)),
                              ),
                              child: Text(
                                a.status[0].toUpperCase() +
                                    a.status.substring(1),
                                style: TextStyle(
                                    fontSize: 10,
                                    color: sc,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.bg, required this.fg});
  final String text;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration:
      BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(text,
          style: TextStyle(
              fontSize: 11, color: fg, fontWeight: FontWeight.w600)),
    );
  }
}