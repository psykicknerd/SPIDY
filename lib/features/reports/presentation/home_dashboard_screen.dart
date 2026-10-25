import 'package:flutter/material.dart';

import '../data/demo_report_data.dart';
import '../domain/report.dart';
import 'report_details_screen.dart';
import 'widgets/civic_widgets.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({
    super.key,
    required this.onReport,
    required this.onHistory,
    required this.onEmergencyInfo,
    required this.reports,
    required this.loading,
    required this.loadError,
    required this.onRetry,
  });

  final ValueChanged<IncidentCategory?> onReport;
  final VoidCallback onHistory;
  final VoidCallback onEmergencyInfo;
  final List<Report> reports;
  final bool loading;
  final String? loadError;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final recent = reports.isEmpty
        ? demoReports.take(2).toList()
        : reports.take(2).toList();
    return PageWidth(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 26),
      child: ListView(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.shield_rounded,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CivicShield',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -.4,
                      ),
                    ),
                    Text(
                      'Community safety, together',
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                onPressed: onEmergencyInfo,
                tooltip: 'Emergency information',
                icon: const Icon(Icons.info_outline_rounded),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF193B66), Color(0xFF285586)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .13),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 15,
                        color: Colors.white,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'LOOK OUT FOR EACH OTHER',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: .65,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  'See something\nthat needs attention?',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    height: 1.12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.4,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  'Create a clear incident record with a location and optional photos.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: .85),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: () => onReport(null),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Report an Incident'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: colors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1E8),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFF9A4D18),
                  size: 19,
                ),
                SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Reports are saved on this device. CivicShield is not connected to emergency services.',
                    style: TextStyle(
                      color: Color(0xFF71350F),
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          const SectionHeading(title: 'Quick report'),
          const SizedBox(height: 11),
          LayoutBuilder(
            builder: (context, constraints) {
              final count = constraints.maxWidth >= 600 ? 4 : 2;
              return GridView.builder(
                itemCount: IncidentCategory.values.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: count,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  mainAxisExtent: 105,
                ),
                itemBuilder: (context, index) {
                  final category = IncidentCategory.values[index];
                  return _CategoryShortcut(
                    category: category,
                    onTap: () => onReport(category),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 25),
          SectionHeading(
            title: 'Recent reports',
            actionLabel: 'View all',
            onAction: onHistory,
          ),
          const SizedBox(height: 10),
          if (loading)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
            )
          else if (loadError != null)
            Card(
              child: ListTile(
                leading: Icon(Icons.cloud_off_outlined, color: colors.error),
                title: const Text('Could not load saved reports'),
                subtitle: Text(loadError!),
                trailing: IconButton(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Try again',
                ),
              ),
            )
          else ...[
            if (reports.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    const SampleTag(),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Example previews · no reports saved yet',
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: colors.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              ),
            ...recent.map(
              (report) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: IncidentReportCard(
                  report: report,
                  isSample: reports.isEmpty,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ReportDetailsScreen(
                        report: report,
                        isSample: reports.isEmpty,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          SectionHeading(
            title: 'Emergency contacts',
            actionLabel: 'View info',
            onAction: onEmergencyInfo,
          ),
          const SizedBox(height: 10),
          const _ContactPreviewCard(),
        ],
      ),
    );
  }
}

class _CategoryShortcut extends StatelessWidget {
  const _CategoryShortcut({required this.category, required this.onTap});
  final IncidentCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tint = incidentTint(context, category);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(incidentIcon(category), color: tint),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  category.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge
                      ?.copyWith(fontWeight: FontWeight.w800, height: 1.15),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 19,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactPreviewCard extends StatelessWidget {
  const _ContactPreviewCard();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const _ContactPreviewRow(
              icon: Icons.local_police_outlined,
              title: 'Police / public safety',
            ),
            Divider(height: 20, color: colors.outlineVariant),
            const _ContactPreviewRow(
              icon: Icons.local_fire_department_outlined,
              title: 'Fire & rescue',
            ),
            Divider(height: 20, color: colors.outlineVariant),
            const _ContactPreviewRow(
              icon: Icons.medical_services_outlined,
              title: 'Medical assistance',
            ),
            const SizedBox(height: 9),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Verified local numbers have not been configured.',
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: colors.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactPreviewRow extends StatelessWidget {
  const _ContactPreviewRow({required this.icon, required this.title});
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
      const SizedBox(width: 10),
      Expanded(
        child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      const Text(
        'Not set',
        style: TextStyle(
          color: Color(0xFF8A4B16),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}
