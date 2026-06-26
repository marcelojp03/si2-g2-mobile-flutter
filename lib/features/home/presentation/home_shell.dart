import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';

class HomeShell extends ConsumerWidget {
  final Widget child;

  const HomeShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final user = ref.watch(authProvider).user;
    final isTutor = user?.esTutor == true;
    final isEstudiante = user?.esEstudiante == true;
    final showAcademicTabs = isEstudiante || (!isTutor && user != null);

    final destinations = <NavigationDestination>[
      const NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: 'Inicio',
      ),
      const NavigationDestination(
        icon: Icon(Icons.credit_card_outlined),
        selectedIcon: Icon(Icons.credit_card),
        label: 'Cuotas',
      ),
      if (showAcademicTabs) ...[
        const NavigationDestination(
          icon: Icon(Icons.calendar_month_outlined),
          selectedIcon: Icon(Icons.calendar_month),
          label: 'Asistencia',
        ),
        const NavigationDestination(
          icon: Icon(Icons.grading_outlined),
          selectedIcon: Icon(Icons.grading),
          label: 'Notas',
        ),
      ],
    ];

    final currentIndex = _selectedIndex(location, showAcademicTabs);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (i) {
          switch (i) {
            case 0: context.go('/home');
            case 1: context.go('/cuotas');
            case 2: if (showAcademicTabs) context.go('/asistencia');
            case 3: if (showAcademicTabs) context.go('/calificaciones');
          }
        },
        destinations: destinations,
      ),
    );
  }

  int _selectedIndex(String location, bool showAcademic) {
    if (location.startsWith('/cuotas')) return 1;
    if (showAcademic) {
      if (location.startsWith('/asistencia')) return 2;
      if (location.startsWith('/calificaciones')) return 3;
    }
    return 0;
  }
}
