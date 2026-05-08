import 'package:uuid/uuid.dart';

// User Profile Model
class UserProfile {
  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final double? lastLat;
  final double? lastLng;
  final bool isOnline;
  final int batteryLevel;
  final DateTime lastSeen;
  final DateTime createdAt;

  UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    this.lastLat,
    this.lastLng,
    this.isOnline = false,
    this.batteryLevel = 100,
    required this.lastSeen,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      displayName: json['display_name'] ?? 'User',
      avatarUrl: json['avatar_url'],
      lastLat: json['last_lat']?.toDouble(),
      lastLng: json['last_lng']?.toDouble(),
      isOnline: json['is_online'] ?? false,
      batteryLevel: json['battery_level'] ?? 100,
      lastSeen: json['last_seen'] != null 
          ? DateTime.parse(json['last_seen']) 
          : DateTime.now(),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'last_lat': lastLat,
      'last_lng': lastLng,
      'is_online': isOnline,
      'battery_level': batteryLevel,
      'last_seen': lastSeen.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? displayName,
    String? avatarUrl,
    double? lastLat,
    double? lastLng,
    bool? isOnline,
    int? batteryLevel,
    DateTime? lastSeen,
    DateTime? createdAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      lastLat: lastLat ?? this.lastLat,
      lastLng: lastLng ?? this.lastLng,
      isOnline: isOnline ?? this.isOnline,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// Circle Model
class Circle {
  final String id;
  final String name;
  final String inviteCode;
  final String adminId;
  final String? description;
  final String? color;
  final bool isActive;
  final DateTime createdAt;

  Circle({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.adminId,
    this.description,
    this.color,
    this.isActive = true,
    required this.createdAt,
  });

  factory Circle.fromJson(Map<String, dynamic> json) {
    return Circle(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      inviteCode: json['invite_code'] ?? '',
      adminId: json['admin_id'] ?? '',
      description: json['description'],
      color: json['color'],
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'invite_code': inviteCode,
      'admin_id': adminId,
      'description': description,
      'color': color,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

// Circle Member Model
class CircleMember {
  final String id;
  final String circleId;
  final String userId;
  final String role; // 'admin' or 'member'
  final DateTime joinedAt;

  CircleMember({
    required this.id,
    required this.circleId,
    required this.userId,
    this.role = 'member',
    required this.joinedAt,
  });

  factory CircleMember.fromJson(Map<String, dynamic> json) {
    return CircleMember(
      id: json['id'] ?? '',
      circleId: json['circle_id'] ?? '',
      userId: json['user_id'] ?? '',
      role: json['role'] ?? 'member',
      joinedAt: json['joined_at'] != null 
          ? DateTime.parse(json['joined_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'circle_id': circleId,
      'user_id': userId,
      'role': role,
      'joined_at': joinedAt.toIso8601String(),
    };
  }
}

// Geofence Model
class Geofence {
  final String id;
  final String circleId;
  final String name;
  final double latitude;
  final double longitude;
  final int radiusMeters;
  final String? createdBy;
  final String color;
  final bool isActive;
  final DateTime createdAt;

  Geofence({
    required this.id,
    required this.circleId,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    this.createdBy,
    this.color = '#43A047',
    this.isActive = true,
    required this.createdAt,
  });

  factory Geofence.fromJson(Map<String, dynamic> json) {
    return Geofence(
      id: json['id'] ?? '',
      circleId: json['circle_id'] ?? '',
      name: json['name'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      radiusMeters: json['radius_meters'] ?? 100,
      createdBy: json['created_by'],
      color: json['color'] ?? '#43A047',
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'circle_id': circleId,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'radius_meters': radiusMeters,
      'created_by': createdBy,
      'color': color,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

// Geofence Event Model
class GeofenceEvent {
  final String id;
  final String geofenceId;
  final String userId;
  final String eventType; // 'entered' or 'exited'
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;

  GeofenceEvent({
    required this.id,
    required this.geofenceId,
    required this.userId,
    required this.eventType,
    this.latitude,
    this.longitude,
    required this.createdAt,
  });

  factory GeofenceEvent.fromJson(Map<String, dynamic> json) {
    return GeofenceEvent(
      id: json['id'] ?? '',
      geofenceId: json['geofence_id'] ?? '',
      userId: json['user_id'] ?? '',
      eventType: json['event_type'] ?? 'unknown',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'geofence_id': geofenceId,
      'user_id': userId,
      'event_type': eventType,
      'latitude': latitude,
      'longitude': longitude,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
