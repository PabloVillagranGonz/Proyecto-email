import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_email/Ajustes/providerA.dart';
import 'package:proyecto_email/BD/basedatos.dart';
import 'package:proyecto_email/Traduccion/traducciones.dart';

/// Pantalla de registro de usuarios.
class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

/// Estado de la pantalla de registro de usuarios.
class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  final TextEditingController _confirmarContrasenaController =
      TextEditingController();

  /// Variable para almacenar el tipo de usuario seleccionado.
  String? _tipoUsuario;

  final BaseDeDatos _database = BaseDeDatos();

  /// Método para validar y enviar el formulario.
  void _submit() async {
    final languageProvider = Provider.of<ProviderA>(context, listen: false);
    String currentLanguage = languageProvider.idioma.languageCode;

    if (_formKey.currentState!.validate()) {
      final nombre = _nombreController.text.trim();
      final apellidos = _apellidosController.text.trim();
      final correo = _correoController.text.trim();
      final contrasena = _contrasenaController.text.trim();
      final confirmarContrasena = _confirmarContrasenaController.text.trim();

      if (contrasena != confirmarContrasena) {
        _showErrorDialog(
            Traducciones.translate(currentLanguage, 'Passwords do not match'));
        return;
      }

      if (_tipoUsuario == null) {
        _showErrorDialog(
            Traducciones.translate(currentLanguage, 'Please select user type'));
        return;
      }

      try {
        final result = await _database.insertUser(
          nombre,
          apellidos,
          correo,
          contrasena,
          _tipoUsuario!,
        );
        if (result > 0) {
          _showSuccessDialog(Traducciones.translate(
              currentLanguage, 'User registered successfully'));
        } else {
          _showErrorDialog(Traducciones.translate(
              currentLanguage, 'Error registering user'));
        }
      } catch (e) {
        _showErrorDialog(
            Traducciones.translate(currentLanguage, 'Database error: $e'));
      }
    }
  }

  /// Método para limpiar los campos del formulario.
  void _clearFields() {
    _nombreController.clear();
    _apellidosController.clear();
    _correoController.clear();
    _contrasenaController.clear();
    _confirmarContrasenaController.clear();
  }

  /// Muestra un diálogo de error.
  void _showErrorDialog(String message) {
    final languageProvider = Provider.of<ProviderA>(context, listen: false);
    String currentLanguage = languageProvider.idioma.languageCode;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          Traducciones.translate(currentLanguage, 'Error'),
          style: const TextStyle(color: Colors.red),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              Traducciones.translate(currentLanguage, 'Accept'),
            ),
          ),
        ],
      ),
    );
  }

  /// Muestra un diálogo de éxito.
  void _showSuccessDialog(String message) {
    final languageProvider = Provider.of<ProviderA>(context, listen: false);
    String currentLanguage = languageProvider.idioma.languageCode;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          Traducciones.translate(currentLanguage, 'Success'),
          style: const TextStyle(color: Colors.green),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              Traducciones.translate(currentLanguage, 'Accept'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<ProviderA>(context);
    String currentLanguage = languageProvider.idioma.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          Traducciones.translate(currentLanguage, 'Register'),
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF009688),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            // Clave para el formulario para validar entradas
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TextFormField para ingresar el nombre
                TextFormField(
                  controller: _nombreController,
                  decoration: InputDecoration(
                    labelText: Traducciones.translate(currentLanguage, 'Name'),
                    labelStyle: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium!.color),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF009688)),
                    ),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF757575)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return Traducciones.translate(
                          currentLanguage, 'Please enter your name');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // TextFormField para ingresar los apellidos
                TextFormField(
                  controller: _apellidosController,
                  decoration: InputDecoration(
                    labelText:
                        Traducciones.translate(currentLanguage, 'Last name'),
                    labelStyle: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium!.color),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF009688)),
                    ),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF757575)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return Traducciones.translate(
                          currentLanguage, 'Please enter your last name');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // TextFormField para ingresar el correo
                TextFormField(
                  controller: _correoController,
                  decoration: InputDecoration(
                    labelText: Traducciones.translate(currentLanguage, 'Email'),
                    labelStyle: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium!.color),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF009688)),
                    ),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF757575)),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return Traducciones.translate(
                          currentLanguage, 'Please enter your email');
                    }
                    if (!RegExp(r"^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                        .hasMatch(value)) {
                      return Traducciones.translate(
                          currentLanguage, 'Please enter a valid email');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // TextFormField para ingresar la contraseña
                TextFormField(
                  controller: _contrasenaController,
                  decoration: InputDecoration(
                    labelText:
                        Traducciones.translate(currentLanguage, 'Password'),
                    labelStyle: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium!.color),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF009688)),
                    ),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF757575)),
                    ),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return Traducciones.translate(
                          currentLanguage, 'Please enter a password');
                    }
                    if (value.length < 6) {
                      return Traducciones.translate(currentLanguage,
                          'Password must be at least 6 characters');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // TextFormField para confirmar la contraseña
                TextFormField(
                  controller: _confirmarContrasenaController,
                  decoration: InputDecoration(
                    labelText: Traducciones.translate(
                        currentLanguage, 'Confirm Password'),
                    labelStyle: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium!.color),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF009688)),
                    ),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF757575)),
                    ),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return Traducciones.translate(
                          currentLanguage, 'Please confirm your password');
                    }
                    // Verificar si las contraseñas coinciden
                    if (value != _contrasenaController.text) {
                      return Traducciones.translate(
                          currentLanguage, 'Passwords do not match');
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),
                // Etiqueta para la selección del tipo de usuario
                Text(
                  Traducciones.translate(currentLanguage, 'User Type'),
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium!.color),
                ),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: Text(
                          Traducciones.translate(currentLanguage, 'Student'),
                          style: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .color),
                        ),
                        value: 'alumno',
                        groupValue: _tipoUsuario,
                        onChanged: (value) {
                          setState(() {
                            _tipoUsuario = value;
                          });
                        },
                        activeColor: const Color(0xFF009688),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: Text(
                          Traducciones.translate(currentLanguage, 'Teacher'),
                          style: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .color),
                        ),
                        value: 'profesor',
                        groupValue: _tipoUsuario,
                        onChanged: (value) {
                          setState(() {
                            _tipoUsuario = value;
                          });
                        },
                        activeColor: const Color(0xFF009688),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Botones para enviar el formulario o borrar los campos.
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF009688),
                        foregroundColor: Colors.white,
                      ),
                      child:
                          Text(Traducciones.translate(currentLanguage, 'Next')),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _clearFields,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD32F2F),
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                          Traducciones.translate(currentLanguage, 'Clear')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
