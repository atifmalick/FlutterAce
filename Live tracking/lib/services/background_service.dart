import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_background_service_ios/flutter_background_service_ios.dart';
import 'dart:async';
import 'location_service.dart';

/// Background service for continuous location tracking
/// Phase 2: Location Engine - Background Tasks
class BackgroundService {
  static final BackgroundService _instance = BackgroundService._internal();
  
  factory BackgroundService() {
    return _instance;
  }
  
  BackgroundService._internal();

  final LocationService _locationService = LocationService();

  /// Initialize background service
  Future<void> initializeBackgroundService() async {
    final service = BackgroundService();
    
    if (Platform.isAndroid) {
      await _initializeAndroidBackground(service);
    } else if (Platform.isIOS) {
      await _initializeIOSBackground(service);
    }
  }

  /// Initialize Android background service
  Future<void> _initializeAndroidBackground(BackgroundService service) async {
    final androidService = FlutterBackgroundServiceAndroid();

    await androidService.configure(
      onStart: onStart,
      onIsForeground: (isForeground) {
        // Handle foreground/background state changes
        return isForeground;
      },
      autoStart: false,
      isForegroundMode: true,
    );

    await BackgroundService.instance.startService();
  }

  /// Initialize iOS background service
  Future<void> _initializeIOSBackground(BackgroundService service) async {
    final iosService = FlutterBackgroundServiceIOS();

    iosService.onStart.listen((event) {
      onStart(DispatcherEntry(
        tag: 'bgService',
        sendPort: null,
      ));
    });

    iosService.onIsForeground.listen((event) {
      // Handle foreground/background state
    });

    await BackgroundService.instance.startService();
  }

  /// Main background task handler
  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) {
    DartPluginRegistrant.ensureInitialized();

    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((event) {
        service.setAsForegroundService();
      });

      service.on('setAsBackground').listen((event) {
        service.setAsBackgroundService();
      });
    }

    // Start location tracking loop
    Timer.periodic(const Duration(seconds: 30), (timer) async {
      final locationService = LocationService();
      
      final position = await locationService.getCurrentLocation();
      if (position != null) {
        await locationService.updateLocationInSupabase(
          latitude: position.latitude,
          longitude: position.longitude,
          batteryLevel: 85, // Placeholder
        );

        if (service is AndroidServiceInstance) {
          service.setForegroundNotificationInfo(
            title: 'CircleGuard',
            content: 'Tracking your location',
            subText: 'Last update: ${DateTime.now().toLocal()}',
          );
        }
      }
    });
  }

  /// Start background location tracking
  Future<void> startBackgroundLocationTracking() async {
    await BackgroundService.instance.startService();
  }

  /// Stop background location tracking
  Future<void> stopBackgroundLocationTracking() async {
    await BackgroundService.instance.invoke('stopService');
  }
}

// Import dart:io
import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
