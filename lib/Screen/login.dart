import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_email/Ajustes/providerA.dart';
import 'package:proyecto_email/BD/basedatos.dart';
import 'package:proyecto_email/Screen/registro.dart';
import 'package:proyecto_email/Traduccion/traducciones.dart';
import 'package:proyecto_email/main.dart';

/// Pantalla de inicio de sesión.
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

/// Estado de la pantalla de inicio de sesión.
class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  /// Controladores de texto para los campos.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  /// Instancia de la base de datos.
  final _database = BaseDeDatos();

  /// Inicia sesión con las credenciales proporcionadas.
  void _login(BuildContext context) async {
    final languageProvider = Provider.of<ProviderA>(context, listen: false);
    String currentLanguage = languageProvider.idioma.languageCode;

    if (!_formKey.currentState!.validate()) {
      return; // Si el formulario no es válido, no continuar.
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final user = await _database.getUser(email, password);
    if (user != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(email: email),
        ),
      );
    } else {
      _showErrorDialog(
        context,
        Traducciones.translate(currentLanguage, 'Error'),
        Traducciones.translate(currentLanguage,
            'The user does not exist or the password is incorrect.'),
      );
    }
  }

  /// Muestra un diálogo de error.
  void _showErrorDialog(BuildContext context, String title, String message) {
    final languageProvider = Provider.of<ProviderA>(context, listen: false);
    String currentLanguage = languageProvider.idioma.languageCode;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: const TextStyle(color: Color(0xFF212121))),
        content:
            Text(message, style: const TextStyle(color: Color(0xFF757575))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              Traducciones.translate(currentLanguage, 'Accept'),
              style: const TextStyle(color: Color(0xFF009688)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<ProviderA>(context, listen: false);
    String currentLanguage = languageProvider.idioma.languageCode;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey, // Asignamos la clave al formulario
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// Imagen del gestor.
                Image.asset(
                  'lib/Ajustes/gestor.jpg',
                  width: 150,
                  height: 150,
                ),
                const SizedBox(height: 24),

                /// Campo de texto para el correo electrónico.
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: Traducciones.translate(
                        currentLanguage, "Enter your email"),
                    labelStyle: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium!.color),
                    border: const OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFF009688)),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  cursorColor: const Color(0xFF009688),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return Traducciones.translate(
                          currentLanguage, 'Please enter your email');
                    }
                    if (!RegExp(
                            r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                        .hasMatch(value)) {
                      return Traducciones.translate(
                          currentLanguage, 'Please enter a valid email');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                /// Campo de texto para la contraseña.
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: Traducciones.translate(
                        currentLanguage, "Enter your password"),
                    labelStyle: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium!.color),
                    border: const OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFF009688)),
                    ),
                  ),
                  cursorColor: const Color(0xFF009688),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return Traducciones.translate(
                          currentLanguage, 'Please enter your password');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                Semantics(
                  label:
                      Traducciones.translate(currentLanguage, 'Login button'),
                  hint: Traducciones.translate(currentLanguage,
                      'Press when you have entered your username and password'),

                  /// Botón de inicio de sesión.
                  child: ElevatedButton.icon(
                    onPressed: () => _login(context),
                    icon: const Icon(Icons.login, color: Colors.white),
                    label:
                        Text(Traducciones.translate(currentLanguage, "Login")),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF009688),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Semantics(
                  label: Traducciones.translate(
                      currentLanguage, 'Create account button'),
                  hint: Traducciones.translate(
                      currentLanguage, 'Press to create a new account'),

                  /// Botón para crear una cuenta.
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RegisterScreen()),
                      );
                    },
                    child: Text(
                      Traducciones.translate(currentLanguage, "Create Account"),
                      style: const TextStyle(color: Color(0xFF009688)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
