import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:rxdart/rxdart.dart';
import '../../domain/entities/position.dart';
import '../../core/config/app_config.dart';
import 'bluetooth_service.dart';

class UWBService {
  final BluetoothService bluetoothService;
  
  final BehaviorSubject<Position?> _positionSubject = 
      BehaviorSubject<Position?>.seeded(null);
  
  final BehaviorSubject<List<AnchorInfo>> _anchorsSubject = 
      BehaviorSubject<List<AnchorInfo>>.seeded([]);
  
  StreamSubscription? _dataSubscription;
  
  UWBService({required this.bluetoothService});
  
  Stream<Position?> get positionStream => _positionSubject.stream;
  Stream<List<AnchorInfo>> get anchorsStream => _anchorsSubject.stream;
  
  Position? get currentPosition => _positionSubject.value;
  List<AnchorInfo> get anchors => _anchorsSubject.value;
  
  // Start listening to UWB position data
  void startPositioning() {
    _dataSubscription?.cancel();
    
    _dataSubscription = bluetoothService.dataStream.listen((data) {
      try {
        final position = _parsePositionData(data);
        if (position != null) {
          _positionSubject.add(position);
        }
      } catch (e) {
        print('Error parsing position data: $e');
      }
    });
  }
  
  // Stop listening to position data
  void stopPositioning() {
    _dataSubscription?.cancel();
    _dataSubscription = null;
  }
  
  // Parse position data from UWB receiver
  Position? _parsePositionData(List<int> data) {
    try {
      // Convert bytes to string
      final jsonString = utf8.decode(data);
      final json = jsonDecode(jsonString);
      
      // Expected format:
      // {
      //   "x": 1.23,
      //   "y": 4.56,
      //   "z": 0.0,
      //   "accuracy": 0.15,
      //   "anchors": [
      //     {"id": "A1", "distance": 2.3, "rssi": -45},
      //     {"id": "A2", "distance": 3.1, "rssi": -50}
      //   ]
      // }
      
      final position = Position(
        x: json['x']?.toDouble() ?? 0.0,
        y: json['y']?.toDouble() ?? 0.0,
        z: json['z']?.toDouble() ?? 0.0,
        timestamp: DateTime.now(),
        accuracy: json['accuracy']?.toDouble() ?? 0.0,
      );
      
      // Update anchor information
      if (json['anchors'] != null) {
        final anchors = (json['anchors'] as List)
            .map((a) => AnchorInfo.fromJson(a))
            .toList();
        _anchorsSubject.add(anchors);
      }
      
      return position;
    } catch (e) {
      print('Error parsing position data: $e');
      return null;
    }
  }
  
  // Calibrate anchors
  Future<void> calibrateAnchors(List<AnchorPosition> anchorPositions) async {
    // Send calibration data to the UWB receiver
    final calibrationData = {
      'command': 'calibrate',
      'anchors': anchorPositions.map((a) => a.toJson()).toList(),
    };
    
    final jsonString = jsonEncode(calibrationData);
    final bytes = utf8.encode(jsonString);
    
    await bluetoothService.sendCommand(bytes);
  }
  
  // Request anchor status
  Future<void> requestAnchorStatus() async {
    final command = utf8.encode('{"command":"status"}');
    await bluetoothService.sendCommand(command);
  }
  
  void dispose() {
    _dataSubscription?.cancel();
    _positionSubject.close();
    _anchorsSubject.close();
  }
}

// Anchor information from UWB system
class AnchorInfo {
  final String id;
  final double distance;
  final int rssi;
  
  AnchorInfo({
    required this.id,
    required this.distance,
    required this.rssi,
  });
  
  factory AnchorInfo.fromJson(Map<String, dynamic> json) {
    return AnchorInfo(
      id: json['id'],
      distance: json['distance']?.toDouble() ?? 0.0,
      rssi: json['rssi'] ?? 0,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'distance': distance,
      'rssi': rssi,
    };
  }
}

// Anchor position for calibration
class AnchorPosition {
  final String id;
  final Position position;
  
  AnchorPosition({
    required this.id,
    required this.position,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'position': position.toJson(),
    };
  }
}
