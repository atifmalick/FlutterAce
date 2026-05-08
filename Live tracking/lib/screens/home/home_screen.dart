import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../../models/models.dart' hide Circle;
import '../../models/models.dart' as models;
import '../../services/auth_service.dart';
import '../../services/circle_service.dart';
import '../../services/location_service.dart';
import '../../services/geofence_service.dart';
import 'package:animations/animations.dart';
import 'widgets/circle_selector.dart';
import 'widgets/members_bottom_sheet.dart';
import 'widgets/add_safezone_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late GoogleMapController _mapController;
  final AuthService _authService = AuthService();
  final CircleService _circleService = CircleService();
  final LocationService _locationService = LocationService();
  final GeofenceService _geofenceService = GeofenceService();

  Set<Marker> _markers = {};
  Set<Circle> _mapCircles = {};
  List<models.Circle> _userCircles = [];
  models.Circle? _selectedCircle;
  List<UserProfile> _circleMembers = [];
  UserProfile? _currentUser;
  bool _isLoadingMap = true;
  StreamSubscription<List<UserProfile>>? _membersSubscription;
  StreamSubscription<Position>? _userLocationSubscription;
  bool _hasInitialLocation = false;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    // Initialize notifications for geofences
    await _geofenceService.initializeNotifications();
    
    // Get current user
    _currentUser = await _authService.getCurrentUserProfile();
    
    // Load circles
    _userCircles = await _circleService.getUserCircles();
    
    if (_userCircles.isNotEmpty) {
      _selectedCircle = _userCircles.first;
      await _loadCircleMembers();
    }

    // Start location tracking
    await _locationService.startLocationTracking();

    // Listen to current user's location for map centering
    _userLocationSubscription = _locationService.locationStream.listen((position) {
      if (!_hasInitialLocation && mounted) {
        _mapController.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(position.latitude, position.longitude),
            15,
          ),
        );
        _hasInitialLocation = true;
      }
    });

    setState(() => _isLoadingMap = false);
  }

  Future<void> _loadCircleMembers() async {
    if (_selectedCircle == null) return;

    // Cancel existing subscription
    await _membersSubscription?.cancel();

    // Subscribe to real-time updates
    _membersSubscription = _circleService
        .streamCircleMembers(_selectedCircle!.id)
        .listen((members) {
      if (mounted) {
        setState(() {
          _circleMembers = members;
          _updateMarkers();
        });
      }
    });
  }

  void _updateMarkers() async {
    final newMarkers = <Marker>{};

    for (final member in _circleMembers) {
      if (member.lastLat != null && member.lastLng != null) {
        final markerId = MarkerId(member.id);
        
        newMarkers.add(
          Marker(
            markerId: markerId,
            position: LatLng(member.lastLat!, member.lastLng!),
            infoWindow: InfoWindow(
              title: member.displayName,
              snippet: 'Battery: ${member.batteryLevel}%',
            ),
            // You can customize marker appearance here
          ),
        );
      }
    }

    setState(() => _markers = newMarkers);
  }

  void _onCircleSelected(models.Circle circle) {
    setState(() => _selectedCircle = circle);
    _loadCircleMembers();
  }

  void _showMembersSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => MembersBottomSheet(
        members: _circleMembers,
        circle: _selectedCircle,
        onMemberTap: (member) {
          if (member.lastLat != null && member.lastLng != null) {
            _mapController.animateCamera(
              CameraUpdate.newLatLng(
                LatLng(member.lastLat!, member.lastLng!),
              ),
            );
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  void _showAddSafeZoneDialog() {
    showDialog(
      context: context,
      builder: (context) => AddSafeZoneDialog(
        circle: _selectedCircle,
        onSafeZoneCreated: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Safe zone created!'),
              backgroundColor: Color(0xFF43A047),
            ),
          );
        },
      ),
    );
  }

  void _showCircleMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => CircleSelector(
        circles: _userCircles,
        selectedCircle: _selectedCircle,
        onCircleSelected: _onCircleSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedCircle?.name ?? 'CircleGuard',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: _showInviteCode,
            tooltip: 'Invite Members',
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: _showProfileMenu,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Google Map
          _isLoadingMap
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
                  onMapCreated: (controller) => _mapController = controller,
                  initialCameraPosition: CameraPosition(
                    target: _currentUser?.lastLat != null &&
                            _currentUser?.lastLng != null
                        ? LatLng(_currentUser!.lastLat!, _currentUser!.lastLng!)
                        : const LatLng(37.7749, -122.4194), // SF default
                    zoom: 15,
                  ),
                  markers: _markers,
                  circles: _mapCircles,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  mapToolbarEnabled: true,
                  onLongPress: (LatLng latLng) {
                    if (_selectedCircle?.adminId == _currentUser?.id) {
                      _showAddSafeZoneDialog();
                    }
                  },
                ),
          
          // Circle selector button
          Positioned(
            top: 16,
            left: 16,
            child: FloatingActionButton.small(
              onPressed: _showCircleMenu,
              backgroundColor: Colors.white,
              child: const Icon(Icons.groups, color: Color(0xFF1E88E5)),
            ),
          ),
          
          // Members button
          Positioned(
            top: 16,
            right: 16,
            child: FloatingActionButton.small(
              onPressed: _showMembersSheet,
              backgroundColor: Colors.white,
              child: const Icon(Icons.list, color: Color(0xFF1E88E5)),
            ),
          ),

          // Re-center button
          Positioned(
            bottom: 32,
            right: 16,
            child: FloatingActionButton.small(
              onPressed: _recenterMap,
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location, color: Color(0xFF1E88E5)),
            ),
          ),

          // SOS Button
          Positioned(
            bottom: 32,
            left: 16,
            child: FloatingActionButton.extended(
              onPressed: _handleSOS,
              backgroundColor: const Color(0xFFD32F2F),
              icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
              label: const Text('SOS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _showProfileMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _currentUser?.displayName ?? 'User',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _currentUser?.email ?? '',
              style: const TextStyle(color: Color(0xFF757575)),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleSignOut();
                },
                child: const Text('Sign Out'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSignOut() async {
    _locationService.dispose();
    await _authService.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  @override
  void dispose() {
    _membersSubscription?.cancel();
    _userLocationSubscription?.cancel();
    _locationService.dispose();
    _geofenceService.dispose();
    super.dispose();
  }

  Future<void> _recenterMap() async {
    final position = await _locationService.getCurrentLocation();
    if (position != null && mounted) {
      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          15,
        ),
      );
    }
  }

  void _showInviteCode() {
    if (_selectedCircle == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invite to Circle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Share this code with people you want to add to this circle:'),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: Text(
                _selectedCircle!.inviteCode,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  color: Color(0xFF1E88E5),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              // Copy to clipboard logic could go here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Invite code copied!')),
              );
              Navigator.pop(context);
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copy'),
          ),
        ],
      ),
    );
  }

  void _handleSOS() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send SOS Alert?', style: TextStyle(color: Color(0xFFD32F2F))),
        content: const Text('This will notify all members in your current circle that you need help and share your exact location.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('SOS Alert Sent!'),
                  backgroundColor: Color(0xFFD32F2F),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD32F2F)),
            child: const Text('SEND SOS', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
