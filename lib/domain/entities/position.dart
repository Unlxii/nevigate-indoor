import 'dart:math' as math;
import 'package:equatable/equatable.dart';

class Position extends Equatable {
  final double x;
  final double y;
  final double z;
  final DateTime timestamp;
  final double accuracy;

  const Position({
    required this.x,
    required this.y,
    required this.z,
    required this.timestamp,
    this.accuracy = 0.0,
  });

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      x: json['x']?.toDouble() ?? 0.0,
      y: json['y']?.toDouble() ?? 0.0,
      z: json['z']?.toDouble() ?? 0.0,
      timestamp: DateTime.parse(json['timestamp']),
      accuracy: json['accuracy']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'z': z,
      'timestamp': timestamp.toIso8601String(),
      'accuracy': accuracy,
    };
  }

  double distanceTo(Position other) {
    final dx = x - other.x;
    final dy = y - other.y;
    final dz = z - other.z;
    return math.sqrt(dx * dx + dy * dy + dz * dz);
  }

  @override
  List<Object?> get props => [x, y, z, timestamp, accuracy];
}
