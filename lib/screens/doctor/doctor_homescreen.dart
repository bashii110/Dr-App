import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../components/custom_widget.dart';
import '../../models/app_models.dart';
import '../../provider/auth_provider.dart';
import '../../service/api_service.dart';
import '../../utils/config.dart';

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
          decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color),
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
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
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
  const _ShimmerCard({this.height = 100, this.width = double.infinity});
  final double height;
  final double width;

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
        width: widget.width,
        height: widget.height,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Color.lerp(
              const Color(0xFF1C2333), const Color(0xFF232B40), _anim.value),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  DOCTOR HOME SCREEN
// ══════════════════════════════════════════════════════════════════════════════

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});
  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen>
    with TickerProviderStateMixin {
  List<AppointmentModel> _today = [];
  List<AppointmentModel> _upcoming = [];
  Map<String, int> _stats = {
    'total': 0,
    'pending': 0,
    'completed': 0,
    'cancelled': 0,
  };
  bool _loading = true;


  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _fadeCtrl.forward();
    });
    _load();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ApiService.getDoctorAppointments();
      if (res['status'] == 200) {
        final items = ((res['data'] as Map)['data'] as List)
            .map((e) => AppointmentModel.fromJson(e as Map<String, dynamic>))
            .toList();
        final todayStr = _todayStr();
        setState(() {
          _today = items.where((a) => a.appointmentDate == todayStr).toList();
          _upcoming = items
              .where((a) =>
          a.appointmentDate.compareTo(todayStr) > 0 &&
              (a.isPending || a.isConfirmed))
              .take(5)
              .toList();
          _stats = {
            'total': items.length,
            'pending': items.where((a) => a.isPending).length,
            'completed': items.where((a) => a.isCompleted).length,
            'cancelled': items.where((a) => a.isCancelled).length,
          };
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  String _todayStr() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  Future<void> _changeStatus(int id, String status) async {
    final res = await ApiService.updateAppointmentStatus(id, status);
    if (!mounted) return;
    if (res['status'] == 200) {
      _load();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Appointment $status.'),
          backgroundColor: const Color(0xFF1A73E8),
          behavior: SnackBarBehavior.floating,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final name = (user?.name ?? '').split(' ').first;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: Stack(
        children: [
          // Background blobs
          _AnimatedBlob(
            color: const Color(0xFF1A73E8).withOpacity(0.12),
            size: 320,
            duration: const Duration(seconds: 5),
            delay: Duration.zero,
            offsetX: -100,
            offsetY: -80,
          ),
          _AnimatedBlob(
            color: const Color(0xFF34A853).withOpacity(0.08),
            size: 260,
            duration: const Duration(seconds: 6),
            delay: const Duration(milliseconds: 700),
            offsetX: 200,
            offsetY: 180,
          ),
          _AnimatedBlob(
            color: const Color(0xFF6C5CE7).withOpacity(0.07),
            size: 220,
            duration: const Duration(seconds: 4),
            delay: const Duration(seconds: 1),
            offsetX: 80,
            offsetY: 600,
          ),
          _AnimatedBlob(
            color: const Color(0xFF00CEC9).withOpacity(0.06),
            size: 180,
            duration: const Duration(seconds: 7),
            delay: const Duration(milliseconds: 400),
            offsetX: -40,
            offsetY: 400,
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: RefreshIndicator(
                onRefresh: _load,
                color: const Color(0xFF1A73E8),
                backgroundColor: const Color(0xFF141829),
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                        child: _buildHeader(name)),
                    SliverToBoxAdapter(
                        child: _buildStatsGrid()),
                    SliverToBoxAdapter(
                        child: _buildTodaySection()),
                    SliverToBoxAdapter(
                        child: _buildUpcomingSection()),
                    const SliverToBoxAdapter(
                        child: SizedBox(height: 100)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String name) {
    return _FadeSlideIn(
      delay: const Duration(milliseconds: 100),
      direction: const Offset(0, -0.2),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _greeting,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dr $name 👨‍⚕️',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Doctor Dashboard',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.4),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A73E8), Color(0xFF00CEC9)],
                ),
              ),
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFF141829),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'D',
                    style: const TextStyle(
                      color: Color(0xFF1A73E8),
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return _FadeSlideIn(
      delay: const Duration(milliseconds: 200),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: _loading
            ? const _ShimmerCard(height: 160)
            : GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.8,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _StatTile(
              label: 'Total',
              value: '${_stats['total']}',
              icon: Icons.event_note_outlined,
              gradientColors: const [
                Color(0xFF1A73E8),
                Color(0xFF00CEC9)
              ],
            ),
            _StatTile(
              label: 'Pending',
              value: '${_stats['pending']}',
              icon: Icons.hourglass_top_outlined,
              gradientColors: const [
                Color(0xFFFFA000),
                Color(0xFFFF6B35)
              ],
            ),
            _StatTile(
              label: 'Completed',
              value: '${_stats['completed']}',
              icon: Icons.check_circle_outline,
              gradientColors: const [
                Color(0xFF34A853),
                Color(0xFF00CEC9)
              ],
            ),
            _StatTile(
              label: 'Cancelled',
              value: '${_stats['cancelled']}',
              icon: Icons.cancel_outlined,
              gradientColors: const [
                Color(0xFFEA4335),
                Color(0xFFFF6B35)
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaySection() {
    return _FadeSlideIn(
      delay: const Duration(milliseconds: 300),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const _SectionLabel(label: "Today's Appointments"),
                if (_today.isNotEmpty)
                  TextButton(
                    onPressed: () {},
                    child: const Text('See all',
                        style: TextStyle(
                            color: Color(0xFF00CEC9),
                            fontWeight: FontWeight.w700,
                            fontSize: 13)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (_loading)
              ...List.generate(2, (_) => const _ShimmerCard(height: 90))
            else if (_today.isEmpty)
              _buildEmptyState(
                  'No appointments today', Icons.today_outlined)
            else
              ..._today.asMap().entries.map(
                    (entry) => _FadeSlideIn(
                  delay:
                  Duration(milliseconds: 300 + entry.key * 70),
                  child: _AppointmentCard(
                    appointment: entry.value,
                    isDoctor: true,
                    onStatusChange: (s) =>
                        _changeStatus(entry.value.id, s),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingSection() {
    return _FadeSlideIn(
      delay: const Duration(milliseconds: 400),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionLabel(label: 'Upcoming'),
            const SizedBox(height: 12),
            if (_loading)
              ...List.generate(2, (_) => const _ShimmerCard(height: 90))
            else if (_upcoming.isEmpty)
              _buildEmptyState(
                  'No upcoming appointments', Icons.calendar_month_outlined)
            else
              ..._upcoming.asMap().entries.map(
                    (entry) => _FadeSlideIn(
                  delay:
                  Duration(milliseconds: 400 + entry.key * 70),
                  child: _AppointmentCard(
                    appointment: entry.value,
                    isDoctor: true,
                    onStatusChange: (s) =>
                        _changeStatus(entry.value.id, s),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 28, color: Colors.white.withOpacity(0.25)),
          const SizedBox(width: 14),
          Text(
            message,
            style: TextStyle(
                color: Colors.white.withOpacity(0.45),
                fontSize: 14,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

// ── Section label ──────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white));
  }
}

// ── Stat tile ──────────────────────────────────────────────────────────────

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.gradientColors,
  });
  final String label;
  final String value;
  final IconData icon;
  final List<Color> gradientColors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.10), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient:
              LinearGradient(colors: gradientColors),
              borderRadius: BorderRadius.circular(10),
            ),
            child:
            Icon(icon, size: 20, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
              Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.5),
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Appointment card ───────────────────────────────────────────────────────

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({
    required this.appointment,
    required this.isDoctor,
    this.onStatusChange,
  });
  final AppointmentModel appointment;
  final bool isDoctor;
  final void Function(String)? onStatusChange;

  Color get _statusColor {
    switch (appointment.status.toLowerCase()) {
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
    final name = isDoctor
        ? (appointment.patient?['name'] as String? ?? 'Patient')
        : (appointment.doctor?.name ?? 'Doctor');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: Colors.white.withOpacity(0.10), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1A73E8).withOpacity(0.8),
                  const Color(0xFF00CEC9).withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                name[0].toUpperCase(),
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
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
                  isDoctor ? name : 'Dr $name',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 11,
                        color: Colors.white.withOpacity(0.4)),
                    const SizedBox(width: 4),
                    Text(
                      appointment.appointmentDate,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.45),
                          fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.access_time_outlined,
                        size: 11,
                        color: Colors.white.withOpacity(0.4)),
                    const SizedBox(width: 4),
                    Text(
                      appointment.appointmentTime,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.45),
                          fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: _statusColor.withOpacity(0.3), width: 1),
                ),
                child: Text(
                  appointment.status[0].toUpperCase() +
                      appointment.status.substring(1),
                  style: TextStyle(
                      color: _statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700),
                ),
              ),
              if (isDoctor &&
                  onStatusChange != null &&
                  appointment.isPending) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    _ActionBtn(
                      label: '✓',
                      color: const Color(0xFF34A853),
                      onTap: () => onStatusChange!('confirmed'),
                    ),
                    const SizedBox(width: 6),
                    _ActionBtn(
                      label: '✕',
                      color: const Color(0xFFEA4335),
                      onTap: () => onStatusChange!('cancelled'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn(
      {required this.label, required this.color, required this.onTap});
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Center(
          child: Text(label,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 12)),
        ),
      ),
    );
  }
}