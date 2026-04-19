import 'package:doctor_app/service/api_service.dart';
import 'package:flutter/material.dart';

import '../../models/app_models.dart';
import '../../utils/config.dart';
import 'doctors_details.dart';

// ── Animated floating blob (reused from login) ────────────────────────────

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
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color,
          ),
        ),
      ),
    );
  }
}

// ── Fade + Slide in animation wrapper ─────────────────────────────────────

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
          color: Color.lerp(const Color(0xFF1C2333), const Color(0xFF232B40),
              _anim.value),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

// ── Category chip ──────────────────────────────────────────────────────────

class _CategoryChipCard extends StatefulWidget {
  const _CategoryChipCard({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_CategoryChipCard> createState() => _CategoryChipCardState();
}

class _CategoryChipCardState extends State<_CategoryChipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 150),
        lowerBound: 0.93,
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
        widget.onTap();
      },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _ctrl,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(right: 14),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: widget.selected
                ? const Color(0xFF1A73E8)
                : Colors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: widget.selected
                  ? const Color(0xFF1A73E8)
                  : Colors.white.withOpacity(0.12),
              width: 1.5,
            ),
            boxShadow: widget.selected
                ? [
              BoxShadow(
                color: const Color(0xFF1A73E8).withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              )
            ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon,
                  size: 22,
                  color: widget.selected
                      ? Colors.white
                      : Colors.white.withOpacity(0.55)),
              const SizedBox(height: 6),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: widget.selected
                      ? Colors.white
                      : Colors.white.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Availability dot ───────────────────────────────────────────────────────

class _AvailabilityDot extends StatefulWidget {
  const _AvailabilityDot({required this.available});
  final bool available;

  @override
  State<_AvailabilityDot> createState() => _AvailabilityDotState();
}

