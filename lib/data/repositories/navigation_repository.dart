import 'dart:collection';
import 'dart:math';
// import 'package:cloud_firestore/cloud_firestore.dart'; // ปิดไว้ก่อน
import '../../domain/entities/position.dart';
import '../../domain/entities/room.dart';
import '../../domain/entities/navigation_path.dart';
import '../../core/config/app_config.dart';

class NavigationRepository {
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance; // ปิดไว้ก่อน
  
  // Mock rooms data
  final List<Room> _mockRooms = [
    Room(
      id: 'room_1',
      name: 'Conference Room A',
      description: 'Large conference room with projector',
      centerPosition: Position(
        x: 5.0, 
        y: 5.0, 
        z: 0.0,
        timestamp: DateTime.now(),
      ),
      boundary: [
        Position(x: 3.0, y: 3.0, z: 0.0, timestamp: DateTime.now()),
        Position(x: 7.0, y: 3.0, z: 0.0, timestamp: DateTime.now()),
        Position(x: 7.0, y: 7.0, z: 0.0, timestamp: DateTime.now()),
        Position(x: 3.0, y: 7.0, z: 0.0, timestamp: DateTime.now()),
      ],
      floor: 1,
      imageUrl: null,
      metadata: const {'capacity': 20, 'hasProjector': true},
    ),
    Room(
      id: 'room_2',
      name: 'Office 101',
      description: 'Private office space',
      centerPosition: Position(
        x: 15.0, 
        y: 5.0, 
        z: 0.0,
        timestamp: DateTime.now(),
      ),
      boundary: [
        Position(x: 13.0, y: 3.0, z: 0.0, timestamp: DateTime.now()),
        Position(x: 17.0, y: 3.0, z: 0.0, timestamp: DateTime.now()),
        Position(x: 17.0, y: 7.0, z: 0.0, timestamp: DateTime.now()),
        Position(x: 13.0, y: 7.0, z: 0.0, timestamp: DateTime.now()),
      ],
      floor: 1,
      imageUrl: null,
      metadata: const {'capacity': 4},
    ),
    Room(
      id: 'room_3',
      name: 'Lab Room',
      description: 'Research laboratory',
      centerPosition: Position(
        x: 5.0, 
        y: 15.0, 
        z: 0.0,
        timestamp: DateTime.now(),
      ),
      boundary: [
        Position(x: 3.0, y: 13.0, z: 0.0, timestamp: DateTime.now()),
        Position(x: 7.0, y: 13.0, z: 0.0, timestamp: DateTime.now()),
        Position(x: 7.0, y: 17.0, z: 0.0, timestamp: DateTime.now()),
        Position(x: 3.0, y: 17.0, z: 0.0, timestamp: DateTime.now()),
      ],
      floor: 1,
      imageUrl: null,
      metadata: const {'hasEquipment': true},
    ),
    Room(
      id: 'room_4',
      name: 'Meeting Room B',
      description: 'Small meeting room',
      centerPosition: Position(
        x: 15.0, 
        y: 15.0, 
        z: 0.0,
        timestamp: DateTime.now(),
      ),
      boundary: [
        Position(x: 13.0, y: 13.0, z: 0.0, timestamp: DateTime.now()),
        Position(x: 17.0, y: 13.0, z: 0.0, timestamp: DateTime.now()),
        Position(x: 17.0, y: 17.0, z: 0.0, timestamp: DateTime.now()),
        Position(x: 13.0, y: 17.0, z: 0.0, timestamp: DateTime.now()),
      ],
      floor: 1,
      imageUrl: null,
      metadata: const {'capacity': 8},
    ),
  ];
  
  // Get all rooms
  Future<List<Room>> getRooms({int? floor}) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay
      
      if (floor != null) {
        return _mockRooms.where((room) => room.floor == floor).toList();
      }
      
