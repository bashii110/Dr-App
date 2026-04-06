import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../components/custom_widget.dart';
import '../../models/app_models.dart';
import '../../service/api_service.dart';
import '../../utils/config.dart';


class PatientHistoryScreen extends StatefulWidget {
  const PatientHistoryScreen({super.key});
  @override
  State<PatientHistoryScreen> createState() => _PatientHistoryScreenState();
}

class _PatientHistoryScreenState extends State<PatientHistoryScreen> {
  List<AppointmentModel> _completed  = [];
  List<AppointmentModel> _cancelled  = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Config.bgColor,
        appBar: AppBar(
          title: const Text('Medical History'),
          bottom: const TabBar(
            labelColor: Config.primaryColor,
            unselectedLabelColor: Config.textMid,
            indicatorColor: Config.primaryColor,
            tabs: [
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: _loading
            ? const Padding(
            padding: EdgeInsets.all(20), child: ShimmerList())
            : TabBarView(
          children: [
            _AppointmentList(
              items: _completed,
              emptyMessage: 'No completed appointments yet.',
              showReview: true,
              onRefresh: _load,
            ),
            _AppointmentList(
              items: _cancelled,
              emptyMessage: 'No cancelled appointments.',
              onRefresh: _load,
            ),
          ],
        ),
      ),
    );
  }
}

// ── List widget ───────────────────────────────────────────────────────────

class _AppointmentList extends StatelessWidget {
  const _AppointmentList({
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
      return EmptyState(
        message: emptyMessage,
        icon: Icons.history_outlined,
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (_, i) {
          final appt = items[i];
          return _HistoryCard(
            appointment: appt,
            showReview: showReview,
          );
        },
      ),
    );
  }
}

// ── History card with review CTA ──────────────────────────────────────────

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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _ReviewSheet(
        appointment: widget.appointment,
        onSubmitted: () => setState(() => _reviewed = true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.appointment;
    final doctorName = a.doctor?.name ?? 'Doctor';
    final category   = a.doctor?.category ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Config.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Config.primaryColor.withOpacity(0.1),
                  child: Text(
                    doctorName[0].toUpperCase(),
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Config.primaryColor,
                        fontSize: 18),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dr $doctorName',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: Config.textDark)),
                      if (category.isNotEmpty)
                        Text(category,
                            style: const TextStyle(
                                fontSize: 12, color: Config.textMid)),
                    ],
                  ),
                ),
                StatusBadge(status: a.status),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Date / time / fee row
            Wrap(
              spacing: 16,
              runSpacing: 6,
              children: [
                _chip(Icons.calendar_today_outlined, a.appointmentDate),
                _chip(Icons.access_time_outlined,    a.appointmentTime),
                if (a.consultationFee > 0)
                  _chip(Icons.payments_outlined,
                      'Rs ${a.consultationFee.toInt()}'),
              ],
            ),

            if (a.notes != null && a.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Config.bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.notes_outlined,
                        size: 14, color: Config.textMid),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(a.notes!,
                          style: const TextStyle(
                              fontSize: 12,
                              color: Config.textMid,
                              fontStyle: FontStyle.italic)),
                    ),
                  ],
                ),
              ),
            ],

            // Review button — only for completed appointments
            if (widget.showReview && a.isCompleted) ...[
              const SizedBox(height: 12),
              _reviewed
                  ? Row(
                children: const [
                  Icon(Icons.check_circle_outline,
                      size: 16, color: Config.secondaryColor),
                  SizedBox(width: 6),
                  Text('Review submitted',
                      style: TextStyle(
                          color: Config.secondaryColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ],
              )
                  : SizedBox(
                width: double.infinity,
                height: 38,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.rate_review_outlined, size: 16),
                  label: const Text('Write a Review'),
                  onPressed: _openReviewSheet,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Config.primaryColor,
                    side: const BorderSide(color: Config.primaryColor),
                    padding: EdgeInsets.zero,
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13),
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
      Icon(icon, size: 13, color: Config.textMid),
      const SizedBox(width: 4),
      Text(text,
          style: const TextStyle(fontSize: 12, color: Config.textMid)),
    ],
  );
}

// ── Review bottom sheet ───────────────────────────────────────────────────

class _ReviewSheet extends StatefulWidget {
  const _ReviewSheet({
    required this.appointment,
    required this.onSubmitted,
  });
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

  Future<void> _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a star rating.')),
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
          const SnackBar(
            content: Text('Review submitted. Thank you!'),
            backgroundColor: Config.secondaryColor,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] as String? ?? 'Submission failed.'),
            backgroundColor: Config.errorColor,
          ),
        );
      }
    } catch (_) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connection error.')),
      );
    }
  }

  static const _labels = [
    '', 'Poor', 'Fair', 'Good', 'Very Good', 'Excellent'
  ];

  @override
  Widget build(BuildContext context) {
    final doctorName = widget.appointment.doctor?.name ?? 'Doctor';

    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Config.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Doctor avatar
          CircleAvatar(
            radius: 32,
            backgroundColor: Config.primaryColor.withOpacity(0.1),
            child: Text(
              doctorName[0].toUpperCase(),
              style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                  color: Config.primaryColor),
            ),
          ),
          const SizedBox(height: 12),
          Text('Dr $doctorName',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Config.textDark)),
          const SizedBox(height: 4),
          const Text('How was your experience?',
              style: TextStyle(color: Config.textMid, fontSize: 14)),
          const SizedBox(height: 24),

          // Star rating
          RatingBar.builder(
            initialRating: _rating,
            minRating: 1,
            itemCount: 5,
            itemSize: 44,
            glow: false,
            itemBuilder: (_, __) =>
            const Icon(Icons.star_rounded, color: Color(0xFFFFA000)),
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
                  color: Color(0xFFFFA000)),
            ),
          ),
          const SizedBox(height: 20),

          // Comment
          TextField(
            controller: _commentCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText:
              'Tell others about your experience (optional)…',
            ),
          ),
          const SizedBox(height: 20),

          PrimaryButton(
            label: 'Submit Review',
            loading: _loading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}