class _AvailabilityDotState extends State<_AvailabilityDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 1))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.5, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.available) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text('Offline',
            style: TextStyle(
                fontSize: 10,
                color: Colors.white.withOpacity(0.35),
                fontWeight: FontWeight.w600)),
      );
    }
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFF34A853).withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: const Color(0xFF34A853).withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Opacity(
              opacity: _pulse.value,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                    color: Color(0xFF34A853), shape: BoxShape.circle),
              ),
            ),
            const SizedBox(width: 4),
            const Text('Available',
                style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF34A853),
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  HOME SCREEN
// ══════════════════════════════════════════════════════════════════════════════

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // ── Data state ─────────────────────────────────────────────────────────────
  String? _userName;
  List<String> _categories = [];
  List<DoctorModel> _doctors = [];
  List<AppointmentModel> _appointments = [];
  String? _selectedCategory;
  String _search = '';
  bool _loadingCats = true;
  bool _loadingDoctors = true;
  bool _loadingAppointments = true;

  final TextEditingController _searchCtrl = TextEditingController();

  // ── Animation ──────────────────────────────────────────────────────────────
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  static const Map<String, IconData> _catIcons = {
    'General': Icons.person_outline_rounded,
    'Cardiology': Icons.favorite_outline,
    'Respirations': Icons.air_outlined,
    'Respiratory': Icons.air_outlined,
    'Dermatology': Icons.face_outlined,
    'Gynaecology': Icons.pregnant_woman_outlined,
    'Gynecology': Icons.pregnant_woman_outlined,
    'Dental': Icons.mood_outlined,
    'Orthopaedics': Icons.accessibility_new_outlined,
    'Orthopedics': Icons.accessibility_new_outlined,
    'Neurology': Icons.psychology_outlined,
    'Paediatrics': Icons.child_care_outlined,
    'Pediatrics': Icons.child_care_outlined,
    'Psychiatry': Icons.self_improvement_outlined,
    'Ophthalmology': Icons.visibility_outlined,
  };

  IconData _iconFor(String cat) =>
      _catIcons[cat] ?? Icons.medical_services_outlined;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _fadeCtrl.forward();
    });
    _loadAll();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Data loaders ───────────────────────────────────────────────────────────

  Future<void> _loadAll() async {
    await Future.wait([
      _loadUser(),
      _loadCategories(),
      _loadDoctors(),
      _loadAppointments(),
    ]);
  }

  Future<void> _loadUser() async {
    final res = await ApiService.getMe();
    if (res['status'] == 200 && mounted) {
      final user = UserModel.fromJson(res['user']);
      setState(() => _userName = user.name);
    }
  }

  Future<void> _loadCategories() async {
    setState(() => _loadingCats = true);
    try {
      final res = await ApiService.getCategories();
      if (!mounted) return;
      if (res['status'] == 200) {
        List raw = [];
        if (res['categories'] is List) {
          raw = res['categories'];
        } else if (res['data'] is List) {
          raw = res['data'];
        } else if (res['categories']?['data'] is List) {
          raw = res['categories']['data'];
        }
        setState(() {
          _categories = raw.map((e) => e['name'].toString()).toList();
          _loadingCats = false;
        });
      } else {
        setState(() {
          _categories = [];
          _loadingCats = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingCats = false);
    }
  }

  Future<void> _loadDoctors({String? category, String? search}) async {
    if (mounted) setState(() => _loadingDoctors = true);
    try {
      final res = await ApiService.getDoctors(
        category: _selectedCategory,
        search: _search.trim().isEmpty ? null : _search.trim(),
      );
      if (!mounted) return;
      if (res['status'] == 200) {
        List raw = [];
        if (res['data'] is List) {
          raw = res['data'];
        } else if (res['data'] != null && res['data']['data'] is List) {
          raw = res['data']['data'];
        }
        setState(() {
          _doctors = raw.map((e) => DoctorModel.fromJson(e)).toList();
          _loadingDoctors = false;
        });
      } else {
        setState(() {
          _doctors = [];
          _loadingDoctors = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingDoctors = false);
    }
  }

  Future<void> _loadAppointments() async {
    setState(() => _loadingAppointments = true);
    final res = await ApiService.getMyAppointments();
    if (!mounted) return;
    if (res['status'] == 200) {
      final data = res['data'];
      final List raw = data is List ? data : (data['data'] ?? []);
      final today = DateTime.now().toString().split(' ').first;
      setState(() {
        _appointments = raw
            .map((e) => AppointmentModel.fromJson(e))
            .where((e) => e.appointmentDate == today)
            .toList();
        _loadingAppointments = false;
      });
    } else {
      if (mounted) setState(() => _loadingAppointments = false);
    }
  }

  void _onCategoryTap(String cat) {
    final next = _selectedCategory == cat ? null : cat;
    setState(() => _selectedCategory = next);
    _loadDoctors(
        category: next, search: _search.isNotEmpty ? _search : null);
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: Stack(
        children: [
          // Background blobs (same as login)
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

          // Content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: RefreshIndicator(
                onRefresh: _loadAll,
                color: const Color(0xFF1A73E8),
                backgroundColor: const Color(0xFF141829),
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: _buildHeader()),
                    SliverToBoxAdapter(child: _buildSearchBar()),
                    if (_appointments.isNotEmpty)
                      SliverToBoxAdapter(child: _buildAppointmentsSection()),
                    SliverToBoxAdapter(child: _buildCategorySection()),
                    SliverToBoxAdapter(child: _buildDoctorsSection()),
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    final firstName = (_userName ?? 'Guest').split(' ').first;
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
                    '$firstName 👋',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            // Avatar with gradient border
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
                    firstName.isNotEmpty ? firstName[0].toUpperCase() : 'G',
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

  // ── Search bar ─────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return _FadeSlideIn(
      delay: const Duration(milliseconds: 200),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.5),
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Icon(Icons.search, color: Colors.white.withOpacity(0.4), size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  style: const TextStyle(color: Colors.black, fontSize: 14),
                  onChanged: (v) {
                    _search = v;
                    _loadDoctors();
                  },
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Search doctors, specialties…',
                    hintStyle: TextStyle(
                        color: Colors.grey.withOpacity(0.7), fontSize: 14),
                  ),
                ),
              ),
              if (_search.isNotEmpty)
                IconButton(
                  icon:
                  Icon(Icons.clear, color: Colors.white.withOpacity(0.4), size: 18),
                  onPressed: () {
                    _searchCtrl.clear();
                    _search = '';
                    _loadDoctors();
                    setState(() {});
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Today's appointments banner ────────────────────────────────────────────

  Widget _buildAppointmentsSection() {
    return _FadeSlideIn(
      delay: const Duration(milliseconds: 280),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionLabel(label: "Today's Appointments"),
            const SizedBox(height: 12),
            ..._appointments.map((e) => _AppointmentBanner(appointment: e)),
          ],
        ),
      ),
    );
  }

  // ── Category section ───────────────────────────────────────────────────────

  Widget _buildCategorySection() {
    return _FadeSlideIn(
      delay: const Duration(milliseconds: 350),
      child: Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SectionLabel(label: 'Specialties'),
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
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 88,
              child: _loadingCats
                  ? ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: 5,
                itemBuilder: (_, __) => Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: _ShimmerCard(width: 82, height: 80)),
              )
                  : _categories.isEmpty
                  ? const SizedBox.shrink()
                  : ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                physics: const BouncingScrollPhysics(),
                itemCount: _categories.length,
                itemBuilder: (_, i) => _FadeSlideIn(
                  delay:
                  Duration(milliseconds: 350 + i * 60),
                  direction: const Offset(0.3, 0),
                  child: _CategoryChipCard(
                    icon: _iconFor(_categories[i]),
                    label: _categories[i],
                    selected:
                    _selectedCategory == _categories[i],
                    onTap: () =>
                        _onCategoryTap(_categories[i]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Doctors section ────────────────────────────────────────────────────────

  Widget _buildDoctorsSection() {
    return _FadeSlideIn(
      delay: const Duration(milliseconds: 420),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _SectionLabel(
                    label: _selectedCategory != null
                        ? '$_selectedCategory Doctors'
                        : 'Top Doctors'),
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
            if (_loadingDoctors)
              ...List.generate(
                  3, (_) => const _ShimmerCard(height: 110))
            else if (_doctors.isEmpty)
              _buildEmptyDoctors()
            else
              ..._doctors.asMap().entries.map(
                    (entry) => _FadeSlideIn(
                  delay:
                  Duration(milliseconds: 420 + entry.key * 80),
                  child: _DoctorCard(
                    doctor: entry.value,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            DoctorDetailScreen(doctorId: entry.value.id),
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

  Widget _buildEmptyDoctors() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded,
              size: 48, color: Colors.white.withOpacity(0.25)),
          const SizedBox(height: 12),
          Text(
            'No doctors found',
            style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 15,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Try a different search or category',
            style: TextStyle(
                color: Colors.white.withOpacity(0.3), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  Sub-widgets
// ══════════════════════════════════════════════════════════════════════════════

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.white));
  }
}

// ── Today appointment banner ───────────────────────────────────────────────

class _AppointmentBanner extends StatelessWidget {
  const _AppointmentBanner({required this.appointment});
  final AppointmentModel appointment;

  @override
  Widget build(BuildContext context) {
    final name = appointment.doctor?.name ?? 'Doctor';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A73E8),
            const Color(0xFF1A73E8).withBlue(220),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A73E8).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                name[0].toUpperCase(),
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Dr $name',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15)),
                const SizedBox(height: 3),
                Text(
                  '${appointment.doctor?.category ?? ''} • ${appointment.appointmentTime}',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.75), fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              appointment.status[0].toUpperCase() +
                  appointment.status.substring(1),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Doctor card ────────────────────────────────────────────────────────────

class _DoctorCard extends StatefulWidget {
  const _DoctorCard({required this.doctor, required this.onTap});
  final DoctorModel doctor;
  final VoidCallback onTap;

  @override
  State<_DoctorCard> createState() => _DoctorCardState();
}

class _DoctorCardState extends State<_DoctorCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 120),
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
    final d = widget.doctor;
    final name = d.name ?? 'Doctor';

    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) {
        _ctrl.forward();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _ctrl,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withOpacity(0.10), width: 1.5),
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF1A73E8).withOpacity(0.8),
                      const Color(0xFF00CEC9).withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text(
                    name[0].toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dr $name',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 15)),
                    const SizedBox(height: 4),
                    if (d.category != null)
                      Text(d.category!,
                          style: const TextStyle(
                              color: Color(0xFF1A73E8),
                              fontWeight: FontWeight.w700,
                              fontSize: 13)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.work_outline,
                            size: 12,
                            color: Colors.white.withOpacity(0.4)),
                        const SizedBox(width: 3),
                        Text(
                          '${d.experience ?? 0} yrs',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.45),
                              fontSize: 12),
                        ),
                        const SizedBox(width: 10),
                        Icon(Icons.payments_outlined,
                            size: 12,
                            color: Colors.white.withOpacity(0.4)),
                        const SizedBox(width: 3),
                        Text(
                          'Rs ${d.consultationFee.toInt()}',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.45),
                              fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Rating + availability
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 14, color: Color(0xFFFFA000)),
                      const SizedBox(width: 3),
                      Text(
                        d.rating.toStringAsFixed(1),
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _AvailabilityDot(available: d.status == 'available'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}