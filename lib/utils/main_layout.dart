import 'package:flutter/material.dart';
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

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});
  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final isDoctor = context.watch<AuthProvider>().isDoctor;

    final screens = isDoctor
        ? const [
      DoctorHomeScreen(),
      DoctorAppointmentsScreen(),
      DoctorPatientHistoryScreen(),
      DoctorScheduleScreen(),
      ProfileScreen(),
    ]
        : const [
      PatientHomeScreen(),
      PatientAppointmentsScreen(),
      PatientHistoryScreen(),
      ProfileScreen(),
    ];

    final navItems = isDoctor
        ? const [
      BottomNavigationBarItem(
        icon:       Icon(Icons.dashboard_outlined),
        activeIcon: Icon(Icons.dashboard_rounded),
        label:      'Dashboard',
      ),
      BottomNavigationBarItem(
        icon:       Icon(Icons.calendar_today_outlined),
        activeIcon: Icon(Icons.calendar_today_rounded),
        label:      'Appointments',
      ),
      BottomNavigationBarItem(
        icon:       Icon(Icons.people_outline_rounded),
        activeIcon: Icon(Icons.people_rounded),
        label:      'Patients',
      ),
      BottomNavigationBarItem(
        icon:       Icon(Icons.event_available_outlined),
        activeIcon: Icon(Icons.event_available_rounded),
        label:      'Schedule',
      ),
      BottomNavigationBarItem(
        icon:       Icon(Icons.person_outline_rounded),
        activeIcon: Icon(Icons.person_rounded),
        label:      'Profile',
      ),
    ]
        : const [
      BottomNavigationBarItem(
        icon:       Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home_rounded),
        label:      'Home',
      ),
      BottomNavigationBarItem(
        icon:       Icon(Icons.event_note_outlined),
        activeIcon: Icon(Icons.event_note_rounded),
        label:      'Appointments',
      ),
      BottomNavigationBarItem(
        icon:       Icon(Icons.history_outlined),
        activeIcon: Icon(Icons.history_rounded),
        label:      'History',
      ),
      BottomNavigationBarItem(
        icon:       Icon(Icons.person_outline_rounded),
        activeIcon: Icon(Icons.person_rounded),
        label:      'Profile',
      ),
    ];

    final safeIndex = _index.clamp(0, screens.length - 1);

    return Scaffold(
      body: IndexedStack(index: safeIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: safeIndex,
        onTap: (i) => setState(() => _index = i),
        items: navItems,
      ),
    );
  }
}