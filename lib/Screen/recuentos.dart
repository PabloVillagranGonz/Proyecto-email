import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_email/Ajustes/providerA.dart';
import 'package:proyecto_email/Traduccion/traducciones.dart';
import 'package:sqflite/sqflite.dart';
import '../BD/basedatos.dart';

/// Widget que muestra el recuento de correos enviados y recibidos por un usuario.
class Recuentos extends StatefulWidget {
  final String email;

  /// Constructor del widget Recuentos.
  Recuentos({required this.email});

  @override
  _RecuentosState createState() => _RecuentosState();
}

/// Estado del widget Recuentos.
class _RecuentosState extends State<Recuentos> {
  /// Nombre del usuario.
  String nombre = 'Cargando...';

  /// Total de correos enviados por el usuario.
  int totalCorreosEnviados = 0;

  /// Total de correos recibidos por el usuario.
  int totalCorreosRecibidos = 0;

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuarioYCorreos(widget.email);
  }

  /// Obtiene el nombre del usuario a partir de su correo electrónico.
  Future<String> obtenerNombreUsuario(String email) async {
    final db = await BaseDeDatos().database;
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      columns: ['nombre'],
      where: 'email = ?',
      whereArgs: [email],
    );

    if (result.isEmpty) {
      print('No se encontró ningún usuario con el email $email');
      return 'Nombre no disponible';
    }

    return result.first['nombre'] ?? 'Nombre no disponible';
  }

  /// Obtiene el número de correos enviados y recibidos por el usuario.
  Future<Map<String, int>> obtenerCorreosEnviadosYRecibidos(
      String email) async {
    final db = await BaseDeDatos().database;

    final userIdQuery = await db.query(
      'users',
      columns: ['id'],
      where: 'email = ?',
      whereArgs: [email],
    );

    if (userIdQuery.isEmpty) {
      throw Exception('Usuario no encontrado con el correo: $email');
    }

    final userId = userIdQuery.first['id'];

    final enviados = Sqflite.firstIntValue(
          await db.rawQuery('''
        SELECT COUNT(*) 
        FROM correos 
        WHERE user_id = ?
      ''', [userId]),
        ) ??
        0;

    final recibidos = Sqflite.firstIntValue(
          await db.rawQuery('''
        SELECT COUNT(*) 
        FROM correos 
        WHERE destinatario_id = ?
      ''', [userId]),
        ) ??
        0;

    return {
      'enviados': enviados,
      'recibidos': recibidos,
    };
  }

  /// Carga los datos del usuario y el recuento de correos enviados y recibidos.
  void _cargarDatosUsuarioYCorreos(String email) async {
    final db = BaseDeDatos();
    final user = await db.getUserByEmail(email);

    if (user != null) {
      final correos = await db.obtenerCorreosEnviadosYRecibidos(email);
      setState(() {
        nombre = '${user['nombre']}';
        totalCorreosEnviados = correos['enviados']!;
        totalCorreosRecibidos = correos['recibidos']!;
      });
    } else {
      setState(() {
        nombre = 'Usuario no encontrado';
        totalCorreosEnviados = 0;
        totalCorreosRecibidos = 0;
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
          Traducciones.translate(currentLanguage, 'Email count'),
          style:
              TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color),
        ),
        backgroundColor: const Color(0xFF009688),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(
                Icons.email,
                size: 100,
                color: Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              Traducciones.translate(currentLanguage, 'Name:'),
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium!.color),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.symmetric(vertical: 8),
              color: Colors.grey[300],
              child: Text(
                nombre,
                style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF757575)),
              ),
            ),
            Text(
              Traducciones.translate(currentLanguage, 'Total sent emails:'),
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium!.color),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.symmetric(vertical: 8),
              color: Colors.grey[300],
              child: Text(
                '$totalCorreosEnviados ${Traducciones.translate(currentLanguage, 'Sent emails')}',
                style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF757575)),
              ),
            ),
            Text(
              Traducciones.translate(currentLanguage, 'Total received emails:'),
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium!.color),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.symmetric(vertical: 8),
              color: Colors.grey[300],
              child: Text(
                '$totalCorreosRecibidos ${Traducciones.translate(currentLanguage, 'Received emails')}',
                style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF757575)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
