import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:firebase_core/firebase_core.dart'; // ปิดไว้ก่อน - จะเปิดทีหลัง
import 'package:provider/provider.dart';

import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/uwb_repository.dart';
import 'data/repositories/navigation_repository.dart';
import 'data/services/bluetooth_service.dart';
import 'data/services/uwb_service.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/positioning/positioning_bloc.dart';
import 'presentation/bloc/navigation/navigation_bloc.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/main/main_screen.dart';
import 'presentation/screens/permission/permission_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase - ปิดไว้ก่อน จะเปิดทีหลัง
  // await Firebase.initializeApp();
  
  runApp(const IndoorNavigationApp());
}

class IndoorNavigationApp extends StatelessWidget {
  const IndoorNavigationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Services
        Provider<BluetoothService>(
          create: (_) => BluetoothService(),
        ),
        Provider<UWBService>(
          create: (context) => UWBService(
            bluetoothService: context.read<BluetoothService>(),
          ),
        ),
        
        // Repositories
        Provider<AuthRepository>(
          create: (_) => AuthRepository(),
        ),
        Provider<UWBRepository>(
          create: (context) => UWBRepository(
            uwbService: context.read<UWBService>(),
          ),
        ),
        Provider<NavigationRepository>(
          create: (_) => NavigationRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
            )..add(CheckAuthStatusEvent()),
          ),
          BlocProvider<PositioningBloc>(
            create: (context) => PositioningBloc(
              uwbRepository: context.read<UWBRepository>(),
            ),
          ),
          BlocProvider<NavigationBloc>(
            create: (context) => NavigationBloc(
              navigationRepository: context.read<NavigationRepository>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: AppConfig.appName,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(),
            '/login': (context) => const LoginScreen(),
            '/permission': (context) => const PermissionScreen(),
            '/main': (context) => const MainScreen(),
          },
        ),
      ),
    );
  }
}
