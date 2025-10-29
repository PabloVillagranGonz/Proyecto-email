import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_email/Ajustes/providerA.dart';
import 'package:proyecto_email/BD/basedatos.dart';
import 'package:proyecto_email/Traduccion/traducciones.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Widget que representa la pantalla de recepción de mensajes.
class RecibirMensaje extends StatefulWidget {
  @override
  _RecibirMensajeState createState() => _RecibirMensajeState();
}

/// Estado del widget RecibirMensaje.
class _RecibirMensajeState extends State<RecibirMensaje> {
  final BaseDeDatos _db = BaseDeDatos();
  List<Map<String, dynamic>> _correos = [];
  String _filtroSeleccionado = 'alumno';

  @override
  void initState() {
    super.initState();
    _cargarCorreos();
  }

  /// Obtiene el correo electrónico del usuario actualmente en sesión.
  Future<String?> _obtenerCorreoUsuarioActivo() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email');
  }

  /// Carga los correos electrónicos recibidos por el usuario actualmente en sesión.
  Future<void> _cargarCorreos() async {
    try {
      final userEmail = await _obtenerCorreoUsuarioActivo();
      if (userEmail == null) {
        throw Exception('Usuario no autenticado.');
      }

      final correos =
          await _db.getCorreosPorTipo(userEmail, _filtroSeleccionado);

      debugPrint("Correos obtenidos: $correos");

      // Convertir la lista en mutable
      setState(() {
        _correos = List.from(correos);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar correos: $e')),
      );
    }
  }

  /// Marca un correo como leído.
  Future<void> _marcarComoLeido(BuildContext context, int correoId) async {
    try {
      final userEmail = await _obtenerCorreoUsuarioActivo();
      if (userEmail == null) throw Exception('Usuario no autenticado.');

      final usuario = await _db.getUserByEmail(userEmail);
      if (usuario == null) throw Exception('Usuario no encontrado.');

      final usuarioId = usuario['id'] as int?;
      if (usuarioId == null || usuarioId <= 0) {
        throw Exception('ID de usuario no válido.');
      }

      await _db.marcarCorreoComoLeido(correoId, usuarioId);

      // Actualizar el estado localmente
      setState(() {
        final correoIndex =
            _correos.indexWhere((correo) => correo['id'] == correoId);
        if (correoIndex != -1) {
          // Crear una copia mutable del correo y actualizar el campo 'leido'
          final correoActualizado =
              Map<String, dynamic>.from(_correos[correoIndex]);
          correoActualizado['leido'] = 1;

          // Actualizar la lista _correos
          _correos[correoIndex] = correoActualizado;
        }
      });

      debugPrint("Correo marcado como leído: $correoId");
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al marcar como leído: $e')),
      );
    }
  }

  /// Elimina un correo.
  Future<void> _eliminarCorreo(int correoId) async {
    try {
      final userEmail = await _obtenerCorreoUsuarioActivo();
      if (userEmail == null) {
        throw Exception('Usuario no autenticado. Inicia sesión nuevamente.');
      }

      final usuario = await _db.getUserByEmail(userEmail);
      if (usuario == null) {
        throw Exception('No se encontró un usuario con el email: $userEmail');
      }

      final usuarioId = usuario['id'];
      if (usuarioId != null) {
        await _db.eliminarCorreoParaUsuario(correoId, usuarioId);

        setState(() {
          _correos.removeWhere((correo) => correo['id'] == correoId);
        });
      } else {
        throw Exception('ID de usuario no válido.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el correo: $e')),
      );
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
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF009688),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Filtro para seleccionar el tipo de correos.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Traducciones.translate(currentLanguage, 'Filter:'),
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium!.color),
                ),
                DropdownButton<String>(
                  value: _filtroSeleccionado,
                  items: [
                    DropdownMenuItem(
                      value: 'profesor',
                      child: Semantics(
                        label: 'Filter teacher',
                        hint: 'Selecciona para filtrar correos de profesores',
                        child: Text(
                          Traducciones.translate(currentLanguage, 'Teacher'),
                          style: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .color),
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'alumno',
                      child: Semantics(
                        label: 'Filter student',
                        hint: 'Selecciona para filtrar correos de alumnos',
                        child: Text(
                          Traducciones.translate(currentLanguage, 'Student'),
                          style: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .color),
                        ),
                      ),
                    ),
                  ],
                  onChanged: (String? nuevoFiltro) async {
                    if (nuevoFiltro != null) {
                      setState(() {
                        _filtroSeleccionado = nuevoFiltro;
                      });
                      await _cargarCorreos();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            // Lista de correos recibidos.
            Expanded(
              child: RefreshIndicator(
                onRefresh: _cargarCorreos,
                child: _correos.isEmpty
                    ? Center(
                        child: Text(
                          Traducciones.translate(
                              currentLanguage, 'You have no received emails.'),
                          style: TextStyle(
                              color: Color(0xFF212121)),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _correos.length,
                        itemBuilder: (context, index) {
                          final correo = _correos[index];
                          return mensajeCard(
                            correo['id'],
                            correo['usuario_id'],
                            correo['nombre'],
                            correo['asunto'],
                            correo['cuerpo'],
                            correo['leido'] == 1,
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget que representa una tarjeta de mensaje.
  Widget mensajeCard(int? correoId, int? usuarioId, String? remitente,
      String? asunto, String? cuerpo, bool leido) {
    final languageProvider = Provider.of<ProviderA>(context);
    String currentLanguage = languageProvider.idioma.languageCode;

    return Card(
      elevation: 2.0,
      color: leido ? const Color(0xFFF5F5F5) : Colors.red[100],
      child: ListTile(
        // Titulo de la tarjeta que muestra el remitente del correo.
        title: Text(
          '${Traducciones.translate(currentLanguage, "From:")} ${remitente ?? Traducciones.translate(currentLanguage, "No sender")}',
          style: const TextStyle(color: Color(0xFF212121)),
        ),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${Traducciones.translate(currentLanguage, "Subject:")} ${asunto ?? Traducciones.translate(currentLanguage, "No subject")}',
              style: const TextStyle(color: Color(0xFF757575)),
            ),
            Text(
              '${Traducciones.translate(currentLanguage, "Body:")} ${cuerpo ?? Traducciones.translate(currentLanguage, "No body")}',
              style: const TextStyle(color: Color(0xFF757575)),
            ),
          ],
        ),
        // Accion al tocar la tarjeta.
        onTap: correoId != null
            ? () async {
                await _marcarComoLeido(context, correoId);
              }
            : null,
        // Iconos adicionales para marcar como leído y eliminar el correo.
        trailing: correoId != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      leido ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: leido
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFF757575),
                    ),
                    onPressed: () async {
                      await _marcarComoLeido(context, correoId);
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Color(0xFFD32F2F),
                    ),
                    onPressed: () async {
                      final confirmar = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Semantics(
                            label: 'Eliminar correo',
                            hint:
                                'Diálogo de confirmación para eliminar un correo',
                            child: Text(
                              Traducciones.translate(
                                  currentLanguage, 'Delete email'),
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color),
                            ),
                          ),
                          content: Semantics(
                            label: 'Mensaje de confirmación',
                            hint:
                                'Pregunta si estás seguro de eliminar el correo',
                            child: Text(
                              Traducciones.translate(
                                  currentLanguage, '¿Confirm delete email?'),
                              style: TextStyle(
                                  color: Color.fromARGB(
                                      255, 157, 157, 157)),
                            ),
                          ),
                          actions: [
                            Semantics(
                              label: 'Cancelar eliminación',
                              hint:
                                  'Pulsa para cerrar el diálogo sin eliminar el correo',
                              button: true,
                              child: TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(
                                  Traducciones.translate(
                                      currentLanguage, 'Cancel'),
                                  style:
                                      const TextStyle(color: Color(0xFF009688)),
                                ),
                              ),
                            ),
                            Semantics(
                              label: 'Confirmar eliminación',
                              hint: 'Pulsa para eliminar el correo',
                              button: true,
                              child: TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text(
                                  Traducciones.translate(
                                      currentLanguage, 'Delete'),
                                  style: TextStyle(
                                      color: Color(0xFFD32F2F)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirmar == true) {
                        _eliminarCorreo(correoId);
                      }
                    },
                  ),
                ],
              )
            : null,
      ),
    );
  }
}