      return List.from(_mockRooms);
    } catch (e) {
      throw Exception('Failed to get rooms: $e');
    }
  }
  
  // Search rooms by name
  Future<List<Room>> searchRooms(String query) async {
    try {
      await Future.delayed(const Duration(milliseconds: 200)); // Simulate network delay
      
      return _mockRooms.where((room) {
        return room.name.toLowerCase().contains(query.toLowerCase()) ||
               room.description.toLowerCase().contains(query.toLowerCase());
      }).toList();
    } catch (e) {
      throw Exception('Failed to search rooms: $e');
    }
  }
  
  // Get room by ID
  Future<Room?> getRoomById(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100)); // Simulate network delay
      
      try {
        return _mockRooms.firstWhere((room) => room.id == id);
      } catch (e) {
        return null;
      }
    } catch (e) {
      throw Exception('Failed to get room: $e');
    }
  }
  
  // Find room by position
  Future<Room?> findRoomByPosition(Position position) async {
    try {
      final rooms = await getRooms(floor: position.z.toInt());
      
      for (final room in rooms) {
        if (room.containsPosition(position)) {
          return room;
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to find room: $e');
    }
  }
  
  // Calculate navigation path using A* algorithm
  Future<NavigationPath> calculatePath({
    required Position start,
    required Position destination,
  }) async {
    try {
      // Get rooms on the floor
      final rooms = await getRooms(floor: start.z.toInt());
      
      // Build navigation graph
      final graph = _buildNavigationGraph(rooms);
      
      // Run A* pathfinding
      final waypoints = _aStarPathfinding(
        start: start,
        goal: destination,
        graph: graph,
      );
      
      // Calculate total distance
      double totalDistance = 0.0;
      for (int i = 0; i < waypoints.length - 1; i++) {
        totalDistance += waypoints[i].distanceTo(waypoints[i + 1]);
      }
      
      // Estimate time based on walking speed
      final estimatedSeconds = (totalDistance / AppConfig.walkingSpeed).ceil();
      
      return NavigationPath(
        waypoints: waypoints,
        totalDistance: totalDistance,
        estimatedTime: Duration(seconds: estimatedSeconds),
        floor: start.z.toInt(),
      );
    } catch (e) {
      throw Exception('Failed to calculate path: $e');
    }
  }
  
  // Build navigation graph from rooms
  Map<String, List<Position>> _buildNavigationGraph(List<Room> rooms) {
    final graph = <String, List<Position>>{};
    
    // Add room centers as nodes
    for (final room in rooms) {
      final key = '${room.centerPosition.x},${room.centerPosition.y}';
      graph[key] = [];
      
      // Connect to nearby rooms
      for (final other in rooms) {
        if (room.id != other.id) {
          final distance = room.centerPosition.distanceTo(other.centerPosition);
          if (distance < 20.0) { // Connect rooms within 20 meters
            graph[key]!.add(other.centerPosition);
          }
        }
      }
    }
    
    return graph;
  }
  
  // A* pathfinding algorithm
  List<Position> _aStarPathfinding({
    required Position start,
    required Position goal,
    required Map<String, List<Position>> graph,
  }) {
    final openSet = PriorityQueue<_PathNode>();
    final closedSet = <String>{};
    final cameFrom = <String, Position>{};
    final gScore = <String, double>{};
    final fScore = <String, double>{};
    
    final startKey = '${start.x},${start.y}';
    gScore[startKey] = 0.0;
    fScore[startKey] = _heuristic(start, goal);
    
    openSet.add(_PathNode(start, fScore[startKey]!));
    
    while (openSet.isNotEmpty) {
      final current = openSet.removeFirst();
      final currentKey = '${current.position.x},${current.position.y}';
      
      // Goal reached
      if (current.position.distanceTo(goal) < 1.0) {
        return _reconstructPath(cameFrom, current.position, start);
      }
      
      closedSet.add(currentKey);
      
      // Check neighbors
      final neighbors = graph[currentKey] ?? [];
      for (final neighbor in neighbors) {
        final neighborKey = '${neighbor.x},${neighbor.y}';
        
        if (closedSet.contains(neighborKey)) continue;
        
        final tentativeGScore = gScore[currentKey]! + 
                                current.position.distanceTo(neighbor);
        
        if (!gScore.containsKey(neighborKey) || 
            tentativeGScore < gScore[neighborKey]!) {
          cameFrom[neighborKey] = current.position;
          gScore[neighborKey] = tentativeGScore;
          fScore[neighborKey] = tentativeGScore + _heuristic(neighbor, goal);
          
          openSet.add(_PathNode(neighbor, fScore[neighborKey]!));
        }
      }
    }
    
    // No path found, return direct path
    return [start, goal];
  }
  
  // Heuristic function (Euclidean distance)
  double _heuristic(Position a, Position b) {
    return a.distanceTo(b);
  }
  
  // Reconstruct path from A* result
  List<Position> _reconstructPath(
    Map<String, Position> cameFrom,
    Position current,
    Position start,
  ) {
    final path = <Position>[current];
    var currentKey = '${current.x},${current.y}';
    
    while (cameFrom.containsKey(currentKey)) {
      current = cameFrom[currentKey]!;
      path.insert(0, current);
      currentKey = '${current.x},${current.y}';
    }
    
    return path;
  }
  
  // Add or update room (admin only)
  Future<void> saveRoom(Room room) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      // Mock: would update _mockRooms list
      final index = _mockRooms.indexWhere((r) => r.id == room.id);
      if (index >= 0) {
        _mockRooms[index] = room;
      } else {
        _mockRooms.add(room);
      }
    } catch (e) {
      throw Exception('Failed to save room: $e');
    }
  }
  
  // Delete room (admin only)
  Future<void> deleteRoom(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      // Mock: remove from _mockRooms list
      _mockRooms.removeWhere((room) => room.id == id);
    } catch (e) {
      throw Exception('Failed to delete room: $e');
    }
  }
}

// Priority queue for A* algorithm
class PriorityQueue<T extends _PathNode> {
  final _queue = <T>[];
  
  void add(T item) {
    _queue.add(item);
    _queue.sort((a, b) => a.priority.compareTo(b.priority));
  }
  
  T removeFirst() => _queue.removeAt(0);
  
  bool get isNotEmpty => _queue.isNotEmpty;
}

// Path node for A* algorithm
class _PathNode {
  final Position position;
  final double priority;
  
  _PathNode(this.position, this.priority);
}
