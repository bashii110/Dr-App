import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../components/custom_widget.dart';
import '../../models/app_models.dart';
import '../../service/api_service.dart';

class PatientHistoryScreen extends StatefulWidget {
  const PatientHistoryScreen({super.key});
  @override
  State<PatientHistoryScreen> createState() => _PatientHistoryScreenState();
}

class _PatientHistoryScreenState extends State<PatientHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  List<AppointmentModel> _completed = [];
  List<AppointmentModel> _cancelled = [];
  bool _loading = true;

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
    setState(() => _loading = true);
    try {
      final res = await ApiService.getMyAppointments();
      if (res['status'] == 200) {
        final items = ((res['data'] as Map)['data'] as List)
            .map((e) => AppointmentModel.fromJson(e as Map<String, dynamic>))
            .toList();
        setState(() {
          _completed = items.where((a) => a.isCompleted).toList();
          _cancelled = items.where((a) => a.isCancelled).toList();
        });
      }
    } catch (_) {}
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E1A),
        elevation: 0,
        title: const Text('Medical History',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.10)),
            ),
            child: TabBar(
              controller: _tabs,
              indicatorColor: const Color(0xFF1D9E75),
              indicatorWeight: 2,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.4),
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 13),
              indicatorPadding:
              const EdgeInsets.symmetric(horizontal: 8),
              tabs: const [Tab(text: 'Completed'), Tab(text: 'Cancelled')],
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: _DarkShimmerList())
          : TabBarView(
        controller: _tabs,
        children: [
          _HistoryList(
            items: _completed,
            emptyMessage: 'No completed appointments yet.',
            showReview: true,
            onRefresh: _load,
          ),
          _HistoryList(
            items: _cancelled,
            emptyMessage: 'No cancelled appointments.',
            onRefresh: _load,
          ),
        ],
      ),
    );
  }
}

// ── History list ──────────────────────────────────────────────────────────

class _HistoryList extends StatelessWidget {
  const _HistoryList({
    required this.items,
    required this.emptyMessage,
    this.showReview = false,
    required this.onRefresh,
  });
  final List<AppointmentModel> items;
  final String emptyMessage;
  final bool showReview;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_outlined,
                size: 56, color: Colors.white.withOpacity(0.15)),
            const SizedBox(height: 16),
            Text(emptyMessage,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.35),
                    fontSize: 15,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: const Color(0xFF1A73E8),
      backgroundColor: const Color(0xFF141829),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (_, i) =>
            _HistoryCard(appointment: items[i], showReview: showReview),
      ),
    );
  }
}

// ── History card ──────────────────────────────────────────────────────────

class _HistoryCard extends StatefulWidget {
  const _HistoryCard({required this.appointment, this.showReview = false});
  final AppointmentModel appointment;
  final bool showReview;

  @override
  State<_HistoryCard> createState() => _HistoryCardState();
}

class _HistoryCardState extends State<_HistoryCard> {
  bool _reviewed = false;

  void _openReviewSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF141829),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _ReviewSheet(
        appointment: widget.appointment,
        onSubmitted: () => setState(() => _reviewed = true),
      ),
    );
  }

  static const _statusConfig = {
    'completed': {
      'color': Color(0xFF1D9E75),
      'bg': Color(0xFF0A1F18),
      'label': 'Completed'
    },
    'cancelled': {
      'color': Color(0xFFE24B4A),
      'bg': Color(0xFF2A0F0F),
      'label': 'Cancelled'
    },
  };

  @override
  Widget build(BuildContext context) {
    final a = widget.appointment;
    final doctorName = a.doctor?.name ?? 'Doctor';
    final category = a.doctor?.category ?? '';
    final cfg = _statusConfig[a.status] ?? _statusConfig['completed']!;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.09)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
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
                    child: Text(doctorName[0].toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 20)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dr $doctorName',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15)),
                      if (category.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(category,
                            style: const TextStyle(
                                color: Color(0xFF1A73E8),
                                fontWeight: FontWeight.w600,
                                fontSize: 12)),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: cfg['bg'] as Color,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color:
                        (cfg['color'] as Color).withOpacity(0.35)),
                  ),
                  child: Text(cfg['label'] as String,
                      style: TextStyle(
                          color: cfg['color'] as Color,
                          fontWeight: FontWeight.w700,
                          fontSize: 11)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(height: 0.5, color: Colors.white.withOpacity(0.08)),
            const SizedBox(height: 14),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _chip(Icons.calendar_today_outlined, a.appointmentDate),
                _chip(Icons.access_time_outlined, a.appointmentTime),
                if (a.consultationFee > 0)
                  _chip(Icons.payments_outlined,
                      'Rs ${a.consultationFee.toInt()}'),
              ],
            ),
            if (a.notes != null && a.notes!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.notes_outlined,
                        size: 13, color: Colors.white.withOpacity(0.35)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(a.notes!,
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.45),
                              fontStyle: FontStyle.italic)),
                    ),
                  ],
                ),
              ),
            ],
            if (widget.showReview && a.isCompleted) ...[
              const SizedBox(height: 14),
              _reviewed
                  ? Row(
                children: [
                  Icon(Icons.check_circle_outline,
                      size: 15,
                      color: const Color(0xFF1D9E75)),
                  const SizedBox(width: 6),
                  const Text('Review submitted',
                      style: TextStyle(
                          color: Color(0xFF1D9E75),
                          fontWeight: FontWeight.w600,
                          fontSize: 13)),
                ],
              )
                  : GestureDetector(
                onTap: _openReviewSheet,
                child: Container(
                  width: double.infinity,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A73E8).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color:
                        const Color(0xFF1A73E8).withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.rate_review_outlined,
                          size: 15,
                          color: const Color(0xFF378ADD)),
                      const SizedBox(width: 6),
                      const Text('Write a Review',
                          style: TextStyle(
                              color: Color(0xFF378ADD),
                              fontWeight: FontWeight.w600,
                              fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String text) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 13, color: Colors.white.withOpacity(0.35)),
      const SizedBox(width: 4),
      Text(text,
          style: TextStyle(
              fontSize: 12, color: Colors.white.withOpacity(0.5))),
    ],
  );
}

