import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/position.dart';
import '../../../domain/entities/room.dart';
import '../../../domain/entities/navigation_path.dart';
import '../../../data/repositories/navigation_repository.dart';

// Events
abstract class NavigationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadRoomsEvent extends NavigationEvent {
  final int? floor;
  
  LoadRoomsEvent({this.floor});
  
  @override
  List<Object?> get props => [floor];
}

class SearchRoomsEvent extends NavigationEvent {
  final String query;
  
  SearchRoomsEvent(this.query);
  
  @override
  List<Object?> get props => [query];
}

class CalculatePathEvent extends NavigationEvent {
  final Position start;
  final Position destination;
  
  CalculatePathEvent({
    required this.start,
    required this.destination,
  });
  
  @override
  List<Object?> get props => [start, destination];
}

class NavigateToRoomEvent extends NavigationEvent {
  final String roomId;
  final Position currentPosition;
  
  NavigateToRoomEvent({
    required this.roomId,
    required this.currentPosition,
  });
  
  @override
  List<Object?> get props => [roomId, currentPosition];
}

class ClearNavigationEvent extends NavigationEvent {}

class FindCurrentRoomEvent extends NavigationEvent {
  final Position position;
  
  FindCurrentRoomEvent(this.position);
  
  @override
  List<Object?> get props => [position];
}

// States
abstract class NavigationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NavigationInitialState extends NavigationState {}

class NavigationLoadingState extends NavigationState {}

class RoomsLoadedState extends NavigationState {
  final List<Room> rooms;
  final Room? currentRoom;
  
  RoomsLoadedState({
    required this.rooms,
    this.currentRoom,
  });
  
  @override
  List<Object?> get props => [rooms, currentRoom];
}

class RoomSearchResultState extends NavigationState {
  final List<Room> results;
  
  RoomSearchResultState(this.results);
  
  @override
  List<Object?> get props => [results];
}

class NavigationPathCalculatedState extends NavigationState {
  final NavigationPath path;
  final Room? destinationRoom;
  
  NavigationPathCalculatedState({
    required this.path,
    this.destinationRoom,
  });
  
  @override
  List<Object?> get props => [path, destinationRoom];
}

class NavigationErrorState extends NavigationState {
  final String message;
  
  NavigationErrorState(this.message);
  
  @override
  List<Object?> get props => [message];
}

// BLoC
class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  final NavigationRepository navigationRepository;
  
  NavigationBloc({required this.navigationRepository}) 
      : super(NavigationInitialState()) {
    on<LoadRoomsEvent>(_onLoadRooms);
    on<SearchRoomsEvent>(_onSearchRooms);
    on<CalculatePathEvent>(_onCalculatePath);
    on<NavigateToRoomEvent>(_onNavigateToRoom);
    on<ClearNavigationEvent>(_onClearNavigation);
    on<FindCurrentRoomEvent>(_onFindCurrentRoom);
  }
  
  Future<void> _onLoadRooms(
    LoadRoomsEvent event,
    Emitter<NavigationState> emit,
  ) async {
    emit(NavigationLoadingState());
    
    try {
      final rooms = await navigationRepository.getRooms(floor: event.floor);
      emit(RoomsLoadedState(rooms: rooms));
    } catch (e) {
      emit(NavigationErrorState(e.toString()));
    }
  }
  
  Future<void> _onSearchRooms(
    SearchRoomsEvent event,
    Emitter<NavigationState> emit,
  ) async {
    emit(NavigationLoadingState());
    
    try {
      final results = await navigationRepository.searchRooms(event.query);
      emit(RoomSearchResultState(results));
    } catch (e) {
      emit(NavigationErrorState(e.toString()));
    }
  }
  
  Future<void> _onCalculatePath(
    CalculatePathEvent event,
    Emitter<NavigationState> emit,
  ) async {
    emit(NavigationLoadingState());
    
    try {
      final path = await navigationRepository.calculatePath(
        start: event.start,
        destination: event.destination,
      );
      
      emit(NavigationPathCalculatedState(path: path));
    } catch (e) {
      emit(NavigationErrorState(e.toString()));
    }
  }
  
  Future<void> _onNavigateToRoom(
    NavigateToRoomEvent event,
    Emitter<NavigationState> emit,
  ) async {
    emit(NavigationLoadingState());
    
    try {
      final room = await navigationRepository.getRoomById(event.roomId);
      
      if (room != null) {
        final path = await navigationRepository.calculatePath(
          start: event.currentPosition,
          destination: room.centerPosition,
        );
        
        emit(NavigationPathCalculatedState(
          path: path,
          destinationRoom: room,
        ));
      } else {
        emit(NavigationErrorState('Room not found'));
      }
    } catch (e) {
      emit(NavigationErrorState(e.toString()));
    }
  }
  
  Future<void> _onClearNavigation(
    ClearNavigationEvent event,
    Emitter<NavigationState> emit,
  ) async {
    emit(NavigationInitialState());
  }
  
  Future<void> _onFindCurrentRoom(
    FindCurrentRoomEvent event,
    Emitter<NavigationState> emit,
  ) async {
    try {
      final room = await navigationRepository.findRoomByPosition(event.position);
      
      if (state is RoomsLoadedState) {
        final currentState = state as RoomsLoadedState;
        emit(RoomsLoadedState(
          rooms: currentState.rooms,
          currentRoom: room,
        ));
      }
    } catch (e) {
      // Don't emit error for room detection failures
      print('Failed to find current room: $e');
    }
  }
}
