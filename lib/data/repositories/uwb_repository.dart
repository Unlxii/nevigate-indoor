import 'dart:async';
import '../../domain/entities/position.dart';
import '../services/uwb_service.dart';

class UWBRepository {
  final UWBService uwbService;
  
  UWBRepository({required this.uwbService});
  
  // Get position stream
  Stream<Position?> get positionStream => uwbService.positionStream;
  
  // Get current position
  Position? get currentPosition => uwbService.currentPosition;
  
  // Get anchor information
  Stream<List<AnchorInfo>> get anchorsStream => uwbService.anchorsStream;
  List<AnchorInfo> get anchors => uwbService.anchors;
  
  // Start position tracking
  void startTracking() {
    uwbService.startPositioning();
  }
  
  // Stop position tracking
  void stopTracking() {
    uwbService.stopPositioning();
  }
  
  // Calibrate anchors
  Future<void> calibrateAnchors(List<AnchorPosition> anchorPositions) async {
    await uwbService.calibrateAnchors(anchorPositions);
  }
  
  // Get anchor status
  Future<void> getAnchorStatus() async {
    await uwbService.requestAnchorStatus();
  }
  
  // Calculate position accuracy
  double getPositionAccuracy() {
    final position = currentPosition;
    if (position == null) return 0.0;
    return position.accuracy;
  }
  
  // Check if positioning is reliable
  bool isPositioningReliable() {
    final anchorCount = anchors.length;
    final accuracy = getPositionAccuracy();
    
    return anchorCount >= 2 && accuracy > 0 && accuracy < 1.0;
  }
}
