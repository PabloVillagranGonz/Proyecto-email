import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_email/Ajustes/providerA.dart';
import 'package:proyecto_email/BD/basedatos.dart';
import 'package:proyecto_email/Traduccion/traducciones.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Página para escribir un nuevo correo.
class EscribirCorreoPage extends StatefulWidget {
  const EscribirCorreoPage({Key? key}) : super(key: key);

  @override
  _EscribirCorreoPageState createState() => _EscribirCorreoPageState();
}

/// Estado de la página para escribir un nuevo correo.
class _EscribirCorreoPageState extends State<EscribirCorreoPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _paraController = TextEditingController();
  final TextEditingController _asuntoController = TextEditingController();
  final TextEditingController _mensajeController = TextEditingController();
  final BaseDeDatos _db = BaseDeDatos();

  /// Construye la interfaz de la página para escribir un correo.
  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<ProviderA>(context, listen: false);
    String currentLanguage = languageProvider.idioma.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          Traducciones.translate(currentLanguage, 'Write Email'),
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF009688),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Asignamos la clave al formulario
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Campo para ingresar el correo del destinatario.
              TextFormField(
                controller: _paraController,
                decoration: InputDecoration(
                  labelText:
                      Traducciones.translate(currentLanguage, 'To (Email)'),
                  labelStyle: const TextStyle(color: Color(0xFF757575)),
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF009688)),
                  ),
                ),
                cursorColor: const Color(0xFF009688),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return Traducciones.translate(
                        currentLanguage, 'Please enter recipient email');
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
              const SizedBox(height: 16.0),

              // Campo para ingresar el asunto del correo.
              TextFormField(
                controller: _asuntoController,
                decoration: InputDecoration(
                  labelText: Traducciones.translate(currentLanguage, 'Subject'),
                  labelStyle: const TextStyle(color: Color(0xFF757575)),
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF009688)),
                  ),
                ),
                cursorColor: const Color(0xFF009688),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return Traducciones.translate(
                        currentLanguage, 'Please enter a subject');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Campo expandido para ingresar el cuerpo del mensaje.
              Expanded(
                child: TextFormField(
                  controller: _mensajeController,
                  decoration: InputDecoration(
                    labelText:
                        Traducciones.translate(currentLanguage, 'Message'),
                    labelStyle: const TextStyle(color: Color(0xFF757575)),
                    border: const OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFF009688)),
                    ),
                  ),
                  cursorColor: const Color(0xFF009688),
                  maxLines: null,
                  expands: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return Traducciones.translate(
                          currentLanguage, 'Please enter a message');
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16.0),

              // Botón para enviar el correo.
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) {
                      return; // Si hay errores, no continúa con el envío.
                    }

                    try {
                      final prefs = await SharedPreferences.getInstance();
                      final emisorEmail = prefs.getString('user_email');

                      if (emisorEmail == null) {
                        throw Exception('You are not logged in.');
                      }

                      final emisor = await _db.getUserByEmail(emisorEmail);
                      if (emisor == null) {
                        throw Exception(
                            'The sender does not exist in the database');
                      }

                      final destinatario =
                          await _db.getUserByEmail(_paraController.text);
                      if (destinatario == null) {
                        throw Exception('The recipient does not exist');
                      }

                      await _db.insertCorreo(
                        emisor['id'],
                        _asuntoController.text,
                        _mensajeController.text,
                        emisor['tipo'],
                        destinatario['id'],
                      );

                      // Mostrar el diálogo de éxito y, al cerrarlo, regresar a la pantalla anterior con true.
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(Traducciones.translate(
                              currentLanguage, 'Success')),
                          content: Text(Traducciones.translate(
                              currentLanguage, 'Email sent successfully')),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Cierra el diálogo
                                Navigator.pop(context,
                                    true); // Cierra la página, retornando true
                              },
                              child: Text(Traducciones.translate(
                                  currentLanguage, 'Accept')),
                            ),
                          ],
                        ),
                      );

                      _formKey.currentState!
                          .reset(); // Limpiar campos tras enviar
                    } catch (e) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(
                              Traducciones.translate(currentLanguage, 'Error')),
                          content: Text(Traducciones.translate(
                              currentLanguage, 'Error sending email: $e')),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(Traducciones.translate(
                                  currentLanguage, 'Accept')),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF009688),
                  ),
                  child: Text(
                    Traducciones.translate(currentLanguage, 'Send'),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
