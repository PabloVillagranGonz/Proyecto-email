import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_email/Ajustes/providerA.dart';
import 'package:proyecto_email/BD/basedatos.dart';
import 'package:proyecto_email/Screen/escribirCorreo.dart';
import 'package:proyecto_email/Traduccion/traducciones.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: EnviarMensaje(),
    );
  }
}

/// Widget que representa la pantalla de enviar mensajes.
class EnviarMensaje extends StatefulWidget {
  @override
  _EnviarMensajeState createState() => _EnviarMensajeState();
}

/// Estado del widget EnviarMensaje.
class _EnviarMensajeState extends State<EnviarMensaje> {
  final BaseDeDatos _db = BaseDeDatos();
  List<Map<String, dynamic>> _correos = [];

  @override
  void initState() {
    super.initState();
    _cargarCorreos();
  }

  /// Función que obtiene el correo electrónico del usuario actualmente en sesión.
  Future<String?> _obtenerCorreoUsuarioActivo() async {
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString('user_email');
    print(
        'Correo del usuario activo en _obtenerCorreoUsuarioActivo: $userEmail');
    return userEmail;
  }

  /// Carga los correos electrónicos enviados por el usuario actualmente en sesión.
  Future<void> _cargarCorreos() async {
    try {
      final userEmail = await _obtenerCorreoUsuarioActivo();
      if (userEmail == null) {
        throw Exception('No hay un usuario activo. Inicia sesión nuevamente.');
      }

      final correos = await _db.getCorreosEnviadosPorUsuario(userEmail);
      print('Correos cargados: $correos');
      setState(() {
        _correos = correos;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar correos: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<ProviderA>(context, listen: false);
    String currentLanguage = languageProvider.idioma.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          Traducciones.translate(currentLanguage, 'My Sent Emails'),
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF009688),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16.0),
            _correos.isEmpty
                ? Center(
                    child: Text(Traducciones.translate(
                        currentLanguage, 'No sent emails')),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _correos.length,
                    itemBuilder: (context, index) {
                      final correo = _correos[index];
                      return mensajeCard(
                        correo['nombre'],
                        correo['asunto'],
                        correo['cuerpo'],
                      );
                    },
                  ),
          ],
        ),
      ),
      floatingActionButton: Semantics(
        label: 'Redactar correo',
        hint: 'Pulsa para escribir un nuevo correo',
        button: true,
        child: FloatingActionButton(
          onPressed: () async {
            final correoEnviado = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EscribirCorreoPage()),
            );
            if (correoEnviado == true) {
              _cargarCorreos();
            }
          },
          backgroundColor: const Color(0xFF4CAF50),
          child: const Icon(Icons.edit, color: Colors.white),
        ),
      ),
    );
  }

  /// Tarjeta que muestra un correo enviado.
  Widget mensajeCard(String remitente, String asunto, String cuerpo) {
    final languageProvider = Provider.of<ProviderA>(context, listen: false);
    String currentLanguage = languageProvider.idioma.languageCode;

    return GestureDetector(
      onTap: () {
        _mostrarDialogoCorreo(remitente, asunto, cuerpo);
      },
      child: Card(
        elevation: 2.0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${Traducciones.translate(currentLanguage, 'From')}: $remitente',
                style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium!.color),
              ),
              Text(
                '${Traducciones.translate(currentLanguage, 'Subject')}: $asunto',
                style:
                    const TextStyle(color: Color.fromARGB(255, 141, 140, 140)),
              ),
              Text(
                '${Traducciones.translate(currentLanguage, 'Body')}: $cuerpo',
                style:
                    const TextStyle(color: Color.fromARGB(255, 141, 140, 140)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Muestra un cuadro de diálogo con la previsualización del correo.
  void _mostrarDialogoCorreo(String remitente, String asunto, String cuerpo) {
    final languageProvider = Provider.of<ProviderA>(context, listen: false);
    String currentLanguage = languageProvider.idioma.languageCode;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            Traducciones.translate(currentLanguage, 'Preview Email'),
            style:
                TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${Traducciones.translate(currentLanguage, 'From')}: $remitente',
                style: const TextStyle(
                  color: Color(0xFF757575),
                ),
              ),
              Text(
                '${Traducciones.translate(currentLanguage, 'Subject')}: $asunto',
                style: const TextStyle(
                  color: Color(0xFF757575),
                ),
              ),
              Text(
                '${Traducciones.translate(currentLanguage, 'Body')}: $cuerpo',
                style: const TextStyle(
                  color: Color(0xFF757575),
                ),
              ),
            ],
          ),
          actions: [
            Semantics(
              label: Traducciones.translate(currentLanguage, 'Dialog Box'),
              hint: Traducciones.translate(currentLanguage, 'Show dialog box?'),
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  Traducciones.translate(currentLanguage, 'Close'),
                  style: const TextStyle(color: Color(0xFF009688)),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
