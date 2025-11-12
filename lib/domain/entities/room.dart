import 'package:equatable/equatable.dart';
import 'position.dart';

class Room extends Equatable {
  final String id;
  final String name;
  final String description;
  final Position centerPosition;
  final List<Position> boundary;
  final int floor;
  final String? imageUrl;
  final Map<String, dynamic>? metadata;

  const Room({
    required this.id,
    required this.name,
    required this.description,
    required this.centerPosition,
    required this.boundary,
    required this.floor,
    this.imageUrl,
    this.metadata,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      centerPosition: Position.fromJson(json['centerPosition']),
      boundary: (json['boundary'] as List)
          .map((e) => Position.fromJson(e))
          .toList(),
      floor: json['floor'],
      imageUrl: json['imageUrl'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'centerPosition': centerPosition.toJson(),
      'boundary': boundary.map((e) => e.toJson()).toList(),
      'floor': floor,
      'imageUrl': imageUrl,
      'metadata': metadata,
    };
  }

  bool containsPosition(Position position) {
    if (position.z.toInt() != floor) return false;
    
    // Point-in-polygon algorithm (Ray Casting)
    int intersections = 0;
    for (int i = 0; i < boundary.length; i++) {
      final j = (i + 1) % boundary.length;
      final p1 = boundary[i];
      final p2 = boundary[j];
      
      if ((p1.y > position.y) != (p2.y > position.y)) {
        final xIntersection = (p2.x - p1.x) * (position.y - p1.y) / 
                             (p2.y - p1.y) + p1.x;
        if (position.x < xIntersection) {
          intersections++;
        }
      }
    }
    
    return intersections.isOdd;
  }

  @override
  List<Object?> get props => [id, name, centerPosition, floor];
}
