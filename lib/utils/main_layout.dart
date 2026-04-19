import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../provider/auth_provider.dart';
import '../screens/doctor/doctor_homescreen.dart';
import '../screens/doctor/dr_appointments_screen.dart';
import '../screens/doctor/dr_patient_history_screen.dart';
import '../screens/doctor/dr_shedule_screen.dart';
import '../screens/patients/appointment_screen.dart';
import '../screens/patients/home_screen.dart';
import '../screens/patients/patient_history_screen.dart';
import '../screens/shared/profile_screen.dart';
import '../utils/config.dart';

// ══════════════════════════════════════════════════════════════════════════════
//  NAV ITEM MODEL
// ══════════════════════════════════════════════════════════════════════════════

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

// ── Patient nav items ─────────────────────────────────────────────────────────
const _patientNavItems = [
  _NavItem(
    icon:       Icons.home_outlined,
    activeIcon: Icons.home_rounded,
    label:      'Home',
  ),
  _NavItem(
    icon:       Icons.event_note_outlined,
    activeIcon: Icons.event_note_rounded,
    label:      'Appointments',
  ),
  _NavItem(
    icon:       Icons.history_outlined,
    activeIcon: Icons.history_rounded,
    label:      'History',
  ),
  _NavItem(
    icon:       Icons.person_outline_rounded,
    activeIcon: Icons.person_rounded,
    label:      'Profile',
  ),
];

// ── Doctor nav items ──────────────────────────────────────────────────────────
const _doctorNavItems = [
  _NavItem(
    icon:       Icons.dashboard_outlined,
    activeIcon: Icons.dashboard_rounded,
    label:      'Dashboard',
  ),
  _NavItem(
    icon:       Icons.calendar_today_outlined,
    activeIcon: Icons.calendar_today_rounded,
    label:      'Appointments',
  ),
  _NavItem(
    icon:       Icons.people_outline_rounded,
    activeIcon: Icons.people_rounded,
    label:      'Patients',
  ),
  _NavItem(
    icon:       Icons.event_available_outlined,
    activeIcon: Icons.event_available_rounded,
    label:      'Schedule',
  ),
  _NavItem(
    icon:       Icons.person_outline_rounded,
    activeIcon: Icons.person_rounded,
    label:      'Profile',
  ),
];

// ══════════════════════════════════════════════════════════════════════════════
//  ANIMATED BOTTOM NAV BAR
// ══════════════════════════════════════════════════════════════════════════════

class _AnimatedNavBar extends StatefulWidget {
  const _AnimatedNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  final int currentIndex;
  final void Function(int) onTap;
  final List<_NavItem> items;

  @override
  State<_AnimatedNavBar> createState() => _AnimatedNavBarState();
}

class _AnimatedNavBarState extends State<_AnimatedNavBar>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _scales;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _controllers = List.generate(
      widget.items.length,
          (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
        value: i == widget.currentIndex ? 1.0 : 0.0,
      ),
    );
    _scales = _controllers
        .map((c) => Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: c, curve: Curves.easeOutBack),
    ))
        .toList();
  }

  @override
  void didUpdateWidget(_AnimatedNavBar old) {
    super.didUpdateWidget(old);

    // If items list changed (role switch), reinitialise controllers
    if (old.items.length != widget.items.length) {
      for (final c in _controllers) {
        c.dispose();
      }
      _initAnimations();
      return;
    }

    if (old.currentIndex != widget.currentIndex) {
      if (old.currentIndex < _controllers.length) {
        _controllers[old.currentIndex].reverse();
      }
      if (widget.currentIndex < _controllers.length) {
        _controllers[widget.currentIndex].forward();
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84,
      margin: const EdgeInsets.fromLTRB(4, 0, 4, 2),
      decoration: BoxDecoration(
        color: const Color(0xFF141829).withOpacity(0.92),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A73E8).withOpacity(0.12),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: List.generate(widget.items.length, (i) {
            final item = widget.items[i];
            final isActive = widget.currentIndex == i;

            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HapticFeedback.lightImpact();
                  widget.onTap(i);
                },
                child: ScaleTransition(
                  scale: i < _scales.length
                      ? _scales[i]
                      : const AlwaysStoppedAnimation(1.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeOutCubic,
                        width: isActive ? 56 : 42,
                        height: 38,
                        decoration: BoxDecoration(
                          gradient: isActive
                              ? const LinearGradient(
                            colors: [
                              Color(0xFF1A73E8),
                              Color(0xFF00CEC9),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                              : null,
                          color: isActive
                              ? null
                              : Colors.white.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isActive
                                ? Colors.transparent
                                : Colors.white.withOpacity(0.06),
                          ),
                          boxShadow: isActive
                              ? [
                            BoxShadow(
                              color: const Color(0xFF1A73E8)
                                  .withOpacity(0.28),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ]
                              : [],
                        ),
                        child: Icon(
                          isActive ? item.activeIcon : item.icon,
                          color: isActive
                              ? Colors.white
                              : Colors.white.withOpacity(0.55),
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 6),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 220),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                          isActive ? FontWeight.w700 : FontWeight.w500,
                          color: isActive
                              ? const Color(0xFF00CEC9)
                              : Colors.white.withOpacity(0.42),
                          letterSpacing: 0.2,
                        ),
                        child: Text(item.label),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  MAIN LAYOUT
// ══════════════════════════════════════════════════════════════════════════════

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _index = 0;

  // ── Patient screens ───────────────────────────────────────────────────────
  static const _patientScreens = [
    HomeScreen(),
    PatientAppointmentsScreen(),
    PatientHistoryScreen(),
    ProfileScreen(),
  ];

  // ── Doctor screens ────────────────────────────────────────────────────────
  static const _doctorScreens = [
    DoctorHomeScreen(),
    DoctorAppointmentsScreen(),
    DoctorPatientHistoryScreen(),
    DoctorScheduleScreen(),
    ProfileScreen(),
  ];

  void _onTabTap(int i) {
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    final isDoctor = context.watch<AuthProvider>().isDoctor;

    final screens   = isDoctor ? _doctorScreens   : _patientScreens;
    final navItems  = isDoctor ? _doctorNavItems   : _patientNavItems;

    // Guard: clamp index so switching roles doesn't cause out-of-range
    final safeIndex = _index.clamp(0, screens.length - 1);

    return Scaffold(
      backgroundColor: Config.bgColor,
      body: IndexedStack(
        index: safeIndex,
        children: screens,
      ),
      bottomNavigationBar: _AnimatedNavBar(
        currentIndex: safeIndex,
        onTap:        _onTabTap,
        items:        navItems,
      ),
    );
  }
}