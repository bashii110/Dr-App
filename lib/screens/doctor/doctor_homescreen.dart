import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../components/custom_widget.dart';
import '../../models/app_models.dart';
import '../../provider/auth_provider.dart';
import '../../service/api_service.dart';
import '../../utils/config.dart';


class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});
  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  List<AppointmentModel> _today = [];
  List<AppointmentModel> _upcoming = [];
  Map<String, int> _stats = {'total': 0, 'pending': 0, 'completed': 0, 'cancelled': 0};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
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
          _today    = items.where((a) => a.appointmentDate == todayStr).toList();
          _upcoming = items
              .where((a) =>
          a.appointmentDate.compareTo(todayStr) > 0 &&
              (a.isPending || a.isConfirmed))
              .take(5)
              .toList();
          _stats = {
            'total':     items.length,
            'pending':   items.where((a) => a.isPending).length,
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
    return '${n.year}-${n.month.toString().padLeft(2,'0')}-${n.day.toString().padLeft(2,'0')}';
  }

  Future<void> _changeStatus(int id, String status) async {
    final res = await ApiService.updateAppointmentStatus(id, status);
    if (!mounted) return;
    if (res['status'] == 200) {
      _load();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Appointment $status.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final name = (user?.name ?? '').split(' ').first;

    return Scaffold(
      backgroundColor: Config.bgColor,
      body: RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              backgroundColor: Colors.white,
              title: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Config.primaryColor.withOpacity(0.1),
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'D',
                      style: const TextStyle(
                          color: Config.primaryColor,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dr $name',
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Config.textDark)),
                      const Text('Doctor dashboard',
                          style: TextStyle(
                              fontSize: 11, color: Config.textMid)),
                    ],
                  ),
                ],
              ),
            ),

            SliverToBoxAdapter(
              child: _loading
                  ? const Padding(
                  padding: EdgeInsets.all(20), child: ShimmerList())
                  : Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Stats ────────────────────────────────────
                    _StatsGrid(stats: _stats),
                    const SizedBox(height: 24),

                    // ── Today's appointments ──────────────────────
                    SectionHeader(
                      title: "Today's Appointments",
                      action: _today.isEmpty ? null : 'See all',
                      onAction: () {},
                    ),
                    const SizedBox(height: 10),
                    if (_today.isEmpty)
                      const EmptyState(
                        message: 'No appointments today.',
                        icon: Icons.today_outlined,
                      )
                    else
                      ..._today.map((a) => AppointmentCard(
                        appointment: a,
                        isDoctor: true,
                        onStatusChange: (s) =>
                            _changeStatus(a.id, s),
                      )),
                    const SizedBox(height: 24),

                    // ── Upcoming ──────────────────────────────────
                    const SectionHeader(title: 'Upcoming'),
                    const SizedBox(height: 10),
                    if (_upcoming.isEmpty)
                      const EmptyState(
                        message: 'No upcoming appointments.',
                        icon: Icons.calendar_month_outlined,
                      )
                    else
                      ..._upcoming.map((a) => AppointmentCard(
                        appointment: a,
                        isDoctor: true,
                        onStatusChange: (s) =>
                            _changeStatus(a.id, s),
                      )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stats grid ────────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});
  final Map<String, int> stats;

  @override
  Widget build(BuildContext context) => GridView.count(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisCount: 2,
    childAspectRatio: 1.8,
    crossAxisSpacing: 12,
    mainAxisSpacing: 12,
    children: [
      _StatTile('Total', '${stats['total']}', Icons.event_note_outlined, Config.primaryColor),
      _StatTile('Pending', '${stats['pending']}', Icons.hourglass_top_outlined, Config.accentColor),
      _StatTile('Completed', '${stats['completed']}', Icons.check_circle_outline, Config.secondaryColor),
      _StatTile('Cancelled', '${stats['cancelled']}', Icons.cancel_outlined, Config.errorColor),
    ],
  );
}

class _StatTile extends StatelessWidget {
  const _StatTile(this.label, this.value, this.icon, this.color);
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: color.withOpacity(0.2)),
    ),
    child: Row(
      children: [
        Icon(icon, size: 28, color: color),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: color)),
            Text(label,
                style: const TextStyle(
                    fontSize: 12, color: Config.textMid)),
          ],
        ),
      ],
    ),
  );
}