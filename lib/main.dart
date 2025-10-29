import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_email/Ajustes/oscuro.dart';
import 'package:proyecto_email/Ajustes/providerA.dart';
import 'package:proyecto_email/BD/basedatos.dart';
import 'package:proyecto_email/Screen/alumno.dart';
import 'package:proyecto_email/Screen/login.dart';
import 'package:proyecto_email/Screen/registro.dart';
import 'package:proyecto_email/Traduccion/traducciones.dart';
import 'package:proyecto_email/Screen/correosEnviados.dart';
import 'package:proyecto_email/Screen/recibir.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Función principal que inicializa la aplicación.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  if(Platform.isWindows || Platform.isMacOS) {
    databaseFactory = databaseFactoryFfi;
  } else {
    databaseFactory = databaseFactory;
  }
  await BaseDeDatos().initDatabase();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ProviderA()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: const CentrosNetApp(),
    ),
  );
}

class CentrosNetApp extends StatelessWidget {
  const CentrosNetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light().copyWith(
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(backgroundColor: Colors.blue),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              selectedItemColor: Colors.blue,
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.grey[300],
              labelStyle: const TextStyle(color: Colors.black),
            ),
          ),
          darkTheme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: Colors.black,
            appBarTheme: const AppBarTheme(backgroundColor: Colors.black),
          ),
          themeMode: themeProvider.themeMode,
          locale: Provider.of<ProviderA>(context).idioma,
          supportedLocales: const [Locale('en'), Locale('es')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          initialRoute: '/login',
          routes: {
            '/login': (context) => LoginScreen(),
            '/registro': (context) => RegisterScreen(),
            '/home': (context) => const HomeScreen(email: ''),
          },
        );
      },
    );
  }
}

/// Clase que representa la pantalla principal de la aplicación.
class HomeScreen extends StatefulWidget {
  final String email;

  const HomeScreen({super.key, required this.email});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      EnviarMensaje(),
      RecibirMensaje(),
      AlumnoScreen(email: widget.email),
    ];
  }

  /// Cambia la pantalla mostrada según el índice seleccionado.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<ProviderA>(context);
    String currentLanguage = languageProvider.idioma.languageCode;

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor:
            Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor:
            Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor:
            Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.check_circle),
            label: Traducciones.translate(currentLanguage, "Send"),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.message),
            label: Traducciones.translate(currentLanguage, "Receive"),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: Traducciones.translate(currentLanguage, "Profile"),
          ),
        ],
      ),
    );
  }
}
