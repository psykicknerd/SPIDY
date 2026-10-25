import 'dart:io';

import 'package:flutter/material.dart';

import '../../domain/report.dart';

const civicPageMaxWidth = 760.0;

IconData incidentIcon(IncidentCategory category) => switch (category) {
  IncidentCategory.fire => Icons.local_fire_department_rounded,
  IncidentCategory.accident => Icons.car_crash_rounded,
  IncidentCategory.medical => Icons.medical_services_rounded,
  IncidentCategory.suspiciousActivity => Icons.visibility_rounded,
  IncidentCategory.other => Icons.report_problem_rounded,
};

Color incidentTint(BuildContext context, IncidentCategory category) =>
    switch (category) {
      IncidentCategory.fire => const Color(0xFFB94728),
      IncidentCategory.accident => const Color(0xFFB65C22),
      IncidentCategory.medical => const Color(0xFF27735B),
      IncidentCategory.suspiciousActivity => Theme.of(
        context,
      ).colorScheme.primary,
      IncidentCategory.other => Theme.of(context).colorScheme.secondary,
    };

class PageWidth extends StatelessWidget {
  const PageWidth({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 12, 20, 28),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: civicPageMaxWidth),
      child: Padding(padding: padding, child: child),
    ),
  );
}

class SectionHeading extends StatelessWidget {
  const SectionHeading({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -.3),
        ),
      ),
      if (actionLabel != null)
        TextButton(onPressed: onAction, child: Text(actionLabel!)),
    ],
  );
}

class SampleTag extends StatelessWidget {
  const SampleTag({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: const Color(0xFFEAF0F7),
      borderRadius: BorderRadius.circular(99),
    ),
    child: const Text(
      'SAMPLE',
      style: TextStyle(
        color: Color(0xFF465B76),
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: .55,
      ),
    ),
  );
}

class DeliveryBadge extends StatelessWidget {
  const DeliveryBadge({super.key, required this.status, this.compact = false});

  final DeliveryStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final (label, icon, color, fill) = switch (status) {
      DeliveryStatus.localOnly => (
        'On this device',
        Icons.phone_android_rounded,
        const Color(0xFF79520A),
        const Color(0xFFFFF3D6),
      ),
      DeliveryStatus.pending => (
        'Pending',
        Icons.schedule_rounded,
        const Color(0xFF87520B),
        const Color(0xFFFFF0D9),
      ),
      DeliveryStatus.sent => (
        'Submitted',
        Icons.check_circle_outline_rounded,
        const Color(0xFF27735B),
        const Color(0xFFE3F4EC),
      ),
      DeliveryStatus.failed => (
        'Not submitted',
        Icons.error_outline_rounded,
        const Color(0xFFB42318),
        const Color(0xFFFEE4E2),
      ),
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 9 : 11, vertical: 7),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class IncidentReportCard extends StatelessWidget {
  const IncidentReportCard({
    super.key,
    required this.report,
    required this.onTap,
    this.isSample = false,
  });

  final Report report;
  final VoidCallback onTap;
  final bool isSample;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: incidentTint(
                        context,
                        report.category,
                      ).withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      incidentIcon(report.category),
                      color: incidentTint(context, report.category),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.category.label,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formatReportDate(report.createdAt),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  if (isSample)
                    const SampleTag()
                  else
                    DeliveryBadge(status: report.status, compact: true),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                report.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(height: 1.4),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 17,
                    color: colors.secondary,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      report.locationText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: colors.onSurfaceVariant,
                  ),
                ],
              ),
              if (report.photoPaths.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 76,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: report.photoPaths.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) => ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(report.photoPaths[index]),
                        width: 76,
                        height: 76,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          width: 76,
                          color: colors.surfaceContainerHighest,
                          child: const Icon(Icons.broken_image_outlined),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

String formatReportDate(DateTime date) {
  final local = date.toLocal();
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  final period = local.hour < 12 ? 'AM' : 'PM';
  return '${months[local.month - 1]} ${local.day}, ${local.year} · $hour:$minute $period';
}

class EmptyStateCard extends StatelessWidget {
  const EmptyStateCard({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          if (action != null) ...[const SizedBox(height: 16), action!],
        ],
      ),
    ),
  );
}
