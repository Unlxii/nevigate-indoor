import 'package:equatable/equatable.dart';
import 'position.dart';

class NavigationPath extends Equatable {
  final List<Position> waypoints;
  final double totalDistance;
  final Duration estimatedTime;
  final int floor;
  final String? destinationRoomId;

  const NavigationPath({
    required this.waypoints,
    required this.totalDistance,
    required this.estimatedTime,
    required this.floor,
    this.destinationRoomId,
  });

  factory NavigationPath.fromJson(Map<String, dynamic> json) {
    return NavigationPath(
      waypoints: (json['waypoints'] as List)
          .map((e) => Position.fromJson(e))
          .toList(),
      totalDistance: json['totalDistance']?.toDouble() ?? 0.0,
      estimatedTime: Duration(seconds: json['estimatedTimeSeconds']),
      floor: json['floor'],
      destinationRoomId: json['destinationRoomId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'waypoints': waypoints.map((e) => e.toJson()).toList(),
      'totalDistance': totalDistance,
      'estimatedTimeSeconds': estimatedTime.inSeconds,
      'floor': floor,
      'destinationRoomId': destinationRoomId,
    };
  }

  Position? getNextWaypoint(Position currentPosition, {double threshold = 1.0}) {
    for (final waypoint in waypoints) {
      if (currentPosition.distanceTo(waypoint) > threshold) {
        return waypoint;
      }
    }
    return null;
  }

  @override
  List<Object?> get props => [waypoints, totalDistance, floor, destinationRoomId];
}
