import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../student/student_home.dart';
import '../tutor/tutor_home.dart';
import '../perfil/perfil_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final screens = <Widget>[
      if (auth.isStudent || auth.isTutor) ...{
        if (auth.isStudent) const StudentHome(),
        if (auth.isTutor) const TutorHome(),
      } else
        const Center(child: Text('Bienvenido', style: TextStyle(fontSize: 18))),
      const PerfilScreen(),
    ];

    final titles = <String>[
      if (auth.isStudent) 'Mi Panel',
      if (auth.isTutor) 'Mi Estudiante',
      if (!auth.isStudent && !auth.isTutor) 'Inicio',
      'Mi Perfil',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles.isNotEmpty ? titles[_currentIndex.clamp(0, titles.length - 1)] : 'SIA'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: screens.isNotEmpty ? screens[_currentIndex.clamp(0, screens.length - 1)] : const SizedBox(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: auth.isStudent ? 'Mi Panel' : auth.isTutor ? 'Estudiante' : 'Inicio',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person),
            label: 'Mi Perfil',
          ),
        ],
      ),
    );
  }
}
