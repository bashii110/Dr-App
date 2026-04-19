import 'package:flutter/material.dart';
import '../../../models/app_models.dart';
import '../../../service/api_service.dart';
import '../../../utils/config.dart';
import '../../components/custom_widget.dart';
import 'booking_screen.dart';

// ── Animated floating blob (same as home screen) ──────────────────────────

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

// ── Fade + Slide in animation wrapper (same as home screen) ───────────────

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

// ── Availability dot (same as home screen) ────────────────────────────────

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
    _ctrl =
    AnimationController(vsync: this, duration: const Duration(seconds: 1))
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text('Offline',
            style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.35),
                fontWeight: FontWeight.w600)),
      );
    }
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF34A853).withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: const Color(0xFF34A853).withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Opacity(
              opacity: _pulse.value,
              child: Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                    color: Color(0xFF34A853), shape: BoxShape.circle),
              ),
            ),
            const SizedBox(width: 5),
            const Text('Available',
                style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF34A853),
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  DOCTOR DETAIL SCREEN
// ══════════════════════════════════════════════════════════════════════════════

class DoctorDetailScreen extends StatefulWidget {
  const DoctorDetailScreen({super.key, required this.doctorId});
  final int doctorId;

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen>
    with TickerProviderStateMixin {
  DoctorModel? _doctor;
  List<ReviewModel> _reviews = [];
  bool _loading = true;
  bool _isFav = false;
  late TabController _tabs;

  // Animation
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);

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
    _tabs.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final futures = await Future.wait([
        ApiService.getDoctorDetail(widget.doctorId),
        ApiService.getDoctorReviews(widget.doctorId),
      ]);
      setState(() {
        if (futures[0]['status'] == 200) {
          _doctor =
              DoctorModel.fromJson(futures[0]['data'] as Map<String, dynamic>);
        }
        if (futures[1]['status'] == 200) {
          final items =
          (futures[1]['data'] as Map<String, dynamic>)['data'] as List;
          _reviews = items
              .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: Stack(
        children: [
          // ── Background blobs (same positions as home screen) ──────────
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
            size: 250,
            duration: const Duration(seconds: 6),
            delay: const Duration(milliseconds: 600),
            offsetX: 160,
            offsetY: 200,
          ),
          _AnimatedBlob(
            color: const Color(0xFF00CEC9).withOpacity(0.06),
            size: 200,
            duration: const Duration(seconds: 4),
            delay: const Duration(seconds: 1),
            offsetX: -30,
            offsetY: 500,
          ),

          // ── Main content ───────────────────────────────────────────────
          _loading
              ? const Center(
              child: CircularProgressIndicator(
                  color: Color(0xFF1A73E8)))
              : _doctor == null
              ? _buildNotFound()
              : FadeTransition(
            opacity: _fadeAnim,
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildNotFound() {
    return SafeArea(
      child: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off_outlined,
                      size: 64, color: Colors.white.withOpacity(0.25)),
                  const SizedBox(height: 16),
                  Text('Doctor not found.',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 16)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Top bar (back + favourite) ─────────────────────────────────────────────

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _GlassButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context),
          ),
          const Spacer(),
          _GlassButton(
            icon: _isFav ? Icons.favorite_rounded : Icons.favorite_outline,
            iconColor: _isFav ? const Color(0xFFFF6B6B) : null,
            onTap: () => setState(() => _isFav = !_isFav),
          ),
        ],
      ),
    );
  }

  // ── Full content ───────────────────────────────────────────────────────────

  Widget _buildContent() {
    final d = _doctor!;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── Sticky header ──────────────────────────────────────────────
        SliverAppBar(
          expandedHeight: 260,
          pinned: true,
          backgroundColor: const Color(0xFF0A0E1A),
          automaticallyImplyLeading: false,
          flexibleSpace: FlexibleSpaceBar(
            background: _buildHeroSection(d),
          ),
          // Custom leading/actions overlay
          leading: Padding(
            padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
            child: _GlassButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: () => Navigator.pop(context),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
              child: _GlassButton(
                icon: _isFav
                    ? Icons.favorite_rounded
                    : Icons.favorite_outline,
                iconColor:
                _isFav ? const Color(0xFFFF6B6B) : null,
                onTap: () => setState(() => _isFav = !_isFav),
              ),
            ),
          ],
        ),

