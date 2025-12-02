import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/tables_screen.dart';
import 'screens/reservations_screen.dart';
import 'screens/menu_screen.dart';
import 'screens/mescommandes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restaurant Express',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color.fromARGB(255, 151, 88, 5),
      ),
      home: LoginScreen(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(),
        '/tables': (context) => TablesScreen(),
        '/reservations': (context) => ReservationsScreen(),
        '/menu': (context) => MenuScreen(),
        '/mes-commandes': (context) => MesCommandesScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
