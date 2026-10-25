import 'package:flutter/material.dart';

import '../domain/report.dart';
import 'app_state.dart';
import 'report_details_screen.dart';
import 'widgets/civic_widgets.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, required this.onReport});

  final VoidCallback onReport;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _searchController = TextEditingController();
  IncidentCategory? _category;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final filtered = state.reports.where((report) {
      final categoryMatches = _category == null || report.category == _category;
      final queryMatches =
          _query.isEmpty ||
          report.description.toLowerCase().contains(_query) ||
          report.locationText.toLowerCase().contains(_query) ||
          report.category.label.toLowerCase().contains(_query);
      return categoryMatches && queryMatches;
    }).toList();

    return PageWidth(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My reports',
            style: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -.6),
          ),
          const SizedBox(height: 5),
          Text(
            'Review incident records saved on this device.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 19),
          TextField(
            controller: _searchController,
            onChanged: (value) =>
                setState(() => _query = value.trim().toLowerCase()),
            decoration: InputDecoration(
              hintText: 'Search reports',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                      icon: const Icon(Icons.close_rounded),
                      tooltip: 'Clear search',
                    ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('All'),
                    selected: _category == null,
                    onSelected: (_) => setState(() => _category = null),
                  ),
                ),
                ...IncidentCategory.values.map(
                  (category) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category.label),
                      selected: _category == category,
                      onSelected: (_) => setState(
                        () =>
                            _category = _category == category ? null : category,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          if (state.loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (state.loadError != null)
            Expanded(
              child: Center(
                child: EmptyStateCard(
                  icon: Icons.error_outline_rounded,
                  title: 'Could not load reports',
                  message: state.loadError!,
                  action: OutlinedButton.icon(
                    onPressed: state.loadReports,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try again'),
                  ),
                ),
              ),
            )
          else if (filtered.isEmpty)
            Expanded(
              child: Center(
                child: EmptyStateCard(
                  icon: state.reports.isEmpty
                      ? Icons.assignment_outlined
                      : Icons.search_off_rounded,
                  title: state.reports.isEmpty
                      ? 'No reports saved yet'
                      : 'No matching reports',
                  message: state.reports.isEmpty
                      ? 'Reports you save with CivicShield will appear here. Example cards on Home are sample previews.'
                      : 'Try another search or category filter.',
                  action: state.reports.isEmpty
                      ? FilledButton.icon(
                          onPressed: widget.onReport,
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Create a report'),
                        )
                      : TextButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _query = '';
                              _category = null;
                            });
                          },
                          child: const Text('Clear filters'),
                        ),
                ),
              ),
            )
          else ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${filtered.length} ${filtered.length == 1 ? 'report' : 'reports'} · saved locally',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: filtered.length,
                separatorBuilder: (_, _) => const SizedBox(height: 9),
                itemBuilder: (context, index) {
                  final report = filtered[index];
                  return IncidentReportCard(
                    report: report,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ReportDetailsScreen(report: report),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
