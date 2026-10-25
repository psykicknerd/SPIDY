import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../domain/report.dart';
import 'app_state.dart';

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({
    super.key,
    required this.onSubmitted,
    this.initialCategory,
  });

  final VoidCallback onSubmitted;
  final IncidentCategory? initialCategory;

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _picker = ImagePicker();
  IncidentCategory? _category;
  XFile? _photo;
  double? _latitude;
  double? _longitude;
  bool _gettingLocation = false;
  bool _saving = false;
  String? _categoryError;
  String? _locationMessage;
  bool _locationMessageIsError = false;

  @override
  void initState() {
    super.initState();
    _category = widget.initialCategory;
  }

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
      if (!enabled) {
        _showLocationMessage(
          'Location services are off. Turn them on or enter an address manually.',
          isError: true,
        );
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        _showLocationMessage(
          'Location permission was denied. You can enter an address manually.',
          isError: true,
        );
        return;
      }
      if (permission == LocationPermission.deniedForever) {
        _showLocationMessage(
          'Location permission is blocked. Enable it in app settings or enter an address manually.',
          isError: true,
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 20),
        ),
      );
      if (!position.latitude.isFinite ||
          !position.longitude.isFinite ||
          position.latitude < -90 ||
          position.latitude > 90 ||
          position.longitude < -180 ||
          position.longitude > 180) {
        _showLocationMessage(
          'A usable position was not available. Try again or enter an address manually.',
          isError: true,
        );
        return;
      }
      if (!mounted) return;
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _locationController.text =
            'GPS: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
        _locationMessage = 'GPS location captured';
        _locationMessageIsError = false;
      });
    } on TimeoutException {
      _showLocationMessage(
        'Location timed out. Try again or enter an address manually.',
        isError: true,
      );
    } on LocationServiceDisabledException {
      _showLocationMessage(
        'Location services are off. Turn them on or enter an address manually.',
        isError: true,
      );
    } on PermissionDeniedException {
      _showLocationMessage(
        'Location permission was denied. You can enter an address manually.',
        isError: true,
      );
    } on PositionUpdateException {
      _showLocationMessage(
        'Your position is unavailable right now. Try again or enter an address manually.',
        isError: true,
      );
    } catch (_) {
      _showLocationMessage(
        'Could not get your location. Try again or enter an address manually.',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _gettingLocation = false);
    }
  }

  void _showLocationMessage(String message, {required bool isError}) {
    if (!mounted) return;
    setState(() {
      _locationMessage = message;
      _locationMessageIsError = isError;
    });
  }

  Future<void> _choosePhotoSource() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;

    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1800,
      );
      if (picked == null || !mounted) return; // User cancelled the picker.
      if (!await File(picked.path).exists()) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'The selected photo is no longer available. Choose another photo.',
            ),
          ),
        );
        return;
      }
      if (mounted) setState(() => _photo = picked);
    } on PlatformException catch (error) {
      if (!mounted) return;
      final message = source == ImageSource.camera
          ? 'Could not open the camera (${error.code}). Choose a gallery photo instead.'
          : 'Could not open the photo gallery. Please try again.';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } on FileSystemException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The selected photo could not be read.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not attach a photo. Please retry.'),
        ),
      );
    }
  }

  Future<void> _submit() async {
    if (_saving) return;
    final valid = _formKey.currentState!.validate();
    setState(
      () => _categoryError = _category == null
          ? 'Choose an incident category.'
          : null,
    );
    if (!valid || _category == null) return;

    final appState = AppStateScope.of(context);
    setState(() => _saving = true);
    try {
      if (_photo != null && !await File(_photo!.path).exists()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'The attached photo is no longer available. Remove it or choose another.',
              ),
            ),
          );
        }
        return;
      }
      await appState.addReport(
        IncidentReport(
          category: _category!,
          description: _descriptionController.text.trim(),
          address: _locationController.text.trim(),
          latitude: _latitude,
          longitude: _longitude,
          photoPath: _photo?.path,
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
        _photo = null;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report an incident'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: Form(
        key: _formKey,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
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
                          'Create a local incident record. CivicShield is not connected to emergency services.',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _SectionTitle(number: '01', title: 'What happened?'),
                const SizedBox(height: 12),
                Semantics(
                  header: true,
                  child: Text(
                    'Choose a category',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
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
                          child: Semantics(
                            button: true,
                            selected: selected,
                            label: '${category.label} incident category',
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
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                  ],
                                ),
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
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Incident description',
                    hintText:
                        'Describe what happened and any details that may help…',
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty) {
                      return 'Enter a description of the incident.';
                    }
                    if (text.length < 20) {
                      return 'Please add a little more detail (at least 20 characters).';
                    }
                    if (text.length > 1000) {
                      return 'Keep the description under 1,000 characters.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 26),
                _SectionTitle(number: '02', title: 'Where is it?'),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _locationController,
                  keyboardType: TextInputType.streetAddress,
                  textInputAction: TextInputAction.done,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (_) {
                    if (_latitude != null) {
                      setState(() {
                        _latitude = null;
                        _longitude = null;
                        _locationMessage = null;
                      });
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    hintText: 'Street, landmark, area or GPS coordinates',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  validator: (value) {
                    final address = value?.trim() ?? '';
                    if (address.isEmpty) {
                      return 'Enter a location or capture GPS coordinates.';
                    }
                    if (address.length < 5) {
                      return 'Enter a more complete location (at least 5 characters).';
                    }
                    return null;
                  },
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
                          : _latitude == null
                          ? 'Use my current location'
                          : 'Update GPS location',
                    ),
                  ),
                ),
                if (_latitude != null && _longitude != null) ...[
                  const SizedBox(height: 8),
                  Semantics(
                    label:
                        'Captured coordinates, latitude ${_latitude!.toStringAsFixed(6)}, longitude ${_longitude!.toStringAsFixed(6)}',
                    child: Row(
                      children: [
                        const Icon(Icons.my_location, size: 17),
                        const SizedBox(width: 7),
                        Expanded(
                          child: SelectableText(
                            'Lat ${_latitude!.toStringAsFixed(6)}  ·  Lon ${_longitude!.toStringAsFixed(6)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _gettingLocation ? null : _captureLocation,
                          icon: const Icon(Icons.refresh, size: 17),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ],
                if (_locationMessage != null) ...[
                  const SizedBox(height: 6),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      _locationMessage!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _locationMessageIsError
                            ? colors.error
                            : colors.primary,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 26),
                _SectionTitle(number: '03', title: 'Add photos'),
                const SizedBox(height: 6),
                Text(
                  'Optional · Attach one photo',
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: colors.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    if (_photo case final photo?)
                      _PhotoPreview(
                        photo: photo,
                        onRemove: () => setState(() => _photo = null),
                      ),
                    OutlinedButton.icon(
                      onPressed: _choosePhotoSource,
                      icon: Icon(
                        _photo == null
                            ? Icons.add_photo_alternate_outlined
                            : Icons.edit_outlined,
                      ),
                      label: Text(
                        _photo == null ? 'Add a photo' : 'Replace photo',
                      ),
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
          ),
        ),
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
          errorBuilder: (context, error, stackTrace) => Container(
            width: 78,
            height: 78,
            alignment: Alignment.center,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: const Icon(Icons.broken_image_outlined),
          ),
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
  IncidentCategory.other => Icons.report_problem_outlined,
};