        // ── Stats ──────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: _FadeSlideIn(
            delay: const Duration(milliseconds: 200),
            child: _buildStats(d),
          ),
        ),

        // ── Availability ───────────────────────────────────────────────
        if (d.availableFrom != null && d.availableTo != null)
          SliverToBoxAdapter(
            child: _FadeSlideIn(
              delay: const Duration(milliseconds: 280),
              child: _buildAvailability(d),
            ),
          ),

        // ── Tabs ───────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: _FadeSlideIn(
            delay: const Duration(milliseconds: 340),
            child: _buildTabs(d),
          ),
        ),

        // ── Book button ────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: _FadeSlideIn(
            delay: const Duration(milliseconds: 420),
            child: _buildBookButton(d),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  // ── Hero section ───────────────────────────────────────────────────────────

  Widget _buildHeroSection(DoctorModel d) {
    return Container(
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Gradient avatar
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              gradient: const LinearGradient(
                colors: [Color(0xFF1A73E8), Color(0xFF00CEC9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: const Color(0xFF141829),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(
                child: Text(
                  (d.name ?? 'D')[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1A73E8),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Dr ${d.name ?? 'Unknown'}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          if (d.category != null)
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF1A73E8).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: const Color(0xFF1A73E8).withOpacity(0.4),
                    width: 1),
              ),
              child: Text(
                d.category!,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF1A73E8),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ── Stats row ──────────────────────────────────────────────────────────────

  Widget _buildStats(DoctorModel d) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          _DarkStatCard(
            icon: Icons.star_rounded,
            value: d.rating.toStringAsFixed(1),
            label: 'Rating',
            iconColor: const Color(0xFFFFA000),
            glowColor: const Color(0xFFFFA000),
          ),
          _DarkStatCard(
            icon: Icons.people_outline,
            value: '${d.ratingCount}',
            label: 'Reviews',
            iconColor: const Color(0xFF1A73E8),
            glowColor: const Color(0xFF1A73E8),
          ),
          _DarkStatCard(
            icon: Icons.work_outline,
            value: '${d.experience ?? 0}y',
            label: 'Exp.',
            iconColor: const Color(0xFF34A853),
            glowColor: const Color(0xFF34A853),
          ),
          _DarkStatCard(
            icon: Icons.payments_outlined,
            value: 'Rs${d.consultationFee.toInt()}',
            label: 'Fee',
            iconColor: const Color(0xFF00CEC9),
            glowColor: const Color(0xFF00CEC9),
          ),
        ],
      ),
    );
  }

  // ── Availability row ───────────────────────────────────────────────────────

  Widget _buildAvailability(DoctorModel d) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.10), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF34A853).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.access_time_outlined,
                  size: 18, color: Color(0xFF34A853)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Available Hours',
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.45),
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(
                    '${d.availableFrom} – ${d.availableTo}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14),
                  ),
                ],
              ),
            ),
            _AvailabilityDot(available: d.status == 'available'),
          ],
        ),
      ),
    );
  }

  // ── Tabs: About + Reviews ──────────────────────────────────────────────────

  Widget _buildTabs(DoctorModel d) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          // Tab bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: Colors.white.withOpacity(0.10), width: 1.5),
              ),
              child: TabBar(
                controller: _tabs,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A73E8), Color(0xFF00CEC9)],
                  ),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.all(4),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white54,
                labelStyle: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 14),
                tabs: const [Tab(text: 'About'), Tab(text: 'Reviews')],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Tab content (fixed height)
          SizedBox(
            height: 260,
            child: TabBarView(
              controller: _tabs,
              children: [
                // About tab
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.09), width: 1.5),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        d.bioData ??
                            'No biography available for this doctor yet.',
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.7),
                            height: 1.7),
                      ),
                    ),
                  ),
                ),
                // Reviews tab
                _reviews.isEmpty
                    ? _buildEmptyReviews()
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _reviews.length,
                  itemBuilder: (_, i) =>
                      _DarkReviewTile(review: _reviews[i]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyReviews() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.rate_review_outlined,
              size: 48, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 12),
          Text('No reviews yet.',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.4), fontSize: 15)),
        ],
      ),
    );
  }

  // ── Book button ────────────────────────────────────────────────────────────

  Widget _buildBookButton(DoctorModel d) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => BookingScreen(doctor: d)),
        ),
        child: Container(
          height: 58,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [Color(0xFF1A73E8), Color(0xFF00CEC9)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1A73E8).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_month_outlined,
                  color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text(
                'Book Appointment',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  Sub-widgets
// ══════════════════════════════════════════════════════════════════════════════

// ── Glass icon button ──────────────────────────────────────────────────────

class _GlassButton extends StatelessWidget {
  const _GlassButton(
      {required this.icon, required this.onTap, this.iconColor});
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: Colors.white.withOpacity(0.15), width: 1.5),
      ),
      child: Icon(icon,
          size: 20,
          color: iconColor ?? Colors.white.withOpacity(0.9)),
    ),
  );
}

// ── Dark stat card ─────────────────────────────────────────────────────────

class _DarkStatCard extends StatelessWidget {
  const _DarkStatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
    required this.glowColor,
  });
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;
  final Color glowColor;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: Colors.white.withOpacity(0.10), width: 1.5),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: Colors.white)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.45))),
        ],
      ),
    ),
  );
}

// ── Dark review tile ───────────────────────────────────────────────────────

class _DarkReviewTile extends StatelessWidget {
  const _DarkReviewTile({required this.review});
  final ReviewModel review;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.05),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
          color: Colors.white.withOpacity(0.09), width: 1.5),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A73E8), Color(0xFF00CEC9)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              (review.patientName ?? 'P')[0].toUpperCase(),
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    review.patientName ?? 'Anonymous',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Colors.white),
                  ),
                  const Spacer(),
                  // Star rating
                  Row(
                    children: List.generate(5, (i) {
                      return Icon(
                        i < review.rating.round()
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 14,
                        color: const Color(0xFFFFA000),
                      );
                    }),
                  ),
                ],
              ),
              if (review.comment != null &&
                  review.comment!.isNotEmpty) ...[
                const SizedBox(height: 5),
                Text(
                  review.comment!,
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.55),
                      height: 1.5),
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}