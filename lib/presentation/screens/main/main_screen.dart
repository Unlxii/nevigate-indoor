import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/positioning/positioning_bloc.dart';
import '../../bloc/navigation/navigation_bloc.dart';
import '../../../domain/entities/user_model.dart';
import '../map/map_view_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import '../profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Start positioning on app start
    context.read<PositioningBloc>().add(StartPositioningEvent());
    // Load rooms
    context.read<NavigationBloc>().add(LoadRoomsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthenticatedState) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = authState.user;
        final isAdmin = user.role == UserRole.admin;

        final screens = [
          const MapViewScreen(),
          isAdmin ? const AdminDashboardScreen() : const ProfileScreen(),
        ];

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.explore,
                    size: 24,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                const Text('Indoor Navigation'),
              ],
            ),
            actions: [
              // User badge
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: user.isAdmin 
                      ? Theme.of(context).colorScheme.tertiaryContainer
                      : Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      user.isAdmin ? Icons.admin_panel_settings : Icons.person,
                      size: 16,
                      color: user.isAdmin
                          ? Theme.of(context).colorScheme.onTertiaryContainer
                          : Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      user.email.split('@').first,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: user.isAdmin
                            ? Theme.of(context).colorScheme.onTertiaryContainer
                            : Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.logout_rounded),
                tooltip: 'ออกจากระบบ',
                onPressed: () => _showLogoutDialog(context),
              ),
            ],
          ),
          body: IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            animationDuration: const Duration(milliseconds: 400),
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.map_outlined),
                selectedIcon: Icon(
                  Icons.map,
                  color: Theme.of(context).colorScheme.primary,
                ),
                label: 'แผนที่',
              ),
              NavigationDestination(
                icon: Icon(
                  isAdmin ? Icons.admin_panel_settings_outlined : Icons.person_outline,
                ),
                selectedIcon: Icon(
                  isAdmin ? Icons.admin_panel_settings : Icons.person,
                  color: Theme.of(context).colorScheme.primary,
                ),
                label: isAdmin ? 'จัดการ' : 'โปรไฟล์',
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ออกจากระบบ'),
        content: const Text('คุณต้องการออกจากระบบใช่หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthBloc>().add(SignOutEvent());
              Navigator.of(context).pushReplacementNamed('/login');
            },
            child: const Text('ออกจากระบบ'),
          ),
        ],
      ),
    );
  }
}
