import 'package:flutter/material.dart';
import '../../components/custom_widget.dart';
import '../../models/app_models.dart';
import '../../service/api_service.dart';
import '../../utils/config.dart';


class DoctorPatientHistoryScreen extends StatefulWidget {
  const DoctorPatientHistoryScreen({super.key});
  @override
  State<DoctorPatientHistoryScreen> createState() =>
      _DoctorPatientHistoryScreenState();
}

class _DoctorPatientHistoryScreenState
    extends State<DoctorPatientHistoryScreen> {
  // Map patientId → list of appointments
  Map<int, List<AppointmentModel>> _grouped = {};
  Map<int, String> _patientNames = {};
  bool _loading = true;
  String _search = '';

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

        final grouped  = <int, List<AppointmentModel>>{};
        final names    = <int, String>{};

        for (final a in items) {
          grouped.putIfAbsent(a.patientId, () => []).add(a);
          if (a.patient != null) {
            names[a.patientId] = a.patient!['name'] as String? ?? 'Patient';
          }
        }

        setState(() {
          _grouped      = grouped;
          _patientNames = names;
          _loading      = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  List<int> get _filteredIds {
    if (_search.isEmpty) return _grouped.keys.toList();
    return _grouped.keys
        .where((id) =>
        (_patientNames[id] ?? '')
            .toLowerCase()
            .contains(_search.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Config.bgColor,
      appBar: AppBar(
        title: const Text('Patient History'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search patients…',
                prefixIcon: const Icon(Icons.search, size: 20),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Config.dividerColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Config.dividerColor),
                ),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),

          // List
          Expanded(
            child: _loading
                ? const Padding(
                padding: EdgeInsets.all(20), child: ShimmerList(count: 6))
                : _grouped.isEmpty
                ? const EmptyState(
                message: 'No patient history yet.',
                icon: Icons.people_outline)
                : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredIds.length,
                itemBuilder: (_, i) {
                  final patId = _filteredIds[i];
                  final appts = _grouped[patId]!;
                  final name  = _patientNames[patId] ?? 'Patient';
                  return _PatientHistoryCard(
                    patientName: name,
                    appointments: appts,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Patient history card (expandable) ────────────────────────────────────

class _PatientHistoryCard extends StatefulWidget {
  const _PatientHistoryCard({
    required this.patientName,
    required this.appointments,
  });
  final String patientName;
  final List<AppointmentModel> appointments;

  @override
  State<_PatientHistoryCard> createState() => _PatientHistoryCardState();
}

class _PatientHistoryCardState extends State<_PatientHistoryCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final total     = widget.appointments.length;
    final completed = widget.appointments.where((a) => a.isCompleted).length;
    final lastVisit = widget.appointments.isNotEmpty
        ? widget.appointments
        .map((a) => a.appointmentDate)
        .reduce((a, b) => a.compareTo(b) > 0 ? a : b)
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Config.dividerColor),
      ),
      child: Column(
        children: [
          // Header row — always visible
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Config.secondaryColor.withOpacity(0.1),
                    child: Text(
                      widget.patientName[0].toUpperCase(),
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Config.secondaryColor,
                          fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.patientName,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: Config.textDark)),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            _pill('$total visits',
                                Config.primaryColor.withOpacity(0.1),
                                Config.primaryColor),
                            const SizedBox(width: 6),
                            _pill('$completed completed',
                                Config.secondaryColor.withOpacity(0.1),
                                Config.secondaryColor),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (lastVisit != null)
                        Text('Last: $lastVisit',
                            style: const TextStyle(
                                fontSize: 11, color: Config.textMid)),
                      const SizedBox(height: 4),
                      Icon(
                        _expanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: Config.textMid,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Expanded appointment list
          if (_expanded) ...[
            const Divider(height: 1, indent: 16, endIndent: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
              child: Column(
                children: widget.appointments.map((a) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Config.bgColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${a.appointmentDate}  ·  ${a.appointmentTime}',
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Config.textDark),
                              ),
                              if (a.notes != null && a.notes!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(a.notes!,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Config.textMid,
                                          fontStyle: FontStyle.italic)),
                                ),
                            ],
                          ),
                        ),
                        StatusBadge(status: a.status),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _pill(String text, Color bg, Color fg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
        color: bg, borderRadius: BorderRadius.circular(20)),
    child: Text(text,
        style: TextStyle(
            fontSize: 11, color: fg, fontWeight: FontWeight.w600)),
  );
}