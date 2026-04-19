import 'package:flutter/material.dart';
import '../../../models/app_models.dart';
import '../../../service/api_service.dart';
import '../../components/custom_widget.dart';

class PatientAppointmentsScreen extends StatefulWidget {
  const PatientAppointmentsScreen({super.key});
  @override
  State<PatientAppointmentsScreen> createState() =>
      _PatientAppointmentsScreenState();
}

class _PatientAppointmentsScreenState extends State<PatientAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  final _statuses = ['pending', 'confirmed', 'completed', 'cancelled'];
  final _labels = ['Pending', 'Confirmed', 'Completed', 'Cancelled'];
  List<AppointmentModel> _all = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: _statuses.length, vsync: this);
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
        final List items = (res['data'] as Map)['data'] as List;
        _all = items
            .map((e) => AppointmentModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('ERROR loading appointments: $e');
    }
    setState(() => _loading = false);
  }

  Future<void> _cancel(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF141829),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFE24B4A).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.cancel_outlined,
                    color: Color(0xFFE24B4A), size: 28),
              ),
              const SizedBox(height: 16),
              const Text('Cancel appointment',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('Are you sure you want to cancel?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.55), fontSize: 14)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, false),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.12)),
                        ),
                        child: Center(
                            child: Text('No',
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontWeight: FontWeight.w600))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, true),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE24B4A).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: const Color(0xFFE24B4A).withOpacity(0.4)),
                        ),
                        child: const Center(
                            child: Text('Yes, cancel',
                                style: TextStyle(
                                    color: Color(0xFFE24B4A),
                                    fontWeight: FontWeight.w600))),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed != true) return;
    final res = await ApiService.cancelAppointment(id);
    if (!mounted) return;
    if (res['status'] == 200) {
      _load();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Appointment cancelled.'),
          backgroundColor: const Color(0xFF1C2333),
          behavior: SnackBarBehavior.floating,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  static const _statusColors = {
    'pending': [Color(0xFFEF9F27), Color(0xFFFAEEDA)],
    'confirmed': [Color(0xFF1A73E8), Color(0xFFE6F1FB)],
    'completed': [Color(0xFF1D9E75), Color(0xFFE1F5EE)],
    'cancelled': [Color(0xFFE24B4A), Color(0xFFFCEBEB)],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E1A),
        elevation: 0,
        title: const Text('My Appointments',
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
              isScrollable: true,
              indicatorColor: const Color(0xFF1A73E8),
              indicatorWeight: 2,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.4),
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 13),
              unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500, fontSize: 13),
              indicatorPadding:
              const EdgeInsets.symmetric(horizontal: 8),
              tabs: _labels.map((l) => Tab(text: l)).toList(),
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: _DarkShimmerList())
          : TabBarView(
        controller: _tabs,
        children: _statuses.map((s) {
          final list = _all.where((a) => a.status == s).toList();
          if (list.isEmpty) {
            return _DarkEmptyState(
              message: 'No $s appointments',
              icon: Icons.calendar_today_outlined,
            );
          }
          return RefreshIndicator(
            onRefresh: _load,
            color: const Color(0xFF1A73E8),
            backgroundColor: const Color(0xFF141829),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (_, i) => _DarkAppointmentCard(
                appointment: list[i],
                onCancel:
                (list[i].isPending || list[i].isConfirmed)
                    ? () => _cancel(list[i].id)
                    : null,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Dark appointment card ─────────────────────────────────────────────────

class _DarkAppointmentCard extends StatefulWidget {
  const _DarkAppointmentCard(
      {required this.appointment, this.onCancel});
  final AppointmentModel appointment;
  final VoidCallback? onCancel;

  @override
  State<_DarkAppointmentCard> createState() =>
      _DarkAppointmentCardState();
}

class _DarkAppointmentCardState extends State<_DarkAppointmentCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 120),
        lowerBound: 0.97,
        upperBound: 1.0,
        value: 1.0);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  static const _statusConfig = {
    'pending': {
      'color': Color(0xFFEF9F27),
      'bg': Color(0xFF2C2010),
      'label': 'Pending'
    },
    'confirmed': {
      'color': Color(0xFF378ADD),
      'bg': Color(0xFF0D1E30),
      'label': 'Confirmed'
    },
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
    final cfg = _statusConfig[a.status] ??
        _statusConfig['pending']!;

    return ScaleTransition(
      scale: _ctrl,
      child: GestureDetector(
        onTapDown: (_) => _ctrl.reverse(),
        onTapUp: (_) => _ctrl.forward(),
        onTapCancel: () => _ctrl.forward(),
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border:
            Border.all(color: Colors.white.withOpacity(0.09), width: 1),
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
                        child: Text(
                          doctorName[0].toUpperCase(),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: (cfg['bg'] as Color),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: (cfg['color'] as Color).withOpacity(0.35)),
                      ),
                      child: Text(
                        cfg['label'] as String,
                        style: TextStyle(
                            color: cfg['color'] as Color,
                            fontWeight: FontWeight.w700,
                            fontSize: 11),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  height: 0.5,
                  color: Colors.white.withOpacity(0.08),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _infoChip(
                        Icons.calendar_today_outlined, a.appointmentDate),
                    const SizedBox(width: 16),
                    _infoChip(Icons.access_time_outlined, a.appointmentTime),
                    if (a.consultationFee > 0) ...[
                      const SizedBox(width: 16),
                      _infoChip(Icons.payments_outlined,
                          'Rs ${a.consultationFee.toInt()}'),
                    ],
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
                      children: [
                        Icon(Icons.notes_outlined,
                            size: 13,
                            color: Colors.white.withOpacity(0.35)),
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
                if (widget.onCancel != null) ...[
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: widget.onCancel,
                    child: Container(
                      width: double.infinity,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE24B4A).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color:
                            const Color(0xFFE24B4A).withOpacity(0.3)),
                      ),
                      child: const Center(
                        child: Text('Cancel Appointment',
                            style: TextStyle(
                                color: Color(0xFFE24B4A),
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) => Row(
    children: [
      Icon(icon, size: 13, color: Colors.white.withOpacity(0.35)),
      const SizedBox(width: 4),
      Text(text,
          style: TextStyle(
              fontSize: 12, color: Colors.white.withOpacity(0.5))),
    ],
  );
}

// ── Helpers ───────────────────────────────────────────────────────────────

class _DarkEmptyState extends StatelessWidget {
  const _DarkEmptyState({required this.message, required this.icon});
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 56, color: Colors.white.withOpacity(0.15)),
        const SizedBox(height: 16),
        Text(message,
            style: TextStyle(
                color: Colors.white.withOpacity(0.35),
                fontSize: 15,
                fontWeight: FontWeight.w500)),
      ],
    ),
  );
}

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