import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_email/Ajustes/providerA.dart';
import 'package:proyecto_email/BD/basedatos.dart';
import 'package:proyecto_email/Traduccion/traducciones.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Elimina el usuario actualmente en sesión.
void eliminarUsuario(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  final userEmail = prefs.getString('user_email');
  final languageProvider = Provider.of<ProviderA>(context, listen: false);
  String currentLanguage = languageProvider.idioma.languageCode;

  if (userEmail != null) {
    // Mostrar confirmación de eliminación
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          Traducciones.translate(currentLanguage, 'Delete Account'),
          style:
              TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color),
        ),
        content: Text(
          Traducciones.translate(currentLanguage,
              'Are you sure you want to delete your account? This action cannot be undone.'),
          style: TextStyle(color: Color(0xFF757575)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              Traducciones.translate(currentLanguage, 'Cancel'),
              style: const TextStyle(color: Color(0xFF009688)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              Traducciones.translate(currentLanguage, 'Delete'),
              style: TextStyle(color: Color(0xFFD32F2F)),
            ),
          ),
        ],
      ),
    );
    if (confirmar == true) {
      await BaseDeDatos().deleteUserByEmail(userEmail);
      await prefs.remove('user_email');

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(Traducciones.translate(
            currentLanguage, 'User deleted successfully.')),
      ));

      Navigator.pushReplacementNamed(context, '/login');
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(Traducciones.translate(
            currentLanguage, 'User not found in session.')),
      ),
    );
  }
}

/// Cierra la sesión del usuario actualmente en sesión.
void cerrarSesion(BuildContext context) async {
  final languageProvider = Provider.of<ProviderA>(context, listen: false);
  String currentLanguage = languageProvider.idioma.languageCode;

  final confirmar = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        Traducciones.translate(currentLanguage, 'Log out'),
        style: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color),
      ),
      content: Text(
        Traducciones.translate(
            currentLanguage, '¿Are you sure you want to log out?'),
        style: TextStyle(color: Color(0xFF757575)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            Traducciones.translate(currentLanguage, 'Cancel'),
            style: const TextStyle(color: Color(0xFF009688)),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            Traducciones.translate(currentLanguage, 'Log out'),
            style: TextStyle(color: Color(0xFFD32F2F)),
          ),
        ),
      ],
    ),
  );

  if (confirmar == true) {
    Navigator.pushReplacementNamed(context, '/login');
  }
}

/// Muestra un cuadro de diálogo para cambiar la contraseña.
void mostrarDialogoCambioContrasena(BuildContext context) {
  TextEditingController actualController = TextEditingController();
  TextEditingController nuevaController = TextEditingController();
  TextEditingController confirmarController = TextEditingController();
  String? errorMessage;

  final languageProvider = Provider.of<ProviderA>(context, listen: false);
  String currentLanguage = languageProvider.idioma.languageCode;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              Traducciones.translate(currentLanguage, 'Change password'),
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium!.color),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: actualController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: Traducciones.translate(
                          currentLanguage, 'Enter your password'),
                      labelStyle: const TextStyle(color: Color(0xFF757575)),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF009688)),
                      ),
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF757575)),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: nuevaController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: Traducciones.translate(
                          currentLanguage, 'New password'),
                      labelStyle: const TextStyle(color: Color(0xFF757575)),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF009688)),
                      ),
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF757575)),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: confirmarController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: Traducciones.translate(
                          currentLanguage, 'Confirm new password'),
                      labelStyle: const TextStyle(color: Color(0xFF757575)),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF009688)),
                      ),
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF757575)),
                      ),
                      errorText: errorMessage,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  Traducciones.translate(currentLanguage, 'Cancel'),
                  style: const TextStyle(color: Color(0xFF009688)),
                ),
              ),
              TextButton(
                onPressed: () async {
                  String actualContrasena = actualController.text.trim();
                  String nuevaContrasena = nuevaController.text.trim();
                  String confirmarContrasena = confirmarController.text.trim();

                  if (actualContrasena.isEmpty || nuevaContrasena.isEmpty || confirmarContrasena.isEmpty) {
                    setState(() => errorMessage = Traducciones.translate(
                        currentLanguage, 'Fields cannot be empty'));
                    return;
                  }

                  if (nuevaContrasena.length < 6) {
                    setState(() => errorMessage = Traducciones.translate(
                        currentLanguage, 'It must be at least 6 characters long'));
                    return;
                  }

                  if (nuevaContrasena != confirmarContrasena) {
                    setState(() => errorMessage = Traducciones.translate(
                        currentLanguage, 'Passwords do not match'));
                    return;
                  }

                  final prefs = await SharedPreferences.getInstance();
                  final userEmail = prefs.getString('user_email');
                  if (userEmail != null) {
                    bool isCorrectPassword = await BaseDeDatos().verifyPassword(userEmail, actualContrasena);
                    if (isCorrectPassword) {
                      await BaseDeDatos().updatePassword(userEmail, nuevaContrasena);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(Traducciones.translate(
                              currentLanguage, 'Password changed successfully.')),
                        ),
                      );
                    } else {
                      setState(() => errorMessage = Traducciones.translate(
                          currentLanguage, 'Incorrect current password'));
                      return;
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Error: No se encontró el usuario en sesión.')),
                    );
                  }

                  Navigator.pop(context);
                },
                child: Text(
                  Traducciones.translate(currentLanguage, 'Save'),
                  style: TextStyle(color: Color.fromARGB(255, 251, 255, 0)),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
