import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/position.dart';
import '../../../data/repositories/uwb_repository.dart';
import '../../../data/services/uwb_service.dart';

// Events
abstract class PositioningEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class StartPositioningEvent extends PositioningEvent {}

class StopPositioningEvent extends PositioningEvent {}

class PositionUpdatedEvent extends PositioningEvent {
  final Position? position;
  
  PositionUpdatedEvent(this.position);
  
  @override
  List<Object?> get props => [position];
}

class AnchorsUpdatedEvent extends PositioningEvent {
  final List<AnchorInfo> anchors;
  
  AnchorsUpdatedEvent(this.anchors);
  
  @override
  List<Object?> get props => [anchors];
}

class CalibrateAnchorsEvent extends PositioningEvent {
  final List<AnchorPosition> anchorPositions;
  
  CalibrateAnchorsEvent(this.anchorPositions);
  
  @override
  List<Object?> get props => [anchorPositions];
}

// States
abstract class PositioningState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PositioningInitialState extends PositioningState {}

class PositioningActiveState extends PositioningState {
  final Position? position;
  final List<AnchorInfo> anchors;
  final bool isReliable;
  
  PositioningActiveState({
    this.position,
    this.anchors = const [],
    this.isReliable = false,
  });
  
  @override
  List<Object?> get props => [position, anchors, isReliable];
  
  PositioningActiveState copyWith({
    Position? position,
    List<AnchorInfo>? anchors,
    bool? isReliable,
  }) {
    return PositioningActiveState(
      position: position ?? this.position,
      anchors: anchors ?? this.anchors,
      isReliable: isReliable ?? this.isReliable,
    );
  }
}

class PositioningInactiveState extends PositioningState {}

class PositioningErrorState extends PositioningState {
  final String message;
  
  PositioningErrorState(this.message);
  
  @override
  List<Object?> get props => [message];
}

// BLoC
class PositioningBloc extends Bloc<PositioningEvent, PositioningState> {
  final UWBRepository uwbRepository;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _anchorsSubscription;
  
  PositioningBloc({required this.uwbRepository}) 
      : super(PositioningInitialState()) {
    on<StartPositioningEvent>(_onStartPositioning);
    on<StopPositioningEvent>(_onStopPositioning);
    on<PositionUpdatedEvent>(_onPositionUpdated);
    on<AnchorsUpdatedEvent>(_onAnchorsUpdated);
    on<CalibrateAnchorsEvent>(_onCalibrateAnchors);
  }
  
  Future<void> _onStartPositioning(
    StartPositioningEvent event,
    Emitter<PositioningState> emit,
  ) async {
    try {
      uwbRepository.startTracking();
      
      emit(PositioningActiveState());
      
      // Listen to position updates
      _positionSubscription?.cancel();
      _positionSubscription = uwbRepository.positionStream.listen((position) {
        add(PositionUpdatedEvent(position));
      });
      
      // Listen to anchor updates
      _anchorsSubscription?.cancel();
      _anchorsSubscription = uwbRepository.anchorsStream.listen((anchors) {
        add(AnchorsUpdatedEvent(anchors));
      });
    } catch (e) {
      emit(PositioningErrorState(e.toString()));
    }
  }
  
  Future<void> _onStopPositioning(
    StopPositioningEvent event,
    Emitter<PositioningState> emit,
  ) async {
    uwbRepository.stopTracking();
    _positionSubscription?.cancel();
    _anchorsSubscription?.cancel();
    
    emit(PositioningInactiveState());
  }
  
  Future<void> _onPositionUpdated(
    PositionUpdatedEvent event,
    Emitter<PositioningState> emit,
  ) async {
    if (state is PositioningActiveState) {
      final currentState = state as PositioningActiveState;
      final isReliable = uwbRepository.isPositioningReliable();
      
      emit(currentState.copyWith(
        position: event.position,
        isReliable: isReliable,
      ));
    }
  }
  
  Future<void> _onAnchorsUpdated(
    AnchorsUpdatedEvent event,
    Emitter<PositioningState> emit,
  ) async {
    if (state is PositioningActiveState) {
      final currentState = state as PositioningActiveState;
      final isReliable = uwbRepository.isPositioningReliable();
      
      emit(currentState.copyWith(
        anchors: event.anchors,
        isReliable: isReliable,
      ));
    }
  }
  
  Future<void> _onCalibrateAnchors(
    CalibrateAnchorsEvent event,
    Emitter<PositioningState> emit,
  ) async {
    try {
      await uwbRepository.calibrateAnchors(event.anchorPositions);
    } catch (e) {
      emit(PositioningErrorState(e.toString()));
    }
  }
  
  @override
  Future<void> close() {
    _positionSubscription?.cancel();
    _anchorsSubscription?.cancel();
    return super.close();
  }
}
