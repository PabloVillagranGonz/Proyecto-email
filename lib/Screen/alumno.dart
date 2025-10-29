import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_email/Ajustes/oscuro.dart';
import 'package:proyecto_email/Ajustes/providerA.dart';
import 'package:proyecto_email/Controller/alumnoController.dart';
import 'package:proyecto_email/Screen/recuentos.dart';
import 'package:proyecto_email/Traduccion/traducciones.dart';
import '../BD/basedatos.dart';

/// Clase Alumno que define la pantalla del perfil del alumno.
class AlumnoScreen extends StatefulWidget {
  final String email;

  /// Constructor que requiere un correo electrónico para inicializar.
  const AlumnoScreen({
    Key? key,
    required this.email,
  }) : super(key: key);

  @override
  _AlumnoScreenState createState() => _AlumnoScreenState();
}

class _AlumnoScreenState extends State<AlumnoScreen> {
  /// Controladores de texto para los campos del nombre, apellidos y correo electrónico.
  late TextEditingController _nombreController;
  late TextEditingController _apellidosController;
  late TextEditingController _correoController;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController();
    _apellidosController = TextEditingController();
    _correoController = TextEditingController();
    _cargarDatosUsuario(widget.email);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidosController.dispose();
    _correoController.dispose();
    super.dispose();
  }

  /// Función que obtiene la información de usuario por correo electrónico.
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await BaseDeDatos().database;
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  /// Función que carga los datos del usuario en los controladores de texto.
  void _cargarDatosUsuario(String email) async {
    final user = await getUserByEmail(email);
    if (user != null) {
      setState(() {
        _nombreController.text = user['nombre'];
        _apellidosController.text = user['apellidos'];
        _correoController.text = user['email'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<ProviderA>(context);
    String currentLanguage = languageProvider.idioma.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          Traducciones.translate(currentLanguage, 'Profile Student'),
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF009688),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16.0),
            TextField(
              controller: _nombreController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: Traducciones.translate(currentLanguage, 'Name'),
                fillColor: Theme.of(context).inputDecorationTheme.fillColor,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _apellidosController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: Traducciones.translate(currentLanguage, 'Last name'),
                fillColor: Theme.of(context).inputDecorationTheme.fillColor,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _correoController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: Traducciones.translate(currentLanguage, 'Email'),
                fillColor: Theme.of(context).inputDecorationTheme.fillColor,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: SizedBox(
                width: 250,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            Recuentos(email: _correoController.text),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF009688),
                    minimumSize: const Size(250, 50),
                  ),
                  icon: const Icon(Icons.email, color: Colors.white),
                  label: Text(
                    Traducciones.translate(currentLanguage, 'Email count'),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Traducciones.translate(currentLanguage, 'Change language'),
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium!.color),
                ),
                Consumer<ProviderA>(
                  builder: (context, ajustes, child) {
                    return DropdownButton<String>(
                      value: ajustes.idioma.languageCode == 'es'
                          ? 'Español'
                          : 'Inglés',
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          String languageCode =
                              newValue == 'Español' ? 'es' : 'en';
                          ajustes.cambiarIdioma(languageCode);
                        }
                      },
                      items: <String>['Español', 'Inglés']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Traducciones.translate(currentLanguage, 'Night mode'),
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium!.color),
                ),
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return Switch(
                      value: themeProvider.themeMode == ThemeMode.dark,
                      onChanged: (bool value) {
                        themeProvider.toggleTheme();
                      },
                      activeColor: Colors.blue,
                      inactiveThumbColor: Colors.grey,
                    );
                  },
                ),
              ],
            ),
            const Spacer(),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 300,
                    child: ElevatedButton.icon(
                      onPressed: () => cerrarSesion(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 105, 105, 105),
                        minimumSize: const Size(250, 50),
                      ),
                      icon: Icon(Icons.logout,
                          color: Theme.of(context).textTheme.bodyMedium!.color),
                      label: Text(
                        Traducciones.translate(currentLanguage, 'Log out'),
                        style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 300,
                    child: ElevatedButton.icon(
                      onPressed: () => mostrarDialogoCambioContrasena(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF009688),
                        minimumSize: const Size(250, 50),
                      ),
                      icon: Icon(Icons.password,
                          color: Theme.of(context).textTheme.bodyMedium!.color),
                      label: Text(
                        Traducciones.translate(
                            currentLanguage, 'Change password'),
                        style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 300,
                    child: ElevatedButton.icon(
                      onPressed: () => eliminarUsuario(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD32F2F),
                        minimumSize: const Size(250, 50),
                      ),
                      icon: Icon(Icons.delete,
                          color: Theme.of(context).textTheme.bodyMedium!.color),
                      label: Text(
                        Traducciones.translate(currentLanguage, 'Delete user'),
                        style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
