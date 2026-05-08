import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../services/geofence_service.dart';

class AddSafeZoneDialog extends StatefulWidget {
  final Circle? circle;
  final VoidCallback onSafeZoneCreated;

  const AddSafeZoneDialog({
    Key? key,
    required this.circle,
    required this.onSafeZoneCreated,
  }) : super(key: key);

  @override
  State<AddSafeZoneDialog> createState() => _AddSafeZoneDialogState();
}

class _AddSafeZoneDialogState extends State<AddSafeZoneDialog> {
  final GeofenceService _geofenceService = GeofenceService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _radiusController = TextEditingController(text: '100');

  bool _isCreating = false;
  String? _errorMessage;

  double _latitude = 37.7749; // Default: San Francisco
  double _longitude = -122.4194;

  @override
  void dispose() {
    _nameController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  Future<void> _createSafeZone() async {
    if (_nameController.text.isEmpty || _radiusController.text.isEmpty) {
      setState(() => _errorMessage = 'Please fill in all fields');
      return;
    }

    if (widget.circle == null) {
      setState(() => _errorMessage = 'No circle selected');
      return;
    }

    setState(() {
      _isCreating = true;
      _errorMessage = null;
    });

    try {
      final radius = int.parse(_radiusController.text);
      
      final geofence = await _geofenceService.createGeofence(
        circleId: widget.circle!.id,
        name: _nameController.text,
        latitude: _latitude,
        longitude: _longitude,
        radiusMeters: radius,
        color: '#43A047',
      );

      if (geofence != null && mounted) {
        widget.onSafeZoneCreated();
        Navigator.pop(context);
      } else {
        setState(() => _errorMessage = 'Failed to create safe zone');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Safe Zone'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Name field
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Zone Name',
                hintText: 'e.g., School, Home',
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 16),

            // Radius field
            TextField(
              controller: _radiusController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Radius (meters)',
                hintText: '100',
                prefixIcon: Icon(Icons.straighten),
                suffixText: 'm',
              ),
            ),
            const SizedBox(height: 8),

            // Slider for radius
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Radius:'),
                      Text(
                        '${_radiusController.text} m',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Slider(
                    value: int.tryParse(_radiusController.text)?.toDouble() ?? 100,
                    min: 10,
                    max: 1000,
                    divisions: 99,
                    label: _radiusController.text,
                    onChanged: (value) {
                      _radiusController.text = value.toInt().toString();
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),

            // Info text
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF43A047).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Tap and hold on the map to set the exact location of this safe zone.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF757575),
                ),
              ),
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: const TextStyle(
                  color: Color(0xFFD32F2F),
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isCreating ? null : _createSafeZone,
          child: _isCreating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
        ),
      ],
    );
  }
}
