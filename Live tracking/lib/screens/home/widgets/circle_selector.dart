import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../services/circle_service.dart';

class CircleSelector extends StatefulWidget {
  final List<Circle> circles;
  final Circle? selectedCircle;
  final Function(Circle) onCircleSelected;

  const CircleSelector({
    Key? key,
    required this.circles,
    required this.selectedCircle,
    required this.onCircleSelected,
  }) : super(key: key);

  @override
  State<CircleSelector> createState() => _CircleSelectorState();
}

class _CircleSelectorState extends State<CircleSelector> {
  final CircleService _circleService = CircleService();
  final TextEditingController _inviteCodeController = TextEditingController();
  final TextEditingController _newCircleNameController = TextEditingController();
  bool _isJoiningCircle = false;
  bool _isCreatingCircle = false;

  @override
  void dispose() {
    _inviteCodeController.dispose();
    _newCircleNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Your Circles',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // List of circles
          SizedBox(
            height: 150,
            child: ListView.builder(
              itemCount: widget.circles.length,
              itemBuilder: (context, index) {
                final circle = widget.circles[index];
                final isSelected = circle.id == widget.selectedCircle?.id;
                
                return GestureDetector(
                  onTap: () {
                    widget.onCircleSelected(circle);
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF1E88E5)
                            : const Color(0xFFBDBDBD),
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: isSelected
                          ? const Color(0xFF1E88E5).withOpacity(0.1)
                          : Colors.transparent,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              circle.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check,
                                  color: Color(0xFF1E88E5)),
                          ],
                        ),
                        if (circle.description != null)
                          Text(
                            circle.description!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF757575),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Join circle section
          TextField(
            controller: _inviteCodeController,
            decoration: InputDecoration(
              labelText: 'Join Circle',
              hintText: 'Enter 6-digit code',
              suffixIcon: _isJoiningCircle
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: Center(
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isJoiningCircle ? null : _joinCircle,
              child: const Text('Join Circle'),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          
          // Create circle section
          const Text(
            'Create New Circle',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _newCircleNameController,
            decoration: const InputDecoration(
              labelText: 'Circle Name',
              hintText: 'e.g., Family, Friends',
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _isCreatingCircle ? null : _createCircle,
              child: _isCreatingCircle 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Create Circle'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createCircle() async {
    if (_newCircleNameController.text.isEmpty) return;
    
    setState(() => _isCreatingCircle = true);
    
    final circle = await _circleService.createCircle(name: _newCircleNameController.text);
    
    if (mounted) {
      setState(() => _isCreatingCircle = false);
      if (circle != null) {
        widget.onCircleSelected(circle);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Circle "${circle.name}" created!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create circle')),
        );
      }
    }
  }

  Future<void> _joinCircle() async {
    if (_inviteCodeController.text.isEmpty) return;

    setState(() => _isJoiningCircle = true);

    final success = await _circleService.joinCircle(_inviteCodeController.text.trim());

    if (mounted) {
      setState(() => _isJoiningCircle = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Circle joined!'),
            backgroundColor: Color(0xFF43A047),
          ),
        );
        _inviteCodeController.clear();
        Navigator.pop(context);
        // We might need to refresh the whole screen here, 
        // but for now, we'll assume the user will refresh or change circles.
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to join circle. Check code.'),
            backgroundColor: Color(0xFFD32F2F),
          ),
        );
      }
    }
  }
}
