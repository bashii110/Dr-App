import 'package:flutter/material.dart';
import '../../../models/app_models.dart';
import '../../../service/api_service.dart';
import '../../../utils/config.dart';
import '../../components/custom_widget.dart';
import 'booking_screen.dart';

class DoctorDetailScreen extends StatefulWidget {
  const DoctorDetailScreen({super.key, required this.doctorId});
  final int doctorId;
  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen>
    with SingleTickerProviderStateMixin {
  DoctorModel? _doctor;
  List<ReviewModel> _reviews = [];
  bool _loading = true;
  bool _isFav = false;
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabs.dispose();
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
          _doctor = DoctorModel.fromJson(futures[0]['data'] as Map<String, dynamic>);
        }
        if (futures[1]['status'] == 200) {
          final items = (futures[1]['data'] as Map<String, dynamic>)['data'] as List;
          _reviews =
              items.map((e) => ReviewModel.fromJson(e as Map<String, dynamic>)).toList();
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
      backgroundColor: Config.bgColor,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _doctor == null
          ? const EmptyState(message: 'Doctor not found.')
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    final d = _doctor!;
    final catColors = Config.categoryColor(d.category);

    return CustomScrollView(
      slivers: [
        // ── App bar ──────────────────────────────────────────────────────
        SliverAppBar(
          expandedHeight: 220,
          pinned: true,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: Icon(
                _isFav ? Icons.favorite_rounded : Icons.favorite_outline,
                color: _isFav ? Config.errorColor : null,
              ),
              onPressed: () => setState(() => _isFav = !_isFav),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: Config.primaryColor.withOpacity(0.12),
                    child: Text(
                      (d.name ?? 'D')[0].toUpperCase(),
                      style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: Config.primaryColor),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text('Dr ${d.name ?? 'Unknown'}',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Config.textDark)),
                  const SizedBox(height: 4),
                  if (d.category != null)
                    Container(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: catColors[0],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(d.category!,
                          style: TextStyle(
                              fontSize: 12,
                              color: catColors[1],
                              fontWeight: FontWeight.w600)),
                    ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Column(
            children: [
              // ── Stats row ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    _StatCard(
                        icon: Icons.star_rounded,
                        value: d.rating.toStringAsFixed(1),
                        label: 'Rating',
                        iconColor: const Color(0xFFFFA000)),
                    _StatCard(
                        icon: Icons.people_outline,
                        value: '${d.ratingCount}',
                        label: 'Reviews',
                        iconColor: Config.primaryColor),
                    _StatCard(
                        icon: Icons.work_outline,
                        value: '${d.experience ?? 0}y',
                        label: 'Experience',
                        iconColor: Config.secondaryColor),
                    _StatCard(
                        icon: Icons.payments_outlined,
                        value: 'Rs${d.consultationFee.toInt()}',
                        label: 'Fee',
                        iconColor: Config.accentColor),
                  ],
                ),
              ),

              // ── Availability ─────────────────────────────────────────
              if (d.availableFrom != null && d.availableTo != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Config.secondaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time_outlined,
                            size: 18, color: Config.secondaryColor),
                        const SizedBox(width: 10),
                        Text(
                          'Available: ${d.availableFrom} – ${d.availableTo}',
                          style: const TextStyle(
                              color: Config.secondaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 13),
                        ),
                        const Spacer(),
                        StatusBadge(status: d.status ?? 'offline'),
                      ],
                    ),
                  ),
                ),

              // ── Tabs ─────────────────────────────────────────────────
              const SizedBox(height: 16),
              TabBar(
                controller: _tabs,
                labelColor: Config.primaryColor,
                unselectedLabelColor: Config.textMid,
                indicatorColor: Config.primaryColor,
                tabs: const [Tab(text: 'About'), Tab(text: 'Reviews')],
              ),
              SizedBox(
                height: 260,
                child: TabBarView(
                  controller: _tabs,
                  children: [
                    // About tab
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        d.bioData ??
                            'No biography available for this doctor yet.',
                        style: const TextStyle(
                            fontSize: 14,
                            color: Config.textMid,
                            height: 1.6),
                      ),
                    ),
                    // Reviews tab
                    _reviews.isEmpty
                        ? const EmptyState(
                        message: 'No reviews yet.',
                        icon: Icons.rate_review_outlined)
                        : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _reviews.length,
                      itemBuilder: (_, i) =>
                          _ReviewTile(review: _reviews[i]),
                    ),
                  ],
                ),
              ),

              // ── Book button ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                child: PrimaryButton(
                  label: 'Book Appointment',
                  icon: Icons.calendar_month_outlined,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookingScreen(doctor: d),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Stat card ─────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
  });
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Config.dividerColor),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Config.textDark)),
          Text(label,
              style:
              const TextStyle(fontSize: 11, color: Config.textMid)),
        ],
      ),
    ),
  );
}

// ── Review tile ───────────────────────────────────────────────────────────

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});
  final ReviewModel review;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: Config.primaryColor.withOpacity(0.1),
          child: Text(
            (review.patientName ?? 'P')[0].toUpperCase(),
            style: const TextStyle(
                color: Config.primaryColor, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(review.patientName ?? 'Anonymous',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Config.textDark)),
                  const Spacer(),
                  ReadRatingBar(rating: review.rating, size: 14),
                ],
              ),
              if (review.comment != null && review.comment!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(review.comment!,
                      style: const TextStyle(
                          fontSize: 13, color: Config.textMid, height: 1.4)),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}