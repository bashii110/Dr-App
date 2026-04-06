import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shimmer/shimmer.dart';
import '../utils/config.dart';
import '../models/app_models.dart';

// ── Primary button ────────────────────────────────────────────────────────

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.width,
    this.icon,
    this.color,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final double? width;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Config.primaryColor,
          disabledBackgroundColor: (color ?? Config.primaryColor).withOpacity(0.6),
        ),
        child: loading
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2.5,
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
            Text(label),
          ],
        ),
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.action, this.onAction});
  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 17, fontWeight: FontWeight.w700, color: Config.textDark)),
        if (action != null)
          TextButton(
            onPressed: onAction,
            child: Text(action!,
                style: const TextStyle(color: Config.primaryColor, fontWeight: FontWeight.w600)),
          ),
      ],
    );
  }
}

// ── Status badge ──────────────────────────────────────────────────────────

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});
  final String status;

  static const _map = {
    'pending':   [Color(0xFFFFF3E0), Color(0xFFE65100)],
    'confirmed': [Color(0xFFE3F2FD), Color(0xFF1565C0)],
    'completed': [Color(0xFFE8F5E9), Color(0xFF2E7D32)],
    'cancelled': [Color(0xFFFFEBEE), Color(0xFFC62828)],
    'available': [Color(0xFFE8F5E9), Color(0xFF2E7D32)],
    'busy':      [Color(0xFFFFEBEE), Color(0xFFC62828)],
    'offline':   [Color(0xFFF1F3F4), Color(0xFF5F6368)],
  };

  @override
  Widget build(BuildContext context) {
    final colors = _map[status] ?? [Config.dividerColor, Config.textMid];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: colors[0], borderRadius: BorderRadius.circular(20)),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: TextStyle(
            color: colors[1], fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ── Doctor card ───────────────────────────────────────────────────────────

class DoctorCard extends StatelessWidget {
  const DoctorCard({super.key, required this.doctor, required this.onTap});
  final DoctorModel doctor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final catColors = Config.categoryColor(doctor.category);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Config.dividerColor),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 32,
                backgroundColor: Config.primaryColor.withOpacity(0.1),
                child: Text(
                  (doctor.name ?? 'D')[0].toUpperCase(),
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w700,
                      color: Config.primaryColor),
                ),
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dr ${doctor.name ?? 'Unknown'}',
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Config.textDark)),
                    const SizedBox(height: 4),
                    if (doctor.category != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: catColors[0],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(doctor.category!,
                            style: TextStyle(
                                fontSize: 11,
                                color: catColors[1],
                                fontWeight: FontWeight.w600)),
                      ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Color(0xFFFFA000)),
                        const SizedBox(width: 3),
                        Text(doctor.rating.toStringAsFixed(1),
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600,
                                color: Config.textDark)),
                        Text(' (${doctor.ratingCount})',
                            style: const TextStyle(
                                fontSize: 12, color: Config.textMid)),
                        const SizedBox(width: 12),
                        if (doctor.experience != null) ...[
                          const Icon(Icons.work_outline, size: 13, color: Config.textMid),
                          const SizedBox(width: 3),
                          Text('${doctor.experience} yrs',
                              style: const TextStyle(
                                  fontSize: 12, color: Config.textMid)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Fee
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (doctor.consultationFee > 0)
                    Text('Rs ${doctor.consultationFee.toInt()}',
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Config.primaryColor)),
                  const SizedBox(height: 4),
                  StatusBadge(status: doctor.status ?? 'offline'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Appointment card ──────────────────────────────────────────────────────

class AppointmentCard extends StatelessWidget {
  const AppointmentCard({
    super.key,
    required this.appointment,
    this.onCancel,
    this.onStatusChange,
    this.isDoctor = false,
  });
  final AppointmentModel appointment;
  final VoidCallback? onCancel;
  final void Function(String)? onStatusChange;
  final bool isDoctor;

  @override
  Widget build(BuildContext context) {
    final doctorName = appointment.doctor?.name ?? 'Doctor';
    final category   = appointment.doctor?.category ?? '';
    final patName    = appointment.patient?['name'] as String? ?? 'Patient';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Config.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Config.primaryColor.withOpacity(0.1),
                  child: Text(
                    isDoctor ? patName[0].toUpperCase() : doctorName[0].toUpperCase(),
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, color: Config.primaryColor),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isDoctor ? patName : 'Dr $doctorName',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Config.textDark),
                      ),
                      if (!isDoctor && category.isNotEmpty)
                        Text(category,
                            style: const TextStyle(
                                fontSize: 12, color: Config.textMid)),
                    ],
                  ),
                ),
                StatusBadge(status: appointment.status),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),
            // Date / time row
            Row(
              children: [
                _infoChip(Icons.calendar_today_outlined, appointment.appointmentDate),
                const SizedBox(width: 12),
                _infoChip(Icons.access_time_outlined, appointment.appointmentTime),
                if (appointment.consultationFee > 0) ...[
                  const SizedBox(width: 12),
                  _infoChip(
                      Icons.payments_outlined,
                      'Rs ${appointment.consultationFee.toInt()}'),
                ],
              ],
            ),
            if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Note: ${appointment.notes}',
                  style: const TextStyle(fontSize: 12, color: Config.textMid,
                      fontStyle: FontStyle.italic)),
            ],
            // Action buttons
            if (isDoctor && (appointment.isPending || appointment.isConfirmed)) ...[
              const SizedBox(height: 12),
              Row(children: [
                if (appointment.isPending)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => onStatusChange?.call('confirmed'),
                      style: OutlinedButton.styleFrom(
                          foregroundColor: Config.secondaryColor,
                          side: const BorderSide(color: Config.secondaryColor),
                          minimumSize: const Size(0, 38),
                          padding: EdgeInsets.zero),
                      child: const Text('Confirm'),
                    ),
                  ),
                if (appointment.isPending) const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => onStatusChange?.call('completed'),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: Config.primaryColor,
                        side: const BorderSide(color: Config.primaryColor),
                        minimumSize: const Size(0, 38),
                        padding: EdgeInsets.zero),
                    child: const Text('Complete'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => onStatusChange?.call('cancelled'),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: Config.errorColor,
                        side: const BorderSide(color: Config.errorColor),
                        minimumSize: const Size(0, 38),
                        padding: EdgeInsets.zero),
                    child: const Text('Cancel'),
                  ),
                ),
              ]),
            ] else if (!isDoctor && (appointment.isPending || appointment.isConfirmed)) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 38,
                child: OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                      foregroundColor: Config.errorColor,
                      side: const BorderSide(color: Config.errorColor),
                      padding: EdgeInsets.zero),
                  child: const Text('Cancel Appointment'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) => Row(
    children: [
      Icon(icon, size: 14, color: Config.textMid),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 12, color: Config.textMid)),
    ],
  );
}

// ── Shimmer list ──────────────────────────────────────────────────────────

class ShimmerList extends StatelessWidget {
  const ShimmerList({super.key, this.count = 4});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade100,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: count,
        itemBuilder: (_, __) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 100,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}

// ── Rating bar ────────────────────────────────────────────────────────────

class ReadRatingBar extends StatelessWidget {
  const ReadRatingBar({super.key, required this.rating, this.size = 16});
  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) => RatingBarIndicator(
    rating: rating,
    itemBuilder: (_, __) =>
    const Icon(Icons.star, color: Color(0xFFFFA000)),
    itemCount: 5,
    itemSize: size,
  );
}

// ── Empty state ───────────────────────────────────────────────────────────

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.message, this.icon});
  final String message;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon ?? Icons.inbox_outlined, size: 64, color: Config.textLight),
          const SizedBox(height: 16),
          Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Config.textMid, fontSize: 15)),
        ],
      ),
    ),
  );
}