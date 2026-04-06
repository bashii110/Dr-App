import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/app_models.dart';
import '../../../service/api_service.dart';

import '../../../utils/config.dart';

import '../../components/custom_widget.dart';
import '../../provider/auth_provider.dart';

import 'doctors_details.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});
  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  final _searchCtrl = TextEditingController();
  String? _selectedCat;
  List<String> _categories = [];
  List<DoctorModel> _doctors = [];
  bool _loading = true;

  static const _allCategoryIcons = <String, IconData>{
    'General':      Icons.person_outline,
    'Cardiology':   Icons.favorite_outline,
    'Respirations': Icons.air_outlined,
    'Dermatology':  Icons.face_outlined,
    'Gynaecology':  Icons.pregnant_woman_outlined,
    'Dental':       Icons.add_reaction_outlined,
    'Orthopaedics': Icons.accessibility_new_outlined,
    'Neurology':    Icons.psychology_outlined,
    'Paediatrics':  Icons.child_care_outlined,
    'Psychiatry':   Icons.self_improvement_outlined,
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load({String? cat, String? search}) async {
    setState(() => _loading = true);
    try {
      final futures = await Future.wait([
        ApiService.getCategories(),
        ApiService.getDoctors(category: cat, search: search),
      ]);
      final catRes = futures[0];
      final docRes = futures[1];

      setState(() {
        if (catRes['status'] == 200) {
          _categories = List<String>.from(catRes['data'] as List);
        }
        if (docRes['status'] == 200) {
          final data = docRes['data'] as Map<String, dynamic>;
          final items = data['data'] as List;
          _doctors = items.map((e) => DoctorModel.fromJson(e as Map<String, dynamic>)).toList();
        }
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  void _onCategoryTap(String cat) {
    final next = _selectedCat == cat ? null : cat;
    setState(() => _selectedCat = next);
    _load(cat: next, search: _searchCtrl.text.isNotEmpty ? _searchCtrl.text : null);
  }

  void _onSearch(String value) {
    _load(cat: _selectedCat, search: value.isNotEmpty ? value : null);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final greeting = _greeting();
    final firstName = (user?.name ?? '').split(' ').first;

    return Scaffold(
      backgroundColor: Config.bgColor,
      body: RefreshIndicator(
        onRefresh: () => _load(cat: _selectedCat),
        child: CustomScrollView(
          slivers: [
            // ── App bar ──────────────────────────────────────────────────
            SliverAppBar(
              floating: true,
              backgroundColor: Colors.white,
              expandedHeight: 160,
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 54, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(greeting,
                                    style: const TextStyle(
                                        fontSize: 13, color: Config.textMid)),
                                Text(firstName,
                                    style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: Config.textDark)),
                              ],
                            ),
                          ),
                          CircleAvatar(
                            radius: 22,
                            backgroundColor:
                            Config.primaryColor.withOpacity(0.1),
                            child: Text(
                              firstName.isNotEmpty
                                  ? firstName[0].toUpperCase()
                                  : 'P',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Config.primaryColor,
                                  fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Search
                      TextField(
                        controller: _searchCtrl,
                        onSubmitted: _onSearch,
                        decoration: InputDecoration(
                          hintText: 'Search doctors…',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          suffixIcon: _searchCtrl.text.isNotEmpty
                              ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              _onSearch('');
                            },
                          )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          filled: true,
                          fillColor: Config.bgColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (v) {
                          if (v.isEmpty) _onSearch('');
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Categories ────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: const SectionHeader(title: 'Specialisations'),
                  ),
                  SizedBox(
                    height: 90,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: (_categories.isEmpty
                          ? _allCategoryIcons.keys.toList()
                          : _categories)
                          .map((cat) => _CategoryChip(
                        label: cat,
                        icon: _allCategoryIcons[cat] ??
                            Icons.medical_services_outlined,
                        selected: _selectedCat == cat,
                        onTap: () => _onCategoryTap(cat),
                      ))
                          .toList(),
                    ),
                  ),

                  // ── Doctors ───────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: SectionHeader(
                      title: _selectedCat != null
                          ? '$_selectedCat Doctors'
                          : 'Top Doctors',
                    ),
                  ),
                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: ShimmerList(),
                    )
                  else if (_doctors.isEmpty)
                    const EmptyState(
                      message: 'No doctors found.\nTry a different search.',
                      icon: Icons.search_off,
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: _doctors
                            .map((d) => DoctorCard(
                          doctor: d,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    DoctorDetailScreen(doctorId: d.id)),
                          ),
                        ))
                            .toList(),
                      ),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning,';
    if (h < 17) return 'Good afternoon,';
    return 'Good evening,';
  }
}

// ── Category chip ─────────────────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Config.categoryColor(label);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Config.primaryColor : colors[0],
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? Config.primaryColor : Colors.transparent,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 26,
                color: selected ? Colors.white : colors[1]),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : colors[1])),
          ],
        ),
      ),
    );
  }
}