import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../domain/entities/position.dart';
import '../../domain/entities/room.dart';

class FloorMapPainter extends CustomPainter {
  final Position? currentPosition;
  final List<Room> rooms;
  final List<Position>? pathWaypoints;
  final double scale;
  final Offset offset;

  FloorMapPainter({
    this.currentPosition,
    this.rooms = const [],
    this.pathWaypoints,
    this.scale = 1.0,
    this.offset = Offset.zero,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Set up transform
    canvas.save();
    canvas.translate(size.width / 2 + offset.dx, size.height / 2 + offset.dy);
    canvas.scale(scale);

    // Draw grid
    _drawGrid(canvas, size);

    // Draw rooms
    for (final room in rooms) {
      _drawRoom(canvas, room);
    }

    // Draw navigation path
    if (pathWaypoints != null && pathWaypoints!.length > 1) {
      _drawPath(canvas, pathWaypoints!);
    }

    // Draw current position
    if (currentPosition != null) {
      _drawCurrentPosition(canvas, currentPosition!);
    }

    canvas.restore();
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 1.0;

    final gridSize = 50.0; // 50 pixels = 5 meters
    final count = (math.max(size.width, size.height) / gridSize * 2).ceil();

    for (int i = -count; i <= count; i++) {
      final offset = i * gridSize;
      
      // Vertical lines
      canvas.drawLine(
        Offset(offset, -size.height),
        Offset(offset, size.height),
        paint,
      );
      
      // Horizontal lines
      canvas.drawLine(
        Offset(-size.width, offset),
        Offset(size.width, offset),
        paint,
      );
    }
  }

  void _drawRoom(Canvas canvas, Room room) {
    if (room.boundary.isEmpty) return;

    final path = Path();
    final firstPoint = _positionToOffset(room.boundary.first);
    path.moveTo(firstPoint.dx, firstPoint.dy);

    for (int i = 1; i < room.boundary.length; i++) {
      final point = _positionToOffset(room.boundary[i]);
      path.lineTo(point.dx, point.dy);
    }
    path.close();

    // Fill room
    final fillPaint = Paint()
      ..color = Colors.blue.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Draw room border
    final borderPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, borderPaint);

    // Draw room label
    final center = _positionToOffset(room.centerPosition);
    final textPainter = TextPainter(
      text: TextSpan(
        text: room.name,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  void _drawPath(Canvas canvas, List<Position> waypoints) {
    final path = Path();
    final firstPoint = _positionToOffset(waypoints.first);
    path.moveTo(firstPoint.dx, firstPoint.dy);

    for (int i = 1; i < waypoints.length; i++) {
      final point = _positionToOffset(waypoints[i]);
      path.lineTo(point.dx, point.dy);
    }

    // Draw path line
    final pathPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, pathPaint);

    // Draw waypoint markers
    for (final waypoint in waypoints) {
      final point = _positionToOffset(waypoint);
      final markerPaint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.fill;
      canvas.drawCircle(point, 4.0, markerPaint);
    }

    // Draw destination marker
    final lastPoint = _positionToOffset(waypoints.last);
    final destPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    canvas.drawCircle(lastPoint, 8.0, destPaint);
    
    final destBorderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(lastPoint, 8.0, destBorderPaint);
  }

  void _drawCurrentPosition(Canvas canvas, Position position) {
    final point = _positionToOffset(position);

    // Draw accuracy circle
    final accuracyPaint = Paint()
      ..color = Colors.blue.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(point, position.accuracy * 10, accuracyPaint);

    // Draw position marker
    final markerPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    canvas.drawCircle(point, 10.0, markerPaint);

    // Draw marker border
    final borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(point, 10.0, borderPaint);

    // Draw direction indicator (pointing up)
    final arrowPath = Path();
    arrowPath.moveTo(point.dx, point.dy - 12);
    arrowPath.lineTo(point.dx - 5, point.dy - 6);
    arrowPath.lineTo(point.dx + 5, point.dy - 6);
    arrowPath.close();

    final arrowPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawPath(arrowPath, arrowPaint);
  }

  Offset _positionToOffset(Position position) {
    // Convert meters to pixels (10 pixels = 1 meter)
    return Offset(position.x * 10, -position.y * 10);
  }

  @override
  bool shouldRepaint(FloorMapPainter oldDelegate) {
    return currentPosition != oldDelegate.currentPosition ||
        rooms != oldDelegate.rooms ||
        pathWaypoints != oldDelegate.pathWaypoints ||
        scale != oldDelegate.scale ||
        offset != oldDelegate.offset;
  }
}
