import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/positioning/positioning_bloc.dart';
import '../../bloc/navigation/navigation_bloc.dart';
import '../../../domain/entities/position.dart';
import '../../../domain/entities/room.dart';
import '../../widgets/floor_map_painter.dart';
import '../../widgets/room_search_delegate.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  double _scale = 1.0;
  Offset _offset = Offset.zero;
  Offset _startFocalPoint = Offset.zero;
  Offset _lastFocalPoint = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildStatusBar(),
          Expanded(
            child: Stack(
              children: [
                _buildMap(),
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: _buildSearchBar(),
                ),
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: _buildZoomControls(),
                ),
              ],
            ),
          ),
          _buildNavigationInfo(),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    return BlocBuilder<PositioningBloc, PositioningState>(
      builder: (context, state) {
        if (state is PositioningActiveState) {
          final isReliable = state.isReliable;
          final anchorCount = state.anchors.length;
          
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: isReliable ? Colors.green : Colors.orange,
            child: Row(
              children: [
                Icon(
                  isReliable ? Icons.check_circle : Icons.warning,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isReliable
                        ? 'ระบุตำแหน่งได้ ($anchorCount จุดอ้างอิง)'
                        : 'กำลังค้นหาสัญญาณ... ($anchorCount จุดอ้างอิง)',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.grey,
          child: const Row(
            children: [
              Icon(Icons.location_off, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'ระบบตำแหน่งไม่ทำงาน',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMap() {
    return GestureDetector(
      onScaleStart: (details) {
        _startFocalPoint = details.focalPoint;
        _lastFocalPoint = _offset;
      },
      onScaleUpdate: (details) {
        setState(() {
          // Handle zoom
          _scale = (_scale * details.scale).clamp(0.5, 3.0);
          
          // Handle pan
          _offset = _lastFocalPoint + (details.focalPoint - _startFocalPoint);
        });
      },
      child: BlocBuilder<PositioningBloc, PositioningState>(
        builder: (context, positioningState) {
          return BlocBuilder<NavigationBloc, NavigationState>(
            builder: (context, navigationState) {
              Position? currentPosition;
              List<Room> rooms = [];
              List<Position>? pathWaypoints;

              if (positioningState is PositioningActiveState) {
                currentPosition = positioningState.position;
              }

              if (navigationState is RoomsLoadedState) {
                rooms = navigationState.rooms;
              } else if (navigationState is NavigationPathCalculatedState) {
                pathWaypoints = navigationState.path.waypoints;
              }

              return CustomPaint(
                painter: FloorMapPainter(
                  currentPosition: currentPosition,
                  rooms: rooms,
                  pathWaypoints: pathWaypoints,
                  scale: _scale,
                  offset: _offset,
                ),
                child: Container(),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        onTap: () async {
          final result = await showSearch(
            context: context,
            delegate: RoomSearchDelegate(),
          );
          
          if (result != null && result is Room) {
            _navigateToRoom(result);
          }
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.search, color: Colors.grey[600]),
              const SizedBox(width: 12),
              Text(
                'ค้นหาห้อง...',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildZoomControls() {
    return Column(
      children: [
        FloatingActionButton.small(
          heroTag: 'zoom_in',
          onPressed: () {
            setState(() {
              _scale = (_scale + 0.2).clamp(0.5, 3.0);
            });
          },
          child: const Icon(Icons.add),
        ),
        const SizedBox(height: 8),
        FloatingActionButton.small(
          heroTag: 'zoom_out',
          onPressed: () {
            setState(() {
              _scale = (_scale - 0.2).clamp(0.5, 3.0);
            });
          },
          child: const Icon(Icons.remove),
        ),
      ],
    );
  }

  Widget _buildNavigationInfo() {
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        if (state is NavigationPathCalculatedState) {
          final path = state.path;
          final room = state.destinationRoom;
          
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.navigation, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            room?.name ?? 'กำลังนำทาง',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${path.totalDistance.toStringAsFixed(1)} เมตร • ${path.estimatedTime.inMinutes} นาที',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        context
                            .read<NavigationBloc>()
                            .add(ClearNavigationEvent());
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        }
        
        return const SizedBox.shrink();
      },
    );
  }

  void _navigateToRoom(Room room) {
    final positioningState = context.read<PositioningBloc>().state;
    
    if (positioningState is PositioningActiveState &&
        positioningState.position != null) {
      context.read<NavigationBloc>().add(
            NavigateToRoomEvent(
              roomId: room.id,
              currentPosition: positioningState.position!,
            ),
          );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ไม่สามารถระบุตำแหน่งปัจจุบันได้'),
        ),
      );
    }
  }
}
