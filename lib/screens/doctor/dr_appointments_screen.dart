import 'package:flutter/material.dart';
import '../../components/custom_widget.dart';
import '../../models/app_models.dart';
import '../../service/api_service.dart';
import '../../utils/config.dart';


class DoctorAppointmentsScreen extends StatefulWidget {
  const DoctorAppointmentsScreen({super.key});
  @override
  State<DoctorAppointmentsScreen> createState() => _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  final _statuses = ['pending', 'confirmed', 'completed', 'cancelled'];
  final _labels   = ['Pending', 'Confirmed', 'Completed', 'Cancelled'];
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
          final items = ((res['data'] as Map)['data'] as List);
          _all = items
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
      _load();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Marked as $status.')));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Config.bgColor,
    appBar: AppBar(
      title: const Text('Appointments'),
      bottom: TabBar(
        controller: _tabs,
        isScrollable: true,
        labelColor: Config.primaryColor,
        unselectedLabelColor: Config.textMid,
        indicatorColor: Config.primaryColor,
        tabs: _labels.map((l) => Tab(text: l)).toList(),
      ),
    ),
    body: _loading
        ? const Padding(
        padding: EdgeInsets.all(20), child: ShimmerList())
        : TabBarView(
      controller: _tabs,
      children: _statuses.map((s) {
        final list = _all.where((a) => a.status == s).toList();
        if (list.isEmpty) {
          return EmptyState(
            message: 'No $s appointments.',
            icon: Icons.calendar_today_outlined,
          );
        }
        return RefreshIndicator(
          onRefresh: _load,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (_, i) => AppointmentCard(
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