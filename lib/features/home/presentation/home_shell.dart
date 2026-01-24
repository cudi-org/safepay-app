import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Constantes
import '../../../core/constants/app_colors.dart';

// Vistas que irán en el body
import '../../activity/presentation/activity_screen.dart'; // Pestaña 1
import '../../bulut_chat/presentation/chat_screen.dart'; // Pestaña 2
import '../../settings/presentation/settings_screen.dart'; // Pestaña 3

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _selectedIndex =
      0; // Estado para la pestaña activa (0: Home, 1: Bulut, 2: Settings)

  // Lista de las pantallas que irán en el body
  static final List<Widget> _widgetOptions = <Widget>[
    const ActivityScreen(), // Pestaña Home/Actividad
    const ChatScreen(), // Pestaña Bulut/Chat
    const SettingsScreen(), // Pestaña Ajustes
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Muestra la pantalla seleccionada
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),

      // La Barra de Navegación Inferior
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        decoration: BoxDecoration(
          color: AppColors.textPrimary, // Usa el color oscuro para el Navbar
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25.0),
            topRight: Radius.circular(25.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: AppColors.textPrimary,
          selectedItemColor:
              AppColors.primary, // Color Verde Menta para el activo
          unselectedItemColor: Colors.grey,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          elevation: 0,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType
              .fixed, // Mantiene el tamaño de los iconos fijos
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.cloud_queue_rounded), // Icono de Nube para Bulut
              label: 'Bulut',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_rounded),
              label: 'Ajustes',
            ),
          ],
        ),
      ),
    );
  }
}

// Nota: Debes crear las carpetas y archivos feature/activity/presentation/activity_screen.dart, etc.
// En los siguientes pasos se crearán las vistas reales.