// ── Review sheet ──────────────────────────────────────────────────────────

class _ReviewSheet extends StatefulWidget {
  const _ReviewSheet(
      {required this.appointment, required this.onSubmitted});
  final AppointmentModel appointment;
  final VoidCallback onSubmitted;

  @override
  State<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<_ReviewSheet> {
  double _rating = 0;
  final _commentCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  static const _labels = ['', 'Poor', 'Fair', 'Good', 'Very Good', 'Excellent'];

  Future<void> _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a star rating.'),
          backgroundColor: const Color(0xFF1C2333),
          behavior: SnackBarBehavior.floating,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    final doctorId = widget.appointment.doctor?.id;
    if (doctorId == null) return;
    setState(() => _loading = true);
    try {
      final res = await ApiService.submitReview(
        doctorId: doctorId,
        rating: _rating,
        comment: _commentCtrl.text.trim(),
      );
      if (!mounted) return;
      setState(() => _loading = false);
      if (res['status'] == 201) {
        Navigator.pop(context);
        widget.onSubmitted();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Review submitted. Thank you!'),
            backgroundColor: const Color(0xFF0A1F18),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctorName = widget.appointment.doctor?.name ?? 'Doctor';
    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A73E8), Color(0xFF00CEC9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Text(doctorName[0].toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 24)),
            ),
          ),
          const SizedBox(height: 14),
          Text('Dr $doctorName',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('How was your experience?',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.45), fontSize: 14)),
          const SizedBox(height: 24),
          RatingBar.builder(
            initialRating: _rating,
            minRating: 1,
            itemCount: 5,
            itemSize: 44,
            glow: false,
            itemBuilder: (_, __) =>
            const Icon(Icons.star_rounded, color: Color(0xFFEF9F27)),
            onRatingUpdate: (r) => setState(() => _rating = r),
          ),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              _rating > 0 ? _labels[_rating.toInt()] : '',
              key: ValueKey(_rating),
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFEF9F27)),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
              border:
              Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: TextField(
              controller: _commentCtrl,
              maxLines: 3,
              style: const TextStyle(color: Colors.black, fontSize: 14),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(14),
                hintText:
                'Tell others about your experience (optional)…',
                hintStyle: TextStyle(
                    color: Colors.grey.withOpacity(0.7), fontSize: 14),
              ),
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _loading ? null : _submit,
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A73E8), Color(0xFF1565C0)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: _loading
                    ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                    : const Text('Submit Review',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shimmer ───────────────────────────────────────────────────────────────

class _DarkShimmerList extends StatefulWidget {
  const _DarkShimmerList({this.count = 4});
  final int count;

  @override
  State<_DarkShimmerList> createState() => _DarkShimmerListState();
}

class _DarkShimmerListState extends State<_DarkShimmerList>
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
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.count,
      itemBuilder: (_, __) => AnimatedBuilder(
        animation: _anim,
        builder: (_, __) => Container(
          height: 130,
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Color.lerp(const Color(0xFF1C2333),
                const Color(0xFF232B40), _anim.value),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}