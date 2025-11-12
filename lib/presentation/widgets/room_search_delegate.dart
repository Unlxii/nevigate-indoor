import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/navigation/navigation_bloc.dart';
import '../../domain/entities/room.dart';

class RoomSearchDelegate extends SearchDelegate<Room?> {
  @override
  String get searchFieldLabel => 'ค้นหาห้อง...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return const Center(
        child: Text('กรุณากรอกชื่อห้องที่ต้องการค้นหา'),
      );
    }

    context.read<NavigationBloc>().add(SearchRoomsEvent(query));

    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        if (state is NavigationLoadingState) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is RoomSearchResultState) {
          if (state.results.isEmpty) {
            return const Center(
              child: Text('ไม่พบห้องที่ค้นหา'),
            );
          }

          return ListView.builder(
            itemCount: state.results.length,
            itemBuilder: (context, index) {
              final room = state.results[index];
              return ListTile(
                leading: const Icon(Icons.room),
                title: Text(room.name),
                subtitle: Text(room.description),
                trailing: Text('ชั้น ${room.floor}'),
                onTap: () {
                  close(context, room);
                },
              );
            },
          );
        }

        if (state is NavigationErrorState) {
          return Center(
            child: Text('เกิดข้อผิดพลาด: ${state.message}'),
          );
        }

        return const Center(
          child: Text('กรุณากดค้นหา'),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'ค้นหาห้องที่ต้องการไป',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Show suggestions while typing
    context.read<NavigationBloc>().add(SearchRoomsEvent(query));

    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        if (state is NavigationLoadingState) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is RoomSearchResultState) {
          return ListView.builder(
            itemCount: state.results.length,
            itemBuilder: (context, index) {
              final room = state.results[index];
              return ListTile(
                leading: const Icon(Icons.room),
                title: Text(room.name),
                subtitle: Text(room.description),
                trailing: Text('ชั้น ${room.floor}'),
                onTap: () {
                  close(context, room);
                },
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
