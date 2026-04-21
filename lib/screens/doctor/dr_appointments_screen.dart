import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_models.dart';
import '../../provider/auth_provider.dart';
import '../../service/api_service.dart';


const _bg = Color(0xFF0A0E1A);
const _card = Color(0xFF141829);
const _accent = Color(0xFF1A73E8);
const _accentTeal = Color(0xFF00CEC9);

class DoctorAppointmentsScreen extends StatefulWidget {
  const DoctorAppointmentsScreen({super.key});
  @override
  State<DoctorAppointmentsScreen> createState() => _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen>
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
      final res = await ApiService.getDoctorAppointments();
      setState(() {
        if (res['status'] == 200) {
          _all = ((res['data'] as Map)['data'] as List)
              .map((e) => AppointmentModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _changeStatus(int id, String status) async {
    final res = await ApiService.updateAppointmentStatus(id, status);
    if (!mounted) return;
    if (res['status'] == 200) {
      await context.read<AuthProvider>().refreshUser();
      _load();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Marked as $status.'),
          backgroundColor: _card,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _card,
        elevation: 0,
        title: const Text('Appointments',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
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
          ? const _DarkShimmerList()
          : TabBarView(
        controller: _tabs,
        children: _statuses.map((s) {
          final list = _all.where((a) => a.status == s).toList();
          if (list.isEmpty) {
            return _DarkEmptyState(
                message: 'No $s appointments.',
                icon: Icons.calendar_today_outlined);
          }
          return RefreshIndicator(
            onRefresh: _load,
            color: _accent,
            backgroundColor: _card,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (_, i) => _DarkAppointmentCard(
                appointment: list[i],
                isDoctor: true,
                onStatusChange: (status) =>
                    _changeStatus(list[i].id, status),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _DarkAppointmentCard extends StatelessWidget {
  const _DarkAppointmentCard({
    required this.appointment,
    required this.isDoctor,
    this.onStatusChange,
    this.onCancel,
  });
  final AppointmentModel appointment;
  final bool isDoctor;
  final void Function(String)? onStatusChange;
  final VoidCallback? onCancel;

  static const _statusColors = {
    'pending': Color(0xFFFFA000),
    'confirmed': Color(0xFF1A73E8),
    'completed': Color(0xFF34A853),
    'cancelled': Color(0xFFD32F2F),
  };

  @override
  Widget build(BuildContext context) {
    final a = appointment;
    final name = isDoctor
        ? (a.patient?['name'] as String? ?? 'Patient')
        : 'Dr ${a.doctor?.name ?? 'Doctor'}';
    final sub = isDoctor ? '' : (a.doctor?.category ?? '');
    final statusColor = _statusColors[a.status] ?? Colors.white38;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_accent, _accentTeal],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(name[0].toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15)),
                    if (sub.isNotEmpty)
                      Text(sub,
                          style: const TextStyle(
                              color: _accent, fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Text(
                  a.status[0].toUpperCase() + a.status.substring(1),
                  style: TextStyle(
                      color: statusColor, fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 0.5, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 12),
          Row(
            children: [
              _chip(Icons.calendar_today_outlined, a.appointmentDate),
              const SizedBox(width: 16),
              _chip(Icons.access_time_outlined, a.appointmentTime),
              if (a.consultationFee > 0) ...[
                const SizedBox(width: 16),
                _chip(Icons.payments_outlined, 'Rs ${a.consultationFee.toInt()}'),
              ],
            ],
          ),
          if (a.notes != null && a.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(a.notes!,
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.4),
                    fontStyle: FontStyle.italic)),
          ],
          if (isDoctor && (a.isPending || a.isConfirmed)) ...[
            const SizedBox(height: 14),
            Row(children: [
              if (a.isPending)
                Expanded(
                    child: _actionBtn('Confirm', const Color(0xFF34A853),
                            () => onStatusChange?.call('confirmed'))),
              if (a.isPending) const SizedBox(width: 8),
              Expanded(
                  child: _actionBtn('Complete', _accent,
                          () => onStatusChange?.call('completed'))),
              const SizedBox(width: 8),
              Expanded(
                  child: _actionBtn('Cancel', const Color(0xFFD32F2F),
                          () => onStatusChange?.call('cancelled'))),
            ]),
          ] else if (!isDoctor && (a.isPending || a.isConfirmed)) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 38,
              child: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFD32F2F),
                    side: const BorderSide(color: Color(0xFFD32F2F))),
                child: const Text('Cancel Appointment'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String text) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 12, color: Colors.white38),
      const SizedBox(width: 4),
      Text(text, style: const TextStyle(fontSize: 12, color: Colors.white38)),
    ],
  );

  Widget _actionBtn(String label, Color color, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          alignment: Alignment.center,
          child: Text(label,
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.w700)),
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

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: List.generate(
            widget.count,
                (_) => Container(
              height: 110,
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Color.lerp(
                    const Color(0xFF1C2333), const Color(0xFF232B40), _ctrl.value),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DarkEmptyState extends StatelessWidget {
  const _DarkEmptyState({required this.message, this.icon});
  final String message;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon ?? Icons.inbox_outlined,
              size: 64, color: Colors.white12),
          const SizedBox(height: 16),
          Text(message,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.3), fontSize: 15)),
        ],
      ),
    ),
  );
}