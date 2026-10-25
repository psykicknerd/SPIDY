import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../domain/report.dart';
import 'app_state.dart';

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key, required this.onSubmitted});

  final VoidCallback onSubmitted;

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _picker = ImagePicker();
  IncidentCategory? _category;
  List<XFile> _photos = [];
  double? _latitude;
  double? _longitude;
  bool _gettingLocation = false;
  bool _saving = false;
  String? _categoryError;

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _captureLocation() async {
    setState(() => _gettingLocation = true);
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) throw Exception('Turn on location services and try again.');

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        throw Exception(
          'Location permission was denied. You can enter a location manually.',
        );
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Location permission is blocked. Enable it in app settings or enter a location manually.',
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (!mounted) return;
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _locationController.text =
            'GPS coordinates: ${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}';
      });
    } catch (error) {
      if (!mounted) return;
      final message = error.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _gettingLocation = false);
    }
  }

  Future<void> _pickPhotos() async {
    try {
      final picked = await _picker.pickMultiImage(
        limit: 4,
        imageQuality: 85,
        maxWidth: 1800,
      );
      if (mounted && picked.isNotEmpty) setState(() => _photos = picked);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open photos. Please try again.'),
          ),
        );
      }
    }
  }

  Future<void> _submit() async {
    final valid = _formKey.currentState!.validate();
    setState(
      () => _categoryError = _category == null
          ? 'Choose an incident category.'
          : null,
    );
    if (!valid || _category == null) return;

    setState(() => _saving = true);
    try {
      await AppStateScope.of(context).addReport(
        Report(
          category: _category!,
          description: _descriptionController.text.trim(),
          locationText: _locationController.text.trim(),
          latitude: _latitude,
          longitude: _longitude,
          photoPaths: _photos.map((photo) => photo.path).toList(),
          createdAt: DateTime.now(),
        ),
      );
      if (!mounted) return;
      _formKey.currentState!.reset();
      _descriptionController.clear();
      _locationController.clear();
      setState(() {
        _category = null;
        _categoryError = null;
        _photos = [];
        _latitude = null;
        _longitude = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report saved on this device. It has not been sent.'),
        ),
      );
      widget.onSubmitted();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save this report. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: colors.primaryContainer.withValues(alpha: .55),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.shield_outlined),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Create a local incident record. SPIDY is not connected to emergency services.',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionTitle(number: '01', title: 'What happened?'),
          const SizedBox(height: 12),
          Text(
            'Choose a category',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = (constraints.maxWidth - 10) / 2;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: IncidentCategory.values.map((category) {
                  final selected = _category == category;
                  return SizedBox(
                    width: itemWidth,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => setState(() {
                        _category = category;
                        _categoryError = null;
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: selected
                              ? colors.primaryContainer
                              : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: selected
                                ? colors.primary
                                : const Color(0xFFE1E7E5),
                            width: selected ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              _categoryIcon(category),
                              color: selected
                                  ? colors.primary
                                  : colors.secondary,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              category.label,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              category.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          if (_categoryError != null) ...[
            const SizedBox(height: 8),
            Text(
              _categoryError!,
              style: TextStyle(color: colors.error, fontSize: 12),
            ),
          ],
          const SizedBox(height: 22),
          TextFormField(
            controller: _descriptionController,
            minLines: 4,
            maxLines: 6,
            maxLength: 1000,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Incident description',
              hintText: 'Describe what happened and any details that may help…',
              alignLabelWithHint: true,
            ),
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.isEmpty) return 'Enter a description of the incident.';
              if (text.length < 10)
                return 'Please add a little more detail (at least 10 characters).';
              return null;
            },
          ),
          const SizedBox(height: 26),
          _SectionTitle(number: '02', title: 'Where is it?'),
          const SizedBox(height: 12),
          TextFormField(
            controller: _locationController,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) {
              if (_latitude != null)
                setState(() {
                  _latitude = null;
                  _longitude = null;
                });
            },
            decoration: const InputDecoration(
              labelText: 'Location',
              hintText: 'Street, landmark, area or GPS coordinates',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
            validator: (value) => (value?.trim().isEmpty ?? true)
                ? 'Enter a location or capture GPS coordinates.'
                : null,
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: _gettingLocation ? null : _captureLocation,
              icon: _gettingLocation
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location_outlined),
              label: Text(
                _gettingLocation
                    ? 'Getting location…'
                    : 'Use my current location',
              ),
            ),
          ),
          const SizedBox(height: 26),
          _SectionTitle(number: '03', title: 'Add photos'),
          const SizedBox(height: 6),
          Text(
            'Optional · Up to 4 photos',
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ..._photos.asMap().entries.map(
                (entry) => _PhotoPreview(
                  photo: entry.value,
                  onRemove: () => setState(() => _photos.removeAt(entry.key)),
                ),
              ),
              if (_photos.length < 4)
                OutlinedButton.icon(
                  onPressed: _pickPhotos,
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: const Text('Choose photos'),
                ),
            ],
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: _saving ? null : _submit,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(
              _saving ? 'Saving report…' : 'Save report on this device',
            ),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'This report stays on your device and is not sent anywhere.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.number, required this.title});
  final String number;
  final String title;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        number,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(width: 10),
      Text(
        title,
        style: Theme.of(context).textTheme.titleLarge
            ?.copyWith(fontWeight: FontWeight.w800),
      ),
    ],
  );
}

class _PhotoPreview extends StatelessWidget {
  const _PhotoPreview({required this.photo, required this.onRemove});
  final XFile photo;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.file(
          File(photo.path),
          width: 78,
          height: 78,
          fit: BoxFit.cover,
        ),
      ),
      Positioned(
        top: -7,
        right: -7,
        child: IconButton.filledTonal(
          visualDensity: VisualDensity.compact,
          onPressed: onRemove,
          icon: const Icon(Icons.close, size: 16),
          tooltip: 'Remove photo',
        ),
      ),
    ],
  );
}

IconData _categoryIcon(IncidentCategory category) => switch (category) {
  IncidentCategory.fire => Icons.local_fire_department_outlined,
  IncidentCategory.accident => Icons.car_crash_outlined,
  IncidentCategory.medical => Icons.medical_services_outlined,
  IncidentCategory.suspiciousActivity => Icons.visibility_outlined,
};
