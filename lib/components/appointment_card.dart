import 'package:doctor_app/utils/config.dart';
import 'package:flutter/material.dart';
import '../models/app_models.dart';

class AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final bool isDoctor;
  final Function(String status) onStatusChange;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.isDoctor = false,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    final patientName = appointment.patient?['name'] ?? 'Unknown Patient';
    final patientImage = appointment.patient?['image'] ?? "assets/images/ana.jpg";

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Config.primaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // ── Patient Info ─────────────────────────────
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage(patientImage),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patientName,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (appointment.notes != null)
                        Text(
                          appointment.notes!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ── Schedule Card ───────────────────────────
              _ScheduleCard(
                date: appointment.appointmentDate,
                time: appointment.appointmentTime,
              ),

              const SizedBox(height: 12),

              // ── Action Buttons (only for doctor) ───────
              if (isDoctor)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () => onStatusChange('cancelled'),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        onPressed: () => onStatusChange('completed'),
                        child: const Text(
                          "Completed",
                          style: TextStyle(color: Colors.white),
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
  }
}

class _ScheduleCard extends StatelessWidget {
  final String? date;
  final String? time;

  const _ScheduleCard({this.date, this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade600,
        borderRadius: BorderRadius.circular(20),
      ),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_today, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              date ?? 'Unknown Date',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 20),
          const Icon(Icons.alarm, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              time ?? 'Unknown Time',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}