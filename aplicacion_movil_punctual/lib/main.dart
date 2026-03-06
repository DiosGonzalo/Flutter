import 'package:aplicacion_movil_punctual/config/app_routes.dart';
import 'package:aplicacion_movil_punctual/feature/checkin/ui/check_in_screen.dart';
import 'package:aplicacion_movil_punctual/feature/dashboard/ui/dashboard_screen.dart';
import 'package:aplicacion_movil_punctual/feature/home/ui/home_schedule_screen.dart';
import 'package:aplicacion_movil_punctual/feature/login/ui/login_screen.dart';
import 'package:aplicacion_movil_punctual/feature/profile/ui/profile_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mi Proyecto App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.dashboard: (_) => const DashboardScreen(),
        AppRoutes.checkin: (_) => const CheckInScreen(),
        AppRoutes.home: (_) => const HomeScheduleScreen(),
        AppRoutes.profile: (_) => const ProfileScreen(),
      },
    );
  }
}